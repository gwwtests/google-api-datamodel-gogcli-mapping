# Gmail & Calendar API Data Model Research Summary

**Date**: 2026-01-30
**Purpose**: Document research progress on Google API data models for gogcli tool

## Overview

This repository documents the data model semantics for Google APIs used by the [gogcli](https://github.com/steipete/gogcli) command-line tool, with focus on understanding how UI concepts map to API data structures.

## Research Completed

### Gmail API

**Archived Documentation** (10 YAML metadata files):
- Messages reference (11 API methods)
- Threads reference (5 API methods)
- Labels reference (5 API methods)
- History reference (sync tracking)
- Sync guide (incremental sync patterns)
- Push guide (Pub/Sub notifications)
- Filtering guide (search query syntax)
- API overview

**Synthesized Analysis**:
- `docs/gmail-data-model-findings.md` - Main findings
- `docs/datamodel/gmail/identifiers.md` - ID semantics
- `docs/datamodel/gmail/gogcli-data-handling.md` - How gogcli handles data
- `docs/datamodel/gmail/ux-to-data-mapping.md` - UI→API mapping with gotchas

**Example API Responses**:
- `message-full.json` - Complete message structure
- `thread-with-messages.json` - Thread with multiple messages
- `labels-system-vs-user.json` - System vs user label comparison

### Calendar API

**Archived Documentation** (9 YAML metadata files):
- Events reference (11 API methods)
- Calendars reference (6 API methods)
- CalendarList reference (7 API methods)
- Recurring events guide
- Events & calendars concepts
- Sharing and ACL guide
- Create events guide
- Event types guide

**Synthesized Analysis**:
- `docs/datamodel/calendar/identifiers.md` - ID semantics
- `docs/datamodel/calendar/timezones.md` - Timezone handling
- `docs/datamodel/calendar/gogcli-data-handling.md` - How gogcli handles data
- `docs/datamodel/calendar/ux-to-data-mapping.md` - UI→API mapping with gotchas

**Example API Responses**:
- `event-timed.json` - Timed event with attendees
- `event-allday.json` - All-day event with duration examples
- `event-recurring-parent-and-instance.json` - Recurring complexity
- `same-meeting-different-calendars.json` - Invitation ID differences

## Key Findings

### Critical Identifier Issues

| Service | ID Field | Uniqueness | Recommendation |
|---------|----------|------------|----------------|
| Gmail | messageId | NOT specified | Use `(userId, messageId)` |
| Gmail | threadId | NOT specified | Use `(userId, threadId)` |
| Gmail | labelId | Per-user | Use `(userId, labelId)` |
| Calendar | eventId | Per-calendar | Use `(calendarId, eventId)` |
| Calendar | calendarId | Global | Safe to use directly |
| Calendar | iCalUID | Global | Use for cross-calendar correlation |

### Counterintuitive UI→API Mappings Documented

**Gmail**:
1. Conversations (threads) vs individual messages
2. Labels as folders (but multi-label possible)
3. Draft dual-ID complexity
4. From header spoofing
5. Subject-based thread grouping errors
6. Three different timestamps

**Calendar**:
1. All-day end date exclusive (phantom day)
2. Three timezone representations
3. Recurring = multiple event IDs
4. Meeting invitation = different IDs
5. Shared calendar vs invitation difference
6. Calendar vs CalendarList confusion

## Repository Structure

```
gogcli-api-datamodel/
├── CLAUDE.md → @AGENTS.md
├── AGENTS.md                    # Research methodology
├── REPO_OBJECTIVES.md           # Purpose
├── CURRENT_WORK.md              # Progress tracking
├── FUTURE_WORK.md               # Roadmap
├── research/
│   ├── RESEARCH_REQUESTS.md     # Question tracking
│   └── gogcli-analysis/         # Source code analysis
├── docs/
│   ├── web/                     # Archived official docs
│   │   ├── gmail/               # 10 YAML + MD pairs
│   │   └── calendar/            # 9 YAML + MD pairs
│   └── datamodel/               # Synthesized documentation
│       ├── gmail/
│       │   ├── identifiers.md
│       │   ├── gogcli-data-handling.md
│       │   ├── ux-to-data-mapping.md
│       │   └── examples/        # 3 JSON files
│       └── calendar/
│           ├── identifiers.md
│           ├── timezones.md
│           ├── gogcli-data-handling.md
│           ├── ux-to-data-mapping.md
│           └── examples/        # 4 JSON files
└── ramblings/                   # This file
```

## Statistics

| Metric | Count |
|--------|-------|
| YAML metadata files | 19 |
| Markdown docs | 36 |
| JSON examples | 7 |
| Research questions tracked | 45 |
| Questions answered | 31 |
| Questions need testing | 9 |
| Commits | 17+ |

## Areas for Further Research

### Gmail Features Not Yet Documented

- [ ] Snooze functionality (how snoozed messages are represented)
- [ ] Priority Inbox views (Important vs not important)
- [ ] Category tabs (Primary, Social, Promotions, Updates, Forums)
- [ ] Send As / delegate sending
- [ ] Confidential mode
- [ ] Scheduled send

### Calendar Features Not Yet Documented

- [ ] Out of office auto-responses
- [ ] Focus time blocks
- [ ] Working location
- [ ] Appointment slots
- [ ] Resource calendars

### Cross-Service Considerations

- [ ] How Gmail and Calendar interact (event invitations in email)
- [ ] Drive attachments in Calendar events
- [ ] Contact integration in both services

## Next Steps

1. Research user discussions about API confusions
2. Document additional Gmail features (categories, send-as, snooze)
3. Add more edge case examples
4. Consider empirical testing for ID uniqueness verification
5. Proceed to Drive/Tasks/Contacts APIs per FUTURE_WORK.md

## Notes on Privacy

All examples in this repository use:
- Fictional email addresses (alice@example.com, bob@company.com)
- Synthetic message IDs and thread IDs
- Made-up meeting titles and descriptions
- No real user data or system configurations

This ensures the repository can be safely shared publicly.
