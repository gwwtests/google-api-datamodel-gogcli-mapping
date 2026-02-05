# GIP: `gog docs named-ranges` Subcommand

**GIP ID:** gog-docs-named-ranges
**Status:** Proposed
**Phase:** 1 (Read-Only Extensions)
**Effort:** Easy
**Value:** High
**Parent:** [gog-docs-overview](./gogcli-GIP-gog-docs-overview.md)

---

## Summary

Add `gog docs named-ranges` subcommand to list and manage named ranges in a Google Doc, enabling template automation and programmatic content tracking.

---

## Proposed Commands

```bash
# List all named ranges
gog docs named-ranges list --docid DOCUMENT_ID

# Get content of a specific named range
gog docs named-ranges get --docid DOCUMENT_ID --name "customer_address"

# Output as JSON
gog docs named-ranges list --docid DOCUMENT_ID --json
```

---

## Example Output

### Table (default TTY)

```
NAME                RANGE ID           START   END    CONTENT PREVIEW
──────────────────  ─────────────────  ─────   ─────  ─────────────────────
customer_name       kix.nr123abc       45      62     {{customer_name}}
customer_address    kix.nr456def       100     150    123 Main Street...
signature_block     kix.nr789ghi       500     550    Sincerely, [Name]
```

### JSON (`--json`)

```json
{
  "customer_name": {
    "namedRangeId": "kix.nr123abc",
    "name": "customer_name",
    "ranges": [
      {
        "startIndex": 45,
        "endIndex": 62,
        "content": "{{customer_name}}"
      }
    ]
  },
  "customer_address": {
    "namedRangeId": "kix.nr456def",
    "name": "customer_address",
    "ranges": [
      {
        "startIndex": 100,
        "endIndex": 150,
        "content": "123 Main Street, City, State 12345"
      }
    ]
  }
}
```

---

## Use Cases

### 1. Template Validation

```bash
# Check if document has all required placeholders
REQUIRED=("customer_name" "customer_address" "order_number")
EXISTING=$(gog docs named-ranges list --docid ID --json | jq -r 'keys[]')

for name in "${REQUIRED[@]}"; do
    if ! echo "$EXISTING" | grep -q "^$name$"; then
        echo "Missing: $name"
    fi
done
```

### 2. Extract Section Content

```bash
# Get content of a specific section
gog docs named-ranges get --docid ID --name "executive_summary"
```

### 3. Pre-fill Template Values

```bash
# List all placeholders and their current values
gog docs named-ranges list --docid ID --json | jq -r 'to_entries[] | "\(.key): \(.value.ranges[0].content)"'
```

Output:
```
customer_name: {{customer_name}}
customer_address: {{customer_address}}
order_number: ORD-12345
```

### 4. Document Automation Pipeline

```bash
# Export template, validate ranges, then use replace command
gog docs named-ranges list --docid TEMPLATE_ID --json > ranges.json
# Process ranges.json to prepare replacements
gog docs replace --docid NEW_DOC --find "{{customer_name}}" --replace "John Smith"
```

---

## Technical Implementation

### API Used

**Method:** `documents.get` (already implemented)

**Fields needed:** `namedRanges` (top-level field in Document response)

### Data Extraction

```go
type NamedRange struct {
    NamedRangeID string       `json:"namedRangeId"`
    Name         string       `json:"name"`
    Ranges       []RangeInfo  `json:"ranges"`
}

type RangeInfo struct {
    StartIndex int64  `json:"startIndex"`
    EndIndex   int64  `json:"endIndex"`
    Content    string `json:"content,omitempty"`
}

func extractNamedRanges(doc *docs.Document) map[string]NamedRange {
    result := make(map[string]NamedRange)

    for name, nr := range doc.NamedRanges {
        ranges := make([]RangeInfo, 0, len(nr.Ranges))

        for _, r := range nr.Ranges {
            content := extractTextInRange(doc, r.StartIndex, r.EndIndex)
            ranges = append(ranges, RangeInfo{
                StartIndex: r.StartIndex,
                EndIndex:   r.EndIndex,
                Content:    content,
            })
        }

        result[name] = NamedRange{
            NamedRangeID: nr.NamedRangeId,
            Name:         name,
            Ranges:       ranges,
        }
    }

    return result
}
```

### Document Structure

```json
{
  "namedRanges": {
    "customer_name": {
      "namedRangeId": "kix.nr123abc",
      "name": "customer_name",
      "ranges": [
        {
          "startIndex": 45,
          "endIndex": 62
        }
      ]
    }
  }
}
```

---

## API Reference

* [NamedRange](https://developers.google.com/workspace/docs/api/reference/rest/v1/documents#namedrange)
* [CreateNamedRangeRequest](https://developers.google.com/workspace/docs/api/reference/rest/v1/documents/batchUpdate#createnamedrangerequest)

---

## Effort Estimate

| Component | Effort |
|-----------|--------|
| Command parsing | Low |
| API call | None (reuse existing) |
| Data extraction | Low |
| Content extraction | Medium |
| Output formatting | Low |
| Tests | Low |
| **Total** | **~3-4 hours** |

---

## Related GIPs

* [gog-docs-replace](./gogcli-GIP-gog-docs-replace.md) - Use named ranges for template replacement
* [gog-docs-headings](./gogcli-GIP-gog-docs-headings.md) - Alternative section identification
