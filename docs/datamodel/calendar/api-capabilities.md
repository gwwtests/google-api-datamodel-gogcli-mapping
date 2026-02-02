# Calendar API: Feature Capabilities Reference

A comprehensive guide to what Google Calendar API can and cannot do.

## Quick Reference Matrix

| Feature | API Support | Notes |
|---------|:-----------:|-------|
| **Attendees** |||
| Add/modify/remove attendees | ✅ Full | `attendees` array |
| Set optional/required status | ✅ Full | `attendees[].optional` |
| Track response status | ✅ Full | `attendees[].responseStatus` |
| **Guest Permissions** |||
| Guests can modify | ✅ Partial | Works in UI; API guest edits are local only |
| Guests can invite others | ✅ Full | `guestsCanInviteOthers` |
| Guests can see other guests | ✅ Full | `guestsCanSeeOtherGuests` |
| **Video Conferencing** |||
| Check if Meet link exists | ✅ Full | `hangoutLink`, `conferenceData` |
| Create Meet link | ✅ Full | `conferenceData.createRequest` |
| Remove Meet link | ✅ Full | Set `conferenceData` to null |
| **Recording/Transcription** |||
| Pre-configure auto-record | ⚠️ Limited | Admin-level, 2024+ feature |
| Pre-configure auto-transcribe | ⚠️ Limited | Admin-level, 2024+ feature |
| Start/stop recording via API | ❌ No | Requires manual UI action |
| Access recordings | ⚠️ Indirect | Via Drive API |
| **Attachments** |||
| Native file attachments | ❌ No | Not supported |
| Workaround with links | ✅ | `description` or `extendedProperties` |
| **Event Operations** |||
| Move to another calendar | ✅ Full | `events.move` method |
| Duplicate/copy event | ⚠️ Manual | Get + Insert (no copy endpoint) |
| **Event Types** |||
| Default events | ✅ Full | Standard support |
| Birthday events | ⚠️ Read-only | Cannot move |
| Out of Office | ✅ Create/read | Special handling |
| Working Location | ✅ Create/read | Special handling |
| Focus Time | ✅ Create/read | Special handling |

---

## Detailed Feature Documentation

### 1. Attendees Management

**Full API Support** - Add, modify, and remove attendees via the `attendees` array.

```json
{
  "summary": "Project Kickoff",
  "attendees": [
    {
      "email": "alice@example.com",
      "displayName": "Alice",
      "optional": false,
      "responseStatus": "needsAction",
      "comment": "Project lead",
      "additionalGuests": 0
    },
    {
      "email": "bob@example.com",
      "optional": true,
      "responseStatus": "tentative"
    }
  ]
}
```

**Available Fields:**

| Field | Type | Description |
|-------|------|-------------|
| `email` | string | Required. Attendee's email |
| `displayName` | string | Optional display name |
| `optional` | boolean | Whether attendance is optional |
| `responseStatus` | enum | `needsAction`, `accepted`, `declined`, `tentative` |
| `comment` | string | Attendee's comment |
| `additionalGuests` | integer | Number of additional guests they're bringing |
| `organizer` | boolean | Read-only. True if this attendee is the organizer |
| `self` | boolean | Read-only. True if this represents the authenticated user |
| `resource` | boolean | True if this is a room/resource |

**Operations:**

```python
# Add attendee
event['attendees'].append({'email': 'charlie@example.com'})
service.events().patch(calendarId='primary', eventId=event_id, body=event).execute()

# Remove attendee
event['attendees'] = [a for a in event['attendees'] if a['email'] != 'bob@example.com']

# Modify response (on your OWN copy)
for a in event['attendees']:
    if a.get('self'):
        a['responseStatus'] = 'accepted'
```

---

### 2. Guest Permissions

Three boolean flags control what attendees can do:

```json
{
  "summary": "Collaborative Meeting",
  "guestsCanModify": true,
  "guestsCanInviteOthers": true,
  "guestsCanSeeOtherGuests": true
}
```

| Flag | Default | Meaning |
|------|---------|---------|
| `guestsCanModify` | `false` | Can attendees modify event details? |
| `guestsCanInviteOthers` | `true` | Can attendees invite additional people? |
| `guestsCanSeeOtherGuests` | `true` | Can attendees see the full attendee list? |

**⚠️ CRITICAL GOTCHA: `guestsCanModify` API Limitation**

When `guestsCanModify: true`:

* **In Calendar UI**: Guests CAN modify the organizer's event (changes sync to everyone)
* **Via API**: Guest modifications only affect their LOCAL COPY, NOT the organizer's version

```python
# Scenario: Alice creates event with guestsCanModify=true
# Bob (attendee) tries to change via API:

event = service.events().get(calendarId='bob@example.com', eventId='bobs_copy_id').execute()
event['summary'] = 'New Title'
service.events().update(calendarId='bob@example.com', eventId='bobs_copy_id', body=event).execute()

# Result:
# - Bob's copy shows "New Title"
# - Alice's original still shows old title!
# - Other attendees see old title!
```

This is a known API limitation documented in Stack Overflow discussions. The workaround is to have the organizer make changes, or use the Calendar UI.

---

### 3. Google Meet Video Conferencing

**Reading Meet Information:**

```json
{
  "hangoutLink": "https://meet.google.com/abc-defg-hij",
  "conferenceData": {
    "entryPoints": [
      {
        "entryPointType": "video",
        "uri": "https://meet.google.com/abc-defg-hij",
        "label": "meet.google.com/abc-defg-hij"
      },
      {
        "entryPointType": "phone",
        "uri": "tel:+1-555-123-4567",
        "pin": "123456789"
      }
    ],
    "conferenceSolution": {
      "name": "Google Meet",
      "key": {"type": "hangoutsMeet"},
      "iconUri": "https://..."
    },
    "conferenceId": "abc-defg-hij"
  }
}
```

**Creating Meet Link:**

```python
event = {
    'summary': 'Meeting with Video',
    'start': {'dateTime': '2025-01-30T10:00:00-08:00'},
    'end': {'dateTime': '2025-01-30T11:00:00-08:00'},
    'conferenceData': {
        'createRequest': {
            'requestId': 'unique-request-id-123',
            'conferenceSolutionKey': {'type': 'hangoutsMeet'}
        }
    }
}

# IMPORTANT: Must include conferenceDataVersion parameter
result = service.events().insert(
    calendarId='primary',
    body=event,
    conferenceDataVersion=1  # Required!
).execute()

print(result.get('hangoutLink'))  # https://meet.google.com/xxx-xxxx-xxx
```

**Removing Meet Link:**

```python
event['conferenceData'] = None
service.events().patch(
    calendarId='primary',
    eventId=event_id,
    body={'conferenceData': None},
    conferenceDataVersion=1
).execute()
```

---

### 4. Recording and Transcription Settings

**⚠️ Limited API Support** - This is an evolving feature (2024+)

**What's Available:**

* **Organization Admins**: Can set defaults for auto-recording, transcription, Gemini notes
* **Meeting Hosts**: Can pre-configure via Calendar UI "Video call options"
* **2024 Update**: Google added ability to pre-configure meeting artifacts

**What's NOT Available via API:**

* No documented API fields for per-event recording/transcription settings
* Cannot programmatically start/stop recordings during meetings
* Cannot retrieve transcripts directly (stored in Drive)

**Accessing Recordings/Transcripts:**

Completed recordings are stored in Google Drive:

* Location: Meet Recordings folder in organizer's Drive
* Access: Use Drive API, not Calendar API
* Filename format: `{Meeting Title} ({Date}) {Time}`

**Requirements:**

* Google Workspace Business Standard, Enterprise, Education Plus, or Gemini add-on
* Recording must be manually started in the meeting (no API control)

---

### 5. Attachments

**❌ NOT SUPPORTED** - Calendar API v3 has no native attachment support.

**Workarounds:**

**Option 1: Links in Description**

```json
{
  "summary": "Budget Review",
  "description": "Please review the following before the meeting:\n\n📎 Agenda: https://docs.google.com/document/d/abc123\n📎 Spreadsheet: https://docs.google.com/spreadsheets/d/xyz789"
}
```

**Option 2: Extended Properties**

```json
{
  "summary": "Budget Review",
  "extendedProperties": {
    "shared": {
      "attachment_1_name": "Budget Q4 2024",
      "attachment_1_url": "https://drive.google.com/file/d/abc123",
      "attachment_1_type": "application/vnd.google-apps.spreadsheet",
      "attachment_2_name": "Meeting Agenda",
      "attachment_2_url": "https://docs.google.com/document/d/xyz789",
      "attachment_2_type": "application/vnd.google-apps.document"
    }
  }
}
```

