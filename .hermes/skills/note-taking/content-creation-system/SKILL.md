---
name: content-creation-system
description: Build a personal content creation system in Obsidian with Kanban boards, day logs, and daily AI check-ins via Telegram. Designed for founders building in public across Instagram, X, and LinkedIn.
---

# Content Creation System — Obsidian + Hermes

System for managing personal/founder brand content across Instagram, X, and LinkedIn.

## File Structure

```
Hermes/content-creation/
├── ideias-backlog.md              ← raw idea backlog per platform/theme
├── content-kanban.md              ← 6-stage draft pipeline
├── calendar-kanban.md             ← monthly schedule (To Do / In Progress / Done)
├── content/
│   └── drafts/                     ← notes created from kanban cards land here
├── day-log/
│   └── YYYY-MM.md                 ← monthly day log with raw observations
└── templates/
    ├── content-draft-template.md  ← template for content-kanban cards
    └── calendar-note-template.md   ← template for calendar-kanban cards
```

## Kanban File Requirements

**Every kanban file MUST have this frontmatter:**
```yaml
---
kanban-plugin: basic
---
```

Without this, Obsidian won't render it as a Kanban board.

## Card Text Format (CRITICAL)

The kanban plugin uses card BODY text (not file frontmatter) for "New note from card". Cards use YAML in the card body:

```markdown
- [ ] **Card Title Here @2026-04-10**
  ```
  ---
  platform: IG
  type: reel
  date: 2026-04-10
  tags: building-in-public, tech
  draft:
  ---
  Resumo do conteúdo ou caption.
  ```
```

- **Card title** = the filename when "New note from card" is triggered
- **Card body** = YAML frontmatter (parses into template vars) + content section
- **@YYYY-MM-DD** = date trigger in card title — shows date picker in Kanban UI
- Template parses the card body YAML to populate frontmatter dynamically

## Content Kanban — 6 Columns

1. **Backlog** — ideas queued for drafting
2. **Dani estáDraftando** — I create drafts here
3. **Need Improvements** — you moved here with comments, I rewrite
4. **Reproved** — you rejected, I delete or repurpose
5. **Approved** — ready to post
6. **Published** — archived

## Calendar Kanban — 3 Columns

Monthly schedule. Columns: **To Do** → **In Progress** → **Done**

Cards carry the date in the title (`@2026-04-10`), platform, and type.

## Templates

Use **Templater** syntax in templates for dynamic frontmatter parsing.

Key Templater functions:
- `<% tp.file.title %>` — card title (becomes filename)
- `<% tp.file.creation_date("YYYY-MM-DD") %>` — creation date
- `<% tp.date.now("YYYY-MM-DD") %>` — current date
- `<%* await tp.file.create_new(...) %>` — create new files programmatically

## Ideias Backlog Format

```markdown
# Ideias Backlog

## Instagram

### Problemas que Enfrentei
-

### Coisas que Aprendi
- [[tag]] Description of the idea

### Opiniões
- [[tag]] Opinion topic

---

## X

### Hot Takes
- [[tag]] Hot take

### Threads Ideas
-

---

## LinkedIn

### Posts
-
```

Tags (`[[tag]]`) allow direct linking from drafts.

## Day Log Format

```markdown
# Day Log — Month Year

## YYYY-MM-DD

**Resumo do dia:**
- What happened today

**Observações para conteúdo:**
- Dani thinks: does this have content potential? Why?

**Ação Dani:**
- [ ] Think if it becomes a draft
```

## Daily Crons

- **7am**: Morning check — scan day log, backlog, kanbans; send Telegram summary
- **8pm**: Evening check-in — ask about his day; reply creates day log entry + drafts

## Design Decisions

- Kanban plugin: `mgmeyers/obsidian-kanban` (Markdown-backed, 2.1M downloads)
- Month grouping for day logs (avoid too many files)
- Day log is Dani's raw notes — not for Vitor, just for me to track patterns
- Backlog ideas get `[[anchor-tags]]` for cross-linking
- Vitor's preferences: direct communication, no fluff, structured reasoning
- Card YAML in body (not file frontmatter) is what "New note from card" reads

## Setup Requirements

**1. Obsidian Plugins:**
- Install `obsidian-kanban` by mgmeyers
- Install `Templater` by SilentVoid13

**2. Kanban Plugin Settings:**
- `Note folder` → `Hermes/content-creation/content/drafts`
- `Note template` → `Hermes/content-creation/templates/content-draft-template.md`
- `Date trigger` → `@` (default)
- `Date format` → `YYYY-MM-DD`

**3. Templater Settings:**
- `Template folder location` → `Hermes/content-creation/templates`
- Enable `Trigger Templater on new file creation`
- Add Folder Template rule: `Hermes/content-creation/content/drafts/` → `content-draft-template.md`

**4. Telegram (for crons):**
```
TELEGRAM_BOT_TOKEN=...
TELEGRAM_CHAT_ID=...
```

**5. Open kanban files as Kanban boards** — click the card icon in the top right of each file in Obsidian.
