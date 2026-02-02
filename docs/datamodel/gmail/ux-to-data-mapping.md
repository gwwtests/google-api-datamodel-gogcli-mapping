# Gmail: UX to Data Mapping

How what users see in Gmail UI maps to the underlying API data structures.

## Counterintuitive and Confusing Cases

### 1. Messages vs Threads: The Conversation View Illusion

**What User Sees (UI)**:
```
┌─────────────────────────────────────────────────────────┐
│ ★ Project Update                              10:30 AM  │
│   Alice, Bob, You (3)                                   │
│   "Thanks for the update! I'll review..."               │
└─────────────────────────────────────────────────────────┘
```
User sees ONE item in inbox representing a "conversation".

**What's in the Data (API)**:
```json
{
  "id": "thread_abc123",           // Thread ID
  "historyId": "12345",
  "messages": [
    {
      "id": "msg_001",             // Message 1 has its OWN ID
      "threadId": "thread_abc123",
      "labelIds": ["INBOX", "UNREAD"],
      "internalDate": "1706540400000"
    },
    {
      "id": "msg_002",             // Message 2 has DIFFERENT ID
      "threadId": "thread_abc123",
      "labelIds": ["INBOX"],
      "internalDate": "1706544000000"
    },
    {
      "id": "msg_003",             // Message 3 has DIFFERENT ID
      "threadId": "thread_abc123",
      "labelIds": ["INBOX"],
      "internalDate": "1706547600000"
    }
  ]
}
```

**⚠️ Counterintuitive Aspects**:
- Each message in a thread has its **own unique ID**
- Labels are on **messages**, not threads
- "Unread" badge on thread = at least one message has `UNREAD` label
- Archiving a thread = removing `INBOX` label from ALL messages
- Thread snippet comes from the **most recent** message

**Practical Implication**:
```
To mark a "conversation" as read:
  ✗ WRONG: Modify the thread
  ✓ RIGHT: Modify EACH message in thread to remove UNREAD label
```

---

### 2. Labels Are NOT Folders

**What User Sees (UI)**:
```
┌──────────────┐
│ □ Inbox      │  ← Looks like a folder
│ □ Starred    │  ← Looks like a folder
│ □ Work       │  ← User-created "folder"
│ □ Personal   │  ← User-created "folder"
└──────────────┘
```
Gmail UI presents labels as if they were folders.

**What's in the Data (API)**:
```json
{
  "id": "msg_abc123",
  "labelIds": [
    "INBOX",           // System label
    "STARRED",         // System label
    "Label_1",         // User label "Work"
    "Label_2"          // User label "Personal"
  ]
}
```

**⚠️ Counterintuitive Aspects**:
- A message can have MULTIPLE labels (not possible with folders!)
- Moving to "folder" = adding label + removing INBOX
- System labels like `INBOX`, `SENT` are just labels
- The same message appears in multiple "folders" in UI

**Example - Archive Operation**:
```
User clicks "Archive" on a message

What UI shows: Message disappears from Inbox
What happens in API:

BEFORE: labelIds = ["INBOX", "IMPORTANT", "Label_1"]
AFTER:  labelIds = ["IMPORTANT", "Label_1"]

Message still exists! Just removed from INBOX view.
```

---

### 3. Draft Messages: Hidden Complexity

**What User Sees (UI)**:
```
┌─────────────────────────────────────────┐
│ Drafts (1)                              │
│   Subject: Meeting notes                │
│   Last edited: 2 min ago                │
└─────────────────────────────────────────┘
```

**What's in the Data (API)**:
```json
{
  "id": "draft_xyz789",           // Draft ID (different from message ID!)
  "message": {
    "id": "msg_draft_abc",        // Message ID
    "threadId": "thread_123",     // May be part of existing thread
    "labelIds": ["DRAFT"],
    "payload": { ... }
  }
}
```

**⚠️ Counterintuitive Aspects**:
- Drafts have TWO IDs: draft ID and message ID
- Draft message has `DRAFT` label
- Editing draft = creating NEW message, deleting old
- If replying, draft has `threadId` of original thread
- Sending draft = message loses `DRAFT` label, gains `SENT`

---

### 4. The "From" Field Deception

**What User Sees (UI)**:
```
From: Alice Smith <alice@company.com>
```