**Note:** `shared` properties are visible to all attendees; `private` properties are visible only to the authenticated user.

**Option 3: Use Google Apps Script**

Google Apps Script's Calendar service has `addEmailReminder` and attachment capabilities not available in the REST API.

---

### 6. Moving Events Between Calendars

**✅ Full Support** via `events.move` method.

```http
POST https://www.googleapis.com/calendar/v3/calendars/{sourceCalendarId}/events/{eventId}/move?destination={destinationCalendarId}
```

```python
moved_event = service.events().move(
    calendarId='source@example.com',
    eventId='event_id_123',
    destination='destination@example.com',
    sendUpdates='all'  # or 'none', 'externalOnly'
).execute()
```

**Behavior:**

* Event is **removed** from source calendar
* Event is **added** to destination calendar
* **Organizer changes** to owner of destination calendar
* Event ID may change
* Attendees can be notified via `sendUpdates` parameter

**Limitations:**

| Event Type | Can Move? |
|------------|-----------|
| Default events | ✅ Yes |
| Birthday events | ❌ No |
| Out of Office | ❌ No |
| Working Location | ❌ No |
| Focus Time | ❌ No |
| From Google tasks | ❌ No |

---

### 7. Duplicating/Copying Events

**No Native Copy Endpoint** - Use get + insert pattern.

```python
def duplicate_event(service, source_calendar_id, event_id, dest_calendar_id):
    """
    Copy an event from one calendar to another.

    Note: Creates independent event - edits won't sync!
    """
    # 1. Get the original event
    event = service.events().get(
        calendarId=source_calendar_id,
        eventId=event_id
    ).execute()

    # 2. Remove fields that can't be copied
    fields_to_remove = [
        'id',
        'etag',
        'created',
        'updated',
        'htmlLink',
        'iCalUID',      # Let Google generate new one
        'creator',      # Will be set to new creator
        'organizer',    # Will be set to new organizer
        'sequence'      # Reset sequence number
    ]
    for field in fields_to_remove:
        event.pop(field, None)

    # 3. Handle recurring event instances
    if 'recurringEventId' in event:
        # This is an instance - remove recurring reference
        event.pop('recurringEventId', None)
        event.pop('originalStartTime', None)

    # 4. Insert into destination calendar
    new_event = service.events().insert(
        calendarId=dest_calendar_id,
        body=event,
        conferenceDataVersion=1  # Preserve Meet link if present
    ).execute()

    return new_event
```

**Key Differences: Move vs Duplicate**

| Aspect | Move (`events.move`) | Duplicate (get+insert) |
|--------|---------------------|------------------------|
| Original event | Deleted | Preserved |
| Event ID | May change | Always new |
| Organizer | Changes to dest owner | Changes to dest owner |
| Future edits | N/A (only one copy) | Independent (no sync) |
| iCalUID | Preserved | New generated |
| Attendees | Optionally notified | Not notified |
| Meet link | Preserved | Preserved (if conferenceDataVersion=1) |

---

## API Operation Reference

| User Intent | API Method | Key Parameters |
|-------------|------------|----------------|
| Create event | `events.insert` | `calendarId`, `body` |
| Update event | `events.update` or `events.patch` | `calendarId`, `eventId`, `body` |
| Delete event | `events.delete` | `calendarId`, `eventId` |
| Move to calendar | `events.move` | `calendarId`, `eventId`, `destination` |
| Copy event | `events.get` + `events.insert` | Manual field cleanup |
| Add attendees | `events.patch` | Include `attendees` array |
| Add Meet link | `events.insert/patch` | `conferenceData.createRequest`, `conferenceDataVersion=1` |
| Remove Meet link | `events.patch` | `conferenceData: null` |
| Get recurring instances | `events.instances` | `calendarId`, `eventId` |

---

## See Also

* `ux-to-data-mapping.md` - UI to API mapping gotchas
* `visualizations.md` - Mermaid diagrams
* `identifiers.md` - Event ID and iCalUID semantics
* `timezones.md` - Timezone handling

### Example Files

* `examples/event-move-and-duplicate.json` - Move and copy operations
* `examples/event-with-meet-and-permissions.json` - Conference data and guest permissions
* `examples/same-meeting-different-calendars.json` - Event ID differences across calendars
* `examples/event-recurring-parent-and-instance.json` - Recurring event structure
* `examples/event-timed.json` - Timed event with attendees
* `examples/event-allday.json` - All-day event date handling
