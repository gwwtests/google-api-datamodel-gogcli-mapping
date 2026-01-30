# gogcli Calendar Data Handling

How the gogcli tool handles Google Calendar API data structures.

**Source**: Analysis of https://github.com/steipete/gogcli source code
**Analysis Date**: 2025-01-29

## Calendar Commands Overview

| Command | Purpose |
|---------|---------|
| `calendars` | List all calendars accessible to the user |
| `acl` | Manage calendar access control lists |
| `events` / `list` | Query events from specific or all calendars |
| `event` / `get` | Retrieve a single event by ID |
| `create` | Create new events with full customization |
| `update` | Modify existing events |
| `delete` | Remove events |
| `colors` | Show available event color IDs |
| `conflicts` | Find scheduling conflicts across calendars |
| `freebusy` | Query free/busy status for calendars |
| `search` | Full-text search for events |
| `time` | Display server time with timezone awareness |
| `respond` | Accept/decline/tentative event invitations |
| `focus-time` | Create Focus Time blocks (auto-decline) |
| `out-of-office` / `ooo` | Create Out of Office events |
| `working-location` / `wl` | Set working location |

## Event ID Handling

### Identification
- Events identified by `calendarID` + `eventID` tuple
- Event IDs are opaque strings assigned by Google Calendar API
- Retrieved via: `svc.Events.Get(calendarID, eventID)`

### Recurring Event Instances
```go
func resolveRecurringInstanceID(ctx context.Context, svc *calendar.Service,
    calendarID, recurringEventID, originalStart string) (string, error)
```

- Instance IDs resolved using `originalStart` time
- Uses `Events.Instances(calendarID, recurringEventID)` with time range
- Instances matched by comparing `OriginalStartTime` and `Start` fields

## Timezone Handling (Critical!)

### Resolution Priority
```go
func resolveEventTimezone(event *calendar.Event, calendarTimezone string,
    loc *time.Location) (string, *time.Location)
```

1. **Explicitly provided `calendarTimezone`** - Used if valid IANA zone
2. **Event's own timezone** - From `Event.Start.TimeZone` or `Event.End.TimeZone`
3. **Fallback to UTC** - If no timezone available

### Time Parsing
```go
func parseEventTime(value string, tz string) (time.Time, bool)
func parseEventDate(value string, tz string) (time.Time, bool)
```

- RFC3339 and RFC3339Nano datetime parsing
- YYYY-MM-DD date-only parsing
- All parsing respects IANA timezone name

### Calendar Location Fetching
```go
func getCalendarLocation(ctx context.Context, svc *calendar.Service,
    calendarID string) (string, *time.Location, error)
```

- Fetches from `CalendarList.Get(calendarID).TimeZone`
- Falls back to UTC if no timezone set

## All-Day vs Timed Events

### Detection
```go
func isAllDayEvent(e *calendar.Event) bool {
    return e != nil && e.Start != nil && e.Start.Date != ""
}
```

### Data Structure
- **All-day events**: Use `Start.Date` and `End.Date` (YYYY-MM-DD format)
- **Timed events**: Use `Start.DateTime` and `End.DateTime` (RFC3339 format)
- All-day events do NOT include time or timezone information

### Creation
```go
func buildEventDateTime(value string, allDay bool) *calendar.EventDateTime {
    if allDay {
        return &calendar.EventDateTime{Date: value}
    }
    edt := &calendar.EventDateTime{DateTime: value}
    if tz := extractTimezone(value); tz != "" {
        edt.TimeZone = tz
    }
    return edt
}
```

## Recurring Events

### RRULE Format
```
RRULE:FREQ=MONTHLY;BYMONTHDAY=11
RRULE:FREQ=WEEKLY;BYDAY=MO,WE,FR
```

### Scope for Modifications
- `"this"` - Single instance only
- `"thisAndFollowing"` - This and all future instances
- `"all"` - Entire recurring series

### Recurrence Truncation
```go
func truncateRecurrence(rules []string, originalStart string) ([]string, error)
```
- Modifies RRULE to remove COUNT/UNTIL
- Adds `UNTIL=originalStart-1` to stop series

