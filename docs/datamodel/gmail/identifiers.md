# Gmail API Identifier Semantics

**Synthesized from official documentation**: 2026-01-29

**Purpose**: Comprehensive analysis of Gmail API identifier formats, uniqueness, and relationships based on available official documentation.

## Executive Summary

Gmail API uses opaque string identifiers for messages, threads, and labels. **Critical finding**: Google's documentation does NOT explicitly specify whether these IDs are globally unique or only unique within a user's mailbox. Multi-account applications should use composite keys `(userId, messageId)` and `(userId, threadId)` to ensure uniqueness.

## Message IDs (`messageId`)

### Format and Properties

* **Type**: String (opaque format)
* **Immutability**: Described as "immutable" - IDs do not change over time
* **Format details**: Not specified (appears to be base64-like, but not documented)
* **Length**: Not specified (variable length observed)

**Source**: `docs/web/gmail/messages/messages-reference.md`

### Uniqueness Scope (CRITICAL UNCERTAINTY)

**What documentation says**:
* IDs are "immutable"
* No explicit statement about global vs per-user uniqueness

**What documentation does NOT say**:
* Whether `messageId` is globally unique across all Gmail users
* Whether `messageId` is only unique within a single user's mailbox
* Whether two users can have the same `messageId` in their respective mailboxes

**Recommendation for multi-account applications**:
```
Always use composite key: (userId, messageId)
Never assume messageId alone is globally unique
```

**Research questions marked as NEEDS_TESTING**:
* GM-ID-001: Is `messageId` unique globally or only within a user's mailbox?
* GM-ID-005: If two users share access to a message (e.g., in shared mailbox), do they see the same `messageId`?

### Relationship to RFC 2822 Message-ID Header

**What documentation says**:
* Gmail threading is based on RFC 2822 References/In-Reply-To headers
* API `messageId` is distinct from the `Message-ID` MIME header

**What documentation does NOT say**:
* Any specific relationship between API `messageId` and RFC 2822 `Message-ID` header
* Whether they're derived from each other or completely independent

**Research question marked as NEEDS_TESTING**:
* GM-ID-006: What is the relationship between `Message-ID` header and API `messageId`?

## Thread IDs (`threadId`)

### Format and Properties

* **Type**: String (opaque format)
* **Immutability**: Messages have immutable `threadId`
* **Format details**: Not specified

**Source**: `docs/web/gmail/messages/messages-reference.md`, `docs/web/gmail/threads/threads-reference.md`

### Uniqueness Scope (CRITICAL UNCERTAINTY)

**Same uncertainty as messageId**:
* No explicit statement about global vs per-user uniqueness
* Multi-account applications should use composite key: `(userId, threadId)`

**Research questions marked as NEEDS_TESTING**:
* GM-ID-002: Is `threadId` unique globally or only within a user's mailbox?
* GM-MA-002: If I export threads from two accounts, can threadIds collide?

### Threading Behavior

**How Gmail determines thread membership** (GM-TH-001: COMPLETED):
* Matching `threadId`
* RFC 2822 References/In-Reply-To headers
* Subject matching (implied)

**Thread message ordering** (GM-TH-003: PARTIAL):
* Implied to be by `internalDate`, newest first
* Not explicitly documented

**Thread splitting** (GM-TH-005: NEEDS_TESTING):
* No documentation on what happens to `threadId` when threads split
* Can messages move between threads? Not documented

**Thread size** (GM-TH-004: PARTIAL):
* `threads.get` implies it returns all messages in a thread
* No explicit limit documented
* No pagination mechanism for large threads

## Label IDs (`labelId`)

### Format and Properties

* **Type**: String
* **Immutability**: Described as "immutable"
* **Format**: Two types - system labels and user labels

**Source**: `docs/web/gmail/labels/labels-reference.md`, `docs/web/gmail/semantics/labels-guide.md`

### System Labels (COMPLETED)

**Documented system label IDs** (GM-LB-001: PARTIAL):
* `INBOX`
* `SPAM`
* `TRASH`
* `UNREAD`
* `STARRED`
* `IMPORTANT`
* `SENT` (automatic)
* `DRAFT` (automatic)
* `CATEGORY_PERSONAL`
* `CATEGORY_SOCIAL`
* `CATEGORY_PROMOTIONS`
* `CATEGORY_UPDATES`
* `CATEGORY_FORUMS`

**Note**: Documentation states "the above list is not exhaustive and other reserved label names exist."

**Automatic labels** (cannot be manually applied):
* `SENT` - Applied automatically to sent messages
* `DRAFT` - Applied automatically to draft messages

### User Labels

* **Maximum per mailbox**: 10,000 user labels
* **Format**: Not specified (different from system labels)
* **Naming**: User-defined names, reserved names not allowed

**Research questions**:
* GM-LB-002 (NEEDS_TESTING): How do system label IDs differ from user label IDs in format?
* GM-LB-004 (NEEDS_TESTING): Are label IDs sequential or random?

### Cross-Account Label Semantics

**What documentation says**:
* Label names are per-account
* Same label name can exist in multiple accounts
* User labels max 10,000 per mailbox

**What documentation does NOT say**:
* Whether label IDs can collide across accounts
* Whether system label IDs are consistent across accounts

**Recommendation**:
* System label IDs (like `INBOX`, `SENT`) appear to be standardized and can be used across accounts
* User label IDs should be treated as account-specific - use composite key `(userId, labelId)` if storing across accounts

