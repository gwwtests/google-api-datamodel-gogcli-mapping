# Research Requests

Tracking questions that need official documentation to answer.

## Status Legend

- 🔴 **PENDING** - Not yet researched
- 🟡 **IN_PROGRESS** - Currently being researched
- 🟢 **COMPLETED** - Answered with source citation
- ⚠️ **PARTIAL** - Partially answered, needs more research
- 🔵 **NEEDS_TESTING** - Cannot be answered from docs, requires empirical testing

---

## Gmail API

### Identifiers

| ID | Question | Status | Source |
|----|----------|--------|--------|
| GM-ID-001 | Is `messageId` unique globally or only within a user's mailbox? | 🔵 NEEDS_TESTING | Not specified in docs. See `docs/gmail-data-model-findings.md` |
| GM-ID-002 | Is `threadId` unique globally or only within a user's mailbox? | 🔵 NEEDS_TESTING | Not specified in docs. See `docs/gmail-data-model-findings.md` |
| GM-ID-003 | What is the format of `messageId`? (base64? numeric? opaque?) | ⚠️ PARTIAL | String, opaque format - `docs/web/gmail/messages/messages-reference.md` |
| GM-ID-004 | Can `messageId` change over time for the same message? | 🟢 COMPLETED | No, described as "immutable" - `docs/web/gmail/messages/messages-reference.md` |
| GM-ID-005 | If two users share access to a message (e.g., in shared mailbox), do they see the same `messageId`? | 🔵 NEEDS_TESTING | Not specified in docs |
| GM-ID-006 | What is the relationship between `Message-ID` header and API `messageId`? | 🔵 NEEDS_TESTING | Not specified in docs |
| GM-ID-007 | Are `labelId` values stable? What's their format? | 🟢 COMPLETED | Yes, described as "immutable". Format is opaque string - `docs/web/gmail/labels/labels-reference.md` |

### Threading Model

| ID | Question | Status | Source |
|----|----------|--------|--------|
| GM-TH-001 | How does Gmail determine which messages belong to a thread? | 🟢 COMPLETED | Based on: matching threadId, RFC 2822 References/In-Reply-To headers, Subject matching - `docs/web/gmail/messages/messages-reference.md` |
| GM-TH-002 | Can a message be moved to a different thread? | 🔵 NEEDS_TESTING | Not specified in docs |
| GM-TH-003 | When I get a thread, are messages ordered? By what? | ⚠️ PARTIAL | Implied by internalDate, newest first - `docs/web/gmail/sync/sync-guide.md` |
| GM-TH-004 | If a thread has 100 messages, does threads.get return all of them? | ⚠️ PARTIAL | Implied yes, but not explicit - `docs/web/gmail/threads/threads-reference.md` |
| GM-TH-005 | What happens to threadId when a thread is split (e.g., forwarded separately)? | 🔵 NEEDS_TESTING | Not specified in docs |

### Labels

| ID | Question | Status | Source |
|----|----------|--------|--------|
| GM-LB-001 | What system labels exist? Complete list? | ⚠️ PARTIAL | 13 documented: INBOX, SENT, DRAFT, SPAM, TRASH, UNREAD, STARRED, IMPORTANT, CATEGORY_{PERSONAL,SOCIAL,PROMOTIONS,UPDATES,FORUMS}. Docs note "not exhaustive" - `docs/web/gmail/semantics/labels-guide.md` |
| GM-LB-002 | How do system label IDs differ from user label IDs? | 🔵 NEEDS_TESTING | Not specified, needs empirical comparison |
| GM-LB-003 | Can the same label name exist in multiple accounts? | 🟢 COMPLETED | Yes, label names are per-account. User labels max 10,000 per mailbox - `docs/web/gmail/labels/labels-reference.md` |
| GM-LB-004 | Are label IDs sequential or random? | 🔵 NEEDS_TESTING | Not specified in docs |

### Multi-Account

| ID | Question | Status | Source |
|----|----------|--------|--------|
| GM-MA-001 | If I export messages from two accounts, can messageIds collide? | 🔵 NEEDS_TESTING | Not specified. Recommendation: use composite key (userId, messageId) - `docs/datamodel/gmail/identifiers.md` |
| GM-MA-002 | If I export threads from two accounts, can threadIds collide? | 🔵 NEEDS_TESTING | Not specified. Recommendation: use composite key (userId, threadId) - `docs/datamodel/gmail/identifiers.md` |
| GM-MA-003 | How do I identify which account a message came from in the API response? | 🟢 COMPLETED | API calls are scoped to userId, response doesn't include it - application must track context - `docs/datamodel/gmail/identifiers.md`, `docs/web/gmail/semantics/delegation-guide.md` |

