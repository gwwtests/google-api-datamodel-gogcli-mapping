# Calendar API Documentation Archival Summary

**Date**: 2026-01-30

**Objective**: Research and archive Google Calendar API documentation with focus on event IDs, timezone handling, all-day vs timed events, recurring events, and calendar IDs.

## Archival Status

### Previously Archived (2026-01-29)

All four requested core documentation URLs were already comprehensively archived:

1. **Events Reference** - `/docs/web/calendar/events/events-reference.md`
   * Source: https://developers.google.com/calendar/api/v3/reference/events
   * Complete Event resource structure and all API methods
   * Event ID format, iCalUID, recurringEventId, originalStartTime
   * Start/end times, timezone handling, attendees, organizer vs creator

2. **Calendars Reference** - `/docs/web/calendar/calendars/calendars-reference.md`
   * Source: https://developers.google.com/calendar/api/v3/reference/calendars
   * Calendar resource metadata
   * Calendar ID format, timezone, location, description

3. **Recurring Events Guide** - `/docs/web/calendar/recurring/recurring-events.md`
   * Source: https://developers.google.com/calendar/api/guides/recurringevents
   * RRULE format (RFC 5545)
   * Recurring event vs instances distinction
   * Instance modification and exceptions

4. **Events & Calendars Concepts** - `/docs/web/calendar/events/events-calendars-concepts.md`
   * Source: https://developers.google.com/calendar/api/concepts/events-calendars
   * Fundamental concepts document
   * Calendar ID = email address format
   * Primary calendar vs other calendars
   * Timed vs all-day events
   * Calendars vs CalendarList collections

### Newly Archived (2026-01-30)

Added two important practical guides missing from the archive:

5. **Create Events Guide** - `/docs/web/calendar/guides/create-events.md`
   * Source: https://developers.google.com/workspace/calendar/api/guides/create-events
   * Practical event creation workflow
   * OAuth requirements and access verification
   * Custom event IDs and format requirements
   * Drive attachments and conference data

6. **Event Types Guide** - `/docs/web/calendar/guides/event-types.md`
   * Source: https://developers.google.com/workspace/calendar/api/guides/event-types
   * All event types: default, birthday, fromGmail, status events
   * Birthday event constraints and properties
   * People API integration for birthdays
   * Event type filtering in API calls

## Key Focus Areas - Documentation Coverage

### Event ID Format and Uniqueness

**Fully documented** in:

* `events/events-reference.md` - Event resource structure
* `events/events-calendars-concepts.md` - Uniqueness scope
* `INDEX.md` - Summary of findings

**Key findings**:

* Format: Base32hex encoding (lowercase a-v, digits 0-9)
* Length: 5-1024 characters
* Uniqueness: **Per calendar only** (NOT globally unique)
* **CRITICAL**: Must use composite key `(calendarId, eventId)` for global uniqueness
* Can specify custom ID at creation (or auto-generated)
* Immutable after creation

### Timezone Handling

**Fully documented** in:

* `events/events-reference.md` - TimeZone field specification
* `events/events-calendars-concepts.md` - Conceptual understanding
* `guides/create-events.md` - Practical usage examples

**Key findings**:

* **Timed events**:
  * Use `start.dateTime` and `end.dateTime` (RFC3339 format)
  * Timezone specified via inline offset OR explicit `start.timeZone` field
  * IANA timezone names (e.g., "America/Los_Angeles")
  * For recurring events: `start.timeZone` is **required** (specifies recurrence expansion timezone)
  * For single events: `start.timeZone` is optional (indicates custom timezone)

* **All-day events**:
  * Use `start.date` and `end.date` (format: `yyyy-mm-dd`)
  * **timeZone field has NO significance** for all-day events
  * Span midnight-to-midnight in calendar's timezone

* **Calendar default timezone**:
  * Calendar resource has `timeZone` field (IANA format)
  * Used for display when event doesn't specify explicit timezone

### All-Day vs Timed Events

**Fully documented** in:

* `events/events-calendars-concepts.md` - Conceptual distinction
* `events/events-reference.md` - Field specifications
* `guides/create-events.md` - Creation examples
* `guides/event-types.md` - Constraints per event type

**Key findings**:

