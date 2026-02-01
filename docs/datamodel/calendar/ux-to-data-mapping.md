# Calendar: UX to Data Mapping

How what users see in Google Calendar UI maps to the underlying API data structures.

## Counterintuitive and Confusing Cases

### 1. All-Day Events: The Phantom Extra Day

**What User Sees (UI)**:
```
┌─────────────────────────────────────────┐
│ January 2025                            │
│ ┌─────┬─────┬─────┬─────┬─────┐        │
│ │ 27  │ 28  │ 29  │ 30  │ 31  │        │
│ │     │█████│█████│     │     │        │
│ │     │ Vacation      │     │        │
│ └─────┴─────┴─────┴─────┴─────┘        │
└─────────────────────────────────────────┘
```
User creates "Vacation" for Jan 28-29 (2 days).

**What's in the Data (API)**:
```json
{
  "summary": "Vacation",
  "start": {
    "date": "2025-01-28"
  },
  "end": {
    "date": "2025-01-30"    // ⚠️ Jan 30, not Jan 29!
  }
}
```

**⚠️ Counterintuitive Aspect**:
- End date is **EXCLUSIVE** (event ends BEFORE this date)
- 2-day event: `start: Jan 28`, `end: Jan 30` (not Jan 29!)
- 1-day event: `start: Jan 28`, `end: Jan 29`

**Common Bug**:
```python
# WRONG: This creates 0-day event (invisible!)
{
  "start": {"date": "2025-01-28"},
  "end": {"date": "2025-01-28"}    # Same date = nothing!
}

# RIGHT: Single day event
{
  "start": {"date": "2025-01-28"},
  "end": {"date": "2025-01-29"}    # Next day
}
```

---

### 2. Timezone Confusion: Three Different Times

**What User Sees (UI)**:
```
┌─────────────────────────────────────────┐
│ Team Meeting                            │
│ 3:00 PM - 4:00 PM                       │
│ Pacific Time                            │
└─────────────────────────────────────────┘
```

**What's in the Data (API)** - Multiple valid representations:
```json
// Option 1: Offset in dateTime
{
  "start": {
    "dateTime": "2025-01-29T15:00:00-08:00"
  }
}

// Option 2: Explicit timeZone
{
  "start": {
    "dateTime": "2025-01-29T15:00:00",
    "timeZone": "America/Los_Angeles"
  }
}

// Option 3: UTC with offset
{
  "start": {
    "dateTime": "2025-01-29T23:00:00Z"    // 3 PM Pacific = 11 PM UTC
  }
}
```

**⚠️ Counterintuitive Aspects**:
- Same logical time has 3+ valid representations
- `timeZone` field uses IANA names, not abbreviations
- `PST`/`PDT` are NOT valid - must use `America/Los_Angeles`
- All-day events: `timeZone` field is **IGNORED**

**DST Trap for Recurring Events**:
```json
// Weekly meeting at 3 PM Pacific
{
  "start": {
    "dateTime": "2025-01-29T15:00:00-08:00",
    "timeZone": "America/Los_Angeles"    // REQUIRED for recurring!
  },
  "recurrence": ["RRULE:FREQ=WEEKLY;BYDAY=WE"]
}
```

Without `timeZone`, after DST change:
- User expects: 3:00 PM Pacific
- They might get: 2:00 PM or 4:00 PM (offset drift!)

---

### 3. Recurring Events: One Event or Many?

**What User Sees (UI)**:
```
┌─────────────────────────────────────────┐
│ Weekly Standup (recurring)              │
│ Every Wednesday at 10:00 AM             │
│ ─────────────────────────────           │
│ ○ Edit this event                       │
│ ○ Edit this and following events        │
│ ○ Edit all events                       │
└─────────────────────────────────────────┘
```
User sees it as ONE recurring event.