**What's in the Data (API)**:
```json
{
  "payload": {
    "headers": [
      {
        "name": "From",
        "value": "\"Alice Smith\" <alice@company.com>"
      },
      {
        "name": "Sender",                           // May differ!
        "value": "sendgrid@marketing.com"
      },
      {
        "name": "X-Google-Original-From",           // The real sender
        "value": "marketing-system@company.com"
      }
    ]
  }
}
```

**⚠️ Counterintuitive Aspects**:
- `From` header can be spoofed
- `Sender` header may reveal actual sending service
- Gmail may modify/add headers
- API message ID ≠ RFC 2822 `Message-ID` header

---

### 5. Thread Grouping: Not What You Expect

**What User Thinks**:
"Replies to an email are in the same thread"

**What Actually Happens**:
Threading is based on:
1. `threadId` (if specified when sending via API)
2. RFC 2822 `In-Reply-To` header
3. RFC 2822 `References` header
4. **Subject line matching** (can cause unrelated emails to group!)

**Example of Incorrect Grouping**:
```
Thread: "Meeting Tomorrow"
  ├── Alice: "Can we meet tomorrow?"
  ├── Bob: "Sure, 10am works"
  └── Carol: "Meeting Tomorrow" (UNRELATED email with same subject!)
        ↑ Grouped because subject matches!
```

**Example of Thread Not Forming**:
```
Email 1: "Project X Update" (threadId: abc)
Email 2: Reply with modified subject "Re: Project X Update - URGENT"
         ↑ May create NEW thread if headers don't link properly!
```

---

### 6. Timestamps: Three Different Times

**What User Sees (UI)**:
```
Jan 29, 2025, 10:30 AM
```

**What's in the Data (API)**:
```json
{
  "internalDate": "1706547000000",     // When Google received it
  "payload": {
    "headers": [
      {
        "name": "Date",                 // What sender claimed
        "value": "Wed, 29 Jan 2025 15:30:00 -0500"
      },
      {
        "name": "Received",             // Actual receipt chain
        "value": "from mail.example.com... Wed, 29 Jan 2025 15:31:02 -0500"
      }
    ]
  }
}
```

**⚠️ Counterintuitive Aspects**:
- `internalDate` = epoch milliseconds (UTC), when Google accepted
- `Date` header = what sender's mail client claimed (can be wrong!)
- Gmail sorts by `internalDate`, not `Date` header
- UI shows local timezone, API stores UTC epoch

**Time Confusion Example**:
```
Sender in Tokyo sends email at 10:00 AM JST (Jan 30)
Receiver in NYC sees it at 8:00 PM EST (Jan 29)
internalDate = 1706666400000 (epoch, no timezone)
Date header = "Thu, 30 Jan 2025 10:00:00 +0900"
```

---

### 7. Multi-Account: The ID Collision Risk

**What User Might Assume**:
"Message IDs are unique, I can use them as database keys"

**What's Actually True**:
```
Account: alice@gmail.com
  Message ID: "18d5abc123def456"

Account: bob@gmail.com
  Message ID: "18d5abc123def456"  ← COULD be same! (unconfirmed)
```

**⚠️ Critical Issue**:
- Official docs don't specify if IDs are globally unique
- Same ID could theoretically exist in different accounts
- **ALWAYS use composite key: (userId, messageId)**

---

### 8. Thread IDs Are USER-SPECIFIC (Critical!)

**What User Might Assume**:
"If Alice and Bob are in the same email thread, they share the same thread ID"

**What's Actually True**:
```
Alice sends email to Bob about "Project Update"

Alice's account:
  threadId: "18d5abc111111111"

Bob's account (same conversation!):
  threadId: "18d5xyz999999999"  ← DIFFERENT thread ID!
```

**⚠️ Critical Discovery** (from community research):
- Thread IDs are **user-specific**, NOT conversation-universal
- Same email thread has **different IDs** for sender vs recipient
- `gmail.users.threads.get(alice_thread_id)` from Bob's account → 404 NOT FOUND

**Cross-Account Correlation**:
- Use SMTP `Message-ID` header (RFC 5322), not Gmail `threadId`
- `In-Reply-To` and `References` headers link across accounts
- Thread ID encodes timestamp (first 11 hex digits) + sequence (last 5)

---

### 9. Categories and Tabs: Hidden Label System

