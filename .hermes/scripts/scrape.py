#!/usr/bin/env python3
"""CLI web content extractor -- fast default scraper for Hermes.

Usage:
    python3 scrape.py <URL>              # clean text extract
    python3 scrape.py <URL> --json       # JSON output with metadata
    python3 scrape.py <URL> --links      # extract all outbound links
    python3 scrape.py <URL> --all        # text + links

Or pipe URLs:
    cat urls.txt | python3 scrape.py
    echo "https://example.com" | python3 scrape.py --json
"""

import argparse
import json
import sys
from urllib.parse import urljoin, urlparse

import requests
import trafilatura


HTTP_HEADERS = {
    "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) "
    "AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36",
    "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
    "Accept-Language": "en-US,en;q=0.5",
}

DEFAULT_TIMEOUT = 30


def fetch_html(url: str) -> str:
    """Fetch raw HTML with realistic browser headers."""
    resp = requests.get(url, headers=HTTP_HEADERS, timeout=DEFAULT_TIMEOUT)
    resp.raise_for_status()
    return resp.text


def extract_text(html: str, url: str) -> dict:
    """Use trafilatura to extract clean text + metadata."""
    try:
        result = trafilatura.bare_extraction(
            html,
            url=url,
            include_comments=False,
            include_tables=True,
            output_format="python",
            favor_precision=True,
        )
        if result:
            return dict(result)
    except Exception:
        pass
    # Fallback to simple text extraction
    text = trafilatura.extract(html, include_comments=False, include_tables=True)
    return {"text": text or ""}


def extract_links(html: str, base_url: str) -> list:
    """Extract all meaningful outbound links from page."""
    from lxml import html as html_parser

    try:
        doc = html_parser.fromstring(html)
    except Exception:
        return []

    links = []
    seen = set()
    for anchor in doc.iter("a"):
        href = anchor.get("href")
        if not href or href.startswith("#") or href.startswith("javascript:") or href.startswith("mailto:"):
            continue
        full = urljoin(base_url, href)
        try:
            parsed = urlparse(full)
            if not parsed.netloc:
                continue
        except Exception:
            continue

        text = "".join(anchor.itertext()).strip()
        if full not in seen:
            seen.add(full)
            links.append({"url": full, "text": text[:120]})

    return links


def process_url(url: str, mode: str, as_json: bool) -> str:
    """Process a single URL and return formatted output."""
    try:
        html = fetch_html(url)
    except requests.RequestException as e:
        err = {"error": str(e), "url": url}
        return json.dumps(err) if as_json else f"ERROR {url}: {e}"

    output = {}
    text_block = ""

    if mode in ("text", "all"):
        result = extract_text(html, url)
        full_text = result.get("text", "").strip()
        output["title"] = result.get("title", "")
        output["author"] = result.get("author", "")
        output["date"] = result.get("date", "")
        output["description"] = result.get("description", "")
        output["tags"] = result.get("categories", [])

        if not as_json:
            parts = []
            if output["title"]:
                parts.append(f"# {output['title']}")
            if output["description"]:
                parts.append(output["description"])
            meta = []
            if output["author"]:
                meta.append(f"Author: {output['author']}")
            if output["date"]:
                meta.append(f"Date: {output['date']}")
            if output["tags"]:
                meta.append(f"Tags: {', '.join(output['tags'])}")
            if meta:
                parts.append("\n".join(meta))
            if full_text:
                parts.append(full_text)
            text_block = "\n\n".join(parts)

    if mode in ("links", "all"):
        links = extract_links(html, url)
        output["links"] = links
        if not as_json:
            if links:
                link_block = "\n## Links"
                for link in links:
                    label = link["text"] if link["text"] else link["url"]
                    link_block += f"\n- {label} ({link['url']})"
                text_block += link_block

    if mode == "links" and not as_json:
        if not text_block.strip():
            links = extract_links(html, url)
            text_block = "## Links"
            for link in links:
                label = link["text"] if link["text"] else link["url"]
                text_block += f"\n- {label} ({link['url']})"

    return json.dumps({**output, "url": url}) if as_json else text_block


def main():
    parser = argparse.ArgumentParser(description="Fast web content scraper")
    parser.add_argument("urls", nargs="*", help="URL(s) to scrape")
    parser.add_argument("--json", action="store_true", dest="as_json")
    parser.add_argument("--links", action="store_true")
    parser.add_argument("--all", action="store_true")
    args = parser.parse_args()

    mode = "links" if args.links else "all" if args.all else "text"

    urls = args.urls
    if not urls and not sys.stdin.isatty():
        urls = [line.strip() for line in sys.stdin if line.strip()]

    if not urls:
        print("Usage: python3 scrape.py <URL> [--json] [--links] [--all]", file=sys.stderr)
        sys.exit(1)

    if len(urls) == 1:
        print(process_url(urls[0], mode, args.as_json))
    else:
        if args.as_json:
            results = [json.loads(process_url(u, mode, True)) for u in urls]
            print(json.dumps({"results": results}, indent=2))
        else:
            for url in urls:
                print(f"--- {url} ---")
                print(process_url(url, mode, False))
                print()


if __name__ == "__main__":
    main()