**What's in the Data (API)**:
```json
// The "parent" recurring event
{
  "id": "abc123",
  "summary": "Weekly Standup",
  "recurrence": ["RRULE:FREQ=WEEKLY;BYDAY=WE"],
  "start": {
    "dateTime": "2025-01-29T10:00:00-08:00",
    "timeZone": "America/Los_Angeles"
  }
}

// Each instance is a SEPARATE event!
// Instance for Jan 29:
{
  "id": "abc123_20250129T180000Z",    // Different ID!
  "recurringEventId": "abc123",        // Points to parent
  "originalStartTime": {
    "dateTime": "2025-01-29T10:00:00-08:00",
    "timeZone": "America/Los_Angeles"
  }
}

// Instance for Feb 5:
{
  "id": "abc123_20250205T180000Z",    // Different ID again!
  "recurringEventId": "abc123",
  "originalStartTime": {
    "dateTime": "2025-02-05T10:00:00-08:00"
  }
}
```

**⚠️ Counterintuitive Aspects**:
- Recurring event has ONE `id`
- Each instance has a DIFFERENT `id` (includes timestamp)
- Modifying one instance creates an "exception"
- `events.list` returns instances, not the parent
- Use `events.instances(parentId)` to expand

**Exception (Modified Instance)**:
```json
// User moved the Feb 5 meeting to 11 AM
{
  "id": "abc123_20250205T180000Z",
  "recurringEventId": "abc123",
  "originalStartTime": {
    "dateTime": "2025-02-05T10:00:00-08:00"    // Original time
  },
  "start": {
    "dateTime": "2025-02-05T11:00:00-08:00"    // New time!
  }
}
```

---

### 4. Meeting Invitations: Multiple Copies

**What User Sees (UI)**:
```
Organizer (Alice): Creates meeting, invites Bob
Bob: Sees meeting appear on his calendar
```
User thinks: "Same event on both calendars"

**What's in the Data (API)**:

```json
// On Alice's calendar (organizer)
{
  "id": "meeting_xyz",
  "calendarId": "alice@company.com",
  "organizer": {
    "email": "alice@company.com",
    "self": true
  },
  "attendees": [
    {"email": "alice@company.com", "responseStatus": "accepted"},
    {"email": "bob@company.com", "responseStatus": "needsAction"}
  ]
}

// On Bob's calendar (attendee) - DIFFERENT EVENT!
{
  "id": "bob_copy_abc",           // ⚠️ DIFFERENT event ID!
  "calendarId": "bob@company.com",
  "organizer": {
    "email": "alice@company.com"   // Still shows Alice
  },
  "attendees": [
    {"email": "alice@company.com", "responseStatus": "accepted"},
    {"email": "bob@company.com", "responseStatus": "needsAction", "self": true}
  ]
}
```

**⚠️ Counterintuitive Aspects**:
- Organizer and attendee have DIFFERENT event IDs
- Same meeting = different events on different calendars
- Use `iCalUID` to correlate same meeting across calendars
- Attendee's copy is on their PRIMARY calendar (not shared)

**To Find Same Meeting Across Accounts**:
```json
// Both events share the same iCalUID
{
  "iCalUID": "meeting_xyz@google.com"   // Same on both!
}
```

---

### 5. Shared Calendars vs Meeting Invitations

**What User Sees (UI)**:
```
Two ways to share an event:
1. Share a calendar with someone (they see all events)
2. Invite someone to a specific event (they get a copy)
```

**Shared Calendar** (Same Event ID):
```json
// Alice's calendar shared with Bob
// BOTH see the SAME event with SAME ID

// Alice queries:
GET /calendars/alice@company.com/events/event_123
{
  "id": "event_123",
  "calendarId": "alice@company.com"
}

// Bob queries the SAME calendar:
GET /calendars/alice@company.com/events/event_123
{
  "id": "event_123",                // Same ID!
  "calendarId": "alice@company.com"  // Same calendar!
}
```

**Meeting Invitation** (Different Event IDs):
```json
// Alice invites Bob - Bob gets COPY on HIS calendar

// Alice's event:
{
  "id": "alice_event_123",
  "calendarId": "alice@company.com"
}

// Bob's copy:
{
  "id": "bob_event_456",            // Different ID!
  "calendarId": "bob@company.com"   // Different calendar!
}
```

---

### 6. Calendar vs CalendarList: The Confusion

**What User Sees (UI)**:
```
My calendars:
  ☑ Personal (blue)
  ☑ Work (green)
  ☐ Holidays (hidden)
```

