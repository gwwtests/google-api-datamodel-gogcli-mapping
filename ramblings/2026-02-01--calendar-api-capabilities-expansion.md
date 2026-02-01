# Calendar API Capabilities Expansion

**Date**: 2026-02-01
**Purpose**: Document additional Calendar API features and gotchas discovered through research

## Overview

Extended the Calendar API documentation with comprehensive coverage of:

* Attendee management
* Guest permissions (with critical API vs UI gotcha)
* Google Meet video conferencing
* Recording/transcription limitations
* Attachment workarounds
* Move vs duplicate operations

## New Documentation Created

### 1. `docs/datamodel/calendar/api-capabilities.md`

Feature matrix and detailed documentation answering "Can the API do X?":

| Category | Full Support | Partial | Not Supported |
|----------|:------------:|:-------:|:-------------:|
| Attendees | ✅ | | |
| Guest permissions | ✅ | (API behavior differs) | |
| Meet links | ✅ | | |
| Recording presets | | ⚠️ | |
| Start/stop recording | | | ❌ |
| Attachments | | | ❌ |
| Move events | ✅ | | |
| Copy events | | (manual get+insert) | |

### 2. `docs/datamodel/calendar/visualizations.md`

Mermaid diagrams for visual understanding:

* Capabilities mindmap
* Event ID relationships across calendars
* Move vs Duplicate operations flowchart
* Guest modification gotcha sequence diagram
* Recurring event structure
* Conference data flow

### 3. `docs/datamodel/calendar/ux-to-data-mapping.md` - Extended

Added sections 8-13:

* **8. Guest Permissions**: UI vs API behavior mismatch
* **9. Moving Events**: Organizer changes, event type restrictions
* **10. Copying Events**: No native copy endpoint
* **11. Video Conferencing**: Meet link lifecycle
* **12. Recording/Transcription**: Very limited API support
* **13. Attachments**: NOT supported (workarounds documented)

### 4. `docs/datamodel/calendar/examples/event-with-meet-and-permissions.json`

Comprehensive example showing:

* conferenceData structure
* Guest permission flags
* extendedProperties as attachment workaround
* Attendee response tracking

## Key Discoveries

### Critical Gotcha: `guestsCanModify` API Limitation

```
guestsCanModify: true

Via Calendar UI: Guest edits sync to organizer ✅
Via API:         Guest edits are LOCAL ONLY ❌
```

This is a significant difference that affects programmatic guest modifications.

### Move vs Duplicate Semantics

| Aspect | Move | Duplicate |
|--------|------|-----------|
| Original | Deleted | Preserved |
| Organizer | Changes to dest owner | Changes to dest owner |
| Event ID | May change | Always new |
| iCalUID | Preserved | New generated |

### Features Without API Support

* **Attachments**: No native field; use `description` or `extendedProperties`
* **Start/stop recording**: Requires meeting UI interaction
* **Direct transcript access**: Must use Drive API
* **Copy endpoint**: Must do get → clean fields → insert manually

## Source Attribution

Research based on:

* Google Calendar API v3 reference documentation
* Stack Overflow developer discussions
* Google Workspace Updates blog (2024 recording features)
* googleapis.github.io Python client documentation

## Privacy Note

All examples use:

* Fictional email addresses (alice@company.com, bob@example.com)
* Synthetic IDs and conference links
* No real user data or configurations
