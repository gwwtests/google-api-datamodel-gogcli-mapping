# Calendar API Identifiers

## Overview

This document describes the identifier semantics for Calendar API resources, focusing on uniqueness guarantees, formats, and multi-account implications.

## Calendar IDs

### Format

* **Calendar ID = Email Address**
* Format: email address (e.g., `user@example.com` or `calendarid@group.calendar.google.com`)

### Primary Calendar

* **ID**: User's primary email address
* **Uniqueness**: Global (tied to user account)
* **Lifetime**: Permanent (cannot be deleted while account exists)
* **Ownership**: User account (cannot be transferred or "un-owned")

Source: [Calendars & Events Concepts](../../web/calendar/events/events-calendars-concepts.md)

### Other Calendars

* **ID**: Email-like identifier (often `<random>@group.calendar.google.com`)
* **Uniqueness**: Global
* **Lifetime**: Until deleted or transferred
* **Ownership**: Single data owner (can be transferred via UI)

### Multi-Account Implications

* **Same calendar, multiple accounts**: Same calendar ID across all users
* **User-specific properties**: Stored in CalendarList (color, reminders), not in Calendar
* **Safe to use calendar ID as unique key** across accounts

## Event IDs

### Format

* **Type**: String (opaque)
* **Allowed characters**: Base32hex encoding (lowercase a-v, digits 0-9)
* **Length**: 5-1024 characters
* **Custom IDs**: Can be specified at creation (must follow format rules)
* **Auto-generated**: Server generates UUID-like ID if not specified

Source: [Events Reference](../../web/calendar/events/events-reference.md) - `id` field documentation

### Uniqueness Guarantee

**CRITICAL**: Event IDs are **unique per calendar**, NOT globally unique.

From the API documentation:

> "the ID must be unique per calendar"

**Multi-Account Implications**:

* Event ID alone is NOT sufficient as a unique key
* **Must use composite key**: `(calendarId, eventId)` for global uniqueness
* Two different calendars can have events with the same ID
* Shared calendars: same event, same ID for all users (since same calendar)

### Recurring Events

**Important distinction**:

* **Recurring event**: Has `recurrence` field, single event ID
* **Instances**: Each instance has **different** event ID
* **All instances share same `iCalUID`** (for iCalendar compatibility)

From the API documentation:

> "in recurring events, all occurrences of one event have different `id`s while they all share the same `icalUID`s"

**Instance ID format**: Often `<recurring-event-id>_<timestamp>`

**Fields for linking**:

* `recurringEventId`: Points to the parent recurring event
* `originalStartTime`: Original scheduled start (for exceptions/modifications)

Source: [Events Reference](../../web/calendar/events/events-reference.md), [Recurring Events](../../web/calendar/recurring/recurring-events.md)

## iCalUID

### Purpose

* iCalendar standard identifier (RFC 5545)
* **Unique across all instances** of a recurring event
* Used for iCalendar import/export compatibility

### Relationship to Event ID

* **Different semantic**: `id` ≠ `iCalUID`
* **Recurring events**: All instances share same `iCalUID`, different `id`s
* **At creation**: Specify either `id` OR `iCalUID`, not both

Source: [Events Reference](../../web/calendar/events/events-reference.md) - `id` field notes

## Attendee IDs

### Format

* **Type**: String (Profile ID)
* **Availability**: "if available" (may be absent)
* **Separate from email**: `attendees[].id` is Profile ID, `attendees[].email` is email address

### Organizer vs Creator

**Important distinction for shared calendars**:

* **Creator**: User who created the event (read-only)
* **Organizer**: Calendar containing the "main copy" of the event
* For shared events, creator ≠ organizer

Source: [Events Reference](../../web/calendar/events/events-reference.md), [Calendars & Events Concepts](../../web/calendar/events/events-calendars-concepts.md)

## Summary Table

| Resource | ID Field | Format | Uniqueness Scope | Stable? | Notes |
|----------|----------|--------|------------------|---------|-------|
| Calendar | `id` | Email address | Global | Yes | Primary calendar ID = user email |
| Event | `id` | Base32hex string (5-1024 chars) | **Per calendar** | Yes | Use `(calendarId, eventId)` for global uniqueness |
| Event | `iCalUID` | String | Global (across instances) | Yes | Same for all recurring event instances |
| Recurring event instance | `id` | Base32hex string | Per calendar | Yes | Different from parent recurring event ID |
| Recurring event instance | `recurringEventId` | Base32hex string | Per calendar | Yes | Points to parent recurring event |
| Attendee | `id` | String (Profile ID) | Unknown | Unknown | May be absent; separate from email |

## Multi-Account Considerations

### When Exporting Data from Multiple Accounts

**Safe to merge by calendar ID**:

* Calendar IDs are globally unique
* Same calendar appears with same ID in all users' CalendarLists

**Event merging requires composite key**:

* **DO NOT** use event ID alone as unique key
* **USE**: `(calendarId, eventId)` composite key
* Example conflict: Two different calendars can have events with ID `"abc123"`

### Shared Calendar Events

When multiple users have access to a shared calendar:

* **Same calendar ID** for all users
* **Same event IDs** for all users (events are on the same calendar)
* **Different CalendarList properties** per user (color, reminders, visibility)
* **Different attendee perspective**: `attendees[].self` indicates if this is user's calendar

### Primary Calendar Uniqueness

* Each user has one primary calendar (ID = user email)
* Primary calendar IDs are globally unique (tied to Google account)
* No collision risk when merging data from multiple users' primary calendars

## Empirical Testing Needed

The following questions require empirical testing to confirm:

1. Are event IDs truly unique only per-calendar, or also per-user-account?
2. If user A and user B share a calendar, do they see the same event IDs?
3. Can two different users create events with the same custom ID on different calendars?
4. What is the format/uniqueness of attendee Profile IDs?

## Related Documentation

* [Events Reference](../../web/calendar/events/events-reference.md) - Event resource structure
* [Calendars Reference](../../web/calendar/calendars/calendars-reference.md) - Calendar resource structure
* [Calendars & Events Concepts](../../web/calendar/events/events-calendars-concepts.md) - Fundamental concepts
* [Recurring Events](../../web/calendar/recurring/recurring-events.md) - Recurring event semantics
* [Calendar Sharing](../../web/calendar/sharing/calendar-sharing.md) - Multi-user implications
