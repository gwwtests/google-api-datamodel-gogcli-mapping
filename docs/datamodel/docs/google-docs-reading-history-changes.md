# Google Docs: Reading Content, History & Change Detection

**Research Date:** 2026-02-05
**Purpose:** Answer key questions about reading documents, tracking changes, and detecting updates

---

## Quick Answers

| Question | Answer | API |
|----------|--------|-----|
| Can we read document contents? | ✅ **Yes, fully** | Docs API `documents.get` |
| Can we read history snapshots? | ✅ **Yes** | Drive API `revisions.list/get` |
| Can we see who made changes? | ⚠️ **Per-revision only** | `revision.lastModifyingUser` |
| Can we get granular change diffs? | ❌ **No** | Must compute yourself |
| Can we get real-time update notifications? | ⚠️ **File-level only** | Drive API `changes.watch` |
| Do notifications include diffs? | ❌ **No** | Notification = "something changed", fetch yourself |

---

## 1. Reading Document Contents

### ✅ Fully Supported

**API Method:** `documents.get`

**Reference:** https://developers.google.com/workspace/docs/api/reference/rest/v1/documents/get

```bash
GET https://docs.googleapis.com/v1/documents/{documentId}
```

**Response includes:**

| Field | Content |
|-------|---------|
| `body.content[]` | Full document structure (paragraphs, tables, lists, etc.) |
| `headers{}` | All header content indexed by ID |
| `footers{}` | All footer content indexed by ID |
| `footnotes{}` | All footnote content indexed by ID |
| `namedRanges{}` | All named ranges with positions |
| `lists{}` | List definitions (bullet styles, nesting) |
| `inlineObjects{}` | Images and embedded objects |
| `positionedObjects{}` | Anchored/floating objects |
| `documentStyle` | Page setup (size, margins, orientation) |
| `namedStyles` | Style definitions (Heading 1, Normal, etc.) |
| `revisionId` | Current revision for conflict detection |
| `tabs[]` | Multi-tab document content (if applicable) |

**Example Response Structure:**

```json
{
  "documentId": "1abc...",
  "title": "My Document",
  "revisionId": "ALm37BV...",
  "body": {
    "content": [
      {
        "startIndex": 1,
        "endIndex": 50,
        "paragraph": {
          "elements": [
            {
              "startIndex": 1,
              "endIndex": 50,
              "textRun": {
                "content": "Hello world, this is my document content.\n",
                "textStyle": {
                  "bold": false,
                  "fontSize": {"magnitude": 11, "unit": "PT"}
                }
              }
            }
          ],
          "paragraphStyle": {
            "namedStyleType": "NORMAL_TEXT"
          }
        }
      }
    ]
  }
}
```

**Key Point:** You get the complete document structure with character-level indexes for every element.

---

## 2. Reading History Snapshots (Revisions)

### ✅ Supported via Drive API

**API Method:** `revisions.list` and `revisions.get`

**Reference:** https://developers.google.com/drive/api/guides/manage-revisions

```bash
# List all revisions
GET https://www.googleapis.com/drive/v3/files/{fileId}/revisions

# Get specific revision metadata
GET https://www.googleapis.com/drive/v3/files/{fileId}/revisions/{revisionId}
```

**Revision Metadata:**

```json
{
  "id": "revision-id",
  "modifiedTime": "2026-02-05T10:30:00.000Z",
  "lastModifyingUser": {
    "displayName": "John Smith",
    "emailAddress": "john@example.com",
    "photoLink": "https://..."
  },
  "keepForever": false,
  "published": false,
  "exportLinks": {
    "application/pdf": "https://...",
    "application/vnd.openxmlformats-officedocument.wordprocessingml.document": "https://..."
  }
}
```

### Downloading Revision Content

**Option 1: Export revision to PDF/DOCX**

```bash
GET https://www.googleapis.com/drive/v3/files/{fileId}/revisions/{revisionId}?alt=media
```

**Option 2: Export via exportLinks**

Each revision has `exportLinks` for various formats. However, **you cannot get the Docs JSON structure for past revisions** - only export formats.

### ⚠️ Limitations

| Limitation | Detail |
|------------|--------|
| **No JSON structure for old revisions** | Can only export to PDF/DOCX, not get Docs API JSON |
| **Revision list may be incomplete** | Google doesn't keep all micro-revisions; may aggregate |
| **Per-revision attribution only** | `lastModifyingUser` is one person, not per-character |
| **No granular diffs** | No API endpoint returns "what changed between revision A and B" |

---

## 3. Who Made What Changes?

### ⚠️ Limited to Per-Revision Attribution

**What you CAN get:**

* `revision.lastModifyingUser` - Who saved this revision
* `revision.modifiedTime` - When it was saved

**What you CANNOT get:**

* Per-character or per-paragraph attribution
* "User A typed this sentence, User B typed that sentence"
* Real-time cursor positions of collaborators

### Suggestions Have Attribution

If using **Suggesting Mode**, you can see who proposed each suggestion:

```json
{
  "textRun": {
    "suggestedInsertionIds": ["kix.suggestion123"],
    "content": "new text",
    "textStyle": {
      "suggestedTextStyleChanges": {
        "kix.suggestion123": {
          "textStyleSuggestionState": {...}
        }
      }
    }
  }
}
```

