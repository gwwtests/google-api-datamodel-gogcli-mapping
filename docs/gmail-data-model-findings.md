# Gmail API Data Model Findings

Comprehensive analysis of Gmail API data model based on official documentation.

**Source**: Archived documentation in `docs/web/gmail/`

**Archive Date**: 2026-01-29

**Reference**: See `docs/web/gmail/INDEX.md` for complete archive inventory

## Executive Summary

This document answers key questions about Gmail API data model for implementing multi-account mailbox export tools. It consolidates findings from official Google documentation.

### Critical Gaps Identified

The official documentation does NOT explicitly answer:

1. Whether `messageId` is globally unique or only per-user unique
2. Whether `threadId` is globally unique or only per-user unique
3. Whether IDs can collide when exporting from multiple accounts
4. How to identify which account a message belongs to from API response alone

These gaps require additional research or testing.

## Identifiers

### Message ID

**Field**: `id` (string)

**Source**: [users.messages Resource](https://developers.google.com/gmail/api/reference/rest/v1/users.messages)

**Characteristics**:

* Described as "immutable ID of the message"
* Type: string (opaque format, not specified)
* Stability: Immutable - does not change over time
* Uniqueness: **NOT explicitly stated** whether global or per-user

**Multi-Account Implications**:

* UNKNOWN if messageIds can collide across accounts
* UNKNOWN if same physical email in two accounts has same or different IDs
* Recommendation: Prefix with userId in export data model

**Related Questions**:

* GM-ID-001: Is messageId unique globally or only within a user's mailbox?
* GM-ID-003: What is the format of messageId?
* GM-ID-004: Can messageId change over time? ANSWERED: No (immutable)
* GM-ID-005: Do shared messages have same messageId? UNANSWERED
* GM-ID-006: Relationship to Message-ID header? UNANSWERED

### Thread ID

**Field**: `threadId` (string)

**Source**: [users.threads Resource](https://developers.google.com/gmail/api/reference/rest/v1/users.threads)

**Characteristics**:

* Described as "unique ID of the thread"
* Type: string (opaque format, not specified)
* Stability: Presumably immutable (not explicitly stated)
* Uniqueness: **NOT explicitly stated** whether global or per-user

**Threading Criteria**:

Messages are grouped into threads based on:

1. Matching `threadId` specified in request
2. RFC 2822 compliant `References` and `In-Reply-To` headers
3. Matching `Subject` headers

**Source**: [Message Resource threadId field description](https://developers.google.com/gmail/api/reference/rest/v1/users.messages)

**Multi-Account Implications**:

* UNKNOWN if threadIds can collide across accounts
* UNKNOWN if same conversation in two accounts has same threadId
* Recommendation: Prefix with userId in export data model

**Related Questions**:

* GM-ID-002: Is threadId unique globally or per-user? UNANSWERED
* GM-TH-001: How are threads determined? ANSWERED (see above)
* GM-TH-002: Can messages be moved between threads? UNANSWERED
* GM-TH-003: Are messages in thread ordered? PARTIALLY (by internalDate implied)
* GM-TH-004: Does threads.get return all messages? IMPLIED yes, but not explicit
* GM-TH-005: What happens to threadId when thread splits? UNANSWERED

### Label ID

**Field**: `id` (string)

**Source**: [users.labels Resource](https://developers.google.com/gmail/api/reference/rest/v1/users.labels)

**Characteristics**:

* Described as "immutable ID of the label"
* Type: string (opaque format, not specified)
* Stability: Immutable
* Uniqueness: **NOT explicitly stated** whether global or per-user

**Label Types**:

Two types of labels exist:

1. **System Labels**:
   * Created by Gmail
   * Cannot be added, modified, or deleted
   * Examples: INBOX, SENT, DRAFTS, TRASH, SPAM, UNREAD
   * May be applied/removed under some circumstances (not guaranteed)
   * INBOX and UNREAD can be applied/removed by users
   * DRAFTS and SENT cannot be applied/removed by users

2. **User Labels**:
   * Created by user or application
   * Can be modified and deleted
   * Can have custom colors
   * Maximum 10,000 labels per user mailbox

**Source**: [Label Resource type field description](https://developers.google.com/gmail/api/reference/rest/v1/users.labels)

**Multi-Account Implications**:

* System labels likely have standard IDs across accounts (needs verification)
* User labels certainly have different IDs across accounts
* Label names can be duplicated across accounts
* Recommendation: Store both labelId and name for export

**Related Questions**:

* GM-ID-007: Are labelId values stable? ANSWERED: Yes (immutable)
* GM-LB-001: What system labels exist? PARTIALLY ANSWERED (examples given, complete list not specified)
* GM-LB-002: How do system vs user label IDs differ? FORMAT UNSPECIFIED
* GM-LB-003: Can same label name exist in multiple accounts? PRESUMABLY yes
* GM-LB-004: Are label IDs sequential or random? UNANSWERED

### History ID

**Field**: `historyId` (string)

**Source**: [users.history Resource](https://developers.google.com/gmail/api/reference/rest/v1/users.history)

**Characteristics**:

* Type: string (opaque format)
* Purpose: Incremental synchronization marker
* Behavior: Monotonically increasing (newer = higher)
* Appears on: Both Message and Thread resources
* Field description: "ID of the last history record that modified this message/thread"

**Usage Pattern**:

1. Perform full sync with `messages.list` or `threads.list`
2. Store `historyId` from most recent message (first in list response)
3. For incremental sync, call `history.list` with `startHistoryId`
4. Apply returned history records to cached data
5. Update stored historyId with latest

**Source**: [Synchronization Guide](https://developers.google.com/gmail/api/guides/sync)

**Retention and Limitations**:

* History records available for "at least one week, often longer"
* Retention period may be "significantly less" in some cases
* Records "may sometimes be unavailable in rare cases"
* If `startHistoryId` outside available range: API returns HTTP 404
* On 404: Must perform full sync

**Source**: [Sync Guide - Limitations](https://developers.google.com/gmail/api/guides/sync)

**Multi-Account Implications**:

* Each account has independent historyId namespace
* Cannot compare historyIds across accounts
* Must track historyId per account

**Related Questions**:

* GM-HI-001: What is historyId? ANSWERED: Sync tracking identifier
* GM-HI-002: How long are history records kept? ANSWERED: At least 1 week, often longer
* GM-HI-003: Can historyId go backwards? IMPLIED no (monotonically increasing)

## Timestamps

### Internal Date

**Field**: `internalDate` (string in int64 format)

**Source**: [Message Resource](https://developers.google.com/gmail/api/reference/rest/v1/users.messages)

**Format**: Epoch milliseconds (int64 as string)

**Timezone**: UTC (implicit - epoch time is timezone-independent)

**Semantics**:

* **For SMTP-received email**: Time message originally accepted by Google
  * More reliable than `Date` header
  * Prevents users from manipulating delivery order via spoofed headers

* **For API-migrated mail**: Can be configured based on `Date` header
  * Allows preserving original timestamps when importing historical mail

**Purpose**: Determines message ordering in inbox

**Source**: [Message Resource internalDate field description](https://developers.google.com/gmail/api/reference/rest/v1/users.messages)

**Multi-Account Implications**:

* Timestamps are absolute (epoch time), not account-relative
* Can compare timestamps across accounts
* Same physical message in two accounts may have different internalDates

**Related Questions**:

* GM-TS-001: What timestamp fields exist? ANSWERED: internalDate (others in headers)
* GM-TS-002: Are timestamps UTC or user timezone? ANSWERED: UTC (epoch ms)
* GM-TS-003: What format are timestamps? ANSWERED: int64 format (epoch ms as string)
* GM-TS-004: Is internalDate same as Date header? ANSWERED: No, more reliable

## Threading Model

**Source**: [users.threads Resource](https://developers.google.com/gmail/api/reference/rest/v1/users.threads)

### Thread Structure

A thread is "a collection of messages representing a conversation".

**Fields**:

* `id` - unique thread identifier (string)
* `snippet` - preview text (string)
* `historyId` - sync tracking (string)
* `messages[]` - array of Message objects

### Threading Algorithm

Messages are grouped based on:

1. **Matching threadId**: Must be specified in request when adding to thread
2. **RFC 2822 Headers**: `References` and `In-Reply-To` must comply with standard
3. **Subject Matching**: Subject headers must match

**Source**: [Message Resource threadId field description](https://developers.google.com/gmail/api/reference/rest/v1/users.messages)

### Message Ordering

While not explicitly stated, messages are implied to be ordered by `internalDate` based on sync guide recommendations to use historyId from "first message in list response" (most recent).

**Inference**: Messages within thread likely ordered newest-to-oldest

### Multi-Account Considerations

* Same email conversation in two accounts creates separate threads
* Threading is account-specific, not global
* No cross-account thread merging

## Synchronization

### Full Sync

**When Required**:

* First time application connects
* When partial sync unavailable (history expired)
* After HTTP 404 from history.list

**Procedure**:

1. Call `messages.list` (or `threads.list`) for first page
2. Batch `messages.get` requests for returned IDs
3. Use `format=FULL` or `format=RAW` for first retrieval (cache results)
4. Use `format=MINIMAL` for re-fetches (only labelIds change)
5. Store `historyId` from most recent message for future partial sync

**Source**: [Sync Guide - Full Synchronization](https://developers.google.com/gmail/api/guides/sync)

### Partial Sync (Incremental)

**When Available**: After recent full or partial sync

**Procedure**:

1. Call `history.list` with `startHistoryId` from last sync
2. Process returned history records (message added/deleted/modified)
3. Merge updates into cached data
4. Update stored historyId with latest

**History Record Types**:

* Message added
* Message deleted
* Labels modified

**Source**: [Sync Guide - Partial Synchronization](https://developers.google.com/gmail/api/guides/sync)

### Push Notifications

**Purpose**: Real-time updates without polling

**Mechanism**: Google Cloud Pub/Sub integration

**API Methods**:

* `users.watch` - Start receiving notifications
* `users.stop` - Stop receiving notifications

**Usage Pattern**:

1. Set up Pub/Sub topic and subscription
2. Call `users.watch` to register mailbox
3. Receive notifications on mailbox changes
4. Trigger partial sync using history.list
5. Renew watch periodically (expiration time provided)

**Source**: [Push Notifications Guide](https://developers.google.com/gmail/api/guides/push)

## Multi-Account Export Considerations

### Key Design Decisions

1. **ID Scoping**: Always prefix messageId/threadId/labelId with userId
   * Prevents potential collisions
   * Makes account origin explicit

2. **Timestamp Handling**: Use internalDate as-is (epoch ms)
   * Already timezone-independent
   * Comparable across accounts

3. **Label Management**: Store both labelId and name
   * System labels may have standard IDs (verify via testing)
   * User labels definitely unique per account
   * Names can duplicate across accounts

4. **Thread Reconstruction**: Don't assume thread continuity across accounts
   * Each account has independent threading
   * Use Message-ID headers for cross-account correlation if needed

5. **Sync State**: Track historyId per account
   * Independent namespaces
   * Cannot compare across accounts

### Recommended Data Model

```
{
  "userId": "user@example.com",          // Account identifier
  "messageId": "17a1b2c3d4e5f6",         // Gmail API message ID
  "threadId": "17a1b2c3d4e5f6",          // Gmail API thread ID
  "internalDate": "1706563200000",       // Epoch ms (UTC)
  "historyId": "234567",                 // For sync tracking
  "labelIds": ["INBOX", "Label_123"],    // Label IDs
  "labels": {                            // Label details
    "INBOX": {"name": "INBOX", "type": "system"},
    "Label_123": {"name": "Work", "type": "user"}
  },
  ...
}
```

### Composite Keys

For global uniqueness in multi-account exports:

* Message: `(userId, messageId)`
* Thread: `(userId, threadId)`
* Label: `(userId, labelId)`

## Unanswered Questions

The following questions remain unanswered by official documentation:

### Identifier Uniqueness

* Is messageId globally unique across all Gmail accounts?
* Is threadId globally unique across all Gmail accounts?
* Do shared/delegated messages have the same messageId for all accessors?
* What is the relationship between API messageId and Message-ID header?

### Threading Behavior

* Can a message be moved from one thread to another?
* Does threads.get always return ALL messages in a thread?
* What happens to threadId when a conversation is forwarded separately?
* Are there size limits on threads (max messages per thread)?

### Label Details

* Complete list of all system labels?
* Format differences between system and user label IDs?
* Are system label IDs consistent across all accounts?

### Multi-Account Specific

* If I export from account A and B, can messageIds collide?
* How do I identify which account a message came from in API response?
  * Note: API calls are scoped to userId, but response doesn't include it
  * Application must track context

## Testing Recommendations

To answer unanswered questions:

1. **ID Uniqueness**: Export same message from multiple accounts, compare IDs
2. **System Label IDs**: List labels from multiple fresh accounts, compare
3. **Collision Testing**: Export large datasets from multiple accounts, check for ID collisions
4. **Threading Behavior**: Experiment with modifying threads, observe ID changes

## References

All findings sourced from official Google documentation archived in:

* `docs/web/gmail/messages/` - Message resource documentation
* `docs/web/gmail/threads/` - Thread resource documentation
* `docs/web/gmail/labels/` - Label resource documentation
* `docs/web/gmail/history/` - History resource documentation
* `docs/web/gmail/sync/` - Synchronization guides

See `docs/web/gmail/INDEX.md` for complete inventory and source URLs.

Each archived document includes:

* `.md` - Markdown content
* `.url` - Source URL
* `.yaml` - Metadata (timestamp, key concepts, notes)

## Document Status

**Created**: 2026-01-29

**Status**: Initial research complete

**Next Steps**:

1. Update `research/RESEARCH_REQUESTS.md` with answered questions
2. Design multi-account data model based on findings
3. Implement test harness to answer unanswered questions
4. Document system label IDs via empirical testing
