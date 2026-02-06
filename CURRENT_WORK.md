# Current Work

**Last Updated**: 2026-02-06

## Current Focus: Google Drive API Data Model

Gmail research is ~95% complete. Calendar, Docs, Sheets, and Drive are 100% complete.

### Google Drive Status

```
[■■■■■■■■■■] 100% - Google Drive API Research (Documentation Phase)
```

**Completed**:

- [x] Research Google Drive UI/UX features (10 sections, 100+ features)
- [x] Research Drive API v3 capabilities (7 resources, all methods)
- [x] Analyze gogcli Drive commands (21 commands)
- [x] Create feature comparison YAML (120 features, 10 categories)
- [x] Generate comparison tables from YAML

**Key Research Findings**:

- **File IDs Globally Unique**: Unlike Gmail/Calendar, no composite key needed
- **Workspace Files vs Binary**: Different download methods (export vs get?alt=media)
- **Shared Drive Support**: All operations need `supportsAllDrives=true`
- **Comments via Drive API**: Same system for Docs, Sheets, Slides; gogcli has full support
- **Export Limit**: 10 MB for Google Workspace file exports
- **gogcli Capabilities**: 21 commands for files, permissions, comments; no revisions/trash management

### Key Google Drive Files

* `docs/datamodel/drive/INDEX.md` - Documentation index
* `docs/datamodel/drive/google-drive-ui-features-comprehensive.md` - Complete UI research
* `docs/datamodel/drive/google-drive-api-capabilities.md` - API v3 comprehensive reference
* `docs/datamodel/drive/google-drive-feature-comparison.yaml` - Machine-readable feature mapping (120 features)
* `docs/datamodel/drive/google-drive-feature-comparison-tables.md` - Generated comparison tables
* `docs/datamodel/drive/google-drive-gogcli-data-handling.md` - How gogcli handles Drive

---

## Previous Work: Google Sheets API Data Model

### Google Sheets Status

```
[■■■■■■■■■■] 100% - Google Sheets API Research (Documentation Phase)
```

**Key Findings**:

- **Notes vs Comments**: Notes (yellow corner) in CellData.note; Comments via Drive API
- **GOOGLEFINANCE**: Current prices readable via API; historical returns #N/A (since 2016)
- **gogcli Capabilities**: 8 commands for data CRUD, formatting, lifecycle

### Key Google Sheets Files

* `docs/datamodel/sheets/INDEX.md` - Documentation index
* `docs/datamodel/sheets/google-sheets-feature-comparison.yaml` - 156 features mapped
* `docs/datamodel/sheets/google-sheets-feature-comparison-tables.md` - Comparison tables

---

## Previous Work: Google Docs API Data Model

### Google Docs Status

```
[■■■■■■■■■■] 100% - Google Docs API Research (Documentation Phase)
```

**Completed**:

- [x] Research Google Docs UI/UX features (editing modes, comments, formatting, page setup)
- [x] Archive Google Docs API documentation
- [x] Analyze gogcli Docs commands
- [x] Create feature comparison YAML (UI vs API vs gogcli)
- [x] Generate comparison tables from YAML

**Key Research Findings**:

- **UI-Only Features**: Accept/reject suggestions, insert TOC, create drawings, read checkbox state
- **gogcli Architecture**: Uses Drive API for create/copy/export; Docs API only for `Documents.Get()`
- **gogcli Commands**: 5 commands (export, info, create, copy, cat) - read-focused, no editing
- **API Capabilities**: 3 methods (get, create, batchUpdate) with 37+ request types
- **UTF-16 Indexing**: Critical for all operations (emoji = 2 indexes)
- **Comments via Drive API**: Not via Docs API

### Gmail Status

```
[■■■■■■■■■□] 95% - Gmail API Research
```

**Completed**:
- [x] Basic API reference archived
- [x] Deep semantics archived (labels, batch, quotas, delegation, bandwidth)
- [x] Data model findings synthesized
- [x] gogcli source analysis (how it handles Gmail data)
- [x] Identifier semantics documented

**Remaining** (empirical testing needed):
- [ ] Verify ID uniqueness across accounts
- [ ] Document all system label IDs
- [ ] Test thread splitting behavior

**Key Finding**: ID uniqueness scope NOT documented - use composite keys `(userId, messageId)`

### Calendar API Status

```
[■■■■■■■■■■] 100% - Calendar API Research (Documentation Phase)
```

**Completed**:
- [x] API reference archived (Events, Calendars, CalendarList)
- [x] Core concepts archived (Events & Calendars, Sharing)
- [x] Recurring events guide archived
- [x] Create events and event types guides archived
- [x] Identifier semantics documented
- [x] Timezone handling documented
- [x] Archive index created
- [x] gogcli Calendar command analysis

