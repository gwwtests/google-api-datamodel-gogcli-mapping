# Gmail API: Feature Capabilities Reference

A comprehensive guide to what Gmail API can and cannot do.

## Quick Reference Matrix

| Feature | API Support | Notes |
|---------|:-----------:|-------|
| **Labels** |||
| Create user labels | ✅ Full | `labels.create` |
| Rename user labels | ✅ Full | `labels.update` or `labels.patch` |
| Delete user labels | ✅ Full | `labels.delete` |
| Change label color | ✅ Full | ~70 predefined colors only |
| Modify system labels | ❌ No | INBOX, SENT, DRAFT, TRASH, etc. are immutable |
| **Messages** |||
| Apply/remove INBOX | ✅ Full | Archive = remove INBOX label |
| Apply/remove UNREAD | ✅ Full | Mark read/unread |
| Apply/remove STARRED | ✅ Full | Star/unstar |
| Apply/remove TRASH | ✅ Full | `messages.trash` / `messages.untrash` |
| Apply/remove SENT | ❌ No | Auto-managed (applied on send) |
| Apply/remove DRAFT | ❌ No | Auto-managed (applied on draft create) |
| **Drafts** |||
| Create draft | ✅ Full | `drafts.create` |
| Create draft as reply | ✅ Full | Requires threadId + SMTP headers |
| Update draft | ✅ Full | `drafts.update` (creates new msg internally) |
| Send draft | ✅ Full | `drafts.send` |
| **Threading** |||
| Create threaded reply | ✅ Full | threadId + In-Reply-To + References headers |
| Cross-account threading | ⚠️ Headers only | Gmail threadId is user-specific |
| **Features** |||
| Snooze | ⚠️ Label only | SNOOZED label exists, no timing API |
| Scheduled Send | ❌ No | No API support |
| Confidential Mode | ❌ No | No API support |

---

## 1. Label Management

### Renaming Labels

**✅ Supported** for USER labels via `labels.update` (PUT) or `labels.patch` (PATCH).

```python
# Using labels.patch (recommended - partial update)
service.users().labels().patch(
    userId='me',
    id='Label_123',
    body={'name': 'New Label Name'}
).execute()

# Using labels.update (full replacement)
label = service.users().labels().get(userId='me', id='Label_123').execute()
label['name'] = 'New Label Name'
service.users().labels().update(userId='me', id='Label_123', body=label).execute()
```

**Mutable Properties (USER labels only):**

| Property | Description |
|----------|-------------|
| `name` | Display name (can be renamed) |
| `color.backgroundColor` | Label background color |
| `color.textColor` | Label text color |
| `messageListVisibility` | `show` or `hide` in message list |
| `labelListVisibility` | `labelShow`, `labelShowIfUnread`, `labelHide` |

**Immutable Properties:**

| Property | Notes |
|----------|-------|
| `id` | Permanent identifier (e.g., `Label_123`) |
| `type` | `system` or `user` - cannot change |

### Color Constraints

Colors must be from Gmail's predefined palette (~70 colors):

```json
{
  "color": {
    "backgroundColor": "#fb4c2f",
    "textColor": "#ffffff"
  }
}
```

Arbitrary hex colors are NOT allowed.

### System vs User Labels

| Operation | System Labels | User Labels |
|-----------|:-------------:|:-----------:|
| Create | ❌ | ✅ |
| Read | ✅ | ✅ |
| Update/Rename | ❌ | ✅ |
| Delete | ❌ | ✅ |
| Apply to messages | Varies | ✅ |

---

## 2. Inbox, Archive, Trash: Label Mechanics

Gmail doesn't have "folders" - everything is labels. Understanding this is crucial.

### INBOX Label (Archive Mechanism)

```
INBOX label PRESENT  → Message appears in Inbox
INBOX label ABSENT   → Message is "archived" (still in All Mail)
```

**Archive a message:**
```python
service.users().messages().modify(
    userId='me',
    id='msg_id',
    body={'removeLabelIds': ['INBOX']}
).execute()
```

