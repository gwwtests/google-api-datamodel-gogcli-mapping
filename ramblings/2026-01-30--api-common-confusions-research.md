# API Common Confusions Research Summary

**Date**: 2026-01-30
**Purpose**: Document community-reported confusions about Gmail and Calendar APIs

## Research Sources

- Stack Overflow questions
- GitHub issues (googleapis/* repositories)
- Google Groups discussions
- Developer blogs and tutorials
- Google Issue Tracker feature requests

## Gmail API: Critical Confusions Discovered

### 1. Thread ID Is User-Specific (CRITICAL)

**The Misconception**: Developers assume thread IDs are conversation-universal.

**The Reality**: `threadId` values are **user-specific**. The same email thread has different thread IDs when viewed from different accounts.

**Evidence**: InboxSDK discussion - `gmail.users.threads.get(sender_thread_id)` returns 200 OK for sender but 404 NOT FOUND for recipient.

**Implication**: Cross-account correlation requires SMTP `Message-ID` header (RFC 5322), not Gmail API `threadId`.

**Technical Detail**: Thread IDs encode timestamp in first 11 hex digits, sequence in last 5 (Metaspike analysis).

### 2. Labels ≠ Folders (Paradigm Mismatch)

Gmail architecture: All emails in single "All Mail" bucket. `INBOX`, `SENT`, `SPAM` are filtered views (labels), not storage locations.

**Multi-assignment**: Single email can have multiple labels simultaneously. IMAP clients render as duplicate emails (one per "folder").

**System label mutability**: `INBOX`/`UNREAD` modifiable via API, but `SENT`/`DRAFTS` are read-only (auto-assigned).

### 3. Threading Requires SMTP Headers

Including `threadId` in `messages.send` creates threading **for sender only**. Recipients see separate messages unless proper SMTP headers present:

```
In-Reply-To: <parent-msg-id@domain.com>
References: <grandparent@domain> <parent@domain>
Subject: Re: Original Subject
```

**Common mistakes**:
- Using Gmail API `message.id` instead of `Message-ID` header value
- Omitting angle brackets
- Incomplete `References` chain

### 4. HistoryId Sync Fragility

**Documented**: "Typically valid for at least a week"
**Actual**: "In rare circumstances may be valid for only a few hours"

**Push notification trap**: Pub/Sub historyId represents state AFTER changes, not before. Using notification historyId directly returns empty results.

**HistoryTypes limitation**: API accepts only ONE type per request → requires 4 separate calls.

### 5. Base64 URL-Safe Encoding

Gmail API returns `raw` field as **URL-safe** Base64 (RFC 4648 §5: `-` and `_` instead of `+` and `/`). Using standard Base64 decoder corrupts data.

### 6. Draft ID Changes on Send

Draft contains two IDs (draft ID + message ID). On `drafts.send()`, draft is deleted and **new message with different ID** is created. Cannot track draft→sent via message ID.

### 7. Rate Limiting Complexity

Multiple overlapping dimensions trigger HTTP 429:
1. Daily quota (project-level)
2. Per-user rate limit
3. Per-user concurrent request limit
4. Per-user bandwidth limit

**Batch paradox**: Batch of n requests counts as n quota, not 1.

### 8. Features Without API Support

| Feature | API Status |
|---------|------------|
| Snooze | SNOOZED label only, no timing (blocked requests #109952618, #287304309) |
| Scheduled Send | No support (blocked request #140922183) |
| Confidential Mode | No support |

## Calendar API: Critical Confusions Discovered

### 1. Event ID vs iCalUID

Two distinct identifier systems:
- `id` (Event ID): Opaque Google-specific, unique per instance
- `iCalUID`: RFC5545 standard, shared across recurring instances

Recurring events: All instances have different `id` but share `iCalUID`.

### 2. Recurring Event Instance IDs

**Misconception**: Instance IDs remain stable when rescheduled.

**Reality**:
- `recurringEventId`: Parent event reference
- `originalStartTime`: Immutable identifier (survives rescheduling)
- `id`: Can change

Use `originalStartTime` to identify instances, not `id`.

### 3. All-Day Event End Date Off-By-One

End date is **exclusive** per iCalendar standard:

```
Single-day event on Jan 15:
  start.date: "2026-01-15"
  end.date:   "2026-01-16"  ← Day AFTER
```

**Invalid**: Mixing `start.date` with `end.dateTime`

### 4. Timezone Handling Pitfalls

For recurring events: `timeZone` field **REQUIRED** for DST expansion.

**Pitfall**: PHP implementations may ignore `timeZone: 'Etc/UTC'` parameter.

### 5. Sync Token vs Page Token

- `pageToken`: Pagination within single session (ephemeral)
- `syncToken`: Bookmark between sessions (persistent, ~1hr TTL)

Cannot use `syncToken` with date bounds (`timeMin`, `timeMax`).

### 6. "Cancelled" vs "Deleted"

No separate "deleted" status; `status='cancelled'` represents deletion.

Cancelled events require `showDeleted=true` to retrieve.

### 7. Organizer vs Attendee Ownership

Organizer calendar owns canonical event data. Attendees get replicated copies.

Only attendee modification propagated back: `responseStatus`.

### 8. singleEvents Parameter

| singleEvents | Returns |
|--------------|---------|
| `false` | Recurring parents + exceptions |
| `true` | Flattened instances, no parents |

## Key Takeaways

### For Gmail Data Model Design

1. Store both Gmail `threadId` AND SMTP `Message-ID`/`In-Reply-To`/`References`
2. Model labels as many-to-many, not folders
3. Qualify all IDs with user context
4. Implement 404 handling for historyId expiration
5. Track draft→sent via `threadId`, not message ID

### For Calendar Data Model Design

1. Use `(calendarId, eventId)` as composite key
2. Store `originalStartTime` for recurring instances
3. Handle exclusive end dates
4. Require timezone for recurring events
5. Use `iCalUID` for cross-calendar correlation

## Privacy Note

All examples in this document use:
- Fictional email addresses (alice@example.com, etc.)
- Synthetic IDs and timestamps
- No real user data or configurations
