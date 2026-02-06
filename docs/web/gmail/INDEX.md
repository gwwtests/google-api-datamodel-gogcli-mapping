# Gmail API Documentation Archive

Archive of official Gmail API documentation for understanding the data model.

**Archive Date**: 2026-01-29

**Purpose**: Research data model questions about identifiers, threading, labels, timestamps, and synchronization.

## Archived Documents

### Overview

* `overview/api-overview.md` - Gmail API overview and introduction
  * Source: https://developers.google.com/gmail/api/guides

### Messages

* `messages/messages-reference.md` - Complete Message resource reference
  * Source: https://developers.google.com/gmail/api/reference/rest/v1/users.messages
  * Key topics: Message ID, Thread ID, Internal Date, History ID, Label IDs

### Threads

* `threads/threads-reference.md` - Thread resource reference
  * Source: https://developers.google.com/gmail/api/reference/rest/v1/users.threads
  * Key topics: Thread ID, message grouping

* `threads/threads-guide.md` - Threads guide
  * Source: https://developers.google.com/gmail/api/guides/threads
  * Key topics: Threading algorithm, conversation management

### Labels

* `labels/labels-reference.md` - Label resource reference
  * Source: https://developers.google.com/gmail/api/reference/rest/v1/users.labels
  * Key topics: Label ID, system vs user labels, label types

* `labels/labels-guide.md` - Labels guide
  * Source: https://developers.google.com/gmail/api/guides/labels
  * Key topics: Label management

### History & Sync

* `history/history-reference.md` - History resource reference
  * Source: https://developers.google.com/gmail/api/reference/rest/v1/users.history
  * Key topics: History ID, change tracking

* `sync/sync-guide.md` - Synchronization guide
  * Source: https://developers.google.com/gmail/api/guides/sync
  * Key topics: Incremental sync, history tracking, push notifications

## File Naming Convention

Each archived document has companion files:

* `.md` - Markdown content extracted via jina.ai reader
* `.url` - Source URL (single line)
* `.yaml` - Metadata including timestamp, covered APIs, key concepts, and notes

## Key Findings Summary

### Identifiers

**Message ID** (`id` field):
* Type: string
* Described as "immutable"
* Format: Not specified (opaque)
* Uniqueness: Not explicitly stated whether global or per-user
* Stability: Immutable - does not change

**Thread ID** (`threadId` field):
* Type: string
* Described as "unique ID of the thread"
* Format: Not specified (opaque)
* Uniqueness: Not explicitly stated whether global or per-user
* Threading criteria: Requires matching threadId + RFC 2822 headers + Subject

**Label ID** (`id` field):
* Type: string
* Described as "immutable ID of the label"
* Format: Not specified (opaque)
* Types: "system" (Gmail-created) or "user" (custom)
* Constraint: Maximum 10,000 labels per mailbox

**History ID** (`historyId` field):
* Type: string
* Purpose: Incremental sync tracking
* Behavior: Monotonically increasing
* Appears on both Message and Thread resources
* Limited retention period (must handle expiration)

### Timestamps

**Internal Date** (`internalDate` field):
* Type: string (int64 format)
* Format: Epoch milliseconds
* For SMTP email: Time message accepted by Google (more reliable than Date header)
* For API-migrated mail: Can be configured based on Date header
* Purpose: Determines inbox ordering
* Timezone: Implicitly UTC (epoch time)

### Threading Model

Messages are grouped into threads based on:
1. Matching `threadId` specified in request
2. RFC 2822 compliant `References` and `In-Reply-To` headers
3. Matching `Subject` headers

Thread resource contains:
* `id` - unique thread identifier
* `messages[]` - array of Message objects
* `historyId` - sync tracking
* `snippet` - preview text

### Multi-Account Considerations

Documentation does NOT explicitly address:
* Whether messageId/threadId can collide across accounts
* How to identify which account a message came from
* Global vs per-user uniqueness guarantees

These questions remain UNANSWERED in official documentation.

## Research Status

See `../../../research/RESEARCH_REQUESTS.md` for tracking of specific questions answered by this archive.

## Extraction Method

All documents retrieved using jina.ai reader (https://r.jina.ai/) for clean markdown extraction from HTML.
