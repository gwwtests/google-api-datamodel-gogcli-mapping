# Google Docs API - Supplementary Research Notes

**Source:** External assistant research notes
**Added:** 2026-02-05
**Purpose:** Additional details for subagents to verify and incorporate

---

## Change Notifications (Webhooks)

**Key Finding:** No direct webhook support in Docs API, but Drive API `watch` method provides push notifications.

```python
channel = {
    'address': 'https://your-webhook-url.com/notifications',
    'type': 'web_hook',
    'id': 'unique-channel-id'
}
Drive.Changes.watch(channel)
```

**Caveats to verify:**

* Requires HTTPS endpoint with valid SSL certificate
* Requires domain verification in Google Cloud Console
* Watch channels expire and must be renewed regularly
* Notifications contain minimal payload—additional API calls needed to fetch actual content changes

**Source to check:** https://developers.google.com/workspace/drive/api/guides/push

---

## Comment Anchors Detail

Comments are via Drive API. The `quotedFileContent` field contains the exact highlighted text:

```json
{
  "id": "comment-id",
  "content": "Please rephrase this",
  "quotedFileContent": {
    "mimeType": "text/plain",
    "value": "The original highlighted text"
  },
  "anchor": "kix.fkuox8etb960",
  "resolved": false
}
```

**Key Detail:** The `anchor` field contains a JSON-encoded region reference. For Google Docs it often appears as an opaque `kix.*` identifier rather than explicit line/position coordinates.

**Source to verify:** https://stackoverflow.com/questions/64448300/google-drive-api-deconstructing-comment-anchors

---

## Suggestions API Limitations (Confirmed)

### Creating Suggestions: ❌ NOT Supported

> "Unfortunately it isn't currently possible to make suggestions to a Google Doc via the API."

**Source:** https://stackoverflow.com/questions/60775916/google-docs-api-edit-text-as-suggestion

### Accepting/Rejecting Suggestions: ❌ NOT Supported

Cannot accept or reject suggestions via API. Must be done manually through web interface.

---

## Workarounds for Suggestions Limitation

Since programmatic suggestions aren't available, common workarounds include:

1. **Use comments instead** — Add comments proposing changes to specific text ranges
2. **External tracking** — Store proposed changes externally and apply them via `batchUpdate` after human approval
3. **Named ranges** — Use `CreateNamedRangeRequest` to flag sections for review, combined with comments

**Source to check:** https://community.latenode.com/t/how-to-add-suggestions-to-documents-using-google-docs-api/30076

---

## SuggestionsViewMode Options

| Mode | Behavior |
|------|----------|
| `SUGGESTIONS_INLINE` | Returns text with all pending insertions/deletions visible |
| `PREVIEW_SUGGESTIONS_ACCEPTED` | Returns document as if all suggestions were accepted |
| `PREVIEW_WITHOUT_SUGGESTIONS` | Returns document with all suggestions rejected |
| `DEFAULT_FOR_CURRENT_ACCESS` | Default based on user permissions |

The response includes `suggestedInsertionIds`, `suggestedDeletionIds`, and `suggestedTextStyleChanges` to identify which text elements are suggestions.

---

## Quick Reference Summary

| Capability | Supported | API |
|------------|-----------|-----|
| Read document content | ✅ | Docs API |
| Write/edit document | ✅ | Docs API `batchUpdate` |
| Subscribe to changes | ⚠️ Via Drive API | Drive API `watch` |
| Read comments | ✅ | Drive API |
| Create/resolve comments | ✅ | Drive API |
| Read highlighted text | ✅ `quotedFileContent` | Drive API |
| Read suggestions | ✅ `SuggestionsViewMode` | Docs API |
| Create suggestions | ❌ | — |
| Accept/reject suggestions | ❌ | — |

---

## TODO for Future Verification

- [ ] Verify Drive API watch channel expiration timing
- [ ] Test `kix.*` anchor format parsing
- [ ] Confirm quotedFileContent availability for all comment types
- [ ] Test workaround: named ranges + comments for suggestion-like workflow
