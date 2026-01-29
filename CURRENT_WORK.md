# Current Work

**Last Updated**: 2025-01-29

## Current Focus: Calendar API Data Model

Gmail research is ~95% complete. Moving to Calendar API.

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
[□□□□□□□□□□] 0% - Calendar API Research (Starting)
```

**To Research**:
- [ ] Event data model (times, timezones, attendees)
- [ ] Calendar IDs and uniqueness
- [ ] Recurring events (RRULE handling)
- [ ] Shared calendars and event IDs
- [ ] Timezone handling (critical!)
- [ ] Free/busy queries

### Next Steps

1. Archive Calendar API documentation:
   - Events reference
   - Calendars reference
   - Recurring events guide
   - Timezone handling

2. Analyze gogcli Calendar commands

3. Document Calendar data model

### Research Tracking

See: `research/RESEARCH_REQUESTS.md`

**Gmail**: 13 completed, 3 partial, 9 need testing
**Calendar**: Not started

### Key Gmail Files

* `docs/gmail-data-model-findings.md` - Main findings
* `docs/datamodel/gmail/identifiers.md` - ID semantics
* `docs/datamodel/gmail/gogcli-data-handling.md` - How gogcli handles data
* `docs/web/gmail/INDEX.md` - Archive inventory
* `docs/web/gmail/semantics/INDEX.md` - Deep semantics inventory

## How to Resume Work

1. Read this file (CURRENT_WORK.md)
2. For Gmail: Read `docs/gmail-data-model-findings.md`
3. For Calendar: Start with `docs/web/calendar/` (once archived)
4. Check `research/RESEARCH_REQUESTS.md` for open questions
