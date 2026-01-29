# Gmail API Usage in gogcli

Analysis of how gogcli uses the Gmail API, based on source code review.

**Source Repository**: https://github.com/steipete/gogcli
**Analysis Date**: 2025-01-29

## API Version

Gmail API v1 (`google.golang.org/api/gmail/v1`)

## OAuth Scopes Used

From `internal/googleauth/service.go`:

```go
gmail.GmailModifyScope           // gmail.modify
gmail.GmailSettingsBasicScope    // gmail.settings.basic
gmail.GmailSettingsSharingScope  // gmail.settings.sharing
```

Note: `--readonly` flag can limit to read-only scopes.

## Commands and API Calls

### Message Operations

| Command | API Call | Notes |
|---------|----------|-------|
| `gog gmail messages` | `users.messages.list` | With query support |
| `gog gmail get <id>` | `users.messages.get` | Supports format param |
| `gog gmail attachment` | `users.messages.attachments.get` | |
| `gog gmail search <query>` | `users.messages.list` | Gmail search syntax |
| `gog gmail send` | `users.messages.send` | Compose and send |
| `gog gmail batch` | Batch operations | Multiple message ops |

### Thread Operations

| Command | API Call | Notes |
|---------|----------|-------|
| `gog gmail thread <id>` | `users.threads.get` | Get full thread |
| `gog gmail thread --list` | `users.threads.list` | List threads |

### Label Operations

| Command | API Call | Notes |
|---------|----------|-------|
| `gog gmail labels` | `users.labels.list` | List all labels |
| `gog gmail labels create` | `users.labels.create` | |
| `gog gmail labels delete` | `users.labels.delete` | |
| `gog gmail labels update` | `users.labels.update` | |

### Draft Operations

| Command | API Call | Notes |
|---------|----------|-------|
| `gog gmail drafts` | `users.drafts.list` | |
| `gog gmail drafts create` | `users.drafts.create` | |
| `gog gmail drafts send` | `users.drafts.send` | |

### Settings Operations

| Command | API Call | Notes |
|---------|----------|-------|
| `gog gmail vacation` | `users.settings.vacation` | Get/set vacation |
| `gog gmail filters` | `users.settings.filters.list` | |
| `gog gmail forwarding` | `users.settings.forwardingAddresses` | |
| `gog gmail sendas` | `users.settings.sendAs` | |
| `gog gmail delegates` | `users.settings.delegates` | |
| `gog gmail autoforward` | `users.settings.autoForwarding` | |

### Watch (Push Notifications)

| Command | API Call | Notes |
|---------|----------|-------|
| `gog gmail watch` | `users.watch` | Pub/Sub setup |
| `gog gmail watch stop` | `users.stop` | Stop watching |

### History (Sync)

| Command | API Call | Notes |
|---------|----------|-------|
| `gog gmail history` | `users.history.list` | Incremental sync |

## Data Structures Used

### Message

From Google API, used directly:
- `gmail.Message`
- `gmail.MessagePart` (for MIME structure)
- `gmail.MessagePartHeader`
- `gmail.MessagePartBody`

Key fields observed in output:
- `id` - Message ID
- `threadId` - Thread this message belongs to
- `labelIds` - Array of label IDs
- `snippet` - Preview text
- `internalDate` - Unix timestamp (string, milliseconds)
- `payload` - MIME structure
- `historyId` - For sync

### Thread

- `gmail.Thread`
- Contains `messages` array

Key fields:
- `id` - Thread ID
- `historyId`
- `messages` - Array of Message objects
- `snippet`

### Label

- `gmail.Label`

Key fields:
- `id` - Label ID (e.g., "INBOX", "SENT", "Label_123")
- `name` - Display name
- `type` - "system" or "user"
- `labelListVisibility`
- `messageListVisibility`

## Output Formatting

### JSON Mode (`--json`)

Direct serialization of Google API response objects. Example:

```json
{
  "id": "18d1234567890abc",
  "threadId": "18d1234567890abc",
  "labelIds": ["INBOX", "UNREAD"],
  "snippet": "Preview of message...",
  "internalDate": "1706540400000"
}
```

### Text Mode (default)

Human-readable table format with colors.

## Interesting Implementation Details

### Retry Logic

From `internal/googleapi/transport.go`:
- Retries on 429 (rate limit) and 5xx errors
- Exponential backoff
- Circuit breaker pattern

### Pagination

Standard Google API pagination:
- Uses `pageToken` for continuation
- `maxResults` to control page size

### User Identifier

All calls use `"me"` as the user ID (authenticated user).

## Questions for Research

Based on this analysis, key questions to research:

1. **Message ID Format**: What guarantees exist about `id` field format and uniqueness?
2. **Thread Grouping**: How exactly does Gmail decide what's in a thread?
3. **Label ID Patterns**: Why do user labels look like `Label_123` vs system labels like `INBOX`?
4. **History ID**: What are the guarantees about historyId for sync?
5. **InternalDate**: Is this always UTC? Always milliseconds?

These are tracked in `../RESEARCH_REQUESTS.md`.
