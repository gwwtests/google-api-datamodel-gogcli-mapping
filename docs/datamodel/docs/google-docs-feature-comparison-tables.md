# Google Docs Feature Comparison Tables

**Research Date:** 2026-02-05
**Source:** `google-docs-feature-comparison.yaml`

## Legend

| Symbol | Meaning |
|--------|---------|
| ✅ | Full support |
| ⚠️ | Partial support |
| 📖 | Read-only |
| ❌ | Not available |

---

## Summary Statistics

| Metric | Count |
|--------|-------|
| **Total Features** | 104 |
| **gogcli: Full Support** | 8 |
| **gogcli: Partial Support** | 1 |
| **gogcli: No Support** | 95 |
| **API: Full Support** | 78 |
| **API: Partial/Read-Only** | 15 |
| **API Limitations (None)** | 11 |

### UI-Only Features (No API Support)

* Accept/Reject Suggestions
* Insert/Create Drawings
* Insert Table of Contents
* Read Checkbox State (checked/unchecked)
* Named Version Names (limited visibility)

### API Limitations (Cannot Do)

* Cannot create suggestions (only read)
* Cannot get JSON structure for old revisions
* Cannot get per-character attribution
* Cannot get diff notifications (must compute yourself)
* Webhooks are file-level only, no content diffs

---

## 1. Document Operations (gogcli Focus)

| Feature | UI | API | gogcli | Command |
|---------|:--:|:---:|:------:|---------|
| Export to PDF | ✅ | ✅ | ✅ | `gog docs export [--format pdf]` |
| Export to DOCX | ✅ | ✅ | ✅ | `gog docs export --format docx` |
| Export to Plain Text | ✅ | ✅ | ✅ | `gog docs export --format txt` |
| Read Document as Plain Text | ✅ | ✅ | ✅ | `gog docs cat` |
| Get Document Metadata | ✅ | ✅ | ✅ | `gog docs info` |
| Create New Document | ✅ | ✅ | ✅ | `gog docs create --name 'Title'` |
| Copy Document | ✅ | ✅ | ✅ | `gog docs copy --docid ID --title 'Title'` |
| Delete Document | ✅ | ✅ | ❌ | Use `gog drive rm` instead |
| Modify Document Content | ✅ | ✅ | ❌ | Not supported |

---

## 2. Editing Modes

| Feature | UI | API | gogcli | Notes |
|---------|:--:|:---:|:------:|-------|
| Editing Mode (direct edit) | ✅ | ✅ | ❌ | gogcli is read-focused; no batchUpdate |
| Suggesting Mode (track changes) | ✅ | ⚠️ | ❌ | API: Can read, cannot accept/reject |
| Viewing Mode (read-only) | ✅ | ✅ | ✅ | `gog docs cat`, `gog docs info` |

---

## 3. Comments & Collaboration

| Feature | UI | API | gogcli | Notes |
|---------|:--:|:---:|:------:|-------|
| Add Comments | ✅ | ✅ | ❌ | Via Drive API, not Docs API |
| Reply Threads | ✅ | ✅ | ❌ | Via Drive API |
| Resolve Comments | ✅ | ✅ | ❌ | — |
| @Mentions in Comments | ✅ | ✅ | ❌ | — |
| Accept/Reject Suggestions | ✅ | ❌ | ❌ | **UI-ONLY** |

---

## 4. Content Insertion

### 4.1 Tables

| Feature | UI | API | gogcli | API Method |
|---------|:--:|:---:|:------:|------------|
| Insert Tables | ✅ | ✅ | ❌ | `InsertTableRequest` |
| Modify Tables (rows/columns) | ✅ | ✅ | ❌ | `InsertTableRowRequest`, etc. |
| Merge Table Cells | ✅ | ✅ | ❌ | `MergeTableCellsRequest` |
| Table Styling | ✅ | ✅ | ❌ | `UpdateTableCellStyleRequest` |

### 4.2 Images

