# GIP: `gog docs replace` Subcommand

**GIP ID:** gog-docs-replace
**Status:** Proposed
**Phase:** 2 (Simple Modifications)
**Effort:** Medium
**Value:** High
**Parent:** [gog-docs-overview](./gogcli-GIP-gog-docs-overview.md)

---

## Summary

Add `gog docs replace` subcommand to perform find-and-replace operations in a Google Doc, enabling template automation and bulk text updates.

---

## Proposed Commands

```bash
# Simple find and replace
gog docs replace --docid DOCUMENT_ID --find "{{customer_name}}" --replace "John Smith"

# Case-sensitive (default is case-insensitive)
gog docs replace --docid DOCUMENT_ID --find "TODO" --replace "DONE" --case-sensitive

# Multiple replacements from file
gog docs replace --docid DOCUMENT_ID --from-file replacements.json

# Dry run (show what would be replaced)
gog docs replace --docid DOCUMENT_ID --find "old" --replace "new" --dry-run

# Replace all instances
gog docs replace --docid DOCUMENT_ID --find "2025" --replace "2026"
```

---

## Example Output

### Dry Run

```
DRY RUN: Would replace 3 occurrences

  Line 15: "Welcome, {{customer_name}}!" → "Welcome, John Smith!"
  Line 42: "Dear {{customer_name}}," → "Dear John Smith,"
  Line 89: "Sincerely, {{customer_name}}" → "Sincerely, John Smith"

Use --execute to apply changes.
```

### After Execution

```
Replaced 3 occurrences of "{{customer_name}}" with "John Smith"
Document revision: ALm37BVxyz...
```

### JSON Output (`--json`)

```json
{
  "replacements": 3,
  "revisionId": "ALm37BVxyz...",
  "matches": [
    {
      "startIndex": 45,
      "endIndex": 62,
      "original": "{{customer_name}}",
      "replacement": "John Smith"
    }
  ]
}
```

---

## Use Cases

### 1. Template Fill

```bash
# Fill a contract template
gog docs replace --docid CONTRACT_ID \
    --find "{{customer_name}}" --replace "Acme Corp" \
    --find "{{date}}" --replace "2026-02-05" \
    --find "{{amount}}" --replace "$10,000"
```

### 2. Bulk Update from JSON

```bash
# replacements.json
# {
#   "{{customer_name}}": "John Smith",
#   "{{customer_address}}": "123 Main St",
#   "{{order_number}}": "ORD-12345"
# }

gog docs replace --docid ID --from-file replacements.json
```

### 3. Year Update

```bash
# Update copyright year across document
gog docs replace --docid ID --find "2025" --replace "2026"
```

### 4. Validate Before Replace

```bash
# Dry run first
gog docs replace --docid ID --find "{{placeholder}}" --replace "value" --dry-run

# If looks good, execute
gog docs replace --docid ID --find "{{placeholder}}" --replace "value"
```

---

## Technical Implementation

### API Used

**Method:** `documents.batchUpdate` with `ReplaceAllTextRequest`

### API Call

```go
req := &docs.BatchUpdateDocumentRequest{
    Requests: []*docs.Request{
        {
            ReplaceAllText: &docs.ReplaceAllTextRequest{
                ContainsText: &docs.SubstringMatchCriteria{
                    Text:      findText,
                    MatchCase: caseSensitive,
                },
                ReplaceText: replaceText,
            },
        },
    },
}

resp, err := docsService.Documents.BatchUpdate(docID, req).Do()
```

### Response Structure

```json
{
  "documentId": "...",
  "replies": [
    {
      "replaceAllText": {
        "occurrencesChanged": 3
      }
    }
  ],
  "writeControl": {
    "requiredRevisionId": "ALm37BVxyz..."
  }
}
```

### Command Structure

```go
type DocsReplaceCmd struct {
    DocID         string   `arg:"" required:"" help:"Document ID or URL"`
    Find          []string `help:"Text to find (can specify multiple)"`
    Replace       []string `help:"Replacement text (paired with --find)"`
    FromFile      string   `help:"JSON file with find/replace pairs"`
    CaseSensitive bool     `help:"Case-sensitive matching" default:"false"`
    DryRun        bool     `help:"Show what would be replaced without making changes"`
    JSON          bool     `help:"Output as JSON"`
}
```

### Dry Run Implementation

```go
func dryRun(doc *docs.Document, findText, replaceText string, caseSensitive bool) []Match {
    var matches []Match
    text := extractFullText(doc)

    // Find all occurrences
    searchText := findText
    if !caseSensitive {
        text = strings.ToLower(text)
        searchText = strings.ToLower(searchText)
    }

    idx := 0
    for {
        pos := strings.Index(text[idx:], searchText)
        if pos == -1 {
            break
        }

        actualPos := idx + pos
        matches = append(matches, Match{
            StartIndex:  actualPos,
            Original:    findText, // Preserve original case
            Replacement: replaceText,
            Context:     getContext(text, actualPos, 20),
        })

        idx = actualPos + len(searchText)
    }

    return matches
}
```

---

## API Reference

* [ReplaceAllTextRequest](https://developers.google.com/workspace/docs/api/reference/rest/v1/documents/batchUpdate#replacealltextrequest)
* [SubstringMatchCriteria](https://developers.google.com/workspace/docs/api/reference/rest/v1/documents#substringmatchcriteria)
* [BatchUpdateDocumentResponse](https://developers.google.com/workspace/docs/api/reference/rest/v1/documents/batchUpdate#response-body)

---

## Safety Considerations

| Risk | Mitigation |
|------|------------|
| Accidental data loss | `--dry-run` by default for first use |
| Wrong replacements | Show context in dry run output |
| Concurrent edits | API handles via revision control |
| Partial failures | batchUpdate is atomic (all or nothing) |

### Recommended Workflow

1. Always run with `--dry-run` first
2. Review the matches and context
3. Execute without `--dry-run` if satisfied
4. Note the revision ID for potential rollback

---

## Effort Estimate

| Component | Effort |
|-----------|--------|
| Command parsing | Low |
| batchUpdate integration | Medium |
| Dry run implementation | Medium |
| From-file parsing | Low |
| Output formatting | Low |
| Tests | Medium |
| **Total** | **~6-8 hours** |

---

## Limitations

| Feature | Supported |
|---------|:---------:|
| Simple text replacement | ✅ |
| Case-insensitive matching | ✅ |
| Multiple replacements | ✅ |
| Regex patterns | ❌ |
| Format-aware replacement | ❌ |
| Replace in headers/footers | ✅ |
| Replace in tables | ✅ |

---

## Related GIPs

* [gog-docs-named-ranges](./gogcli-GIP-gog-docs-named-ranges.md) - Identify placeholders for replacement
