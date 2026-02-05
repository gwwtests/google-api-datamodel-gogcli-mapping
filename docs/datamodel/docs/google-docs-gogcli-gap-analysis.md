# gogcli Google Docs Gap Analysis

**Research Date:** 2026-02-05
**Purpose:** Compare what's possible (UI+API) vs what gogcli implements

---

## Executive Summary

| Metric | Count |
|--------|------:|
| **Total Features (UI+API)** | 104 |
| **gogcli Implements** | 9 (8 full + 1 partial) |
| **API Available, gogcli Missing** | **~70 features** |
| **gogcli Coverage** | **8.7%** |

gogcli focuses on **read and export** operations only. It has no document editing capability.

---

## What gogcli CAN Do (9 features)

| Feature | Command | API Used |
|---------|---------|----------|
| Export to PDF | `gog docs export --format pdf` | Drive API `files.export` |
| Export to DOCX | `gog docs export --format docx` | Drive API `files.export` |
| Export to TXT | `gog docs export --format txt` | Drive API `files.export` |
| Read as plain text | `gog docs cat` | Docs API `documents.get` |
| Get metadata | `gog docs info` | Docs API `documents.get` |
| Create empty document | `gog docs create` | Drive API `files.create` |
| Copy document | `gog docs copy` | Drive API `files.copy` |
| View mode (read-only) | `gog docs cat/info` | Docs API `documents.get` |
| Read TOC (as text) | `gog docs cat` | Docs API `documents.get` (partial) |

### gogcli Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                         gogcli                               │
├─────────────────────────────────────────────────────────────┤
│  Uses Docs API v1:                                          │
│    └─ documents.get() ONLY (for cat, info)                  │
│                                                             │
│  Uses Drive API v3:                                         │
│    ├─ files.create() for create                             │
│    ├─ files.copy() for copy                                 │
│    └─ files.export() for export (PDF/DOCX/TXT)              │
│                                                             │
│  Does NOT use:                                              │
│    ├─ documents.batchUpdate() ← ALL editing                 │
│    ├─ comments.* ← ALL comments                             │
│    ├─ revisions.* ← version history                         │
│    └─ files.watch() ← change notifications                  │
└─────────────────────────────────────────────────────────────┘
```

---

## What API Supports but gogcli Doesn't

### High-Value Missing Features (Easy to Add)

| Feature | API Method | Difficulty | Value |
|---------|------------|:----------:|:-----:|
| List bookmarks | `documents.get` | Easy | High |
| List named ranges | `documents.get` | Easy | High |
| List headings (for navigation) | `documents.get` | Easy | High |
| Read comments | Drive `comments.list` | Easy | High |
| Read suggestions | `documents.get` with `SuggestionsViewMode` | Easy | Medium |
| View revision history | Drive `revisions.list` | Easy | Medium |
| Download old revision | Drive `revisions.get` | Medium | Medium |
| Export by named range | `documents.get` + filter | Medium | High |

### Medium-Value Missing Features (Moderate Effort)

| Feature | API Method | Difficulty | Value |
|---------|------------|:----------:|:-----:|
| Create bookmark | `documents.batchUpdate` | Medium | Medium |
| Create named range | `documents.batchUpdate` | Medium | High |
| Add comment | Drive `comments.create` | Medium | Medium |
| Resolve comment | Drive `comments.update` | Easy | Low |
| Pin revision | Drive `revisions.update` | Easy | Low |
| Set up webhook | Drive `files.watch` | Hard | Medium |

### Content Editing (Major Effort)

| Feature | API Method | Difficulty | Notes |
|---------|------------|:----------:|-------|
| Insert text | `InsertTextRequest` | Medium | Requires index management |
| Delete text | `DeleteContentRangeRequest` | Medium | UTF-16 indexing |
| Format text | `UpdateTextStyleRequest` | Medium | Many style options |
| Insert table | `InsertTableRequest` | Hard | Complex structure |
| Insert image | `InsertInlineImageRequest` | Medium | URL must be public |
| Replace placeholder | `ReplaceAllTextRequest` | Easy | Template use case |

---

## Potential gogcli Enhancements

### Tier 1: Read-Only Extensions (Easy, High Value)

```bash
# List document structure
gog docs headings --docid ID          # List all headings with IDs
gog docs bookmarks --docid ID         # List all bookmarks
gog docs named-ranges --docid ID      # List all named ranges
gog docs toc --docid ID               # Extract table of contents

# Read specific sections
gog docs cat --docid ID --range "section_name"  # By named range
gog docs cat --docid ID --heading "Introduction" # By heading

# Comments
gog docs comments list --docid ID     # List all comments
gog docs comments get --docid ID --id COMMENT_ID

# Suggestions
gog docs suggestions --docid ID       # Show pending suggestions

# History
gog docs revisions list --docid ID    # List revision history
gog docs revisions export --docid ID --rev REV_ID --format pdf
```

### Tier 2: Metadata & Links (Medium Effort)

```bash
# Generate URLs
gog docs url --docid ID --bookmark ID  # URL to bookmark
gog docs url --docid ID --heading ID   # URL to heading

# Named ranges for automation
gog docs named-ranges create --docid ID --name "foo" --start 10 --end 20
gog docs named-ranges delete --docid ID --name "foo"

