# Gmail API: users.settings.filters Reference

**Source**: [Gmail API Reference - users.settings.filters](https://developers.google.com/gmail/api/reference/rest/v1/users.settings.filters)

**Downloaded**: 2026-02-03

---

## Overview

Gmail filters are rules that automatically perform actions on messages matching specified criteria. Filters apply to **individual messages**, not entire threads.

**API Endpoint**: `https://gmail.googleapis.com/gmail/v1/users/{userId}/settings/filters`

**Maximum Filters**: 1,000 filters per Gmail account

---

## Filter Resource Structure

### JSON Schema

```json
{
  "id": "string",
  "criteria": {
    "from": "string",
    "to": "string",
    "subject": "string",
    "query": "string",
    "negatedQuery": "string",
    "hasAttachment": "boolean",
    "excludeChats": "boolean",
    "size": "integer",
    "sizeComparison": "enum (SizeComparison)"
  },
  "action": {
    "addLabelIds": ["string"],
    "removeLabelIds": ["string"],
    "forward": "string"
  }
}
```

### Field Definitions

#### Top-Level Fields

| Field | Type | Description |
|-------|------|-------------|
| `id` | string | Server-assigned unique identifier for the filter |
| `criteria` | object | Message matching conditions (see below) |
| `action` | object | Operations to perform on matched messages (see below) |

#### Criteria Object

**All criteria are ANDed together** - message must satisfy ALL conditions to match.

| Field | Type | Description |
|-------|------|-------------|
| `from` | string | Sender's display name or email address |
| `to` | string | Recipient name/email (includes To, Cc, and Bcc headers) |
| `subject` | string | Case-insensitive phrase in subject line (whitespace trimmed/collapsed) |
| `query` | string | Gmail search query syntax (same as search box) |
| `negatedQuery` | string | Messages NOT matching this query |
| `hasAttachment` | boolean | Whether message contains attachments |
| `excludeChats` | boolean | Whether to exclude chat messages |
| `size` | integer | RFC822 message size in bytes (including headers and attachments) |
| `sizeComparison` | enum | How size relates to `size` field: `unspecified`, `smaller`, `larger` |

#### Action Object

| Field | Type | Description |
|-------|------|-------------|
| `addLabelIds` | string[] | List of label IDs to add to matched messages |
| `removeLabelIds` | string[] | List of label IDs to remove from matched messages |
| `forward` | string | Email address to forward matched messages to (must be verified) |

---

## API Methods

### 1. List Filters

**Endpoint**: `GET /gmail/v1/users/{userId}/settings/filters`

**Description**: Lists all message filters for a user

**Request Parameters**:

* `userId` (path) - User's email address or `"me"` for authenticated user

**Response**:

```json
{
  "filter": [
    {
      "id": "...",
      "criteria": {...},
      "action": {...}
    }
  ]
}
```

**OAuth Scopes** (any of):

* `https://www.googleapis.com/auth/gmail.settings.basic`
* `https://mail.google.com/`
* `https://www.googleapis.com/auth/gmail.modify`
* `https://www.googleapis.com/auth/gmail.readonly`

### 2. Get Filter

**Endpoint**: `GET /gmail/v1/users/{userId}/settings/filters/{id}`

**Description**: Gets a specific filter by ID

**Request Parameters**:

* `userId` (path) - User's email address or `"me"`
* `id` (path) - Filter ID

**Response**: Single Filter resource object

### 3. Create Filter

**Endpoint**: `POST /gmail/v1/users/{userId}/settings/filters`

**Description**: Creates a new filter

**Request Body**: Filter resource (without `id` field)

**Response**: Created Filter resource with assigned `id`

**Maximum**: 1,000 filters per account

### 4. Delete Filter

**Endpoint**: `DELETE /gmail/v1/users/{userId}/settings/filters/{id}`

**Description**: Permanently deletes a filter

**Request Parameters**:

* `userId` (path)
* `id` (path) - Filter ID to delete

**Response**: Empty response body on success

---

## Important Notes

### Query Syntax

The `criteria.query` field supports **full Gmail search syntax**, including:

* Operators: `OR`, `AND`, `-` (negation), `*` (wildcard)
* Special searches: `has:attachment`, `is:starred`, `label:mylabel`
* Date ranges: `after:YYYY/MM/DD`, `before:YYYY/MM/DD`
* Size searches: `size:10M`, `larger:5M`
* Quoted phrases: `"exact phrase"`

### Search vs Filter Differences

**Gmail UI vs API differences**:

1. **Alias Expansion**: UI performs alias expansion, API does not
2. **Thread-wide Search**: UI searches across threads, API does not
3. **Filter Application**: API filters apply to messages, not threads

Source: [Gmail API - Search filter differences](https://developers.google.com/workspace/gmail/api/guides/filtering)

### Multiple Criteria Behavior

When multiple criteria are specified, they function as **AND** (not OR). A message must satisfy ALL criteria to match the filter.

### Label IDs

Use label IDs, not label names:

* System labels: `INBOX`, `SPAM`, `TRASH`, `STARRED`, `UNREAD`, `IMPORTANT`
* User labels: Use `users.labels.list` to get IDs

---

## Related Documentation

* [Managing Filters Guide](https://developers.google.com/workspace/gmail/api/guides/filter_settings)
* [Gmail Search Operators](https://support.google.com/mail/answer/7190)
* [Labels API Reference](https://developers.google.com/gmail/api/reference/rest/v1/users.labels)

---

## Metadata

```yaml
source_url: "https://developers.google.com/gmail/api/reference/rest/v1/users.settings.filters"
download_timestamp: "2026-02-03T00:00:00Z"
document_title: "Gmail API - users.settings.filters"
covered_api_calls:
  - "users.settings.filters.list"
  - "users.settings.filters.get"
  - "users.settings.filters.create"
  - "users.settings.filters.delete"
key_concepts:
  - "filter criteria"
  - "filter actions"
  - "query syntax"
  - "label IDs"
  - "AND logic for multiple criteria"
related_docs:
  - "../labels/labels-reference.md"
  - "filters-xml-export-format.md"
  - "filters-api-vs-xml.md"
```