**Optional deeper analysis**:
- [ ] Free/busy API details
- [ ] ACL API reference
- [ ] Settings API reference

### Key Calendar Findings

**CRITICAL**: Event IDs are unique **per calendar**, NOT globally unique
* **Solution**: Use composite key `(calendarId, eventId)` for global uniqueness
* Calendar IDs are email addresses (globally unique)
* Shared calendar events: same IDs for all users (same calendar)

**Timezone Handling**:
* **All-day events**: Use `date` field, timezone has **NO significance**
* **Timed events**: Use `dateTime` (RFC3339) with timezone (inline offset or `timeZone` field)
* **Recurring events**: `timeZone` field **REQUIRED** for proper DST handling

**Calendars vs CalendarList**:
* Calendars = global metadata (title, timezone)
* CalendarList = user-specific properties (color, reminders)
* Same calendar appears differently in each user's CalendarList

### Key Google Docs Files

* `docs/datamodel/docs/INDEX.md` - Documentation index with insight coverage matrix
* `docs/datamodel/docs/google-docs-ui-features-comprehensive.md` - Complete UI research (17 sections)
* `docs/datamodel/docs/google-docs-feature-comparison.yaml` - Machine-readable feature mapping (104 features)
* `docs/datamodel/docs/google-docs-feature-comparison-tables.md` - Generated comparison tables (16 categories)
* `docs/datamodel/docs/google-docs-gogcli-gap-analysis.md` - (UI+API) vs gogcli coverage analysis
* `docs/datamodel/docs/google-docs-anchors-bookmarks.md` - Bookmarks, named ranges, heading links
* `docs/datamodel/docs/google-docs-reading-history-changes.md` - Reading, revisions, webhooks, diffs
* `docs/datamodel/docs/google-docs-supplementary-notes.md` - Additional notes for verification

### Next Steps

1. [x] Archive Calendar API documentation
2. [x] Document Calendar data model (identifiers, timezones)
3. [x] Analyze gogcli Calendar commands
4. [x] Research Google Docs UI/UX and API
5. [x] Create Google Docs feature comparison (YAML + tables)
6. [x] Research Google Sheets API and create feature comparison
7. [x] Research Google Drive API and create feature comparison
8. [ ] Start next service (Slides, Tasks, or Contacts per FUTURE_WORK.md)

### Research Tracking

See: `research/RESEARCH_REQUESTS.md`

**Gmail**: 17 completed, 4 partial, 9 need testing
**Calendar**: 20 completed, 0 partial, 0 need testing
**Google Docs**: 104 features mapped (7 gogcli full, 73 API full, 5 UI-only)
**Google Sheets**: 156 features mapped (32 gogcli full, 98 API full, 18 API none)
**Google Drive**: 120 features mapped (40 gogcli full, 100 API full, 15 UI-only)

### Key Gmail Files

* `docs/gmail-data-model-findings.md` - Main findings
* `docs/datamodel/gmail/identifiers.md` - ID semantics
* `docs/datamodel/gmail/gogcli-data-handling.md` - How gogcli handles data
* `docs/web/gmail/INDEX.md` - Archive inventory
* `docs/web/gmail/semantics/INDEX.md` - Deep semantics inventory

### Key Calendar Files

* `docs/web/calendar/INDEX.md` - Archive inventory with Q&A
* `docs/datamodel/calendar/identifiers.md` - ID semantics (composite key requirement!)
* `docs/datamodel/calendar/timezones.md` - Timezone handling (all-day vs timed, DST)
* `docs/datamodel/calendar/gogcli-data-handling.md` - How gogcli handles Calendar data
* `docs/web/calendar/events/events-reference.md` - Event resource reference
* `docs/web/calendar/events/events-calendars-concepts.md` - Fundamental concepts

## How to Resume Work

1. Read this file (CURRENT_WORK.md)
2. For Gmail: Read `docs/gmail-data-model-findings.md` and `docs/web/gmail/INDEX.md`
3. For Calendar: Read `docs/web/calendar/INDEX.md` and `docs/datamodel/calendar/identifiers.md`
4. For Google Docs: Read `docs/datamodel/docs/google-docs-feature-comparison-tables.md`
5. For Google Sheets: Read `docs/datamodel/sheets/google-sheets-feature-comparison-tables.md`
6. For Google Drive: Read `docs/datamodel/drive/google-drive-feature-comparison-tables.md`
7. Check `research/RESEARCH_REQUESTS.md` for open questions
8. See `MAINTENANCE.md` for repository upkeep procedures and YAML tracking
