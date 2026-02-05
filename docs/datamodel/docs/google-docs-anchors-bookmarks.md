# Google Docs Anchors, Bookmarks & Named Ranges

**Research Date:** 2026-02-05
**Purpose:** Document how to mark and reference specific locations in Google Docs via API

---

## Overview

Google Docs provides three mechanisms for marking and referencing specific document locations:

| Mechanism | Purpose | API Support | Persistence |
|-----------|---------|-------------|-------------|
| **Bookmarks** | User-visible anchors for internal links | ✅ Full | Survives edits |
| **Named Ranges** | Programmatic labels for text ranges | ✅ Full | May shift with edits |
| **Heading Links** | Auto-generated links to headings | ✅ Read | Auto-maintained |

---

## 1. Bookmarks

Bookmarks are invisible markers at specific positions that can be linked to. They're ideal for:

* Creating internal navigation (jump links)
* External URLs that open document at specific location
* Stable reference points that survive text edits

### API Operations

**Create Bookmark:**

```json
{
  "createNamedRange": null,
  "requests": [{
    "createParagraphBullets": null
  }]
}
```

Actually, bookmarks use `Link` with `bookmarkId`:

**Read Bookmarks:**

```json
// In documents.get response:
{
  "body": {
    "content": [{
      "paragraph": {
        "elements": [{
          "textRun": {
            "textStyle": {
              "link": {
                "bookmarkId": "kix.abc123xyz",
                "tabId": "t.0"
              }
            }
          }
        }]
      }
    }]
  }
}
```

**Link Structure:**

```json
{
  "link": {
    "bookmarkId": "kix.abc123xyz",  // Internal bookmark reference
    "tabId": "t.0"                   // Tab containing bookmark (multi-tab docs)
  }
}
```

### Creating a Link to Bookmark

Use `UpdateTextStyleRequest` to add a bookmark link:

```json
{
  "updateTextStyle": {
    "range": {
      "startIndex": 10,
      "endIndex": 25
    },
    "textStyle": {
      "link": {
        "bookmarkId": "kix.abc123xyz"
      }
    },
    "fields": "link"
  }
}
```

### External URL to Bookmark

Format: `https://docs.google.com/document/d/{docId}/edit#bookmark=id.{bookmarkId}`

Example: `https://docs.google.com/document/d/1abc.../edit#bookmark=id.kix.xyz123`

---

## 2. Named Ranges

Named ranges label a span of text with a programmatic identifier. They're ideal for:

* Tracking specific content sections programmatically
* Template placeholders (e.g., `{{customer_name}}`)
* Flagging sections for review or processing
* Building document automation workflows

### API Operations

**Create Named Range:**

```json
{
  "createNamedRange": {
    "name": "customer_address",
    "range": {
      "startIndex": 100,
      "endIndex": 150
    }
  }
}
```

**Response:**

```json
{
  "replies": [{
    "createNamedRange": {
      "namedRangeId": "kix.namedrange123"
    }
  }]
}
```

**Read Named Ranges:**

In `documents.get` response:

```json
{
  "namedRanges": {
    "customer_address": {
      "namedRangeId": "kix.namedrange123",
      "name": "customer_address",
      "ranges": [{
        "startIndex": 100,
        "endIndex": 150
      }]
    }
  }
}
```

**Delete Named Range:**

```json
{
  "deleteNamedRange": {
    "namedRangeId": "kix.namedrange123"
  }
}
```

Or by name:

```json
{
  "deleteNamedRange": {
    "name": "customer_address"
  }
}
```

### Use Case: Template Placeholders

1. Create document with placeholder text: `{{customer_name}}`
2. Create named range covering the placeholder
3. Later, use `ReplaceAllTextRequest` or delete range + insert text
4. Named range tracks position even if surrounding text changes

```json
// Step 1: Find placeholder and create named range
{
  "createNamedRange": {
    "name": "placeholder_customer_name",
    "range": {
      "startIndex": 45,
      "endIndex": 62  // covers "{{customer_name}}"
    }
  }
}

// Step 2: Replace content (named range auto-adjusts)
{
  "replaceAllText": {
    "containsText": {
      "text": "{{customer_name}}",
      "matchCase": true
    },
    "replaceText": "John Smith"
  }
}
```

### Important: Named Range Behavior

* **Multiple ranges:** A single named range can span multiple non-contiguous ranges
* **Index shifting:** When text is inserted/deleted before a named range, indexes adjust automatically
* **Deletion:** Deleting all text in a named range doesn't delete the range itself (becomes zero-width)
* **Overlapping:** Multiple named ranges can overlap the same text

---

## 3. Heading Links

Headings (H1-H6) automatically get IDs that can be linked to. They're ideal for:

* Table of contents navigation
* Auto-maintained internal links
* Section references that update when heading text changes

### API Structure

**Read Heading ID:**