* **Timed events**: `start.dateTime` + `end.dateTime` + optional `timeZone`
* **All-day events**: `start.date` + `end.date` (no timezone significance)
* Mutually exclusive: Cannot have both `date` and `dateTime` set
* Birthday events: Must be all-day, spanning exactly one day

### Recurring Events (RRULE, instances)

**Fully documented** in:

* `recurring/recurring-events.md` - Complete guide
* `events/events-reference.md` - Recurrence field specification
* `events/events-calendars-concepts.md` - Conceptual overview

**Key findings**:

* **RRULE format**: RFC 5545 standard
* Stored in `recurrence` field as array of strings
* Components: `FREQ` (required), `INTERVAL`, `UNTIL`, `COUNT`, etc.
* Example: `"RRULE:FREQ=WEEKLY;UNTIL=20110701T170000Z"`

* **Recurring event vs instances**:
  * Recurring event: Has `recurrence` field, single event ID
  * Instances: Expanded from recurrence, each has different event ID
  * Use `events.instances` method to expand

* **Modified instances**:
  * Separate event resources
  * `recurringEventId` points to parent
  * `originalStartTime` identifies which instance

* **iCalUID**:
  * All instances of recurring event share same `iCalUID`
  * Different from event `id` field

### Calendar ID Format

**Fully documented** in:

* `calendars/calendars-reference.md` - Calendar resource
* `events/events-calendars-concepts.md` - ID format and usage
* `calendarList/calendarList-reference.md` - User-specific view

**Key findings**:

* Format: Email address (e.g., `user@example.com`, `calendarid@group.calendar.google.com`)
* Uniqueness: **Global**
* Primary calendar ID: User's primary email address (immutable while account exists)
* Special keyword: `'primary'` in API calls refers to authenticated user's primary calendar
* Calendar IDs used in CalendarList are references to Calendar resources

## File Organization

All archived files follow the standard pattern:

* `{basename}.md` - Markdown content via jina.ai reader
* `{basename}.url` - Source URL (single line)
* `{basename}.yaml` - Metadata with:
  * source_url
  * download_timestamp
  * document_title
  * covered_api_calls (list)
  * key_concepts (list)
  * related_docs (list)
  * notes (detailed findings)

## Archive Directory Structure

```
docs/web/calendar/
├── INDEX.md                           # Master index with findings summary
├── overview/
│   ├── api-overview.md
│   ├── api-overview.url
│   └── api-overview.yaml
├── events/
│   ├── events-reference.md            # Complete Event resource reference
│   ├── events-reference.url
│   ├── events-reference.yaml
│   ├── events-calendars-concepts.md   # Fundamental concepts
│   ├── events-calendars-concepts.url
│   └── events-calendars-concepts.yaml
├── calendars/
│   ├── calendars-reference.md
│   ├── calendars-reference.url
│   └── calendars-reference.yaml
├── calendarList/
│   ├── calendarList-reference.md
│   ├── calendarList-reference.url
│   └── calendarList-reference.yaml
├── recurring/
│   ├── recurring-events.md
│   ├── recurring-events.url
│   └── recurring-events.yaml
├── sharing/
│   ├── calendar-sharing.md
│   ├── calendar-sharing.url
│   └── calendar-sharing.yaml
├── guides/
│   ├── create-events.md               # NEW: Practical creation guide
│   ├── create-events.url
│   ├── create-events.yaml
│   ├── event-types.md                 # NEW: Event types reference
│   ├── event-types.url
│   └── event-types.yaml
└── timezones/                          # Empty - timezone info integrated in other docs
```

## Questions Fully Answered by Archive

### Q: If I have an event ID, is it unique globally?

**A**: No. Event IDs are unique **per calendar** only. Use `(calendarId, eventId)` composite key for global uniqueness.

**Source**: `events/events-reference.md`, `INDEX.md`

### Q: If two people share a calendar event, do they see the same event ID?

**A**: Yes. It's the same event on the same calendar, so same event ID.

**Source**: `events/events-calendars-concepts.md`, `sharing/calendar-sharing.md`

### Q: What timezone is the event time in?

**A**:

* **Timed events**: Specified in `start.timeZone` or via offset in `start.dateTime` (RFC3339)
* **All-day events**: Date only (`start.date`), timezone has no significance
* **Default**: Calendar's default timezone if not explicitly specified