## History IDs (`historyId`)

### Format and Properties

* **Type**: String (uint64 format)
* **Monotonic**: Described as "monotonically increasing"
* **Never decreases**: GM-HI-003: COMPLETED - Cannot go backwards

**Source**: `docs/web/gmail/sync/sync-guide.md`, `docs/web/gmail/history/history-reference.md`

### Retention and Expiration

**What documentation says** (GM-HI-002: COMPLETED):
* History records kept for at least 1 week
* Often longer than 1 week
* Can be less in rare cases
* 404 error on expired history = need full sync

**Sync semantics**:
* Use `historyId` as sync marker for incremental sync
* `history.list` returns changes since a given `historyId`

### Multi-Account Considerations

**Critical uncertainty**:
* No documentation on whether `historyId` values can collide across users
* No documentation on whether `historyId` spaces are independent per user

**Recommendation**:
* Treat `historyId` as user-specific
* Store as composite: `(userId, historyId)`
* Never compare `historyId` values across different users

## Delegation and Shared Mailbox Semantics

**From**: `docs/web/gmail/semantics/delegation-guide.md`

### Delegation Model

* **Delegator**: User granting access
* **Delegate**: User receiving access
* **Scope**: Same Google Workspace organization only
* **Permissions**: Read, send, delete messages; view/add contacts

### Identifier Behavior in Delegation (NEEDS_TESTING)

**Critical unanswered questions**:
* Do delegator and delegate see the same `messageId` for the same message?
* How do `labelId` values work in delegated access?
* Are `historyId` values shared or separate?

**What documentation says**:
* API calls must be scoped to specific `userId`
* Application must track context
* No indication in API response shows which account message came from

**Recommendation**:
* Always include `userId` in your data model
* Never rely on ID alone to determine account
* Test delegation scenarios empirically if using delegation features

## Multi-Account Application Guidelines

### Storage Schema Recommendations

**Always use composite keys**:
```sql
-- Messages
PRIMARY KEY (user_id, message_id)

-- Threads
PRIMARY KEY (user_id, thread_id)

-- Labels
PRIMARY KEY (user_id, label_id)

-- History sync state
PRIMARY KEY (user_id), INDEX (last_history_id)
```

### System Label Handling

**System labels can be used directly** (same across accounts):
```
INBOX, SENT, DRAFT, SPAM, TRASH, etc.
```

**But still scope queries by userId**:
```
SELECT * FROM messages
WHERE user_id = ? AND 'INBOX' = ANY(label_ids)
```

### User Label Handling

**Never assume user label IDs are comparable across accounts**:
```python
# WRONG - label IDs may collide across users
if message.label_id == "Label_123":
    ...

# RIGHT - always include user context
if (message.user_id, message.label_id) == (target_user, "Label_123"):
    ...
```

## Testing Recommendations

The following aspects **MUST be tested empirically** because official documentation does not specify:

### High Priority Tests

1. **ID Uniqueness Across Accounts**:
   * Create identical messages in two accounts
   * Check if `messageId` values are same or different
   * Check if `threadId` values are same or different

2. **Delegation ID Consistency**:
   * Set up delegator and delegate
   * Compare `messageId`, `threadId`, `labelId` as seen by each
   * Test if IDs are identical for same messages

3. **History ID Collision**:
   * Compare `historyId` ranges across multiple accounts
   * Determine if history ID spaces overlap

### Medium Priority Tests

4. **Label ID Format Patterns**:
   * Create user labels in multiple accounts
   * Document label ID format patterns
   * Determine if system vs user labels have distinguishable formats

5. **Thread Behavior**:
   * Test if messages can be moved between threads
   * Test thread splitting scenarios (forwarding, subject changes)
   * Test maximum thread size

6. **RFC 2822 Message-ID Relationship**:
   * Send message with specific `Message-ID` header
   * Compare with API `messageId`
   * Determine any correlation

## Summary: What We Know vs Don't Know

### ✅ What Official Documentation Confirms

* IDs are immutable (don't change over time)
* IDs are opaque strings (implementation details not exposed)
* `historyId` is monotonically increasing
* System labels have standardized IDs
* User labels limited to 10,000 per mailbox
* Delegation requires same organization and service account

### ❌ Critical Gaps in Documentation

* **ID uniqueness scope**: Global vs per-user (MOST CRITICAL)
* ID format specifications
* Relationship between API IDs and RFC 2822 Message-ID
* Thread splitting and message movement behavior
* Delegation ID consistency
* Maximum thread size
* Label ID format patterns

### 🎯 Recommended Approach

**For production multi-account applications**:
1. **Always use composite keys** with `userId`
2. **Never assume global uniqueness** of any ID
3. **Test empirically** for your specific use cases
4. **Monitor for collisions** in production
5. **Design for ID namespace independence** per user

## References

* `docs/web/gmail/messages/messages-reference.md`
* `docs/web/gmail/threads/threads-reference.md`
* `docs/web/gmail/labels/labels-reference.md`
* `docs/web/gmail/semantics/labels-guide.md`
* `docs/web/gmail/history/history-reference.md`
* `docs/web/gmail/sync/sync-guide.md`
* `docs/web/gmail/semantics/delegation-guide.md`
* `research/RESEARCH_REQUESTS.md`
