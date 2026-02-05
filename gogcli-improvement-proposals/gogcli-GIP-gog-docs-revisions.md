# GIP: `gog docs revisions` Subcommand

**GIP ID:** gog-docs-revisions
**Status:** Proposed
**Phase:** 1 (Read-Only Extensions)
**Effort:** Easy
**Value:** Medium
**Parent:** [gog-docs-overview](./gogcli-GIP-gog-docs-overview.md)

---

## Summary

Add `gog docs revisions` subcommand to list document revision history and export specific revisions, enabling version tracking and recovery.

---

## Proposed Commands

```bash
# List all revisions
gog docs revisions list --docid DOCUMENT_ID

# Limit results
gog docs revisions list --docid DOCUMENT_ID --limit 10

# Export specific revision
gog docs revisions export --docid DOCUMENT_ID --rev REVISION_ID --format pdf

# Get revision metadata
gog docs revisions get --docid DOCUMENT_ID --rev REVISION_ID

# Output as JSON
gog docs revisions list --docid DOCUMENT_ID --json
```

---

## Example Output

### Table (default TTY)

```
REVISION ID      MODIFIED TIME         MODIFIED BY           KEEP FOREVER
───────────────  ────────────────────  ────────────────────  ────────────
ALm37BVxyz...    2026-02-05 10:30:00   john@example.com      No
ALm37BVabc...    2026-02-04 15:45:00   jane@example.com      Yes
ALm37BVdef...    2026-02-03 09:15:00   john@example.com      No
```

### JSON (`--json`)

```json
[
  {
    "id": "ALm37BVxyz123",
    "modifiedTime": "2026-02-05T10:30:00.000Z",
    "lastModifyingUser": {
      "displayName": "John Smith",
      "emailAddress": "john@example.com",
      "photoLink": "https://..."
    },
    "keepForever": false,
    "exportLinks": {
      "application/pdf": "https://...",
      "application/vnd.openxmlformats-officedocument.wordprocessingml.document": "https://..."
    }
  }
]
```

---

## Use Cases

### 1. View Recent Changes

```bash
# Who edited the document in the last week?
gog docs revisions list --docid ID --json | jq '.[] | select(.modifiedTime > "2026-01-29") | {time: .modifiedTime, user: .lastModifyingUser.emailAddress}'
```

### 2. Export Previous Version

```bash
# Export version from before a problematic edit
gog docs revisions export --docid ID --rev ALm37BVabc... --format pdf -o backup.pdf
```

### 3. Pin Important Versions

```bash
# List pinned revisions
gog docs revisions list --docid ID --json | jq '.[] | select(.keepForever == true)'
```

### 4. Compare Authors

```bash
# Count revisions by author
gog docs revisions list --docid ID --json | jq 'group_by(.lastModifyingUser.emailAddress) | map({author: .[0].lastModifyingUser.emailAddress, count: length})'
```

---

## Technical Implementation

### API Used

**Method:** Drive API `revisions.list` and `revisions.get`

### API Calls

```go
// List revisions
resp, err := driveService.Revisions.List(fileID).
    Fields("revisions(id,modifiedTime,lastModifyingUser,keepForever,exportLinks)").
    PageSize(100).
    Do()

// Get specific revision
rev, err := driveService.Revisions.Get(fileID, revisionID).
    Fields("*").
    Do()

// Export revision
resp, err := driveService.Revisions.Get(fileID, revisionID).
    Download()
// Or use exportLinks to download in specific format
```

### Data Structure

```go
type Revision struct {
    ID                string            `json:"id"`
    ModifiedTime      string            `json:"modifiedTime"`
    LastModifyingUser *User             `json:"lastModifyingUser"`
    KeepForever       bool              `json:"keepForever"`
    ExportLinks       map[string]string `json:"exportLinks,omitempty"`
}
```

---

## API Reference

* [revisions.list](https://developers.google.com/drive/api/reference/rest/v3/revisions/list)
* [revisions.get](https://developers.google.com/drive/api/reference/rest/v3/revisions/get)
* [Manage Revisions](https://developers.google.com/drive/api/guides/manage-revisions)

---

## Limitations

| Feature | Supported |
|---------|:---------:|
| List revisions | ✅ |
| Get revision metadata | ✅ |
| Export revision (PDF/DOCX) | ✅ |
| Get JSON structure of old revision | ❌ |
| Compare revisions (diff) | ❌ |
| Per-character attribution | ❌ |

**Note:** Google does not expose the Docs API JSON structure for old revisions. You can only export them to PDF/DOCX/TXT.

---

## Effort Estimate

| Component | Effort |
|-----------|--------|
| Command parsing | Low |
| Drive API integration | Medium (may already exist) |
| Download handling | Medium |
| Output formatting | Low |
| Tests | Low |
| **Total** | **~4-6 hours** |

---

## Related GIPs

* [gog-docs-comments](./gogcli-GIP-gog-docs-comments.md) - Also uses Drive API
