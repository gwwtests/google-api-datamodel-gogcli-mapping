# Calendar API: Visual Documentation

Mermaid diagrams illustrating Calendar API concepts, capabilities, and workflows.

## API Capabilities Mindmap

```mermaid
mindmap
  root((Calendar API))
    Attendees
      Add/Remove
      Modify Details
      Track Responses
        needsAction
        accepted
        declined
        tentative
      Optional/Required
    Guest Permissions
      guestsCanModify
        UI: Full sync
        API: Local only!
      guestsCanInviteOthers
      guestsCanSeeOtherGuests
    Video Conferencing
      Check Meet Link
        hangoutLink
        conferenceData
      Create Meet Link
        conferenceDataVersion=1
      Remove Meet Link
    Recording/Transcription
      Pre-configure
        Admin defaults
        2024+ feature
      Start/Stop
        NOT via API
      Access via Drive API
    Attachments
      NOT Supported
      Workarounds
        Description links
        extendedProperties
    Event Operations
      Create
      Update/Patch
      Delete
      Move
        events.move
        Changes organizer
      Duplicate
        Get + Insert
        Independent copy
```

## Feature Support Status

```mermaid
pie title API Feature Coverage
    "Full Support" : 60
    "Partial/Limited" : 25
    "Not Supported" : 15
```

## Event ID Relationships

```mermaid
flowchart TB
    subgraph org["Organizer's Calendar"]
        E1["Event ID: meeting_xyz<br/>iCalUID: meeting_xyz@google.com"]
    end

    subgraph att1["Attendee A's Calendar"]
        E2["Event ID: copy_abc_123<br/>iCalUID: meeting_xyz@google.com"]
    end

    subgraph att2["Attendee B's Calendar"]
        E3["Event ID: copy_def_456<br/>iCalUID: meeting_xyz@google.com"]
    end

    E1 -->|"Invitation"| E2
    E1 -->|"Invitation"| E3

    E2 -.->|"Same iCalUID"| E3

    style E1 fill:#90EE90
    style E2 fill:#87CEEB
    style E3 fill:#87CEEB
```

## Shared Calendar vs Invitation

```mermaid
flowchart LR
    subgraph scenario1["Scenario 1: Shared Calendar"]
        A1["Alice's Calendar<br/>Event ID: event_123"]
        B1["Bob views Alice's calendar"]
        A1 -->|"Same ID"| B1
    end

    subgraph scenario2["Scenario 2: Invitation"]
        A2["Alice's Event<br/>ID: alice_event_123"]
        B2["Bob's Copy<br/>ID: bob_event_456"]
        A2 -->|"Creates copy"| B2
    end

    style A1 fill:#90EE90
    style A2 fill:#90EE90
    style B2 fill:#FFB6C1
```

## Move vs Duplicate Operations

```mermaid
flowchart TD
    subgraph move["events.move"]
        M1["Source Calendar<br/>Event: abc123"] -->|"DELETE"| M2["(removed)"]
        M1 -->|"CREATE"| M3["Dest Calendar<br/>Event: abc123"]
        M3 --> M4["Organizer = Dest Owner"]
    end

    subgraph duplicate["get + insert"]
        D1["Source Calendar<br/>Event: abc123"] -->|"GET"| D2["Copy data"]
        D2 -->|"Remove id, etag, etc"| D3["Clean data"]
        D3 -->|"INSERT"| D4["Dest Calendar<br/>Event: xyz789"]
        D1 -->|"PRESERVED"| D5["Original unchanged"]
    end

    style M2 fill:#ff6b6b
    style M3 fill:#90EE90
    style D4 fill:#90EE90
    style D5 fill:#87CEEB
```

## Guest Modification Gotcha

```mermaid
sequenceDiagram
    participant Alice as Alice (Organizer)
    participant API as Calendar API
    participant Bob as Bob (Guest)
    participant UI as Calendar UI

    Note over Alice: Creates event with<br/>guestsCanModify: true

    rect rgb(255, 200, 200)
        Note over Bob,API: Via API - Local Only!
        Bob->>API: PATCH event "New Title"
        API->>Bob: 200 OK
        Note over Bob: Bob sees "New Title"
        Note over Alice: Alice still sees old title!
    end

    rect rgb(200, 255, 200)
        Note over Bob,UI: Via Calendar UI - Syncs!
        Bob->>UI: Edit event "New Title"
        UI->>Alice: Update synced
        Note over Alice: Alice sees "New Title"
    end
```

## Recurring Event Structure