| Feature | UI | API | gogcli | API Method |
|---------|:--:|:---:|:------:|------------|
| Insert Inline Images | ✅ | ✅ | ❌ | `InsertInlineImageRequest` |
| Insert Positioned Images | ✅ | ✅ | ❌ | `CreatePositionedObjectRequest` |
| Modify Image Properties | ✅ | ✅ | ❌ | `UpdateImagePropertiesRequest` |

### 4.3 Drawings & Charts

| Feature | UI | API | gogcli | Notes |
|---------|:--:|:---:|:------:|-------|
| Insert/Create Drawings | ✅ | ❌ | ❌ | **UI-ONLY**: Cannot create via API |
| Read Embedded Drawings | ✅ | 📖 | ❌ | Read-only |
| Embed Charts from Sheets | ✅ | ✅ | ❌ | Create in Sheets first |

### 4.4 Links & Navigation

| Feature | UI | API | gogcli | API Method |
|---------|:--:|:---:|:------:|------------|
| Insert Hyperlinks | ✅ | ✅ | ❌ | `UpdateTextStyleRequest` |
| Internal Bookmarks | ✅ | ✅ | ❌ | `BookmarkLink` |
| Links to Headings | ✅ | ✅ | ❌ | `HeadingLink` |
| Insert Table of Contents | ✅ | ❌ | ❌ | **UI-ONLY**: Cannot insert via API |
| Read Table of Contents | ✅ | 📖 | ⚠️ | `gog docs cat` extracts as plain text |

### 4.5 Headers, Footers & Footnotes

| Feature | UI | API | gogcli | API Method |
|---------|:--:|:---:|:------:|------------|
| Insert Headers | ✅ | ✅ | ❌ | `CreateHeaderRequest` |
| Insert Footers | ✅ | ✅ | ❌ | `CreateFooterRequest` |
| Insert Page Numbers | ✅ | ✅ | ❌ | `AutoText (PAGE_NUMBER)` |
| Insert Page Count | ✅ | ✅ | ❌ | `AutoText (PAGE_COUNT)` |
| Insert Footnotes | ✅ | ✅ | ❌ | `CreateFootnoteRequest` |

### 4.6 Other Elements

| Feature | UI | API | gogcli | API Method |
|---------|:--:|:---:|:------:|------------|
| Insert Equations | ✅ | ✅ | ❌ | `Equation` element |
| Insert Horizontal Lines | ✅ | ✅ | ❌ | `HorizontalRule` element |
| Insert Page Breaks | ✅ | ✅ | ❌ | `InsertPageBreakRequest` |
| Insert Section Breaks | ✅ | ✅ | ❌ | `InsertSectionBreakRequest` |

---

## 5. Text Formatting

| Feature | UI | API | gogcli | API Method |
|---------|:--:|:---:|:------:|------------|
| Font Family | ✅ | ✅ | ❌ | `UpdateTextStyleRequest` |
| Font Size | ✅ | ✅ | ❌ | `UpdateTextStyleRequest` |
| Bold | ✅ | ✅ | ❌ | `UpdateTextStyleRequest` |
| Italic | ✅ | ✅ | ❌ | `UpdateTextStyleRequest` |
| Underline | ✅ | ✅ | ❌ | `UpdateTextStyleRequest` |
| Strikethrough | ✅ | ✅ | ❌ | `UpdateTextStyleRequest` |
| Small Caps | ✅ | ✅ | ❌ | `UpdateTextStyleRequest` |
| Text Color | ✅ | ✅ | ❌ | `UpdateTextStyleRequest` |
| Highlight Color | ✅ | ✅ | ❌ | `UpdateTextStyleRequest` |
| Superscript | ✅ | ✅ | ❌ | `UpdateTextStyleRequest` |
| Subscript | ✅ | ✅ | ❌ | `UpdateTextStyleRequest` |

---

## 6. Paragraph Formatting

| Feature | UI | API | gogcli | API Method |
|---------|:--:|:---:|:------:|------------|
| Text Alignment | ✅ | ✅ | ❌ | `UpdateParagraphStyleRequest` |
| Indentation | ✅ | ✅ | ❌ | `UpdateParagraphStyleRequest` |
| Paragraph Spacing | ✅ | ✅ | ❌ | `UpdateParagraphStyleRequest` |
| Line Spacing | ✅ | ✅ | ❌ | `UpdateParagraphStyleRequest` |
| Text Direction (LTR/RTL) | ✅ | ✅ | ❌ | `UpdateParagraphStyleRequest` |

