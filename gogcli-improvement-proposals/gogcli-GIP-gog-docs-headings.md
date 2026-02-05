# GIP: `gog docs headings` Subcommand

**GIP ID:** gog-docs-headings
**Status:** Proposed
**Phase:** 1 (Read-Only Extensions)
**Effort:** Easy
**Value:** High
**Parent:** [gog-docs-overview](./gogcli-GIP-gog-docs-overview.md)

---

## Summary

Add `gog docs headings` subcommand to list all headings in a Google Doc with their IDs, enabling document navigation, TOC generation, and section-based content extraction.

---

## Proposed Commands

```bash
# List all headings
gog docs headings --docid DOCUMENT_ID

# Output as JSON
gog docs headings --docid DOCUMENT_ID --json

# Output as plain TSV
gog docs headings --docid DOCUMENT_ID --plain

# Filter by level
gog docs headings --docid DOCUMENT_ID --level 1,2

# Generate URLs
gog docs headings --docid DOCUMENT_ID --urls
```

---

## Example Output

### Table (default TTY)

```
LEVEL  HEADING ID       TEXT
─────  ───────────────  ──────────────────────────
1      h.abc123         Introduction
2      h.def456         Background
2      h.ghi789         Problem Statement
1      h.jkl012         Methodology
2      h.mno345         Data Collection
1      h.pqr678         Results
1      h.stu901         Conclusion
```

### JSON (`--json`)

```json
[
  {
    "level": 1,
    "headingId": "h.abc123",
    "text": "Introduction",
    "startIndex": 1,
    "endIndex": 13,
    "url": "https://docs.google.com/document/d/DOC_ID/edit#heading=h.abc123"
  },
  {
    "level": 2,
    "headingId": "h.def456",
    "text": "Background",
    "startIndex": 14,
    "endIndex": 25,
    "url": "https://docs.google.com/document/d/DOC_ID/edit#heading=h.def456"
  }
]
```

### Plain TSV (`--plain`)

```
1	h.abc123	Introduction
2	h.def456	Background
2	h.ghi789	Problem Statement
1	h.jkl012	Methodology
```

---

## Use Cases

### 1. Generate Table of Contents

```bash
gog docs headings --docid ID --json | jq -r '.[] | "- [\(.text)](\(.url))"'
```

Output:
```markdown
- [Introduction](https://docs.google.com/document/d/.../edit#heading=h.abc123)
- [Background](https://docs.google.com/document/d/.../edit#heading=h.def456)
```

### 2. Extract Specific Section

```bash
# Get heading index, then extract text between headings
INTRO_START=$(gog docs headings --docid ID --json | jq '.[] | select(.text=="Introduction") | .startIndex')
gog docs cat --docid ID --start $INTRO_START --end $NEXT_HEADING_START
```

### 3. Document Structure Validation

```bash
# Check if document has required sections
gog docs headings --docid ID --json | jq '[.[] | .text] | contains(["Introduction", "Methodology", "Conclusion"])'
```

### 4. Navigation Links for Wiki/README

```bash
gog docs headings --docid ID --urls --plain
```

---

## Technical Implementation

### API Used

**Method:** `documents.get` (already implemented for `cat` and `info`)

**Fields needed:** `body.content[].paragraph.paragraphStyle.namedStyleType`, `body.content[].paragraph.paragraphStyle.headingId`

### Data Extraction

```go
type Heading struct {
    Level     int    `json:"level"`
    HeadingID string `json:"headingId"`
    Text      string `json:"text"`
    StartIndex int64 `json:"startIndex"`
    EndIndex   int64 `json:"endIndex"`
    URL       string `json:"url,omitempty"`
}

func extractHeadings(doc *docs.Document) []Heading {
    var headings []Heading

    for _, elem := range doc.Body.Content {
        if elem.Paragraph == nil {
            continue
        }

        style := elem.Paragraph.ParagraphStyle
        if style == nil || style.HeadingId == "" {
            continue
        }

        level := parseHeadingLevel(style.NamedStyleType) // HEADING_1 -> 1
        if level == 0 {
            continue
        }

        text := extractParagraphText(elem.Paragraph)

        headings = append(headings, Heading{
            Level:      level,
            HeadingID:  style.HeadingId,
            Text:       strings.TrimSpace(text),
            StartIndex: elem.StartIndex,
            EndIndex:   elem.EndIndex,
            URL:        fmt.Sprintf("https://docs.google.com/document/d/%s/edit#heading=%s", docID, style.HeadingId),
        })
    }

    return headings
}

func parseHeadingLevel(namedStyleType string) int {
    switch namedStyleType {
    case "HEADING_1": return 1
    case "HEADING_2": return 2
    case "HEADING_3": return 3
    case "HEADING_4": return 4
    case "HEADING_5": return 5
    case "HEADING_6": return 6
    default: return 0
    }
}
```

### Command Structure

```go
type DocsHeadingsCmd struct {
    DocID  string `arg:"" required:"" help:"Document ID or URL"`
    Level  []int  `help:"Filter by heading levels (e.g., --level 1,2)"`
    URLs   bool   `help:"Include URLs in output"`
    JSON   bool   `help:"Output as JSON"`
    Plain  bool   `help:"Output as plain TSV"`
}
```

---

## API Reference

* [Document Structure](https://developers.google.com/workspace/docs/api/concepts/structure)
* [ParagraphStyle.headingId](https://developers.google.com/workspace/docs/api/reference/rest/v1/documents#paragraphstyle)
* [NamedStyleType enum](https://developers.google.com/workspace/docs/api/reference/rest/v1/documents#namedstyletype)

---

## Effort Estimate

| Component | Effort |
|-----------|--------|
| Command parsing | Low |
| API call | None (reuse existing) |
| Data extraction | Low |
| Output formatting | Low |
| Tests | Low |
| **Total** | **~2-4 hours** |

---

## Related GIPs

* [gog-docs-bookmarks](./gogcli-GIP-gog-docs-bookmarks.md) - Similar structure extraction
* [gog-docs-named-ranges](./gogcli-GIP-gog-docs-named-ranges.md) - Section-based automation