# Comments
gog docs comments create --docid ID --content "Review this" --anchor "kix.abc"
gog docs comments resolve --docid ID --id COMMENT_ID
```

### Tier 3: Content Editing (Major Effort)

```bash
# Simple edits
gog docs insert --docid ID --index 100 --text "Hello"
gog docs delete --docid ID --start 100 --end 110
gog docs replace --docid ID --find "{{name}}" --replace "John"

# Formatting
gog docs format --docid ID --start 100 --end 110 --bold --italic

# Complex content
gog docs insert-table --docid ID --index 100 --rows 3 --cols 4
gog docs insert-image --docid ID --index 100 --url "https://..."
```

---

## Gap Analysis by Category

### ✅ gogcli Has Full Coverage

| Category | gogcli Coverage |
|----------|-----------------|
| Export (PDF/DOCX/TXT) | 100% |
| Read plain text | 100% |
| Get metadata | 100% |
| Create/copy document | 100% |

### ⚠️ gogcli Has Partial Coverage

| Category | Available | gogcli Has | Gap |
|----------|:---------:|:----------:|:---:|
| Read TOC | 1 | 1 (text only) | Structure |

### ❌ gogcli Has No Coverage

| Category | Available in API | gogcli Has | Gap |
|----------|:----------------:|:----------:|:---:|
| Text formatting | 11 | 0 | 11 |
| Paragraph formatting | 5 | 0 | 5 |
| Headings & styles | 3 | 0 | 3 |
| Lists | 6 | 0 | 6 |
| Tables | 4 | 0 | 4 |
| Images | 3 | 0 | 3 |
| Links & bookmarks | 5 | 0 | 5 |
| Named ranges | 5 | 0 | 5 |
| Headers/footers | 5 | 0 | 5 |
| Page setup | 4 | 0 | 4 |
| Comments | 5 | 0 | 5 |
| Suggestions | 2 | 0 | 2 |
| Version history | 4 | 0 | 4 |
| Change detection | 7 | 0 | 7 |
| Special fields | 7 | 0 | 7 |
| Content insertion | 12 | 0 | 12 |

---

## Comparison: gogcli vs gmailctl Pattern

For reference, `gmailctl` (a similar Go CLI for Gmail filters) provides:

| Feature | gmailctl | gogcli (Docs) |
|---------|:--------:|:-------------:|
| Read data | ✅ | ✅ |
| Export data | ✅ | ✅ |
| Create/modify | ✅ | ❌ |
| Config-as-code | ✅ (Jsonnet) | ❌ |
| Diff/sync | ✅ | ❌ |

A `gogcli` enhancement could follow this pattern for Docs templates.

---

## Recommendations

### For Users

1. **Use gogcli for:** Export, read, create empty docs, copy docs
2. **Use API directly for:** Any editing, comments, suggestions, formatting
3. **Use Google Docs UI for:** Accept/reject suggestions, insert TOC, drawings

### For gogcli Contributors

**Quick wins (Tier 1):**
- `gog docs headings` - list headings for navigation
- `gog docs comments list` - read comments
- `gog docs revisions list` - show history

**High-value additions (Tier 2):**
- `gog docs cat --range "named_range"` - export by section
- `gog docs replace --find "{{x}}" --replace "y"` - template filling

**Major features (Tier 3):**
- Full `batchUpdate` support for editing

---

## Summary Table: UI+API vs gogcli

| What You Want To Do | UI | API | gogcli |
|---------------------|:--:|:---:|:------:|
| **Read & Export** |
| Read document text | ✅ | ✅ | ✅ |
| Export to PDF/DOCX/TXT | ✅ | ✅ | ✅ |
| Get metadata (title, ID) | ✅ | ✅ | ✅ |
| **Document Operations** |
| Create new document | ✅ | ✅ | ✅ |
| Copy document | ✅ | ✅ | ✅ |
| Delete document | ✅ | ✅ | ❌ (use `gog drive rm`) |
| **Structure & Navigation** |
| List headings | ✅ | ✅ | ❌ |
| List bookmarks | ✅ | ✅ | ❌ |
| List named ranges | — | ✅ | ❌ |
| Read TOC structure | ✅ | ✅ | ⚠️ (text only) |
| **Comments & Collaboration** |
| Read comments | ✅ | ✅ | ❌ |
| Add comments | ✅ | ✅ | ❌ |
| Read suggestions | ✅ | ✅ | ❌ |
| Accept/reject suggestions | ✅ | ❌ | ❌ |
| **Content Editing** |
| Insert/delete text | ✅ | ✅ | ❌ |
| Format text (bold, etc.) | ✅ | ✅ | ❌ |
| Insert tables | ✅ | ✅ | ❌ |
| Insert images | ✅ | ✅ | ❌ |
| Replace placeholders | ✅ | ✅ | ❌ |
| **Version History** |
| View revision list | ✅ | ✅ | ❌ |
| Download old revision | ✅ | ✅ | ❌ |
| Compare revisions | ✅ | ❌ | ❌ |
| **Change Detection** |
| Real-time notifications | — | ⚠️ | ❌ |
| Get diffs | — | ❌ | ❌ |