---

## 7. Headings & Styles

| Feature | UI | API | gogcli | API Method |
|---------|:--:|:---:|:------:|------------|
| Apply Heading Styles (H1-H6) | ✅ | ✅ | ❌ | `namedStyleType: HEADING_*` |
| Apply Title/Subtitle Style | ✅ | ✅ | ❌ | `namedStyleType: TITLE/SUBTITLE` |
| Modify Default Style Definitions | ✅ | ✅ | ❌ | `documents.namedStyles` |

---

## 8. Lists

| Feature | UI | API | gogcli | Notes |
|---------|:--:|:---:|:------:|-------|
| Bulleted Lists | ✅ | ✅ | ❌ | `CreateParagraphBulletsRequest` |
| Numbered Lists | ✅ | ✅ | ❌ | `CreateParagraphBulletsRequest` |
| Create Checkbox Lists | ✅ | ✅ | ❌ | `BULLET_CHECKBOX` preset |
| Read Checkbox State | ✅ | ❌ | ❌ | **UI-ONLY**: Cannot detect checked/unchecked |
| Nested Lists (up to 9 levels) | ✅ | ✅ | ❌ | `nestingLevel` property |
| Remove List Formatting | ✅ | ✅ | ❌ | `DeleteParagraphBulletsRequest` |

---

## 9. Columns

| Feature | UI | API | gogcli | API Method |
|---------|:--:|:---:|:------:|------------|
| Multi-Column Layout | ✅ | ✅ | ❌ | `SectionStyle.columnProperties` |
| Column Breaks | ✅ | ✅ | ❌ | `ColumnBreak` element |
| Column Separators | ✅ | ✅ | ❌ | `columnSeparatorStyle` |

---

## 10. Page Setup

| Feature | UI | API | gogcli | API Method |
|---------|:--:|:---:|:------:|------------|
| Page Size (Letter, A4, custom) | ✅ | ✅ | ❌ | `pageSize` (PT, IN, MM) |
| Page Margins | ✅ | ✅ | ❌ | `marginTop/Bottom/Left/Right` |
| Page Orientation | ✅ | ✅ | ❌ | `flipPageOrientation` |
| Page Background Color | ✅ | ✅ | ❌ | `background.color` |

---

## 11. Special Fields & Variables

| Feature | UI | API | gogcli | Notes |
|---------|:--:|:---:|:------:|-------|
| AutoText: Page Number | ✅ | ✅ | ❌ | `AutoText (PAGE_NUMBER)` |
| AutoText: Page Count | ✅ | ✅ | ❌ | `AutoText (PAGE_COUNT)` |
| AutoText: Date | ✅ | ⚠️ | ❌ | API support unclear |
| Smart Chip: Date | ✅ | ⚠️ | ❌ | Read support; write limited |
| Smart Chip: Person | ✅ | ⚠️ | ❌ | Read support; write limited |
| Smart Chip: File Link | ✅ | ⚠️ | ❌ | Read support; write limited |
| Smart Chip: Calendar Event | ✅ | ⚠️ | ❌ | Read support; write limited |

---

## 12. Document Modes

| Feature | UI | API | gogcli | Notes |
|---------|:--:|:---:|:------:|-------|
| Pages Format (paginated) | ✅ | ✅ | ❌ | Default with headers/footers |
| Pageless Format (continuous) | ✅ | ✅ | ❌ | No headers/footers |

---

## 13. Multi-Tab Documents

| Feature | UI | API | gogcli | API Method |
|---------|:--:|:---:|:------:|------------|
| Multiple Tabs per Document | ✅ | ✅ | ❌ | `Document.tabs` array |
| Tab Hierarchy (child tabs) | ✅ | ✅ | ❌ | `Tab.childTabs` |

---

## 14. Version History