**What's in the Data (API)**:

Two completely different resources!

```json
// CALENDAR resource (global properties)
GET /calendars/work@company.com
{
  "id": "work@company.com",
  "summary": "Work Calendar",
  "timeZone": "America/New_York"    // Calendar's timezone
}

// CALENDARLIST resource (user-specific view)
GET /users/me/calendarList/work@company.com
{
  "id": "work@company.com",
  "summary": "Work Calendar",
  "backgroundColor": "#00ff00",      // User's color choice
  "selected": true,                  // Show/hide toggle
  "defaultReminders": [...]          // User's reminders
}
```

**⚠️ Counterintuitive Aspects**:
- `Calendar` = shared metadata (title, timezone)
- `CalendarList` = per-user settings (color, visibility, reminders)
- Same calendar appears differently in each user's CalendarList
- Sharing calendar ≠ auto-adding to CalendarList

---

### 7. Event End Times: Exclusive Boundary

**What User Sees (UI)**:
```
Meeting: 2:00 PM - 3:00 PM
```

**What's in the Data (API)**:
```json
{
  "start": {"dateTime": "2025-01-29T14:00:00-08:00"},
  "end": {"dateTime": "2025-01-29T15:00:00-08:00"}
}
```

**⚠️ Counterintuitive Aspect**:
- End time is **EXCLUSIVE** (meeting ends AT 3:00 PM, not before)
- Duration = end - start = 1 hour (correct!)
- No overlap: Event 2-3 PM and Event 3-4 PM don't conflict

**All-Day Event Duration**:
```json
// 1-day event (Jan 29)
{
  "start": {"date": "2025-01-29"},
  "end": {"date": "2025-01-30"}     // Next day!
}

// 3-day event (Jan 29-31)
{
  "start": {"date": "2025-01-29"},
  "end": {"date": "2025-02-01"}     // Feb 1!
}
```

---

### 8. Guest Permissions: UI vs API Behavior Mismatch

**What User Sees (UI)**:
```
Event Settings:
  ☑ Guests can modify event
  ☑ Guests can invite others
  ☑ Guests can see other guests
```
User enables "Guests can modify event" → expects guests can edit the event.

**What's in the Data (API)**:
```json
{
  "summary": "Team Meeting",
  "guestsCanModify": true,
  "guestsCanInviteOthers": true,
  "guestsCanSeeOtherGuests": true
}
```

**⚠️ Counterintuitive Aspect - API vs UI Asymmetry**:

| Action | Result |
|--------|--------|
| Guest edits via **Calendar UI** | Changes sync to organizer and all attendees ✅ |
| Guest edits via **API** | Changes only affect guest's LOCAL copy! ❌ |

```python
# Bob (guest) tries to modify via API:
event = service.events().get(calendarId='bob@example.com', eventId='bobs_copy').execute()
event['summary'] = 'Updated Title'
service.events().update(calendarId='bob@example.com', eventId='bobs_copy', body=event).execute()

# Result:
# - Bob sees: "Updated Title"
# - Alice (organizer) sees: Original title (unchanged!)
# - Carol (other attendee) sees: Original title (unchanged!)
```

This is a known limitation. The `guestsCanModify` flag is fully functional in the Calendar UI, but API calls by guests only modify their local copy.

---

### 9. Moving Events: Organizer Changes

**What User Sees (UI)**:
```
Right-click event → Move to calendar → Select "Team Calendar"
```
User moves event from personal calendar to team calendar.

**What's in the Data (API)**:
```python
# events.move method
moved_event = service.events().move(
    calendarId='alice@example.com',       # Source
    eventId='meeting_123',
    destination='team@example.com'        # Destination
).execute()
```

**⚠️ Counterintuitive Aspects**:

1. **Organizer Changes**: After move, the destination calendar's owner becomes the new organizer
2. **Event Disappears from Source**: Not a copy - original is deleted
3. **Event ID May Change**: Don't rely on ID staying the same
4. **Not All Events Can Move**:

| Event Type | Movable? |
|------------|----------|
| Default events | ✅ Yes |
| Birthday events | ❌ No |
| Out of Office | ❌ No |
| Working Location | ❌ No |
| Focus Time | ❌ No |