**Unarchive (move back to inbox):**
```python
service.users().messages().modify(
    userId='me',
    id='msg_id',
    body={'addLabelIds': ['INBOX']}
).execute()
```

**Important behavior:**
- Archived messages still exist in "All Mail"
- When someone replies to archived thread, Gmail **automatically re-adds INBOX**
- Messages in SPAM/TRASH cannot be archived directly

### TRASH Label

```python
# Move to trash (adds TRASH label, removes other labels)
service.users().messages().trash(userId='me', id='msg_id').execute()

# Restore from trash
service.users().messages().untrash(userId='me', id='msg_id').execute()

# Permanent delete (bypasses trash)
service.users().messages().delete(userId='me', id='msg_id').execute()
```

**Trash behavior:**
- Messages auto-delete after 30 days
- `messages.trash` adds TRASH label and removes most other labels
- Can also manually modify: `addLabelIds: ['TRASH']`

### DRAFT Label

**❌ Cannot be manually applied or removed!**

```python
# This will FAIL with "400 Invalid label"
service.users().messages().modify(
    userId='me',
    id='msg_id',
    body={'addLabelIds': ['DRAFT']}  # ERROR!
).execute()
```

**DRAFT label is auto-managed:**
- Applied automatically when draft is created
- Removed automatically when draft is sent
- Draft messages cannot have any OTHER labels

### SENT Label

**❌ Cannot be manually applied or removed!**

```python
# This will FAIL with "400 Invalid label: SENT"
service.users().messages().modify(
    userId='me',
    id='msg_id',
    body={'removeLabelIds': ['SENT']}  # ERROR!
).execute()
```

**SENT label is auto-managed:**
- Applied automatically on `messages.send` or `drafts.send`
- Immutable once applied

### Label Operation Matrix

| System Label | Apply to Message | Remove from Message | Auto-Applied |
|-------------|:----------------:|:-------------------:|:------------:|
| INBOX | ✅ | ✅ | |
| UNREAD | ✅ | ✅ | |
| STARRED | ✅ | ✅ | |
| IMPORTANT | ✅ | ✅ | |
| SPAM | ✅ | ✅ | |
| TRASH | ✅ | ✅ | |
| CATEGORY_* | ✅ | ✅ | |
| SENT | ❌ | ❌ | ✅ on send |
| DRAFT | ❌ | ❌ | ✅ on draft create |
| SNOOZED | ✅ (label only) | ✅ | |

---

## 3. Creating Drafts as Thread Replies

**This is the correct way to create a draft that appears in Gmail Web UI as part of an existing conversation.**

### Requirements

1. **threadId** - Links draft to existing thread (sender-side)
2. **In-Reply-To header** - RFC 5322 Message-ID of email being replied to
3. **References header** - Chain of Message-IDs in conversation
4. **Subject** - Must include "Re: " prefix

### Step-by-Step Process

```python
import base64
from email.mime.text import MIMEText

def create_reply_draft(service, original_message_id, reply_body):
    """
    Create a draft that appears as a reply in Gmail Web UI.
    """
    # 1. Get the original message to extract headers
    original = service.users().messages().get(
        userId='me',
        id=original_message_id,
        format='full'
    ).execute()

    thread_id = original['threadId']
    headers = {h['name']: h['value'] for h in original['payload']['headers']}

    # 2. Extract the Message-ID header (NOT the Gmail message ID!)
    original_message_id_header = headers.get('Message-ID', '')
    # Format: "<abc123@mail.gmail.com>" (with angle brackets)

    # Get existing References chain if any
    existing_references = headers.get('References', '')

    # Build new References: existing chain + this message's ID
    if existing_references:
        new_references = f"{existing_references} {original_message_id_header}"
    else:
        new_references = original_message_id_header

    # 3. Get reply-to address
    reply_to = headers.get('Reply-To') or headers.get('From', '')

    # Original subject
    original_subject = headers.get('Subject', '')
    if not original_subject.lower().startswith('re:'):
        reply_subject = f"Re: {original_subject}"
    else:
        reply_subject = original_subject

    # 4. Create MIME message with threading headers
    message = MIMEText(reply_body, 'plain')
    message['To'] = reply_to
    message['Subject'] = reply_subject
    message['In-Reply-To'] = original_message_id_header
    message['References'] = new_references

    # 5. Encode as base64url (NOT standard base64!)
    raw = base64.urlsafe_b64encode(message.as_bytes()).decode('utf-8')

    # 6. Create draft with threadId
    draft = service.users().drafts().create(
        userId='me',
        body={
            'message': {
                'raw': raw,
                'threadId': thread_id  # Critical: links to thread
            }
        }
    ).execute()

    return draft
```

