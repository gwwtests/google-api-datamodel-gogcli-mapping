# Agent Instructions for gogcli API Data Model Repository

## Purpose

This repository is a **knowledge base** for understanding the data model, semantics, and syntax of Google APIs as used by the [gogcli](https://github.com/steipete/gogcli) command-line tool.

## Core Principles

### 1. Zero-Memory Recovery

If work is resumed with zero memory (new session, different agent):

1. Read `CURRENT_WORK.md` to understand what was being worked on
2. Read `FUTURE_WORK.md` to understand the roadmap
3. Check `research/RESEARCH_REQUESTS.md` for pending research tasks
4. Continue from where previous work left off

### 2. Research Workflow

```
┌─────────────────────────────────────────────────────────────────────┐
│  1. STUDY gogcli source code                                        │
│     → Identify what API calls are made                              │
│     → Note data structures used                                     │
│     → Record questions about semantics                              │
│     → Update research/RESEARCH_REQUESTS.md                          │
├─────────────────────────────────────────────────────────────────────┤
│  2. FIND official sources                                           │
│     → Use web-research-knowledge-searcher agent                     │
│     → Identify official Google documentation URLs                   │
│     → Find API reference pages, guides, best practices              │
├─────────────────────────────────────────────────────────────────────┤
│  3. ARCHIVE artifacts                                               │
│     → Use web-research-archiver agent                               │
│     → Download to docs/web/{service}/{topic}/                       │
│     → Create .yaml metadata files with:                             │
│       - source_url                                                  │
│       - download_timestamp                                          │
│       - covered_api_calls (for searchability via yq)                │
│       - key_concepts                                                │
│       - related_docs                                                │
├─────────────────────────────────────────────────────────────────────┤
│  4. DOCUMENT data model                                             │
│     → Create/update docs/datamodel/{service}/                       │
│     → Include examples (especially non-obvious cases)               │
│     → Document identifier uniqueness guarantees                     │
│     → Note timezone/datetime handling                               │
│     → Cross-reference official sources                              │
├─────────────────────────────────────────────────────────────────────┤
│  5. UPDATE tracking                                                 │
│     → Mark research requests as completed                           │
│     → Update CURRENT_WORK.md progress                               │
│     → Add new findings to appropriate docs                          │
└─────────────────────────────────────────────────────────────────────┘
```

### 3. Documentation Standards

#### For Data Model Documentation

Focus on questions a **meticulous computer scientist/programmer** would ask:

* **Identifier Guarantees**: Are IDs unique across accounts? Within account only? Globally?
* **Data Relationships**: Messages vs Threads in Gmail, Events vs Calendars
* **Timezone Handling**: How are times represented? What timezone assumptions?
* **Multi-Account**: What happens when combining data from multiple accounts?
* **UI vs API Mapping**: How does what user sees map to API representation?
* **Edge Cases**: Empty states, deleted items, permissions, quotas

#### YAML Metadata Files

Every archived document must have a corresponding `.yaml` file:

```yaml
# docs/web/gmail/threads/threads-overview.yaml
source_url: "https://developers.google.com/gmail/api/guides/threads"
download_timestamp: "2025-01-29T12:00:00Z"
document_title: "Gmail API - Threads"
covered_api_calls:
  - "users.threads.list"
  - "users.threads.get"
  - "users.threads.modify"
  - "users.threads.trash"
  - "users.threads.untrash"
  - "users.threads.delete"
key_concepts:
  - "thread grouping"
  - "message threading"
  - "thread labels"
related_docs:
  - "../messages/messages-overview.md"
notes: |
  Important: Thread IDs are unique within a user's mailbox but NOT globally unique.
```

### 4. Directory Structure

```
gogcli-api-datamodel/
├── CLAUDE.md                    # Points to @AGENTS.md
├── AGENTS.md                    # This file - agent instructions
├── REPO_OBJECTIVES.md           # Why this repo exists
├── CURRENT_WORK.md              # Current focus (for session recovery)
├── FUTURE_WORK.md               # Roadmap of services to study
├── research/
│   ├── RESEARCH_REQUESTS.md     # Pending research questions
│   └── gogcli-analysis/         # Notes from studying gogcli source
│       ├── gmail-api-usage.md
│       ├── calendar-api-usage.md
│       └── ...
├── docs/
│   ├── web/                     # Archived web resources
│   │   ├── gmail/
│   │   │   ├── overview/
│   │   │   │   ├── overview.md
│   │   │   │   └── overview.yaml
│   │   │   ├── messages/
│   │   │   ├── threads/
│   │   │   └── ...
│   │   ├── calendar/
│   │   └── ...
│   └── datamodel/               # Our synthesized documentation
│       ├── gmail/
│       │   ├── identifiers.md   # ID uniqueness, formats
│       │   ├── threads-vs-messages.md
│       │   ├── labels.md
│       │   └── ...
│       ├── calendar/
│       └── ...
└── examples/                    # Example API responses
    ├── gmail/
    └── calendar/
```

### 5. Searching Archived Knowledge

Use `yq` to search YAML metadata files:

```bash
# Find docs covering a specific API call
yq '.covered_api_calls[]' docs/web/**/*.yaml | grep "threads.get"

# Find docs about a concept
yq 'select(.key_concepts[] | contains("timezone"))' docs/web/**/*.yaml

# List all archived sources
yq '.source_url' docs/web/**/*.yaml
```

### 6. Key Questions to Answer Per Service

For each Google service (Gmail, Calendar, etc.), we need to answer:

1. **Identifiers**
   - What IDs exist? (message ID, thread ID, label ID, etc.)
   - What format? (numeric, base64, opaque string?)
   - Unique within account or globally?
   - Stable over time or can change?

2. **Hierarchies & Relationships**
   - What contains what? (Thread contains Messages)
   - What references what? (Message has labelIds)
   - One-to-many, many-to-many?

3. **Time & Timezone**
   - What timestamp fields exist?
   - What format? (RFC3339, Unix epoch, other?)
   - What timezone? (UTC, user's timezone, event timezone?)
   - How does DST affect things?

4. **Multi-Account Considerations**
   - If I query same thread from two accounts (shared), same ID?
   - If I export data from multiple accounts, how to avoid collisions?
   - What identifies the "owner" of a resource?

5. **API Behavior**
   - Pagination: tokens, limits, ordering
   - Partial responses: fields parameter
   - Batch operations: limits, error handling
   - Rate limits: quotas, backoff

6. **UI vs API Mapping**
   - How does Gmail web UI map to API concepts?
   - What you see vs what's stored?
   - Labels in UI vs system labels in API?

## Reference: gogcli Services

The gogcli tool uses these 14 Google APIs (study in order per FUTURE_WORK.md):

1. **Gmail API** (v1) - Primary focus first
2. **Calendar API** (v3)
3. **Drive API** (v3)
4. **Contacts/People API** (v1)
5. **Tasks API** (v1)
6. **Chat API** (v1)
7. **Classroom API** (v1)
8. **Sheets API** (v4)
9. **Docs API** (v1)
10. **Slides API** (via Drive export)
11. **Cloud Identity API** (v1) - Groups
12. **Keep API** (v1)

## See Also

* `REPO_OBJECTIVES.md` - Why this repository exists
* `CURRENT_WORK.md` - What we're working on now
* `FUTURE_WORK.md` - Roadmap of what's next
* `research/RESEARCH_REQUESTS.md` - Pending research questions