**Source**: `events/events-reference.md`, `guides/create-events.md`, `INDEX.md`

### Q: How do I get all instances of a recurring event?

**A**: Use `events.instances` method with the recurring event ID. Each instance is a separate event resource with its own ID.

**Source**: `recurring/recurring-events.md`, `INDEX.md`

### Q: Are calendar IDs unique across accounts?

**A**: Yes. Calendar IDs are email addresses, globally unique. Primary calendar ID = user's email.

**Source**: `events/events-calendars-concepts.md`, `calendars/calendars-reference.md`, `INDEX.md`

### Q: How do I distinguish timed from all-day events?

**A**: Check which fields are present:

* Timed: `start.dateTime` and `end.dateTime` are set
* All-day: `start.date` and `end.date` are set

**Source**: `events/events-calendars-concepts.md`, `guides/event-types.md`

### Q: What's the difference between eventType and recurring events?

**A**:

* `eventType`: Category of event (default, birthday, fromGmail, status)
* Recurring events: Use `recurrence` field with RRULE, can be any eventType

These are orthogonal concepts. A birthday event has `eventType='birthday'` AND `recurrence='RRULE:FREQ=YEARLY'`.

**Source**: `guides/event-types.md`, `recurring/recurring-events.md`

## Completeness Assessment

### What's Covered

* Event resource structure and all fields
* Calendar resource structure
* CalendarList vs Calendars distinction
* All API methods for events, calendars, calendarList
* Event ID format, uniqueness scope, custom ID creation
* Timezone handling for timed and all-day events
* RFC3339 datetime format, IANA timezone names
* Recurring events: RRULE format, instances, modifications
* Calendar ID format and uniqueness
* Event types: default, birthday, fromGmail, status
* Sharing and ACL
* Organizer vs creator vs attendees
* iCalUID for iCalendar compatibility

### Potential Gaps (for future research)

* **Timezone edge cases**: What if `dateTime` has offset AND `timeZone` field differs?
* **Modified recurring instances**: Can instance timezone differ from parent?
* **Event ID empirical testing**: Confirm uniqueness scope via actual API calls
* **CalendarList entry creation**: Timing of when shared calendars appear
* **Birthday sync behavior**: Exact timing and conflict resolution with People API
* **Multi-account scenarios**: How gogcli handles events across multiple accounts

## Related Documentation

* Synthesized data model docs (future): `../../datamodel/calendar/`
* Gmail API archive for comparison: `../gmail/INDEX.md`

## Commits

1. `7cf731f` - Archive: Calendar API - Create Events and Event Types guides
2. `e18e192` - Update Calendar API INDEX with new guides

## References

All archived documentation sources:

* [Events Reference](https://developers.google.com/calendar/api/v3/reference/events)
* [Calendars Reference](https://developers.google.com/calendar/api/v3/reference/calendars)
* [CalendarList Reference](https://developers.google.com/calendar/api/v3/reference/calendarList)
* [Recurring Events Guide](https://developers.google.com/calendar/api/guides/recurringevents)
* [Events & Calendars Concepts](https://developers.google.com/calendar/api/concepts/events-calendars)
* [Create Events Guide](https://developers.google.com/workspace/calendar/api/guides/create-events)
* [Event Types Guide](https://developers.google.com/workspace/calendar/api/guides/event-types)
* [Calendar Sharing Concepts](https://developers.google.com/calendar/api/concepts/sharing)
* [API Overview](https://developers.google.com/calendar/api/guides/overview)

## Additional Web Search Sources

During research, these sources provided supplementary information:

* [EventDateTime Class References](https://developers.google.com/resources/api-libraries/documentation/calendar/v3/csharp/latest/classGoogle_1_1Apis_1_1Calendar_1_1v3_1_1Data_1_1EventDateTime.html) - C# library documentation
* [Settings API Reference](https://developers.google.com/calendar/api/v3/reference/settings) - User settings including timezone preferences

## Conclusion

The Google Calendar API documentation archive is comprehensive and complete for all requested focus areas. The metadata files enable efficient searching for specific API concepts, and the INDEX.md provides quick reference to key findings. All documentation follows the repository's archival standards with source URLs, timestamps, and structured metadata.