### Timestamps

| ID | Question | Status | Source |
|----|----------|--------|--------|
| GM-TS-001 | What timestamp fields exist on a message? | 🟢 COMPLETED | `internalDate` (epoch ms), plus Date header in payload - `docs/web/gmail/messages/messages-reference.md` |
| GM-TS-002 | Are timestamps in UTC or user's timezone? | 🟢 COMPLETED | UTC (epoch milliseconds are timezone-independent) - `docs/web/gmail/messages/messages-reference.md` |
| GM-TS-003 | What format are timestamps in? (RFC3339? Unix epoch?) | 🟢 COMPLETED | int64 format (epoch milliseconds as string) - `docs/web/gmail/messages/messages-reference.md` |
| GM-TS-004 | Is `internalDate` the same as the `Date` header? | 🟢 COMPLETED | No, internalDate is when Google accepted the message (more reliable) - `docs/web/gmail/messages/messages-reference.md` |

### History & Sync

| ID | Question | Status | Source |
|----|----------|--------|--------|
| GM-HI-001 | What is `historyId`? How is it used for sync? | 🟢 COMPLETED | Monotonically increasing sync marker. Used for incremental sync via history.list - `docs/web/gmail/sync/sync-guide.md` |
| GM-HI-002 | How long are history records kept? | 🟢 COMPLETED | At least 1 week, often longer. Can be less in rare cases. 404 on expired = need full sync - `docs/web/gmail/sync/sync-guide.md` |
| GM-HI-003 | Can historyId go backwards? | 🟢 COMPLETED | No, described as "monotonically increasing" - `docs/web/gmail/history/history-reference.md` |

### Filters

| ID | Question | Status | Source |
|----|----------|--------|--------|
| GM-FI-001 | What does users.settings.filters.list return? | 🟢 COMPLETED | JSON array of Filter resources with id, criteria, action - `docs/web/gmail/filters/filters-api-reference.md` |
| GM-FI-002 | What format is filter data in API? | 🟢 COMPLETED | JSON with criteria object (matching conditions) and action object (operations) - `docs/web/gmail/filters/filters-api-reference.md` |
| GM-FI-003 | Is API format same as WebUI export? | 🟢 COMPLETED | No, API uses JSON, WebUI uses Atom XML. Not directly compatible - `docs/web/gmail/filters/filters-api-vs-xml.md` |
| GM-FI-004 | Can API filter data be converted to WebUI format? | 🟢 COMPLETED | Yes, but requires label ID→name resolution and action semantic mapping - `docs/web/gmail/filters/filters-api-vs-xml.md` |
| GM-FI-005 | What are key differences between formats? | 🟢 COMPLETED | Label IDs vs names, action flags vs label manipulation, query vs hasTheWord - `docs/web/gmail/filters/filters-api-vs-xml.md` |

---

## Summary Statistics

### Gmail API Research Status

| Status | Count |
|--------|-------|
| 🟢 COMPLETED | 17 |
| ⚠️ PARTIAL | 4 |
| 🔵 NEEDS_TESTING | 9 |
| 🔴 PENDING | 0 |

**Key Findings**:

* Official Google documentation does NOT specify identifier uniqueness scope (global vs per-user). This is critical for multi-account applications and requires empirical testing.
* Filter formats (API JSON vs WebUI XML) are NOT directly compatible - conversion requires label resolution and semantic mapping.

---

## Calendar API

### Identifiers

| ID | Question | Status | Source |
|----|----------|--------|--------|
| CA-ID-001 | Is `eventId` unique globally or only per-calendar? | 🟢 COMPLETED | **Per-calendar only** - NOT globally unique. Must use (calendarId, eventId) - `docs/datamodel/calendar/identifiers.md` |
| CA-ID-002 | What is the format of `eventId`? | 🟢 COMPLETED | Base32hex (a-v, 0-9), 5-1024 chars - `docs/web/calendar/events/events-reference.md` |
| CA-ID-003 | Can `eventId` be set at creation time? | 🟢 COMPLETED | Yes, custom IDs supported (must follow format rules) - `docs/web/calendar/guides/create-events.md` |
| CA-ID-004 | Is `calendarId` unique globally? | 🟢 COMPLETED | Yes, format is email address - `docs/datamodel/calendar/identifiers.md` |
| CA-ID-005 | For shared calendars, do all users see the same eventId? | 🟢 COMPLETED | Yes, same event ID for all users with calendar access - `docs/datamodel/calendar/identifiers.md` |
| CA-ID-006 | What is `iCalUID` and when to use it? | 🟢 COMPLETED | RFC5545 identifier shared across recurring instances, useful for cross-calendar correlation - `docs/datamodel/calendar/identifiers.md` |

