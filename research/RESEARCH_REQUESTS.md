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
| GM-LB-001 | What system labels exist? Complete list? | ⚠️ PARTIAL | Examples: INBOX, SENT, DRAFTS, TRASH, SPAM, UNREAD. Complete list not documented - `docs/web/gmail/labels/labels-reference.md` |
| GM-LB-002 | How do system label IDs differ from user label IDs? | 🔵 NEEDS_TESTING | Not specified, needs empirical comparison |
| GM-LB-003 | Can the same label name exist in multiple accounts? | 🟢 COMPLETED | Yes, label names are per-account. User labels max 10,000 per mailbox - `docs/web/gmail/labels/labels-reference.md` |
| GM-LB-004 | Are label IDs sequential or random? | 🔵 NEEDS_TESTING | Not specified in docs |

### Multi-Account

| ID | Question | Status | Source |
|----|----------|--------|--------|
| GM-MA-001 | If I export messages from two accounts, can messageIds collide? | 🔵 NEEDS_TESTING | Not specified. Recommendation: use composite key (userId, messageId) - `docs/gmail-data-model-findings.md` |
| GM-MA-002 | If I export threads from two accounts, can threadIds collide? | 🔵 NEEDS_TESTING | Not specified. Recommendation: use composite key (userId, threadId) - `docs/gmail-data-model-findings.md` |
| GM-MA-003 | How do I identify which account a message came from in the API response? | 🟢 COMPLETED | API calls are scoped to userId, response doesn't include it - application must track context - `docs/gmail-data-model-findings.md` |

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

---

## Summary Statistics

### Gmail API Research Status

| Status | Count |
|--------|-------|
| 🟢 COMPLETED | 12 |
| ⚠️ PARTIAL | 4 |
| 🔵 NEEDS_TESTING | 9 |
| 🔴 PENDING | 0 |

**Key Finding**: Official Google documentation does NOT specify identifier uniqueness scope (global vs per-user). This is critical for multi-account applications and requires empirical testing.

---

## Calendar API

*(To be populated when we start Calendar research)*

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
