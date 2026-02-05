# GIP: `gog docs suggestions` Subcommand

**GIP ID:** gog-docs-suggestions
**Status:** Proposed
**Phase:** 1 (Read-Only Extensions)
**Effort:** Easy
**Value:** Medium
**Parent:** [gog-docs-overview](./gogcli-GIP-gog-docs-overview.md)

---

## Summary

Add `gog docs suggestions` subcommand to list pending suggestions (track changes) in a Google Doc, showing what text would be inserted or deleted.

---

## Proposed Commands

```bash
# List all suggestions
gog docs suggestions --docid DOCUMENT_ID

# Output as JSON
gog docs suggestions --docid DOCUMENT_ID --json

# Show document preview with suggestions accepted
gog docs suggestions --docid DOCUMENT_ID --preview accepted

# Show document preview with suggestions rejected
gog docs suggestions --docid DOCUMENT_ID --preview rejected
```

---

## Example Output

### Table (default TTY)

```
SUGGESTION ID      TYPE        AUTHOR            ORIGINAL TEXT       SUGGESTED TEXT
─────────────────  ──────────  ────────────────  ──────────────────  ──────────────────
kix.sug123abc      Insert      john@example      -                   "new paragraph"
kix.sug456def      Delete      jane@example      "remove this"       -
kix.sug789ghi      Replace     bob@example       "old text"          "new text"
```

### JSON (`--json`)

```json
[
  {
    "suggestionId": "kix.sug123abc",
    "type": "insert",
    "startIndex": 150,
    "endIndex": 165,
    "suggestedText": "new paragraph",
    "originalText": null,
    "textStyle": {
      "bold": false,
      "italic": true
    }
  },
  {
    "suggestionId": "kix.sug456def",
    "type": "delete",
    "startIndex": 200,
    "endIndex": 212,
    "suggestedText": null,
    "originalText": "remove this"
  }
]
```

---

## Use Cases

### 1. Review Pending Changes

```bash
# Count suggestions by type
gog docs suggestions --docid ID --json | jq 'group_by(.type) | map({type: .[0].type, count: length})'
```

### 2. Export Suggestions for Review

```bash
# Create a review document
gog docs suggestions --docid ID --json > suggestions.json
```

### 3. Preview Document After Accept All

```bash
# See what document would look like with all suggestions accepted
gog docs suggestions --docid ID --preview accepted | less
```

### 4. Validate Before Publishing

```bash
# Check if any suggestions are pending
PENDING=$(gog docs suggestions --docid ID --json | jq length)
if [ "$PENDING" -gt 0 ]; then
    echo "Warning: $PENDING pending suggestions"
fi
```

---

## Technical Implementation

### API Used

**Method:** `documents.get` with `suggestionsViewMode` parameter

### API Calls

```go
// Get document with suggestions inline (default)
doc, err := docsService.Documents.Get(docID).
    SuggestionsViewMode("SUGGESTIONS_INLINE").
    Do()

// Get document as if all suggestions accepted
doc, err := docsService.Documents.Get(docID).
    SuggestionsViewMode("PREVIEW_SUGGESTIONS_ACCEPTED").
    Do()

// Get document as if all suggestions rejected
doc, err := docsService.Documents.Get(docID).
    SuggestionsViewMode("PREVIEW_WITHOUT_SUGGESTIONS").
    Do()
```

### Data Extraction

Look for elements with `suggestedInsertionIds` or `suggestedDeletionIds`:

```go
type Suggestion struct {
    SuggestionID  string     `json:"suggestionId"`
    Type          string     `json:"type"` // insert, delete, replace
    StartIndex    int64      `json:"startIndex"`
    EndIndex      int64      `json:"endIndex"`
    SuggestedText string     `json:"suggestedText,omitempty"`
    OriginalText  string     `json:"originalText,omitempty"`
    TextStyle     *TextStyle `json:"textStyle,omitempty"`
}

func extractSuggestions(doc *docs.Document) []Suggestion {
    var suggestions []Suggestion

    for _, elem := range doc.Body.Content {
        if elem.Paragraph == nil {
            continue
        }

        for _, pe := range elem.Paragraph.Elements {
            if pe.TextRun == nil {
                continue
            }

            // Check for insertions
            if len(pe.TextRun.SuggestedInsertionIds) > 0 {
                for _, sugID := range pe.TextRun.SuggestedInsertionIds {
                    suggestions = append(suggestions, Suggestion{
                        SuggestionID:  sugID,
                        Type:          "insert",
                        StartIndex:    pe.StartIndex,
                        EndIndex:      pe.EndIndex,
                        SuggestedText: pe.TextRun.Content,
                    })
                }
            }

            // Check for deletions
            if len(pe.TextRun.SuggestedDeletionIds) > 0 {
                for _, sugID := range pe.TextRun.SuggestedDeletionIds {
                    suggestions = append(suggestions, Suggestion{
                        SuggestionID: sugID,
                        Type:         "delete",
                        StartIndex:   pe.StartIndex,
                        EndIndex:     pe.EndIndex,
                        OriginalText: pe.TextRun.Content,
                    })
                }
            }
        }
    }

    return suggestions
}
```

---

## API Reference

* [SuggestionsViewMode](https://developers.google.com/workspace/docs/api/reference/rest/v1/documents/get#suggestionsviewmode)
* [Work with Suggestions](https://developers.google.com/workspace/docs/api/how-tos/suggestions)

---

## Limitations

| Feature | Supported |
|---------|:---------:|
| Read suggestions | ✅ |
| Preview with accepted/rejected | ✅ |
| Create suggestions | ❌ |
| Accept suggestions | ❌ |
| Reject suggestions | ❌ |

**Note:** The API can only READ suggestions. Accept/reject must be done in the UI.

---

## Effort Estimate

| Component | Effort |
|-----------|--------|
| Command parsing | Low |
| API call (modify existing) | Low |
| Data extraction | Medium |
| Output formatting | Low |
| Tests | Low |
| **Total** | **~3-4 hours** |

---

## Related GIPs

* [gog-docs-comments](./gogcli-GIP-gog-docs-comments.md) - Similar collaboration feature
