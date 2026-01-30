# Gmail API Scheduled Email Feature Request - Issue #140922183

**Source**: https://issuetracker.google.com/issues/140922183
**Retrieved**: 2026-01-30
**Status**: Blocked

## Summary

This is a feature request to expose scheduled email functionality in the Gmail Java API, mirroring capabilities already available in Gmail's web interface.

## Key Details

**Issue ID**: 140922183

**Status**: Blocked

## Reporter's Request

The requester asks for the ability to "create a message that should be send later as the gmail UI is already offering." They specifically request:

* Creating messages scheduled for later delivery
* Editing send date/time parameters
* Access through the Gmail Java API

## Current State

The feature request remains in a "blocked" status, suggesting it depends on another unresolved issue or external factors.

## Technical Context

The request acknowledges that Gmail's user interface already provides scheduled send functionality. The gap is that this capability hasn't been exposed programmatically through the official Gmail Java API, forcing developers to seek alternative solutions or workarounds.

**Reporter**: A non-Google developer (public contributor)

**Last Activity**: Recent update recorded in the tracking system

This represents a common API limitation where user-facing features lack corresponding programmatic access for developers.

## API Limitations

Currently, the Gmail API:

* **Cannot schedule messages** for future delivery
* **Cannot query scheduled messages** or their send times
* **Does not expose Draft.scheduledTime** or similar fields
* **Does not provide methods** to schedule or cancel scheduled sends

## How Gmail Scheduled Send Works (Web UI)

In the Gmail web interface:

1. User composes a message as a draft
2. User clicks "Schedule send" instead of "Send"
3. User selects a date/time or chooses preset options
4. Gmail stores the message internally with scheduling metadata
5. Gmail automatically sends the message at the scheduled time

## Current Workarounds

Since the API doesn't support scheduled sending, developers must:

1. **External scheduling**:
   * Store draft ID and send time in external database
   * Use cron jobs or task schedulers
   * Call `drafts.send` method at scheduled time

2. **Third-party services**:
   * Use email scheduling services with their own APIs
   * Services maintain their own scheduling infrastructure

3. **Apps Script**:
   * Use Google Apps Script with time-driven triggers
   * Limited to Apps Script environment constraints

## Draft Resource Structure

The Gmail API Draft resource contains only:

```json
{
  "id": "string",
  "message": {
    // Message object
  }
}
```

**Notable absence**: No `scheduledTime`, `scheduledSend`, or similar fields exist in the Draft resource.

## Potential Future Implementation

If this feature were implemented, it might look like:

### Extended Draft Resource

```json
{
  "id": "string",
  "message": {
    // Message object
  },
  "scheduledSendTime": "2026-02-01T10:00:00.000Z"  // RFC 3339 format
}
```

### New Methods

* `drafts.schedule(draftId, scheduledTime)` - Schedule a draft for sending
* `drafts.unschedule(draftId)` - Cancel scheduled send
* `drafts.list` with filter for scheduled drafts
* `scheduledMessages.list()` - List all scheduled messages

### Possible System Label

A new system label like `SCHEDULED` to identify scheduled messages.

## DateTime Format

Based on other Gmail API datetime fields, scheduled times would likely use:

* **Format**: RFC 3339 / ISO 8601
* **Example**: `2026-01-31T14:30:00.000Z`
* **Timezone**: Usually UTC with Z suffix
* **Precision**: Milliseconds

Example from Gmail API documentation: `'2013-02-14T13:15:03-08:00'`

## Related API Endpoints

Currently available draft endpoints:

* `POST /users/{userId}/drafts/create` - Create draft
* `GET /users/{userId}/drafts/list` - List drafts
* `GET /users/{userId}/drafts/{id}` - Get draft
* `PUT /users/{userId}/drafts/{id}` - Update draft
* `DELETE /users/{userId}/drafts/{id}` - Delete draft
* `POST /users/{userId}/drafts/send` - Send draft immediately

**Missing**: Schedule-related endpoints

## Use Cases Blocked

Without API support, developers cannot:

* Build email clients with native scheduled send
* Automate scheduled email campaigns via API
* Migrate scheduled emails between accounts programmatically
* Integrate Gmail scheduling with other business systems
* Build workflow automation with scheduled emails

## Scope Implications

If implemented, this feature would likely require:

* `https://www.googleapis.com/auth/gmail.compose` (existing scope)
* Or possibly a new scope for scheduling operations

## Community Impact

This limitation affects:

* Third-party email client developers
* Marketing automation platforms
* Business workflow automation systems
* Calendar/reminder integration services
* Email productivity tools

## Recommendation for Developers

Until this feature is implemented:

1. **Implement external scheduling** with your own infrastructure
2. **Document limitations** for users
3. **Consider alternative approaches** (e.g., Apps Script for Workspace users)
4. **Monitor issue tracker** for updates on feature request
5. **Educate users** that scheduling is web-UI only
