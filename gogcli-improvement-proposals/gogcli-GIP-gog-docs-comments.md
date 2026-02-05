# GIP: `gog docs comments` Subcommand

**GIP ID:** gog-docs-comments
**Status:** Proposed
**Phase:** 1 (Read-Only Extensions)
**Effort:** Easy
**Value:** High
**Parent:** [gog-docs-overview](./gogcli-GIP-gog-docs-overview.md)

---

## Summary

Add `gog docs comments` subcommand to list and read comments on a Google Doc, including the highlighted text they reference and reply threads.

---

## Proposed Commands

```bash
# List all comments
gog docs comments list --docid DOCUMENT_ID

# Include resolved comments
gog docs comments list --docid DOCUMENT_ID --include-resolved

# Get specific comment with replies
gog docs comments get --docid DOCUMENT_ID --id COMMENT_ID

# Output as JSON
gog docs comments list --docid DOCUMENT_ID --json
```

---

## Example Output

### Table (default TTY)

```
ID            AUTHOR          STATUS      QUOTED TEXT              COMMENT
────────────  ──────────────  ──────────  ───────────────────────  ────────────────────────
AAAbcd123     john@example    Open        "the quick brown fox"    Please rephrase this
AABefg456     jane@example    Resolved    "methodology section"    Add more detail here
AAChij789     bob@example     Open        "Figure 1"               Update with latest data
```

### JSON (`--json`)

```json
[
  {
    "id": "AAAbcd123",
    "author": {
      "displayName": "John Smith",
      "emailAddress": "john@example.com"
    },
    "createdTime": "2026-02-01T10:30:00Z",
    "modifiedTime": "2026-02-01T10:30:00Z",
    "resolved": false,
    "content": "Please rephrase this",
    "quotedFileContent": {
      "mimeType": "text/plain",
      "value": "the quick brown fox"
    },
    "anchor": "kix.abc123",
    "replies": [
      {
        "id": "reply123",
        "author": {
          "displayName": "Jane Doe",
          "emailAddress": "jane@example.com"
        },
        "content": "I'll fix this today",
        "createdTime": "2026-02-01T11:00:00Z"
      }
    ]
  }
]
```

---

## Use Cases

### 1. Review Pending Feedback

```bash
# List only open comments
gog docs comments list --docid ID | grep "Open"
```

### 2. Export Comments for Tracking

```bash
# Export to JSON for issue tracking integration
gog docs comments list --docid ID --json > comments.json
```

### 3. Find Comments by Author

```bash
gog docs comments list --docid ID --json | jq '.[] | select(.author.emailAddress=="john@example.com")'
```

### 4. Count Open vs Resolved

```bash
gog docs comments list --docid ID --include-resolved --json | jq '{
  open: [.[] | select(.resolved == false)] | length,
  resolved: [.[] | select(.resolved == true)] | length
}'
```

---

## Technical Implementation

### API Used

**Method:** Drive API `comments.list` and `comments.get`

**Note:** Comments are NOT in the Docs API; they're in the Drive API.

### API Calls

```go
// List comments
resp, err := driveService.Comments.List(fileID).
    Fields("comments(id,author,content,quotedFileContent,resolved,createdTime,modifiedTime,anchor,replies)").
    IncludeDeleted(false).
    Do()

// Get specific comment with replies
comment, err := driveService.Comments.Get(fileID, commentID).
    Fields("*").
    IncludeDeleted(false).
    Do()
```

### Data Structure

```go
type Comment struct {
    ID                string          `json:"id"`
    Author            Author          `json:"author"`
    CreatedTime       string          `json:"createdTime"`
    ModifiedTime      string          `json:"modifiedTime"`
    Resolved          bool            `json:"resolved"`
    Content           string          `json:"content"`
    QuotedFileContent *QuotedContent  `json:"quotedFileContent,omitempty"`
    Anchor            string          `json:"anchor,omitempty"`
    Replies           []Reply         `json:"replies,omitempty"`
}

type QuotedContent struct {
    MimeType string `json:"mimeType"`
    Value    string `json:"value"`
}

type Reply struct {
    ID          string `json:"id"`
    Author      Author `json:"author"`
    Content     string `json:"content"`
    CreatedTime string `json:"createdTime"`
}
```

---

## API Reference

* [comments.list](https://developers.google.com/drive/api/reference/rest/v3/comments/list)
* [comments.get](https://developers.google.com/drive/api/reference/rest/v3/comments/get)
* [Manage Comments](https://developers.google.com/drive/api/guides/manage-comments)

---

## Effort Estimate

| Component | Effort |
|-----------|--------|
| Command parsing | Low |
| Drive API integration | Medium (may already exist) |
| Data extraction | Low |
| Output formatting | Low |
| Tests | Low |
| **Total** | **~3-5 hours** |

---

## Notes

* Comments are stored in Drive, not Docs, so this uses the Drive API
* The `anchor` field contains an opaque `kix.*` reference, not explicit document positions
* `quotedFileContent.value` contains the highlighted text the comment references

---

## Related GIPs

* [gog-docs-suggestions](./gogcli-GIP-gog-docs-suggestions.md) - Similar collaboration feature