| Feature | UI | API | gogcli | Notes |
|---------|:--:|:---:|:------:|-------|
| View Revisions | ✅ | ✅ | ❌ | Via Drive API |
| Restore Previous Version | ✅ | ✅ | ❌ | Via Drive API |
| Named Versions (labels) | ✅ | ⚠️ | ❌ | Names may not be exposed |
| Pin Revisions | ✅ | ✅ | ❌ | `keepForever: true` |

---

## 15. Anchors, Bookmarks & Named Ranges

| Feature | UI | API | gogcli | Notes |
|---------|:--:|:---:|:------:|-------|
| Bookmarks (invisible anchors) | ✅ | ✅ | ❌ | URL: `#bookmark=id.{bookmarkId}` |
| Named Ranges (programmatic) | ⚠️ | ✅ | ❌ | For templates, automation |
| Heading Links (auto-generated) | ✅ | ✅ | ❌ | URL: `#heading=h.{headingId}` |
| Create Link to Bookmark | ✅ | ✅ | ❌ | `UpdateTextStyleRequest` |
| Create Link to Heading | ✅ | ✅ | ❌ | `UpdateTextStyleRequest` |

**Use Cases:**

* **Bookmarks:** Stable jump points, external URLs to specific location
* **Named Ranges:** Template placeholders, programmatic content tracking
* **Heading Links:** Auto-maintained TOC navigation

---

## 16. Change Detection & Notifications

| Feature | UI | API | gogcli | Notes |
|---------|:--:|:---:|:------:|-------|
| Read Full Document Content | ✅ | ✅ | ✅ | `documents.get` returns complete structure |
| Read with Character Indexes | ✅ | ✅ | ❌ | UTF-16 indexes (emoji=2, newline=1) |
| Webhooks (file-level) | — | ⚠️ | ❌ | Drive API `files.watch`; HTTPS required |
| Webhook Content Diffs | — | ❌ | ❌ | **NOT AVAILABLE** |
| JSON for Old Revisions | ✅ | ❌ | ❌ | **NOT AVAILABLE** - only export to PDF/DOCX |
| Per-Character Attribution | ✅ | ❌ | ❌ | **NOT AVAILABLE** - only per-revision |
| Compute Diffs | ✅ | ❌ | ❌ | **NOT AVAILABLE** - must implement yourself |

**Key Limitations:**

* Webhooks only say "file changed" - you must fetch full document and diff yourself
* Cannot get JSON structure for old revisions (only export formats)
* Cannot see which user wrote which specific text (only who saved each revision)

---

## gogcli Docs Command Summary

```
gog docs export [--format pdf|docx|txt] --docid ID [--output FILE]
gog docs info --docid ID [--json]
gog docs create --name TITLE [--parent FOLDER_ID]
gog docs copy --docid ID --title NEWTITLE [--parent FOLDER_ID]
gog docs cat --docid ID [--max-bytes BYTES] [--json]
```

### Key Limitations

1. **No content editing** - gogcli cannot modify document content (no `batchUpdate` support)
2. **No comments** - Comments are via Drive API, not exposed in gogcli
3. **No suggestions** - Cannot read or manage track changes
4. **Export only** - Focus is on reading and exporting, not authoring

### Architecture Note

gogcli uses:

* **Drive API v3** for: create, copy, export, delete operations
* **Docs API v1** for: `Documents.Get()` only (metadata and text extraction)

This is a deliberate design choice - Drive API is more stable and simpler for file-level operations.

---

## Critical API Concepts

### UTF-16 Indexing

All indexes in Google Docs API use UTF-16 code units:

* Regular ASCII characters = 1 index
* Emoji and some special characters = 2 indexes (surrogate pairs)
* Newline (`\n`) = 1 index

### batchUpdate Atomicity

The `documents.batchUpdate` method is atomic - all requests succeed or all fail. This prevents partial document states but requires careful index management.

### Suggestion Modes

When reading documents with `documents.get`:

* `SUGGESTIONS_INLINE` - Shows suggestions with correct indexes for editing
* `PREVIEW_WITH_SUGGESTIONS_ACCEPTED` - Preview as if all accepted
* `PREVIEW_WITHOUT_SUGGESTIONS` - Preview as if all rejected

---

*Generated from `google-docs-feature-comparison.yaml`*
