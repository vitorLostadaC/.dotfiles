---
name: obsidian
description: Read, search, and create notes in the Obsidian vault.
---

# Obsidian Vault

**Vault path discovery:**
1. Check `~/.hermes/config.env` for `OBSIDIAN_VAULT_PATH`
2. If not set, try `~/Library/Mobile Documents/iCloud~md~obsidian/Documents/` (iCloud Obsidian on macOS)
3. Note: paths may contain spaces — always quote them

**Vitor's vault:** `/Users/vitorlostada/Library/Mobile Documents/iCloud~md~obsidian/Documents/technical documentation/`

## Read a note

```bash
VAULT="${OBSIDIAN_VAULT_PATH:-$HOME/Documents/Obsidian Vault}"
cat "$VAULT/Note Name.md"
```

## List notes

```bash
VAULT="${OBSIDIAN_VAULT_PATH:-$HOME/Documents/Obsidian Vault}"

# All notes
find "$VAULT" -name "*.md" -type f

# In a specific folder
ls "$VAULT/Subfolder/"
```

## Search

```bash
VAULT="${OBSIDIAN_VAULT_PATH:-$HOME/Documents/Obsidian Vault}"

# By filename
find "$VAULT" -name "*.md" -iname "*keyword*"

# By content
grep -rli "keyword" "$VAULT" --include="*.md"
```

## Create a note

```bash
VAULT="${OBSIDIAN_VAULT_PATH:-$HOME/Documents/Obsidian Vault}"
cat > "$VAULT/New Note.md" << 'ENDNOTE'
# Title

Content here.
ENDNOTE
```

## Append to a note

```bash
VAULT="${OBSIDIAN_VAULT_PATH:-$HOME/Documents/Obsidian Vault}"
echo "
New content here." >> "$VAULT/Existing Note.md"
```

## Kanban Plugin Syntax (mgmeyers)

**REQUIRED: YAML frontmatter at top of file**
```markdown
---
kanban-plugin: basic
---
```

**Column format: h2 headers with task list cards**
```markdown
## Column Name

- [ ] Card title
- [ ] `tag` `platform` [[link/to/draft|draft]] — description
```

**Card metadata pattern (for content calendars):**
```markdown
- [ ] `Seg 06` `IG Story` — poll de engajamento [[content/drafts/...|draft]]
- [ ] `2026-04-08` `X` `reel` — hot take [[content/drafts/...|draft]] — tags: `opinion`
```

**Calendar Kanban pattern:** Columns are fixed workflow stages (To Do / In Progress / Done), NOT dates. Date info lives inside each card. This allows cards to move between states regardless of when they're scheduled.

**Common mistakes:**
- Forgetting YAML frontmatter → file renders as plain markdown, not kanban
- Using h3 `###` or custom blocks for columns → they won't render
- Using dates as column headers in calendar kanban → cards can't move freely

**Backlog vs Calendar kanban:**
- Backlog kanban: columns = content stages (Backlog → Dani drafting → Approved → Published)
- Calendar kanban: columns = workflow stages (To Do → In Progress → Done), cards carry date metadata

## Wikilinks

Obsidian links notes with `[[Note Name]]` syntax. When creating notes, use these to link related content.