```json
{
  "paragraph": {
    "paragraphStyle": {
      "namedStyleType": "HEADING_1",
      "headingId": "h.abc123xyz"
    },
    "elements": [{
      "textRun": {
        "content": "Introduction\n"
      }
    }]
  }
}
```

**Link to Heading:**

```json
{
  "updateTextStyle": {
    "range": {
      "startIndex": 500,
      "endIndex": 520
    },
    "textStyle": {
      "link": {
        "headingId": "h.abc123xyz"
      }
    },
    "fields": "link"
  }
}
```

### External URL to Heading

Format: `https://docs.google.com/document/d/{docId}/edit#heading=h.{headingId}`

---

## 4. Comparison: When to Use What

| Scenario | Best Choice | Why |
|----------|-------------|-----|
| Jump to specific section | Heading Link | Auto-maintained, semantic |
| Mark arbitrary position | Bookmark | Stable, survives edits |
| Track content for automation | Named Range | Programmatic access, spans text |
| Template placeholder | Named Range | Can be replaced programmatically |
| External URL to location | Bookmark or Heading | Works in URL fragment |
| Comment-like markers | Named Range + Comment | Combine for visibility |

---

## 5. URL Fragment Formats

| Type | URL Format |
|------|------------|
| Bookmark | `https://docs.google.com/document/d/{docId}/edit#bookmark=id.{bookmarkId}` |
| Heading | `https://docs.google.com/document/d/{docId}/edit#heading=h.{headingId}` |

**Note:** Named ranges don't have a URL fragment format - they're for programmatic use only.

---

## 6. gogcli Implications

Currently gogcli has **no support** for bookmarks, named ranges, or heading links.

**Potential enhancements:**

* `gog docs bookmarks list` - List all bookmarks in document
* `gog docs named-ranges list` - List named ranges
* `gog docs named-ranges create --name "foo" --start 10 --end 20`
* `gog docs headings list` - List all headings with IDs (for linking)
* `gog docs url --bookmark id.xyz` - Generate URL to specific location

**Use case: Document automation**

```bash
# Export document sections by named range
gog docs cat --docid ID --range "section_intro"
gog docs cat --docid ID --range "section_conclusion"
```

---

## 7. API Reference Links

* [Link structure](https://developers.google.com/workspace/docs/api/reference/rest/v1/documents#link)
* [Named Ranges](https://developers.google.com/workspace/docs/api/reference/rest/v1/documents#namedrange)
* [CreateNamedRangeRequest](https://developers.google.com/workspace/docs/api/reference/rest/v1/documents/batchUpdate#createnamedrangerequest)
* [DeleteNamedRangeRequest](https://developers.google.com/workspace/docs/api/reference/rest/v1/documents/batchUpdate#deletenamedrangerequest)
* [Work with links & bookmarks (Support)](https://support.google.com/docs/answer/45893)

---

## 8. Code Examples

### Python: Create Named Range and Link to It

```python
from googleapiclient.discovery import build

def create_named_range_with_link(doc_id, range_name, start, end, link_text_start, link_text_end):
    """Create a named range and a link pointing to it."""

    service = build('docs', 'v1', credentials=creds)

    requests = [
        # Create the named range
        {
            'createNamedRange': {
                'name': range_name,
                'range': {
                    'startIndex': start,
                    'endIndex': end
                }
            }
        }
    ]

    result = service.documents().batchUpdate(
        documentId=doc_id,
        body={'requests': requests}
    ).execute()

    # Note: To link to a named range, you'd typically use a bookmark
    # Named ranges are for programmatic tracking, not direct linking

    return result
```

### Python: List All Headings for Navigation

```python
def list_headings(doc_id):
    """Extract all headings with their IDs for building navigation."""

    service = build('docs', 'v1', credentials=creds)
    doc = service.documents().get(documentId=doc_id).execute()

    headings = []

    for element in doc.get('body', {}).get('content', []):
        if 'paragraph' in element:
            para = element['paragraph']
            style = para.get('paragraphStyle', {})
            named_style = style.get('namedStyleType', '')

            if named_style.startswith('HEADING_'):
                heading_id = style.get('headingId')
                text = ''.join(
                    e.get('textRun', {}).get('content', '')
                    for e in para.get('elements', [])
                ).strip()

                headings.append({
                    'level': int(named_style.split('_')[1]),
                    'text': text,
                    'headingId': heading_id,
                    'url': f"https://docs.google.com/document/d/{doc_id}/edit#heading={heading_id}"
                })

    return headings
```

---

## TODO for Future Verification

- [ ] Test bookmark creation via API (confirm request type)
- [ ] Verify bookmark URL fragment format works
- [ ] Test named range behavior when text is deleted
- [ ] Check if named ranges can be linked to directly (or only via bookmarks)
- [ ] Explore combining named ranges with comments for suggestion-like workflow
