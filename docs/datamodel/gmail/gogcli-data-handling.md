# gogcli Gmail Data Handling

How the gogcli tool handles Gmail API data structures.

**Source**: Analysis of https://github.com/steipete/gogcli source code
**Analysis Date**: 2025-01-29

## ID Handling

### Message IDs
- **Format**: Opaque strings from Gmail API, used as-is
- **Validation**: Only `strings.TrimSpace()` applied
- **No transformation**: Passed directly to API calls

```go
// From gmail_get.go:
messageID := strings.TrimSpace(c.MessageID)
svc.Users.Messages.Get("me", messageID)
```

### Thread IDs
- Same handling as message IDs
- Used in Gmail URLs: `https://mail.google.com/mail/?authuser=%s#all/%s`

### Label IDs
- **System labels**: Standard IDs like `INBOX`, `SENT`, `DRAFT`, `STARRED`
- **User labels**: Format `Label_XXX` (numeric suffix)
- **Resolution**: Bidirectional mapping `nameToID` ↔ `idToName`
- **Case-insensitive**: Name lookups converted to lowercase

## Output Structures

### JSON Output

**Message Item** (`gmail_messages.go`):
```json
{
  "id": "18d1234567890abc",
  "threadId": "18d1234567890abc",
  "date": "2025-01-29 14:30",
  "from": "sender@example.com",
  "subject": "Email subject",
  "labels": ["INBOX", "UNREAD"],
  "body": "Message body text..."
}
```

**Thread Item** (`gmail.go`):
```json
{
  "id": "18d1234567890abc",
  "date": "2025-01-29 14:30",
  "from": "sender@example.com",
  "subject": "Thread subject",
  "labels": ["INBOX"],
  "messageCount": 5
}
```

**Full Message** (`gmail_get.go`):
```json
{
  "message": { /* Full Gmail API Message object */ },
  "headers": { "From": "...", "Subject": "...", "Date": "..." },
  "unsubscribe": "https://...",
  "body": "Full body text",
  "attachments": [
    {
      "filename": "doc.pdf",
      "size": 102400,
      "sizeHuman": "100 KB",
      "mimeType": "application/pdf",
      "attachmentId": "ANGjd..."
    }
  ]
}
```

### Date Formatting
- **Format**: `2006-01-02 15:04` (YYYY-MM-DD HH:MM)
- **Parsing**: RFC 5322 email headers via `mail.ParseDate()`
- **Timezone**: Converted to specified timezone (default: local)
- **Fallback**: Raw header value if parsing fails

## Thread Handling

### Fetching
- `Format("full")` retrieves complete thread with ALL messages
- No pagination - all messages returned in single response

### Concurrent Fetching
- Bounded parallelism: max 10 concurrent requests
- Used when listing multiple threads
- Handles errors by re-running sequentially

### Message Selection
- **Default**: Newest message by date (`newestMessageByDate()`)
- **`--oldest` flag**: Use oldest message
- First message used for display info (From, Subject, Labels)

## Label Handling

### System vs User Detection
```go
Label.Type == "system"  // INBOX, SENT, etc.
Label.Type == "user"    // Custom labels
```

### Resolution Flow
1. Fetch all labels via `Users.Labels.List()`
2. Build `nameToID` and `idToName` maps
3. Accept names OR IDs in commands (case-insensitive)
4. Resolve names to IDs for API calls

## Multi-Account Handling

### Account Selection Priority
1. `--account` flag (explicit)
2. `GOG_ACCOUNT` environment variable
3. Account alias from config
4. Default account from secrets store
5. Single token (if exactly one exists)
6. First token (fallback)
7. Error requiring `--account`

### Consumer Account Detection
```go
func isConsumerAccount(account string) bool {
    domain := account[at+1:]
    return domain == "gmail.com" || domain == "googlemail.com"
}
```

### Service Creation
All Gmail commands use authenticated user ("me"):
```go
svc.Users.Messages.Get("me", messageID)
```

## Body Processing

### Extraction Priority
1. `text/plain` (preferred)
2. `text/html` (fallback, stripped of tags)

### Processing Pipeline
1. Recursive MIME part search
2. Base64 URL decoding (Gmail API format)
3. Content-Transfer-Encoding handling
4. Charset conversion (UTF-8 default)
5. HTML tag stripping (if HTML)
6. Whitespace collapse

### HTML Stripping
- Removes `<script>` and `<style>` blocks entirely
- Strips remaining HTML tags
- Collapses whitespace

### Truncation
- **Text output**: Max 200 characters (with "...")
- **JSON output**: Full body included
- **UTF-8 safe**: Rune-aware truncation

## API Optimizations

### Field Selection
```go
// Search: minimal fields
Fields("messages(id,threadId),nextPageToken")

// Metadata only
Format("metadata").MetadataHeaders("From", "Subject", "Date")

// Full message
Format("full")
```

### Avoiding N+1
- Concurrent thread fetching with semaphore
- Label caching (fetched once per command)
- Batch-friendly design

## Key Source Files

| File | Purpose |
|------|---------|
| `gmail.go` | Search threads, top-level commands |
| `gmail_messages.go` | Message search/fetch |
| `gmail_labels.go` | Label operations |
| `gmail_labels_utils.go` | Label ID resolution |
| `gmail_thread.go` | Thread operations, body decoding |
| `gmail_get.go` | Single message retrieval |
| `gmail_attachments.go` | Attachment handling |
| `account.go` | Account selection logic |
| `gmail_date.go` | Date parsing/formatting |

## Implications for Data Model

1. **IDs are opaque**: Don't parse or assume format
2. **Labels need mapping**: Store both ID and name
3. **Dates are local-aware**: Store raw `internalDate` (epoch ms) for consistency
4. **Multi-account**: Track account context separately (not in API response)
5. **Body handling**: May need to handle both plain and HTML versions
