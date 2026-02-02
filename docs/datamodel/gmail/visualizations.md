# Gmail API: Visual Documentation

Mermaid diagrams illustrating Gmail API concepts, label mechanics, and workflows.

## Label System Overview

```mermaid
mindmap
  root((Gmail Labels))
    System Labels
      Viewable
        INBOX
        SENT
        DRAFT
        TRASH
        SPAM
        STARRED
        UNREAD
        IMPORTANT
        SNOOZED
      Categories
        CATEGORY_PERSONAL
        CATEGORY_SOCIAL
        CATEGORY_PROMOTIONS
        CATEGORY_UPDATES
        CATEGORY_FORUMS
    User Labels
      Label_1 Work
      Label_2 Personal
      Label_N Custom
    Mutability
      Fully Mutable
        INBOX
        STARRED
        UNREAD
        TRASH
        SPAM
        IMPORTANT
        CATEGORY_*
      Auto-Managed
        SENT
        DRAFT
      Label Only
        SNOOZED
```

## Message Location via Labels

```mermaid
flowchart TD
    subgraph allmail["All Mail (Physical Storage)"]
        M1["Message 1"]
        M2["Message 2"]
        M3["Message 3"]
        M4["Message 4"]
        M5["Message 5"]
    end

    subgraph views["Views (Label Filters)"]
        INBOX["INBOX View"]
        SENT["SENT View"]
        TRASH["TRASH View"]
        STARRED["STARRED View"]
    end

    M1 -->|"has INBOX"| INBOX
    M2 -->|"has INBOX, STARRED"| INBOX
    M2 -->|"has INBOX, STARRED"| STARRED
    M3 -->|"has SENT"| SENT
    M4 -->|"has TRASH"| TRASH
    M5 -->|"no INBOX"| allmail

    style allmail fill:#f0f0f0
    style M5 fill:#ffcc00
```

## Archive Operation

```mermaid
sequenceDiagram
    participant User
    participant UI as Gmail UI
    participant API as Gmail API
    participant Msg as Message

    User->>UI: Click "Archive"
    UI->>API: messages.modify
    Note over API: removeLabelIds: ["INBOX"]
    API->>Msg: Remove INBOX label
    Msg-->>API: labelIds updated
    API-->>UI: Success
    UI-->>User: Message disappears from Inbox

    Note over Msg: Message still exists in All Mail!
    Note over Msg: labelIds: ["IMPORTANT", "Label_1"]
```

## Trash Operation

```mermaid
flowchart LR
    subgraph before["Before Trash"]
        B1["Message<br/>labelIds: [INBOX, STARRED, Label_1]"]
    end

    subgraph action["messages.trash()"]
        A1["Add TRASH<br/>Remove others"]
    end

    subgraph after["After Trash"]
        A2["Message<br/>labelIds: [TRASH]"]
    end

    subgraph timer["30 Days Later"]
        T1["Auto-deleted"]
    end

    B1 --> action --> A2 --> timer --> T1

    style B1 fill:#90EE90
    style A2 fill:#FFB6C1
    style T1 fill:#ff6b6b
```

## System Label Mutability

```mermaid
flowchart TD
    subgraph mutable["Fully Mutable (Apply/Remove OK)"]
        L1["INBOX"]
        L2["STARRED"]
        L3["UNREAD"]
        L4["IMPORTANT"]
        L5["TRASH"]
        L6["SPAM"]
        L7["CATEGORY_*"]
    end

    subgraph readonly["Auto-Managed (Cannot Modify)"]
        L8["SENT<br/>Applied on send"]
        L9["DRAFT<br/>Applied on draft create"]
    end

    subgraph partial["Partial (Label Only)"]
        L10["SNOOZED<br/>Can apply, but no timing API"]
    end

    style mutable fill:#90EE90
    style readonly fill:#FFB6C1
    style partial fill:#FFD700
```

## Draft as Thread Reply