**What User Sees (UI)**:
```
┌─────────────────────────────────────────────────────────────┐
│  Primary  │  Social  │  Promotions  │  Updates  │  Forums  │
└─────────────────────────────────────────────────────────────┘
```
User sees "tabs" that look like separate inboxes.

**What's in the Data (API)**:
```json
{
  "id": "msg_newsletter_123",
  "labelIds": [
    "INBOX",
    "CATEGORY_PROMOTIONS"    // ← This is what makes it appear in Promotions tab
  ]
}
```

**System Labels for Categories**:
| Tab | Label ID |
|-----|----------|
| Primary | `CATEGORY_PERSONAL` |
| Social | `CATEGORY_SOCIAL` |
| Promotions | `CATEGORY_PROMOTIONS` |
| Updates | `CATEGORY_UPDATES` |
| Forums | `CATEGORY_FORUMS` |

**⚠️ Counterintuitive Aspects**:
- Categories are just system labels, not separate mailboxes
- Message can only be in ONE category at a time
- Gmail ML automatically assigns category on delivery
- You CAN move messages between categories via label modification

---

### 10. Priority Inbox and "Important" Markers

**What User Sees (UI)**:
```
┌─────────────────────────────────────────────────────────────┐
│ ▶ Important and unread                                      │
│   ★ [Important email from boss]                            │
├─────────────────────────────────────────────────────────────┤
│ ▶ Everything else                                           │
│   [Newsletter]                                              │
└─────────────────────────────────────────────────────────────┘
```

**What's in the Data (API)**:
```json
{
  "id": "msg_from_boss",
  "labelIds": [
    "INBOX",
    "IMPORTANT"              // ← ML-assigned importance marker
  ]
}
```

**How Gmail Determines "Important"**:
- Machine learning algorithm (~80% accuracy reported)
- Factors: sender relationship, engagement history, keywords
- Users can train by marking important/not important

