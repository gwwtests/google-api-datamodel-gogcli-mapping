# Gmail API Capabilities: Labels, System Labels, and Draft Threading

**Date**: 2026-02-01
**Purpose**: Document Gmail API label management and draft reply threading

## Questions Answered

### 1. Can You Change/Rename a Label?

**YES** - User labels can be renamed via `labels.update` (PUT) or `labels.patch` (PATCH).

```python
# Rename label (preferred method - partial update)
service.users().labels().patch(
    userId='me',
    id='Label_123',
    body={'name': 'New Name'}
).execute()
```

**Key insight**: Label `id` is IMMUTABLE, only `name` changes. Store labels by ID, not name.

### 2. Inbox vs Archived - How Implemented?

**INBOX label presence/absence determines this:**

```
INBOX label present  → Message in Inbox
INBOX label absent   → Message archived (still in All Mail)
```

Archive = `messages.modify` with `removeLabelIds: ['INBOX']`

### 3. Trash Bin - How Implemented?

**TRASH system label:**

- `messages.trash()` adds TRASH label, removes most others
- `messages.untrash()` restores message
- Auto-deletes after 30 days
- Can also manually apply/remove TRASH label

### 4. Drafts - How Implemented?

**DRAFT system label (AUTO-MANAGED):**

- Applied automatically on `drafts.create`
- Removed automatically on `drafts.send`
- **Cannot be manually applied or removed!** (returns "400 Invalid label")
- Draft messages cannot have other labels

### 5. Creating a Draft as Thread Reply

**Requires THREE things:**

1. **threadId** in API request (links to thread in sender's mailbox)
2. **In-Reply-To header** with RFC Message-ID (NOT Gmail id!)
3. **References header** with Message-ID chain

**Critical distinction:**

```
Gmail message.id:     "18d5abc123def456"     ← DO NOT use for threading
Message-ID header:    "<abc@mail.gmail.com>"  ← USE THIS for In-Reply-To
```

## System Label Mutability Discovery

| Label | Apply OK? | Remove OK? | Notes |
|-------|:---------:|:----------:|-------|
| INBOX | ✅ | ✅ | Archive = remove |
| STARRED | ✅ | ✅ | |
| UNREAD | ✅ | ✅ | |
| IMPORTANT | ✅ | ✅ | |
| TRASH | ✅ | ✅ | |
| SPAM | ✅ | ✅ | |
| CATEGORY_* | ✅ | ✅ | |
| **SENT** | ❌ | ❌ | Auto-managed on send |
| **DRAFT** | ❌ | ❌ | Auto-managed on draft create |
| SNOOZED | ✅ | ✅ | Label only, no timing API |

## New Documentation Created

### `docs/datamodel/gmail/api-capabilities.md`

- Label management (create, rename, delete, color)
- System vs user label operations matrix
- INBOX/TRASH/DRAFT/SENT label mechanics
- Draft reply threading step-by-step guide
- API scopes reference

### `docs/datamodel/gmail/visualizations.md`

Mermaid diagrams:

- Label system mindmap
- Archive operation sequence
- Trash operation flowchart
- System label mutability chart
- Draft reply threading sequence
- Message-ID vs Gmail ID distinction
- Label rename (ID persists)

### `docs/datamodel/gmail/examples/draft-reply-to-thread.json`

Comprehensive example showing:

- Step 1: Get original message for headers
- Step 2: Extract threading info (Message-ID, not Gmail id!)
- Step 3: Build MIME message with headers
- Step 4: Base64url encode and create draft
- Step 5: API response
- Common mistakes and consequences

### `docs/datamodel/gmail/ux-to-data-mapping.md` - Extended

Added sections 15-17:

- **15. System Label Mechanics**: How "folders" are really labels
- **16. Creating a Draft Reply**: Full process for thread continuation
- **17. Label Renaming**: ID stays, name changes

## Key Takeaways

1. **Gmail has no folders** - Everything is labels, even INBOX/SENT/DRAFT/TRASH

2. **SENT and DRAFT are special** - Cannot manually add/remove, fully auto-managed

3. **Threading requires RFC headers** - Gmail's threadId only affects sender's view

4. **Message-ID ≠ Gmail id** - Critical distinction for cross-account threading

5. **Label IDs are permanent** - Renaming only changes display name, not ID

## Privacy Note

All examples use:

- Fictional email addresses (alice@company.com, bob@company.com)
- Synthetic message IDs and thread IDs
- No real user data or configurations