## Output Formatting

### JSON Output - Event Wrapper
```go
type eventWithDays struct {
    *calendar.Event
    StartDayOfWeek string `json:"startDayOfWeek,omitempty"`
    EndDayOfWeek   string `json:"endDayOfWeek,omitempty"`
    Timezone       string `json:"timezone,omitempty"`
    EventTimezone  string `json:"eventTimezone,omitempty"`
    StartLocal     string `json:"startLocal,omitempty"`
    EndLocal       string `json:"endLocal,omitempty"`
}
```

### Computed Fields
- `StartDayOfWeek` / `EndDayOfWeek` - Monday, Tuesday, etc.
- `Timezone` - Calendar timezone (if different from event)
- `EventTimezone` - Event-specific timezone
- `StartLocal` / `EndLocal` - RFC3339 in calendar's timezone

### Text Output Fields
```
id, summary, type, timezone, start, start-day-of-week, start-local,
end, end-day-of-week, end-local, description, location, color,
visibility, show-as, attendee, recurrence, reminders, meet, link
```

## Multi-Calendar Support

### Single Calendar
- Default to `primary` calendar if not specified
- Can specify any accessible calendar by ID

### All-Calendars Query
```go
func listAllCalendarsEvents(ctx context.Context, svc *calendar.Service, ...) error {
    calResp, err := svc.CalendarList.List().Context(ctx).Do()
    // Iterates through all calendars, queries each, combines results
}
```

- `--all` flag queries all accessible calendars
- Results include `CalendarID` for disambiguation

## Special Event Types

### Focus Time
```go
FocusTimeProperties: &calendar.EventFocusTimeProperties{
    AutoDeclineMode: "declineAllConflictingInvitations",
    DeclineMessage:  "I'm focusing on work",
    ChatStatus:      "doNotDisturb",
}
```

Auto-decline modes: `declineNone`, `declineAllConflictingInvitations`, `declineOnlyNewConflictingInvitations`

### Out of Office
```go
OutOfOfficeProperties: &calendar.EventOutOfOfficeProperties{
    AutoDeclineMode: "declineAllConflictingInvitations",
    DeclineMessage:  "I am out of office and will respond when I return.",
}
```

### Working Location
```go
WorkingLocationProperties: &calendar.EventWorkingLocationProperties{
    Type: "homeOffice" | "officeLocation" | "customLocation",
    HomeOffice: map[string]any{},
    OfficeLocation: {Label, BuildingId, FloorId, DeskId},
    CustomLocation: {Label},
}
```

## Time Range Resolution

### Input Formats
| Format | Example |
|--------|---------|
| RFC3339 | `2026-01-29T14:00:00Z` |
| ISO 8601 | `2026-01-29T14:00:00-0800` |
| Date only | `2026-01-29` |
| Relative | `today`, `tomorrow`, `yesterday` |
| Weekday | `monday`, `next tuesday` |

### Convenience Flags
- `--today` - Start of day to end of day
- `--tomorrow` - Tomorrow only
- `--week` - Full week (configurable start day)
- `--days N` - Next N days

## Key Data Structures

### EventDateTime
```go
type EventDateTime struct {
    Date     string // YYYY-MM-DD (all-day)
    DateTime string // RFC3339 (timed)
    TimeZone string // IANA timezone name
}
```

### EventAttendee
```go
type EventAttendee struct {
    Email          string
    ResponseStatus string // needsAction, declined, tentative, accepted
    Optional       bool
}
```

### EventReminders
```go
type EventReminders struct {
    UseDefault bool
    Overrides  []*EventReminder // Max 5
}
type EventReminder struct {
    Method  string // email, popup
    Minutes int64  // 0 to 40320
}
```

## Implications for Data Model

1. **Event IDs require calendar context**: Always store `(calendarId, eventId)` tuple
2. **Timezone preservation critical**: Store timezone name alongside times
3. **All-day events different**: Check `Date` vs `DateTime` fields
4. **Recurring events complex**: Instance IDs include original start time
5. **Special types have extra properties**: Focus Time, OOO, Working Location
6. **Attendee tracking**: Response status per attendee
