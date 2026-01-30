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
| Archive | `messages.modify` | Remove `INBOX` from labelIds |
| Delete | `messages.trash` | Add `TRASH`, remove other labels |
| Move to folder | `messages.modify` | Add label, optionally remove `INBOX` |
| Reply | `messages.send` | New message with same `threadId` |
| Forward | `messages.send` | New message, may have new `threadId` |
| Label | `messages.modify` | Add label to labelIds |

---

## See Also

* `identifiers.md` - Detailed ID semantics
* `gogcli-data-handling.md` - How gogcli handles these structures
* `../examples/` - Example API responses
