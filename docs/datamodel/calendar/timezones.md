# Calendar API Timezone Handling

## Overview

This document describes how the Calendar API represents times and handles timezones, critical for correctly interpreting event start/end times.

## Event Time Representation

Events can be **timed** or **all-day**, using mutually exclusive field sets:

### Timed Events

Use `dateTime` fields with timezone information:

* `start.dateTime` and `end.dateTime`
* Format: RFC3339 combined date-time
* Examples:
  * `2011-06-03T10:00:00.000-07:00` (with offset)
  * `2011-06-03T10:00:00Z` (UTC)
* Timezone can be specified in two ways (see below)

### All-Day Events

Use `date` fields WITHOUT time component:

* `start.date` and `end.date`
* Format: `yyyy-mm-dd` (e.g., `2011-06-03`)
* **CRITICAL**: `timeZone` field has **NO significance** for all-day events
* All-day events span midnight-to-midnight in the calendar's timezone

Source: [Calendars & Events Concepts](../../web/calendar/events/events-calendars-concepts.md)

> "Note that the timezone field has no significance for all-day events."

## Timezone Specification for Timed Events

Timed events can specify timezone in **two ways**:

### Option 1: Inline Offset (in dateTime)

* Include timezone offset in the RFC3339 dateTime value
* Example: `2011-06-03T10:00:00.000-07:00`
* No separate `timeZone` field needed

### Option 2: Explicit timeZone Field

* Use `start.timeZone` and `end.timeZone` fields
* Format: IANA Time Zone Database name (e.g., `"Europe/Zurich"`, `"America/Los_Angeles"`)
* If `timeZone` is specified, dateTime can omit the offset

**From API documentation**:

> "A time zone offset is required unless a time zone is explicitly specified in `timeZone`"

Source: [Events Reference](../../web/calendar/events/events-reference.md) - `start.dateTime` and `end.dateTime` fields

## Timezone Field Semantics

The `start.timeZone` and `end.timeZone` fields have **different meanings** for single vs recurring events:

### Single Events

* `timeZone` is **optional**
* Indicates a **custom timezone** for the event start/end
* If omitted, timezone is determined by offset in `dateTime` or calendar default

### Recurring Events

* `timeZone` is **required**
* Specifies the timezone **in which the recurrence is expanded**
* Critical for daylight saving time (DST) transitions
* Example: Weekly meeting "every Monday at 10am America/Los_Angeles" stays at 10am local time even across DST changes

**From API documentation**:

> "For recurring events this field is required and specifies the time zone in which the recurrence is expanded. For single events this field is optional and indicates a custom time zone for the event start/end."

Source: [Events Reference](../../web/calendar/events/events-reference.md) - `start.timeZone` field

## Calendar Default Timezone

Calendars have a default timezone:

* Calendar resource field: `timeZone` (IANA format)
* Used when event doesn't specify explicit timezone
* User-facing: shown in Calendar UI settings

Source: [Calendars Reference](../../web/calendar/calendars/calendars-reference.md)

## RFC3339 Format Details

Event times use RFC3339 format for `dateTime` fields:

* Full format: `YYYY-MM-DDTHH:MM:SS.sssZ` or `YYYY-MM-DDTHH:MM:SS.sss±HH:MM`
* Examples:
  * `2011-06-03T10:00:00Z` (UTC)
  * `2011-06-03T10:00:00.000-07:00` (PDT, UTC-7)
  * `2011-06-03T17:00:00+00:00` (UTC with explicit offset)

Source: [RFC3339](https://tools.ietf.org/html/rfc3339)

## Recurring Events and DST

For recurring events, timezone handling is critical:

* **Recurrence expanded in specified timezone**
* Weekly meeting "10am America/Los_Angeles" maintains 10am local time across DST
* Instances may have different UTC offsets across DST transitions
* Example:
  * Before DST: 10am PST = 18:00 UTC (UTC-8)
  * After DST: 10am PDT = 17:00 UTC (UTC-7)

**Important**: The `originalStartTime` field (for modified instances) also respects the recurring event's timezone.

Source: [Events Reference](../../web/calendar/events/events-reference.md) - `originalStartTime.timeZone`

## Multi-Account Considerations

### Same Event, Different Users

When a shared calendar event is accessed by users in different timezones:

* **Event times are the same** (same calendar, same event)
* **User's display timezone** affects only UI presentation, not API data
* Event `start.dateTime` and `start.timeZone` are identical for all users

### Primary Calendars from Different Users

When combining data from multiple users' primary calendars:

* Each calendar may have different default timezone
* Event times are stored with explicit timezone (or offset)
* Safe to merge data: each event has its own timezone specification

## Best Practices

### When Creating Events

1. **Timed events**: Always specify timezone explicitly (via `timeZone` field or offset in `dateTime`)
2. **All-day events**: Use `date` fields only, ignore `timeZone`
3. **Recurring events**: **Required** to specify `start.timeZone` for proper DST handling

### When Parsing Events

1. **Check for `start.date` first**: If present, it's an all-day event (ignore `timeZone`)
2. **For timed events**: Look for `start.timeZone` field or extract offset from `start.dateTime`
3. **Recurring events**: Use `start.timeZone` to understand recurrence expansion
4. **Don't assume UTC**: Times may be in any timezone

### When Displaying Events

1. **All-day events**: Display as date only (no time component)
2. **Timed events**: Convert to user's preferred display timezone
3. **Cross-timezone**: Show original timezone for context (e.g., "10am PT")

## Summary Table

| Event Type | Time Fields | Timezone Field | Format | Timezone Significance |
|------------|-------------|----------------|--------|----------------------|
| Timed (single) | `start.dateTime`, `end.dateTime` | `start.timeZone` (optional) | RFC3339 | Optional; indicates custom timezone |
| Timed (recurring) | `start.dateTime`, `end.dateTime` | `start.timeZone` (required) | RFC3339 | Required; specifies recurrence expansion timezone |
| All-day | `start.date`, `end.date` | `start.timeZone` (ignored) | `yyyy-mm-dd` | **NO significance** |

## Edge Cases

### All-Day Events Crossing Date Line

* All-day events use dates only, no timezone conversion needed
* Same date seen by all users regardless of their timezone
* Example: "July 4th" holiday is July 4th for all users

### Events Spanning DST Transitions

* Event duration may appear to change in local time
* Example: 2-hour event starting 1am before DST "spring forward" may end at 4am
* Always calculate duration using UTC or timezone-aware libraries

### Modified Recurring Event Instances

* Use `originalStartTime` to identify which instance was modified
* `originalStartTime.timeZone` must match the recurring event's timezone
* Actual `start.dateTime` may be different (user moved the instance)

## Empirical Testing Needed

The following questions require empirical testing:

1. What happens if `start.dateTime` has offset AND `start.timeZone` is specified (conflicting)?
2. How are all-day events represented when queried via API (what `date` format exactly)?
3. Do recurring event instances inherit parent's `start.timeZone` or can they differ?
4. What is the behavior for calendars with unrecognized timezone names?

## Related Documentation

* [Events Reference](../../web/calendar/events/events-reference.md) - Event resource structure
* [Calendars Reference](../../web/calendar/calendars/calendars-reference.md) - Calendar timezone field
* [Calendars & Events Concepts](../../web/calendar/events/events-calendars-concepts.md) - Timed vs all-day events
* [Recurring Events](../../web/calendar/recurring/recurring-events.md) - Recurrence expansion