But this only works for **pending suggestions**, not accepted changes.

**Reference:** https://developers.google.com/workspace/docs/api/how-tos/suggestions

---

## 4. Real-Time Update Notifications

### ⚠️ File-Level Only via Drive API Watch

**API Method:** `changes.watch` or `files.watch`

**Reference:** https://developers.google.com/drive/api/guides/push

```python
# Set up webhook
channel = {
    'id': 'unique-channel-id',
    'type': 'web_hook',
    'address': 'https://your-server.com/webhook',
    'expiration': 1707134400000  # Unix timestamp ms
}

# Watch for changes
response = drive_service.files().watch(
    fileId='document-id',
    body=channel
).execute()
```

**Notification Payload:**

```http
POST /webhook HTTP/1.1
X-Goog-Channel-ID: unique-channel-id
X-Goog-Resource-ID: resource-id
X-Goog-Resource-State: update
X-Goog-Changed: content
```

### ❌ Notifications Do NOT Include Diffs

The notification only tells you:

* **Something changed** (`X-Goog-Resource-State: update`)
* **What kind of change** (`X-Goog-Changed: content` or `properties`)

**You must then:**

1. Call `documents.get` to fetch current content
2. Compare with your cached previous version
3. Compute the diff yourself

### Webhook Requirements

| Requirement | Detail |
|-------------|--------|
| **HTTPS only** | Must have valid SSL certificate |
| **Domain verification** | Must verify domain in Google Cloud Console |
| **Channel expiration** | Max ~1 week, must renew |
| **No localhost** | Cannot use for local development without tunneling |

**Reference:** https://developers.google.com/drive/api/guides/push

---

## 5. Computing Diffs Yourself

Since Google provides no diff API, you must:

### Approach 1: Index-Based Comparison

```python
def compare_documents(old_doc, new_doc):
    """Compare two documents.get responses."""
    old_text = extract_plain_text(old_doc)
    new_text = extract_plain_text(new_doc)

    # Use difflib or similar
    import difflib
    diff = difflib.unified_diff(
        old_text.splitlines(),
        new_text.splitlines(),
        lineterm=''
    )
    return '\n'.join(diff)

def extract_plain_text(doc):
    """Extract plain text from document structure."""
    text = []
    for element in doc.get('body', {}).get('content', []):
        if 'paragraph' in element:
            for pe in element['paragraph'].get('elements', []):
                if 'textRun' in pe:
                    text.append(pe['textRun'].get('content', ''))
    return ''.join(text)
```

### Approach 2: Structural Comparison

For richer diffs (detecting formatting changes, table modifications, etc.), you need to walk the document tree and compare elements.

### Approach 3: Use Revision Exports

```python
# Export two revisions to text and diff
rev1_content = export_revision_as_text(file_id, revision_id_1)
rev2_content = export_revision_as_text(file_id, revision_id_2)

diff = compute_diff(rev1_content, rev2_content)
```

---

## 6. Summary: What's Documented Where

| Topic | File | Has References? |
|-------|------|-----------------|
| Reading document contents | `google-docs-ui-features-comprehensive.md` §12 | ✅ Yes |
| Revision history | `google-docs-ui-features-comprehensive.md` §8 | ✅ Yes |
| Webhooks/watch | `google-docs-supplementary-notes.md` | ✅ Yes |
| Suggestions attribution | `google-docs-ui-features-comprehensive.md` §1.2 | ✅ Yes |
| Diff computation | **This document** | ✅ Yes |

---

## 7. Official Documentation References

### Docs API

* **documents.get:** https://developers.google.com/workspace/docs/api/reference/rest/v1/documents/get
* **Document structure:** https://developers.google.com/workspace/docs/api/concepts/structure
* **Suggestions:** https://developers.google.com/workspace/docs/api/how-tos/suggestions

### Drive API

* **Revisions overview:** https://developers.google.com/drive/api/guides/manage-revisions
* **revisions.list:** https://developers.google.com/drive/api/reference/rest/v3/revisions/list
* **revisions.get:** https://developers.google.com/drive/api/reference/rest/v3/revisions/get
* **Push notifications (watch):** https://developers.google.com/drive/api/guides/push
* **files.watch:** https://developers.google.com/drive/api/reference/rest/v3/files/watch
* **changes.watch:** https://developers.google.com/drive/api/reference/rest/v3/changes/watch

---

## 8. Practical Implications

### For Building a "Track Changes" Feature

1. **Poll approach:** Periodically call `documents.get`, cache, and diff
2. **Webhook approach:** Set up `files.watch`, fetch on notification, diff
3. **Limitation:** No per-character attribution for past changes

### For Building a "Version Comparison" Feature

1. Call `revisions.list` to get revision IDs
2. Export each revision to text via `exportLinks`
3. Diff the exported text
4. **Limitation:** Cannot get structural JSON for old revisions

### For Real-Time Collaboration Awareness

* Google Docs has internal real-time collaboration (cursors, presence)
* **This is NOT exposed via API**
* You can only detect "file was modified" via webhooks

---

## TODO for Future Verification

- [ ] Test if any revision format provides more than export (JSON structure?)
- [ ] Measure revision retention policy (how many revisions kept, for how long)
- [ ] Test webhook latency (how quickly after edit does notification arrive)
- [ ] Verify channel expiration behavior and renewal process