```mermaid
sequenceDiagram
    participant Dev as Developer
    participant API as Gmail API
    participant DB as Gmail Storage

    Dev->>API: 1. messages.get(original_id, format=full)
    API-->>Dev: Message with payload.headers

    Note over Dev: Extract from headers:<br/>Message-ID: <abc@gmail.com><br/>Subject: "Project Update"

    Dev->>Dev: 2. Build MIME message
    Note over Dev: To: recipient<br/>Subject: Re: Project Update<br/>In-Reply-To: <abc@gmail.com><br/>References: <abc@gmail.com>

    Dev->>Dev: 3. Base64url encode

    Dev->>API: 4. drafts.create
    Note over API: body: {<br/>  message: {<br/>    raw: "...",<br/>    threadId: "thread_xyz"<br/>  }<br/>}

    API->>DB: Create draft with DRAFT label
    DB-->>API: Draft created
    API-->>Dev: draft_id, message_id

    Note over DB: Draft appears in thread<br/>in Gmail Web UI
```

## Message-ID vs Gmail ID

```mermaid
flowchart TB
    subgraph gmail["Gmail API Response"]
        G1["message.id = '18d5abc123def456'<br/>(Gmail internal ID)"]
        G2["message.threadId = 'thread_xyz'<br/>(Gmail thread ID)"]
    end

    subgraph headers["payload.headers[]"]
        H1["Message-ID: <abc123@mail.gmail.com><br/>(RFC 5322 identifier)"]
        H2["In-Reply-To: <parent@mail.gmail.com>"]
        H3["References: <gp@mail.gmail.com> <p@mail.gmail.com>"]
    end

    gmail --> headers

    subgraph usage["When to Use"]
        U1["Gmail ID → API calls<br/>messages.get(id='18d5abc...')"]
        U2["Message-ID header → Threading<br/>In-Reply-To: <abc123@mail...>"]
    end

    G1 --> U1
    H1 --> U2

    style G1 fill:#87CEEB
    style H1 fill:#90EE90
```

## Thread ID Is User-Specific

```mermaid
flowchart TB
    subgraph alice["Alice's Gmail"]
        A1["Message<br/>threadId: 'alice_thread_111'"]
    end

    subgraph bob["Bob's Gmail"]
        B1["Same Message!<br/>threadId: 'bob_thread_999'"]
    end

    subgraph correlation["Cross-Account Correlation"]
        C1["Use Message-ID header<br/>NOT Gmail threadId"]
    end

    alice -.->|"Different IDs!"| bob
    alice --> correlation
    bob --> correlation

    style A1 fill:#90EE90
    style B1 fill:#87CEEB
    style correlation fill:#FFD700
```

## Label Rename: ID Persists

```mermaid
flowchart LR
    subgraph before["Before Rename"]
        B1["Label<br/>id: 'Label_123'<br/>name: 'Work'"]
    end

    subgraph api["labels.patch"]
        A1["{name: 'Projects'}"]
    end

    subgraph after["After Rename"]
        A2["Label<br/>id: 'Label_123'<br/>name: 'Projects'"]
    end

    before --> api --> after

    style before fill:#FFB6C1
    style after fill:#90EE90
```

## Categories Tab System

```mermaid
flowchart TB
    subgraph inbox["Inbox"]
        subgraph tabs["Category Tabs"]
            T1["Primary<br/>CATEGORY_PERSONAL"]
            T2["Social<br/>CATEGORY_SOCIAL"]
            T3["Promotions<br/>CATEGORY_PROMOTIONS"]
            T4["Updates<br/>CATEGORY_UPDATES"]
            T5["Forums<br/>CATEGORY_FORUMS"]
        end
    end

    subgraph message["Message labelIds"]
        M1["['INBOX', 'CATEGORY_SOCIAL']"]
    end

    M1 --> T2

    style T2 fill:#87CEEB
```

## Draft Lifecycle

```mermaid
stateDiagram-v2
    [*] --> Created: drafts.create
    Created --> Updated: drafts.update
    Updated --> Updated: drafts.update
    Created --> Sent: drafts.send
    Updated --> Sent: drafts.send
    Created --> Deleted: drafts.delete
    Updated --> Deleted: drafts.delete
    Sent --> [*]
    Deleted --> [*]

    note right of Created
        DRAFT label applied
        Has draft_id AND message_id
    end note

    note right of Sent
        DRAFT removed
        SENT applied
        NEW message_id!
    end note
```

---

## See Also

* `api-capabilities.md` - Detailed feature documentation
* `ux-to-data-mapping.md` - UI to API mapping
* `identifiers.md` - ID semantics
