# GIP: `gog docs bookmarks` Subcommand

**GIP ID:** gog-docs-bookmarks
**Status:** Proposed
**Phase:** 1 (Read-Only Extensions)
**Effort:** Easy
**Value:** Medium
**Parent:** [gog-docs-overview](./gogcli-GIP-gog-docs-overview.md)

---

## Summary

Add `gog docs bookmarks` subcommand to list all bookmarks in a Google Doc with their IDs and positions, enabling deep linking and navigation.

---

## Proposed Commands

```bash
# List all bookmarks
gog docs bookmarks --docid DOCUMENT_ID

# Output as JSON
gog docs bookmarks --docid DOCUMENT_ID --json

# Generate shareable URLs
gog docs bookmarks --docid DOCUMENT_ID --urls
```

---

## Example Output

### Table (default TTY)

```
BOOKMARK ID        INDEX   CONTEXT (±20 chars)
─────────────────  ─────   ─────────────────────────────────
kix.abc123xyz      156     ...important section starts here...
kix.def456uvw      892     ...see footnote reference below...
kix.ghi789rst      1205    ...conclusion of the analysis...
```

### JSON (`--json`)

```json
[
  {
    "bookmarkId": "kix.abc123xyz",
    "index": 156,
    "context": "important section starts here",
    "url": "https://docs.google.com/document/d/DOC_ID/edit#bookmark=id.kix.abc123xyz"
  }
]
```

---

## Use Cases

### 1. Share Deep Links

```bash
# Get URL for specific bookmark
gog docs bookmarks --docid ID --json | jq -r '.[] | select(.bookmarkId=="kix.abc123xyz") | .url'
```

### 2. Validate Document Has Required Anchors

```bash
# Check if "important_section" bookmark exists
gog docs bookmarks --docid ID --json | jq 'any(.bookmarkId == "kix.important_section")'
```

### 3. Export All Deep Links for Documentation

```bash
gog docs bookmarks --docid ID --urls --plain > bookmarks.txt
```

---

## Technical Implementation

### API Used

**Method:** `documents.get` (already implemented)

**Fields needed:** Bookmarks are referenced in `TextStyle.link.bookmarkId` and stored implicitly at document positions.

### Data Extraction

```go
type Bookmark struct {
    BookmarkID string `json:"bookmarkId"`
    Index      int64  `json:"index"`
    Context    string `json:"context,omitempty"`
    URL        string `json:"url,omitempty"`
}

func extractBookmarks(doc *docs.Document, docID string) []Bookmark {
    var bookmarks []Bookmark
    seen := make(map[string]bool)

    // Walk through all text runs looking for bookmark links
    for _, elem := range doc.Body.Content {
        if elem.Paragraph == nil {
            continue
        }

        for _, pe := range elem.Paragraph.Elements {
            if pe.TextRun == nil || pe.TextRun.TextStyle == nil {
                continue
            }

            link := pe.TextRun.TextStyle.Link
            if link == nil || link.BookmarkId == "" {
                continue
            }

            if seen[link.BookmarkId] {
                continue
            }
            seen[link.BookmarkId] = true

            bookmarks = append(bookmarks, Bookmark{
                BookmarkID: link.BookmarkId,
                Index:      pe.StartIndex,
                URL:        fmt.Sprintf("https://docs.google.com/document/d/%s/edit#bookmark=id.%s", docID, link.BookmarkId),
            })
        }
    }

    return bookmarks
}
```

---

## API Reference

* [Link.bookmarkId](https://developers.google.com/workspace/docs/api/reference/rest/v1/documents#link)
* [Work with links & bookmarks](https://support.google.com/docs/answer/45893)

---

## Effort Estimate

| Component | Effort |
|-----------|--------|
| Command parsing | Low |
| API call | None (reuse existing) |
| Data extraction | Low |
| Output formatting | Low |
| Tests | Low |
| **Total** | **~2-3 hours** |

---

## Related GIPs

* [gog-docs-headings](./gogcli-GIP-gog-docs-headings.md) - Similar navigation feature
* [gog-docs-named-ranges](./gogcli-GIP-gog-docs-named-ranges.md) - Alternative anchor mechanism