**⚠️ Counterintuitive Aspects**:
- `IMPORTANT` is a system label, not user-created
- ML assignment happens on delivery (can't control via API on send)
- Manual override = adding/removing `IMPORTANT` label

---

### 11. Snooze: The Missing API Feature

**What User Sees (UI)**:
```
┌─────────────────────────────────────────────┐
│ Snooze until...                             │
│   ○ Later today                             │
│   ○ Tomorrow                                │
│   ○ This weekend                            │
│   ○ Next week                               │
│   ○ Pick date & time                        │
└─────────────────────────────────────────────┘
```

**What's in the Data (API)**:
```json
{
  "id": "msg_snoozed_123",
  "labelIds": [
    "SNOOZED"                // ← Label exists, but...
  ]
  // NO snooze time information!
  // NO way to set snooze via API!
}
```

**⚠️ API Limitation**:
- `SNOOZED` label indicates message is snoozed
- **NO API access to snooze time**
- **NO API method to snooze a message**
- Feature requests #109952618 and #287304309 are BLOCKED

**Workaround** (third-party apps):
- Custom labels + external scheduler
- NOT compatible with Gmail's native snooze

---

### 12. Send As: Multiple Sender Addresses

**What User Sees (UI)**:
```
From: [dropdown menu]
  ├── alice@company.com (default)
  ├── alice@personal.com
  └── team@company.com
```

**What's in the Data (API)**:

```json
// GET users.settings.sendAs.list
{
  "sendAs": [
    {
      "sendAsEmail": "alice@company.com",
      "displayName": "Alice Smith",
      "isPrimary": true,
      "isDefault": true
    },
    {
      "sendAsEmail": "alice@personal.com",
      "displayName": "Alice",
      "replyToAddress": "alice@company.com",
      "verificationStatus": "accepted"
    }
  ]
}
```

**⚠️ Key Concepts**:
- Full API support via `users.settings.sendAs`
- `isPrimary` = the Gmail account's email (cannot change)
- `isDefault` = which address is pre-selected for new emails
- `verificationStatus` = "accepted" for verified addresses
- Can configure custom SMTP for external domains

---

### 13. Draft Lifecycle: ID Transformation

**What User Expects**:
"Draft ID stays the same when I send it"

**What Actually Happens**:
```
BEFORE SEND:
  Draft ID: "r1234567890"
  Message ID: "m9876543210"

AFTER drafts.send():
  Draft: DELETED
  New Message ID: "m_COMPLETELY_DIFFERENT"  ← New ID!
```

**⚠️ Critical for Tracking**:
- Cannot track draft→sent via message ID (changes!)
- Use `threadId` for correlation
- Or add custom header before sending

**Temporary ID Trap**:
- Inline reply creates temporary message ID
- API returns 404 for temporary ID
- Real ID appears after brief delay

---

### 14. Threading Requires SMTP Headers for Recipients

**What Developer Expects**:
"Setting `threadId` in API will thread the email for everyone"

**What Actually Happens**:
```
Developer sends via API with threadId: "abc123"

Sender's mailbox: ✓ Message appears in thread abc123
Recipient's mailbox: ✗ Message appears as NEW thread!
```

**Why**: `threadId` only affects sender's view. Recipients need SMTP headers.

**Required Headers for Recipient-Side Threading**:
```
In-Reply-To: <original-message-id@domain.com>
References: <grandparent@domain> <parent@domain>
Subject: Re: Original Subject
```

**Common Mistakes**:
- Using Gmail API `message.id` instead of `Message-ID` header value
- Missing angle brackets: `msg-id@domain` vs `<msg-id@domain>`
- Incomplete `References` chain

---

## Entity Relationship Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                         USER                                │
│  (identified by email, e.g., user@gmail.com)               │
└─────────────────────────────────────────────────────────────┘
           │
           │ has many
           ▼
┌─────────────────────────────────────────────────────────────┐
│                        LABEL                                │
│  id: string (e.g., "INBOX", "Label_123")                   │
│  name: string                                               │
│  type: "system" | "user"                                    │
│  ─────────────────────────────────────                      │
│  Max 10,000 per user                                        │
└─────────────────────────────────────────────────────────────┘
           │
           │ applied to (many-to-many)
           ▼
┌─────────────────────────────────────────────────────────────┐
│                       MESSAGE                               │
│  id: string (immutable, unique within user? TBD)           │
│  threadId: string                                           │
│  labelIds: string[]                                         │
│  internalDate: string (epoch ms)                           │
│  historyId: string                                          │
│  ─────────────────────────────────────                      │
│  Labels are on MESSAGES, not threads                        │
└─────────────────────────────────────────────────────────────┘
           │
           │ belongs to
           ▼
┌─────────────────────────────────────────────────────────────┐
│                        THREAD                               │
│  id: string (unique within user? TBD)                      │
│  messages: Message[]                                        │
│  historyId: string                                          │
│  ─────────────────────────────────────                      │
│  Thread is a VIEW, not a container                          │
│  Thread ID = first message's ID (typically)                │
└─────────────────────────────────────────────────────────────┘
```

---

## Quick Reference: UI Action → API Operation

| UI Action | API Operation | What Changes |
|-----------|---------------|--------------|
| Open email | `messages.get` | Nothing (read only) |
| Mark as read | `messages.modify` | Remove `UNREAD` from labelIds |
| Star | `messages.modify` | Add `STARRED` to labelIds |
| Mark important | `messages.modify` | Add `IMPORTANT` to labelIds |
| Archive | `messages.modify` | Remove `INBOX` from labelIds |
| Delete | `messages.trash` | Add `TRASH`, remove other labels |
| Move to folder | `messages.modify` | Add label, optionally remove `INBOX` |
| Move to category | `messages.modify` | Remove old `CATEGORY_*`, add new one |
| Reply | `messages.send` | New message with same `threadId` + headers |
| Forward | `messages.send` | New message, may have new `threadId` |
| Label | `messages.modify` | Add label to labelIds |
| Snooze | ❌ NO API | Cannot snooze via API |
| Schedule send | ❌ NO API | Cannot schedule via API |
| Send as alias | `messages.send` + header | Set `From` header to alias address |

## Features Without API Support

| Feature | API Status | Workaround |
|---------|------------|------------|
| Snooze | SNOOZED label only, no timing | External scheduler + custom labels |
| Scheduled Send | No support | External scheduler + drafts.send |
| Confidential Mode | No support | None (use CSE for encryption) |

---

### 15. System Label Mechanics: The Real "Folder" System

**What User Sees (UI)**:
```
┌─────────────────────────┐
│ ✉ Inbox           (12)  │
│ ★ Starred              │
│ ⏰ Snoozed              │
│ 📤 Sent                 │
│ 📝 Drafts          (2)  │
│ 🗑 Trash                │
│ ⚠ Spam                 │
└─────────────────────────┘
```
Looks like folders. But...

**What's in the Data (API)**:

These are ALL implemented as system labels:

| UI "Folder" | System Label | Can Manually Apply? | Can Manually Remove? |
|-------------|--------------|:-------------------:|:--------------------:|
| Inbox | `INBOX` | ✅ | ✅ (= archive) |
| Starred | `STARRED` | ✅ | ✅ |
| Snoozed | `SNOOZED` | ✅ (label only) | ✅ |
| Sent | `SENT` | ❌ Auto-managed | ❌ |
| Drafts | `DRAFT` | ❌ Auto-managed | ❌ |
| Trash | `TRASH` | ✅ | ✅ |
| Spam | `SPAM` | ✅ | ✅ |

**⚠️ Critical Discovery**: SENT and DRAFT labels are FULLY AUTO-MANAGED

```python
# THIS FAILS with "400 Invalid label"
service.users().messages().modify(
    userId='me',
    id='msg_id',
    body={'addLabelIds': ['DRAFT']}  # ERROR!
)

# THIS ALSO FAILS
service.users().messages().modify(
    userId='me',
    id='msg_id',
    body={'removeLabelIds': ['SENT']}  # ERROR!
)
```

**Archive = Remove INBOX label**:
```python
# Archive message (remove from inbox, keep in All Mail)
service.users().messages().modify(
    userId='me',
    id='msg_id',
    body={'removeLabelIds': ['INBOX']}
)

# Unarchive (bring back to inbox)
service.users().messages().modify(
    userId='me',
    id='msg_id',
    body={'addLabelIds': ['INBOX']}
)
```

---

### 16. Creating a Draft Reply (Thread Continuation)

**What User Wants**:
"Create a draft that appears as a reply to an existing conversation, so I can review it in Gmail UI before sending"

**What's Required**:

1. **threadId** - Links draft to thread (for sender's view)
2. **In-Reply-To header** - RFC Message-ID of message being replied to
3. **References header** - Chain of Message-IDs in conversation
4. **Subject with "Re:" prefix** - Maintains thread grouping

```
⚠️ CRITICAL DISTINCTION:

Gmail API message.id:     "18d5abc123def456"
  → Internal identifier, DO NOT use for threading

RFC Message-ID header:    "<abc123@mail.gmail.com>"
  → Found in payload.headers, USE THIS for In-Reply-To
```

**Correct Draft Reply Structure**:

```
MIME Headers:
  To: recipient@example.com
  Subject: Re: Original Subject
  In-Reply-To: <original-message-id@mail.gmail.com>
  References: <grandparent@mail.gmail.com> <parent@mail.gmail.com>

API Request:
  POST /users/me/drafts
  {
    "message": {
      "raw": "<base64url-encoded-mime-message>",
      "threadId": "thread_abc123"
    }
  }
```

**Result in Gmail Web UI**:
- Draft appears at bottom of conversation thread
- Shows "Draft" chip/label
- Click to edit before sending
- Recipients see it as proper thread continuation

---

### 17. Label Renaming: ID Stays, Name Changes

**What User Sees (UI)**:
```
Settings → Labels → Edit "Work" → Rename to "Projects"
```
Label appears renamed everywhere.

**What's in the Data (API)**:

```json
// BEFORE rename
{
  "id": "Label_123",      // ← This NEVER changes
  "name": "Work",
  "type": "user"
}

// AFTER rename via labels.patch
{
  "id": "Label_123",      // ← Same ID!
  "name": "Projects",     // ← Only name changed
  "type": "user"
}
```

**Rename via API**:
```python
service.users().labels().patch(
    userId='me',
    id='Label_123',
    body={'name': 'Projects'}
).execute()
```

**⚠️ Implication for Data Storage**:
- Store label by `id`, not `name`
- Names can change, IDs are permanent
- Messages keep `labelIds` array - these are IDs, not names

---

## See Also

* `api-capabilities.md` - Feature matrix and label management details
* `visualizations.md` - Mermaid diagrams for visual understanding
* `identifiers.md` - Detailed ID semantics
* `gogcli-data-handling.md` - How gogcli handles these structures
* `advanced-features.md` - Snooze, categories, send-as details
* `../examples/` - Example API responses
* `../examples/draft-reply-to-thread.json` - Draft threading example