---

### 10. Copying Events: No Native Support

**What User Sees (UI)**:
```
In Calendar UI (or most apps):
  Ctrl+C → Ctrl+V  or  "Duplicate" option
```
User expects a simple copy operation.

**What's in the Data (API)**:
```python
# NO events.copy endpoint exists!
# Must do: GET → clean fields → INSERT

# 1. Get original
event = service.events().get(calendarId='source@example.com', eventId='abc123').execute()

# 2. Remove system-managed fields
for field in ['id', 'etag', 'created', 'updated', 'htmlLink', 'iCalUID', 'creator', 'organizer']:
    event.pop(field, None)

# 3. Insert as new event
new_event = service.events().insert(calendarId='dest@example.com', body=event).execute()
```

**⚠️ Counterintuitive Aspects**:

* **New iCalUID**: Copy gets entirely new identifier (can't correlate with original)
* **No Sync**: Changes to original don't affect copy (and vice versa)
* **Must Remove Fields**: System fields will cause errors if included

---

### 11. Video Conferencing: Meet Link Lifecycle

**What User Sees (UI)**:
```
☑ Add Google Meet video conferencing
  → Link appears: meet.google.com/abc-defg-hij
```

**What's in the Data (API)**:

```json
{
  "hangoutLink": "https://meet.google.com/abc-defg-hij",
  "conferenceData": {
    "entryPoints": [
      {
        "entryPointType": "video",
        "uri": "https://meet.google.com/abc-defg-hij"
      },
      {
        "entryPointType": "phone",
        "uri": "tel:+1-555-123-4567",
        "pin": "123456789"
      }
    ],
    "conferenceSolution": {
      "name": "Google Meet",
      "key": {"type": "hangoutsMeet"}
    },
    "conferenceId": "abc-defg-hij"
  }
}
```

**⚠️ Counterintuitive Aspects**:

* **Creating Meet Link** requires special parameter:
  ```python
  service.events().insert(
      calendarId='primary',
      body=event_with_conferenceData_createRequest,
      conferenceDataVersion=1  # REQUIRED!
  )
  ```
* **`hangoutLink`** is read-only - can't set directly
* **Two entry points**: Video URL + optional phone dial-in
* **Removing link**: Set `conferenceData` to `null` (with `conferenceDataVersion=1`)

---

### 12. Recording/Transcription: Very Limited API

**What User Sees (UI)**:
```
In Google Meet:
  ⏺ Record meeting
  📝 Turn on transcription
  🤖 Take notes with Gemini

In Calendar Event:
  Video call options → Meeting records → Pre-configure
```

**What's in the Data (API)**:

**Mostly NOT accessible!**

| Feature | API Support |
|---------|-------------|
| Pre-configure auto-record | ⚠️ Admin-level only (2024+ feature) |
| Per-event recording toggle | ❌ No direct field |
| Start/stop recording | ❌ Requires meeting UI |
| Access recordings | ⚠️ Via Drive API, not Calendar |
| Access transcripts | ⚠️ Via Drive API, not Calendar |

**⚠️ Counterintuitive Aspects**:

* Calendar API cannot start/stop recordings
* Recordings stored in Drive, not Calendar
* No field in event response indicates recording status
* Transcripts are separate Drive documents

---

### 13. Attachments: NOT Supported

**What User Sees (UI)**:
```
In some calendar clients:
  📎 Attach file → Select from Drive
```

**What's in the Data (API)**:

**No native attachment support in Calendar API v3!**

**Workarounds**:
```json
{
  "description": "Attachments:\n📎 https://docs.google.com/document/d/abc123\n📎 https://drive.google.com/file/d/xyz789",

  "extendedProperties": {
    "shared": {
      "attachment_url_1": "https://docs.google.com/document/d/abc123",
      "attachment_url_2": "https://drive.google.com/file/d/xyz789"
    }
  }
}
```

**⚠️ Counterintuitive Aspect**:

Despite Google Calendar UI supporting Drive attachments, the REST API has no attachment field. Must use:
- `description` with links
- `extendedProperties` for structured data
- Apps Script for true attachment support

---

## Entity Relationship Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                         USER                                │
│  (identified by email, e.g., user@gmail.com)               │
└─────────────────────────────────────────────────────────────┘
           │
           │ has one PRIMARY, many SECONDARY
           ▼
┌─────────────────────────────────────────────────────────────┐
│                       CALENDAR                              │
│  id: string (email format, GLOBALLY unique)                │
│  summary: string (title)                                    │
│  timeZone: string (IANA)                                    │
│  ─────────────────────────────────────                      │
│  Primary calendar ID = user's email                         │
│  Global properties shared by all users                      │
└─────────────────────────────────────────────────────────────┘
           │
           │ viewed via (per-user settings)
           ▼
┌─────────────────────────────────────────────────────────────┐
│                    CALENDARLIST ENTRY                       │
│  id: string (same as calendar ID)                          │
│  backgroundColor: string (user's color)                     │
│  selected: boolean (show/hide)                              │
│  defaultReminders: array                                    │
│  ─────────────────────────────────────                      │
│  Different for each user viewing same calendar              │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                         EVENT                               │
│  id: string (unique PER-CALENDAR only!)                    │
│  calendarId: string                                         │
│  iCalUID: string (correlates same meeting across calendars)│
│  start: {date | dateTime, timeZone?}                       │
│  end: {date | dateTime, timeZone?}                         │
│  ─────────────────────────────────────                      │
│  ⚠️ Event ID NOT globally unique                           │
│  Use (calendarId, eventId) as composite key                 │
└─────────────────────────────────────────────────────────────┘
           │
           │ if recurring, has instances
           ▼
┌─────────────────────────────────────────────────────────────┐
│                    RECURRING INSTANCE                       │
│  id: string (different from parent!)                       │
│  recurringEventId: string (points to parent)               │
│  originalStartTime: {dateTime, timeZone}                   │
│  ─────────────────────────────────────                      │
│  Instance ID format: {parentId}_{timestamp}                │
│  Each instance is a separate resource                       │
└─────────────────────────────────────────────────────────────┘
```

---

## Quick Reference: UI Action → API Operation

| UI Action | API Operation | Notes |
|-----------|---------------|-------|
| Create event | `events.insert` | Returns event with ID |
| Edit event | `events.patch` or `events.update` | |
| Delete event | `events.delete` | |
| Invite attendee | `events.patch` with attendees | Creates copy on their calendar |
| Accept/Decline | `events.patch` responseStatus | On attendee's copy |
| Move to calendar | `events.move` | Changes organizer |
| Get instances | `events.instances` | Expands recurring event |
| Share calendar | `acl.insert` | Doesn't auto-add to CalendarList |
| Add shared calendar | `calendarList.insert` | User must explicitly add |
| Change color | `calendarList.patch` | Per-user setting |

---

## Key Gotchas Summary

| Gotcha | Reality |
|--------|---------|
| Event ID is unique | Only per-calendar! Use `(calendarId, eventId)` |
| End date is the last day | End date is EXCLUSIVE (day after last day) |
| End time is the last moment | End time is EXCLUSIVE (ends AT that time) |
| Same meeting = same event | Attendees have DIFFERENT event IDs |
| Recurring = one event | Each instance has DIFFERENT ID |
| Calendar color is shared | Color is per-user (CalendarList) |
| Sharing adds to their list | Must explicitly add via CalendarList |
| guestsCanModify works | Only in UI; API guest edits are local only |
| events.copy exists | NO! Must use get + insert manually |
| Moving preserves ownership | NO! Organizer changes to dest owner |
| Attachments via API | NOT SUPPORTED - use links workaround |
| Recording via API | VERY LIMITED - admin presets only |
| Meet link via URL | NO! Must use conferenceData + version=1 |

---

## See Also

* `api-capabilities.md` - Feature matrix and detailed capability documentation
* `visualizations.md` - Mermaid diagrams for visual understanding
* `identifiers.md` - Detailed ID semantics
* `timezones.md` - Timezone handling in depth
* `gogcli-data-handling.md` - How gogcli handles these structures
* `../examples/` - Example API responses
