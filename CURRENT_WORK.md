# Current Work

**Last Updated**: 2026-01-29

## Current Focus: Calendar API Data Model

Gmail research is ~95% complete. Calendar API core research now ~85% complete.

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
[■■■■■■■■□□] 85% - Calendar API Research
```

**Completed**:
- [x] API reference archived (Events, Calendars, CalendarList)
- [x] Core concepts archived (Events & Calendars, Sharing)
- [x] Recurring events guide archived
- [x] Identifier semantics documented
- [x] Timezone handling documented
- [x] Archive index created

**Remaining** (empirical testing/deeper analysis needed):
- [ ] gogcli Calendar command analysis
- [ ] Free/busy API details
- [ ] Verify event ID uniqueness scope empirically
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

### Next Steps

1. [x] Archive Calendar API documentation
2. [x] Document Calendar data model (identifiers, timezones)
3. [ ] Analyze gogcli Calendar commands
4. [ ] Archive ACL and Settings API references
5. [ ] Empirical testing of event ID uniqueness

### Research Tracking

See: `research/RESEARCH_REQUESTS.md`

**Gmail**: 13 completed, 3 partial, 9 need testing
**Calendar**: 6 completed, 4 need testing/deeper analysis

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
* `docs/web/calendar/events/events-reference.md` - Event resource reference
* `docs/web/calendar/events/events-calendars-concepts.md` - Fundamental concepts

## How to Resume Work

1. Read this file (CURRENT_WORK.md)
2. For Gmail: Read `docs/gmail-data-model-findings.md` and `docs/web/gmail/INDEX.md`
3. For Calendar: Read `docs/web/calendar/INDEX.md` and `docs/datamodel/calendar/identifiers.md`
4. Check `research/RESEARCH_REQUESTS.md` for open questions