### Critical Distinctions

**Gmail `id` vs RFC `Message-ID`:**

```
Gmail API message.id:     "18d5abc123def456"     (internal identifier)
RFC Message-ID header:    "<abc123@mail.gmail.com>"  (use THIS for threading)
```

**Where to find Message-ID:**
```python
msg = service.users().messages().get(userId='me', id='msg_id', format='full').execute()
for header in msg['payload']['headers']:
    if header['name'] == 'Message-ID':
        message_id = header['value']  # "<abc123@mail.gmail.com>"
```

### Common Mistakes

| Mistake | Result |
|---------|--------|
| Using Gmail `id` instead of `Message-ID` header | Threading breaks for recipients |
| Missing angle brackets in Message-ID | RFC violation, Gmail may reject |
| Using standard base64 instead of base64url | API error |
| Omitting threadId | Draft won't be linked to thread in sender's view |
| Omitting In-Reply-To/References | Recipients see separate thread |
| Wrong Subject (no "Re:" prefix) | May break threading |

### Result in Gmail Web UI

After creating the draft correctly:

1. Open Gmail Web UI
2. Navigate to original thread
3. Draft appears at the bottom of the conversation
4. Shows "Draft" label
5. Click to continue editing
6. Send when ready - recipients see it as part of same thread

---

## 4. System Label Reference

### All System Labels

| Label ID | Purpose | User Can Modify? |
|----------|---------|:----------------:|
| `INBOX` | Messages in inbox | Apply/Remove ✅ |
| `SENT` | Sent messages | ❌ Auto-managed |
| `DRAFT` | Draft messages | ❌ Auto-managed |
| `TRASH` | Deleted messages | Apply/Remove ✅ |
| `SPAM` | Spam messages | Apply/Remove ✅ |
| `UNREAD` | Unread messages | Apply/Remove ✅ |
| `STARRED` | Starred messages | Apply/Remove ✅ |
| `IMPORTANT` | Important (ML-assigned) | Apply/Remove ✅ |
| `SNOOZED` | Snoozed messages | Apply only (no timing) |
| `CATEGORY_PERSONAL` | Primary tab | Apply/Remove ✅ |
| `CATEGORY_SOCIAL` | Social tab | Apply/Remove ✅ |
| `CATEGORY_PROMOTIONS` | Promotions tab | Apply/Remove ✅ |
| `CATEGORY_UPDATES` | Updates tab | Apply/Remove ✅ |
| `CATEGORY_FORUMS` | Forums tab | Apply/Remove ✅ |

---

## 5. API Scopes Required

| Operation | Minimum Scope |
|-----------|---------------|
| Read labels | `gmail.labels` |
| Modify labels | `gmail.labels` |
| Read messages | `gmail.readonly` |
| Modify messages | `gmail.modify` |
| Send messages | `gmail.send` |
| Full access | `mail.google.com` |

---

## See Also

* `ux-to-data-mapping.md` - UI to API mapping gotchas
* `visualizations.md` - Mermaid diagrams
* `identifiers.md` - Message ID and thread ID semantics
* `advanced-features.md` - Snooze, categories, send-as details

### Example Files

* `examples/label-operations.json` - Label CRUD, archive, trash operations
* `examples/labels-system-vs-user.json` - System vs user label comparison
* `examples/draft-reply-to-thread.json` - Creating draft as thread reply
* `examples/message-full.json` - Complete message structure
* `examples/thread-with-messages.json` - Thread with multiple messages