```mermaid
flowchart TB
    Parent["Parent Event<br/>ID: weekly_standup<br/>RRULE: FREQ=WEEKLY;BYDAY=WE"]

    Parent --> I1["Instance Jan 29<br/>ID: weekly_standup_20250129T180000Z<br/>recurringEventId: weekly_standup"]
    Parent --> I2["Instance Feb 5<br/>ID: weekly_standup_20250205T180000Z<br/>recurringEventId: weekly_standup"]
    Parent --> I3["Exception Feb 12<br/>ID: weekly_standup_20250212T180000Z<br/>Modified: 11 AM instead of 10 AM"]
    Parent --> I4["...more instances"]

    style Parent fill:#FFD700
    style I3 fill:#FFA07A
```

## Conference Data Flow

```mermaid
flowchart LR
    subgraph create["Creating Meet Link"]
        C1["Event Body"] --> C2["conferenceData:<br/>createRequest:<br/>requestId: unique-123"]
        C2 --> C3["conferenceDataVersion=1"]
        C3 --> C4["events.insert"]
        C4 --> C5["Response includes<br/>hangoutLink"]
    end

    subgraph remove["Removing Meet Link"]
        R1["events.patch"] --> R2["conferenceData: null"]
        R2 --> R3["conferenceDataVersion=1"]
    end
```

## All-Day Event Date Math

```mermaid
flowchart LR
    subgraph ui["What User Sees"]
        U1["1-day event on Jan 28"]
        U2["3-day event Jan 28-30"]
    end

    subgraph api["What's in API"]
        A1["start: Jan 28<br/>end: Jan 29"]
        A2["start: Jan 28<br/>end: Jan 31"]
    end

    U1 --> A1
    U2 --> A2

    subgraph formula["Formula"]
        F1["days = end_date - start_date"]
        F2["end_date = start_date + days"]
    end
```

## Event Types and Operations

```mermaid
flowchart TD
    subgraph types["Event Types"]
        T1["Default Events"]
        T2["Birthday"]
        T3["Out of Office"]
        T4["Working Location"]
        T5["Focus Time"]
    end

    subgraph ops["Allowed Operations"]
        O1["Create ✅"]
        O2["Read ✅"]
        O3["Update ✅"]
        O4["Delete ✅"]
        O5["Move ✅"]
    end

    subgraph restricted["Restricted Operations"]
        R1["Create ❌"]
        R2["Move ❌"]
    end

    T1 --> O1 & O2 & O3 & O4 & O5
    T2 --> O2
    T2 --> R1 & R2
    T3 --> O1 & O2 & O3 & O4
    T3 --> R2
    T4 --> O1 & O2 & O3 & O4
    T4 --> R2
    T5 --> O1 & O2 & O3 & O4
    T5 --> R2

    style T1 fill:#90EE90
    style T2 fill:#FFB6C1
    style T3 fill:#87CEEB
    style T4 fill:#87CEEB
    style T5 fill:#87CEEB
```

## Calendar vs CalendarList

```mermaid
flowchart TB
    subgraph calendar["Calendar Resource"]
        C1["id: work@company.com"]
        C2["summary: Work Calendar"]
        C3["timeZone: America/New_York"]
        C4["(Shared properties)"]
    end

    subgraph alice["Alice's CalendarList Entry"]
        A1["id: work@company.com"]
        A2["backgroundColor: #00ff00"]
        A3["selected: true"]
        A4["defaultReminders: [...]"]
    end

    subgraph bob["Bob's CalendarList Entry"]
        B1["id: work@company.com"]
        B2["backgroundColor: #0000ff"]
        B3["selected: false"]
        B4["defaultReminders: [...]"]
    end

    calendar --> alice
    calendar --> bob

    style calendar fill:#FFD700
    style alice fill:#90EE90
    style bob fill:#87CEEB
```

## Recording/Transcription Availability

```mermaid
flowchart TD
    subgraph available["What's Available"]
        A1["Admin: Set org-wide defaults"]
        A2["Host: Pre-configure in Calendar UI"]
        A3["Drive API: Access completed recordings"]
    end

    subgraph notavailable["NOT Available via API"]
        N1["Per-event recording settings"]
        N2["Start/stop recording programmatically"]
        N3["Direct transcript access"]
    end

    subgraph requirements["Requirements"]
        R1["Workspace Business Standard+"]
        R2["OR Education Plus"]
        R3["OR Gemini add-on"]
    end

    style available fill:#90EE90
    style notavailable fill:#FFB6C1
    style requirements fill:#87CEEB
```

---

## See Also

* `api-capabilities.md` - Detailed feature documentation
* `ux-to-data-mapping.md` - UI to API mapping
* `identifiers.md` - ID semantics
