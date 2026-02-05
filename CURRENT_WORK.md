# Current Work

**Last Updated**: 2026-02-05

## Current Focus: Google Docs API Data Model

Gmail research is ~95% complete. Calendar API core research is ~100% complete. Now researching Google Docs.

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

* `docs/datamodel/docs/google-docs-ui-features-comprehensive.md` - Complete UI research (17 sections)
* `docs/datamodel/docs/google-docs-feature-comparison.yaml` - Machine-readable feature mapping
* `docs/datamodel/docs/google-docs-feature-comparison-tables.md` - Generated comparison tables
* `docs/datamodel/docs/google-docs-supplementary-notes.md` - Additional notes for verification (webhooks, comment anchors)

### Next Steps

1. [x] Archive Calendar API documentation
2. [x] Document Calendar data model (identifiers, timezones)
3. [x] Analyze gogcli Calendar commands
4. [x] Research Google Docs UI/UX and API
5. [x] Create Google Docs feature comparison (YAML + tables)
6. [ ] Optional: Archive ACL and Settings API references
7. [ ] Start next service (Drive, Tasks, or Contacts per FUTURE_WORK.md)

### Research Tracking

See: `research/RESEARCH_REQUESTS.md`

**Gmail**: 12 completed, 4 partial, 9 need testing
**Calendar**: 19 completed, 1 partial, 0 need testing
**Google Docs**: 92 features mapped (7 gogcli full, 73 API full, 5 UI-only)

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
5. Check `research/RESEARCH_REQUESTS.md` for open questions
