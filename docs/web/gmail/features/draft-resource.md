# Gmail Draft Resource - API Reference

**Source**: https://developers.google.com/gmail/api/reference/rest/v1/users.drafts
**Retrieved**: 2026-01-30

## Overview

The Draft resource represents a draft email message in Gmail. Drafts can be created, updated, and sent through the API.

## Resource Path

```
users.drafts
```

Full path: `https://gmail.googleapis.com/gmail/v1/users/{userId}/drafts`

## Draft Resource Structure

The Draft resource has a minimal structure with only two fields:

### Fields

**id** (string)
The immutable ID of the draft.

**message** (object)
References a Message object containing "The message content of the draft."

## JSON Representation

```json
{
  "id": "string",
  "message": {
    // Message object
  }
}
```

## Notable Absence: No Scheduled Send Fields

**IMPORTANT**: There are no `scheduledTime`, `scheduledSend`, or similar fields for scheduling draft messages. The Draft structure only contains the draft's identifier and its message content.

## Available Methods

### create

Creates a new draft with the DRAFT label.

```http
POST https://gmail.googleapis.com/gmail/v1/users/{userId}/drafts
```

Request body:

```json
{
  "message": {
    "raw": "base64url-encoded-email"
  }
}
```

### delete

Immediately and permanently deletes the specified draft.

```http
DELETE https://gmail.googleapis.com/gmail/v1/users/{userId}/drafts/{id}
```

### get

Gets the specified draft.

```http
GET https://gmail.googleapis.com/gmail/v1/users/{userId}/drafts/{id}
```

Query parameters:

* `format` - Format of the draft message (minimal, full, raw, metadata)

### list

Lists the drafts in the user's mailbox.

```http
GET https://gmail.googleapis.com/gmail/v1/users/{userId}/drafts
```

Query parameters:

* `maxResults` - Maximum number of drafts to return
* `pageToken` - Token for pagination
* `q` - Query string for filtering drafts
* `includeSpamTrash` - Include drafts from SPAM and TRASH

Response:

```json
{
  "drafts": [
    {
      "id": "string",
      "message": {
        "id": "string",
        "threadId": "string"
      }
    }
  ],
  "nextPageToken": "string",
  "resultSizeEstimate": number
}
```

### send

Sends the specified, existing draft to the recipients in the To, Cc, and Bcc headers.

```http
POST https://gmail.googleapis.com/gmail/v1/users/{userId}/drafts/send
```

Request body:

```json
{
  "id": "string"
}
```

Returns the sent message with the SENT label.

### update

Replaces a draft's content.

```http
PUT https://gmail.googleapis.com/gmail/v1/users/{userId}/drafts/{id}
```

Request body:

```json
{
  "message": {
    "raw": "base64url-encoded-email"
  }
}
```

## Message Format in Drafts

The message object in a draft can be provided in two ways:

### Raw Format (Recommended)

Base64url-encoded RFC 2822 formatted email:

```json
{
  "message": {
    "raw": "base64url-encoded-string"
  }
}
```

### Payload Format

Structured message parts:

```json
{
  "message": {
    "to": "recipient@example.com",
    "subject": "Draft subject",
    "body": "Draft body"
  }
}
```

## Draft Labels

Drafts automatically receive:

* **DRAFT** - System label identifying the message as a draft
* **INBOX** - Often present on draft messages

When sent via `drafts.send`:

* **DRAFT** label is removed
* **SENT** label is added

## Scope Requirements

Requires one of the following OAuth scopes:

* `https://www.googleapis.com/auth/gmail.compose` - Manage drafts and send email
* `https://www.googleapis.com/auth/gmail.modify` - Read and modify email
* `https://mail.google.com/` - Full Gmail access

## Working with Drafts

### Creating a Draft

```bash
POST /gmail/v1/users/me/drafts
Content-Type: application/json

{
  "message": {
    "raw": "VG86IHJlY2lwaWVudEBleGFtcGxlLmNvbQpTdWJqZWN0OiBUZXN0IERyYWZ0CgpUaGlzIGlzIGEgdGVzdCBkcmFmdA=="
  }
}
```

### Listing Drafts

```bash
GET /gmail/v1/users/me/drafts?maxResults=10
```

### Sending a Draft

```bash
POST /gmail/v1/users/me/drafts/send
Content-Type: application/json

{
  "id": "r1234567890"
}
```

## Limitations

* **No scheduled sending** - Cannot schedule drafts for future delivery via API
* **No draft metadata** - No fields for draft creation time, last modified time, etc.
* **No version history** - Cannot track draft revisions
* **No collaboration** - No support for shared drafts or co-authoring
* **Immediate send only** - `drafts.send` method sends immediately, no delay option

## Workarounds for Scheduled Sending

Since the API doesn't support scheduled sending:

1. **Store draft ID externally** with scheduled time
2. **Use cron jobs** or task schedulers
3. **Call drafts.send** at the appropriate time
4. **Implement retry logic** for failed sends
5. **Track sent status** in external database

Example workflow:

```
1. Create draft via API → get draft ID
2. Store {draftId, scheduledTime, userId} in database
3. Background job polls database for due messages
4. When time arrives, call drafts.send(draftId)
5. Update database with sent status
```

## Best Practices

* **Use raw format** for drafts when possible (more reliable encoding)
* **Validate recipients** before creating drafts
* **Handle conflicts** when updating drafts (check if draft still exists)
* **Clean up old drafts** - delete drafts that are no longer needed
* **Implement retry logic** for network failures
* **Use batch requests** when working with multiple drafts
* **Cache draft IDs** to avoid unnecessary list calls
* **Verify sends** by checking for SENT label after drafts.send

## Common Issues

* **Base64url encoding** - Must use URL-safe base64 encoding, not standard base64
* **Missing headers** - Drafts must include To, Subject headers even if empty
* **Size limits** - Drafts have same size limits as regular messages (35 MB)
* **Rate limits** - Drafts creation/sending counts toward API quotas
* **Concurrent updates** - Last write wins, no conflict resolution