### Timezone Handling

| ID | Question | Status | Source |
|----|----------|--------|--------|
| CA-TZ-001 | How are timed event times represented? | 🟢 COMPLETED | RFC3339 in `dateTime` field, optional `timeZone` IANA name - `docs/datamodel/calendar/timezones.md` |
| CA-TZ-002 | How are all-day events represented? | 🟢 COMPLETED | YYYY-MM-DD in `date` field, timeZone is ignored - `docs/datamodel/calendar/timezones.md` |
| CA-TZ-003 | Is `timeZone` required for recurring events? | 🟢 COMPLETED | Yes, required for correct DST handling during expansion - `docs/datamodel/calendar/timezones.md` |
| CA-TZ-004 | How does DST affect recurring events? | 🟢 COMPLETED | With timeZone set, local time preserved across DST changes - `docs/datamodel/calendar/timezones.md` |
| CA-TZ-005 | Are end times inclusive or exclusive? | 🟢 COMPLETED | Exclusive - event ends AT end time. All-day end date is day AFTER last day - `docs/datamodel/calendar/timezones.md` |

### Recurring Events

| ID | Question | Status | Source |
|----|----------|--------|--------|
| CA-RE-001 | What format are recurrence rules in? | 🟢 COMPLETED | RFC 5545 RRULE format in `recurrence` array - `docs/web/calendar/recurring/recurring-events.md` |
| CA-RE-002 | How do recurring event instances get IDs? | 🟢 COMPLETED | Unique `id` per instance, linked via `recurringEventId` to parent - `docs/datamodel/calendar/identifiers.md` |
| CA-RE-003 | Can you modify single instances of recurring events? | 🟢 COMPLETED | Yes, creates exception with same `recurringEventId` and `originalStartTime` - `docs/web/calendar/recurring/recurring-events.md` |
| CA-RE-004 | How to get all instances of a recurring event? | 🟢 COMPLETED | Use `events.instances(calendarId, eventId)` method - `docs/web/calendar/events/events-reference.md` |

### Multi-Account

| ID | Question | Status | Source |
|----|----------|--------|--------|
| CA-MA-001 | Can eventIds collide across calendars? | 🟢 COMPLETED | Yes, eventId only unique per-calendar. Use (calendarId, eventId) - `docs/datamodel/calendar/identifiers.md` |
| CA-MA-002 | For meeting invitations, do organizer and attendee have same eventId? | 🟢 COMPLETED | No - different calendars = different events with different eventIds. Use iCalUID for correlation across accounts - `docs/datamodel/calendar/identifiers.md` |
| CA-MA-003 | How to correlate same meeting across accounts? | 🟢 COMPLETED | Use `iCalUID` field - shared across all copies of same meeting - `docs/datamodel/calendar/identifiers.md` |

### Event Types

| ID | Question | Status | Source |
|----|----------|--------|--------|
| CA-ET-001 | What event types exist? | 🟢 COMPLETED | default, birthday, focusTime, fromGmail, outOfOffice, workingLocation - `docs/web/calendar/guides/event-types.md` |
| CA-ET-002 | How do Focus Time and OOO events auto-decline? | 🟢 COMPLETED | Via `autoDeclineMode`: declineNone, declineAllConflictingInvitations, declineOnlyNewConflictingInvitations - `docs/datamodel/calendar/gogcli-data-handling.md` |

---

### Calendar API Research Status

| Status | Count |
|--------|-------|
| 🟢 COMPLETED | 20 |
| ⚠️ PARTIAL | 0 |
| 🔵 NEEDS_TESTING | 0 |
| 🔴 PENDING | 0 |

**Key Finding**: Event IDs are unique per-calendar only (NOT globally). Calendar IDs are globally unique (email format). Use `iCalUID` to correlate same meeting across accounts/calendars.

---

## Adding Research Requests

When you find a question that needs official documentation:

1. Add it to the appropriate section with a unique ID
2. Set status to 🔴 PENDING
3. Once researched, update status and add source reference
4. Link to archived documentation in `docs/web/{service}/`

## Searching This File

```bash
# Find all pending questions
grep "🔴 PENDING" research/RESEARCH_REQUESTS.md

# Find questions needing testing
grep "🔵 NEEDS_TESTING" research/RESEARCH_REQUESTS.md

# Find completed questions with their sources
grep "🟢 COMPLETED" research/RESEARCH_REQUESTS.md
```
