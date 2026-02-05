# GIP: Google Docs Subcommand Enhancements Overview

**GIP ID:** gog-docs-overview
**Status:** Proposal
**Target Repository:** https://github.com/steipete/gogcli
**Research Repository:** https://github.com/gwwtests/google-api-datamodel-gogcli-mapping
**Last Updated:** 2026-02-05

---

## Executive Summary

This proposal outlines enhancements to `gog docs` subcommands based on comprehensive research of Google Docs API capabilities vs current gogcli coverage.

| Metric | Value |
|--------|------:|
| **Total Features Available (UI+API)** | 104 |
| **gogcli Currently Implements** | 9 |
| **Current Coverage** | 8.7% |
| **Proposed New Subcommands** | 7 |
| **Potential Coverage After** | ~25% |

---

## Current State

### What gogcli CAN Do Today

```bash
gog docs export [--format pdf|docx|txt] --docid ID   # Export document
gog docs cat --docid ID                               # Read as plain text
gog docs info --docid ID                              # Get metadata
gog docs create --name TITLE                          # Create empty doc
gog docs copy --docid ID --title NEWTITLE             # Copy document
```

### Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Current gogcli                            │
├─────────────────────────────────────────────────────────────┤
│  Uses Docs API v1:                                          │
│    └─ documents.get() ONLY                                  │
│                                                             │
│  Uses Drive API v3:                                         │
│    ├─ files.create()                                        │
│    ├─ files.copy()                                          │
│    └─ files.export()                                        │
└─────────────────────────────────────────────────────────────┘
```

### Key Gaps

| Category | API Supports | gogcli Has |
|----------|:------------:|:----------:|
| Document structure (headings, bookmarks) | ✅ | ❌ |
| Named ranges (for automation) | ✅ | ❌ |
| Comments | ✅ | ❌ |
| Version history | ✅ | ❌ |
| Suggestions (track changes) | ✅ read | ❌ |
| Template replacement | ✅ | ❌ |

---

## Proposed Enhancements

### Phase 1: Read-Only Extensions (Low Risk, High Value)

| GIP | New Subcommand | Effort | Value | Status |
|-----|----------------|:------:|:-----:|--------|
| [gog-docs-headings](./gogcli-GIP-gog-docs-headings.md) | `gog docs headings` | Easy | High | Proposed |
| [gog-docs-bookmarks](./gogcli-GIP-gog-docs-bookmarks.md) | `gog docs bookmarks` | Easy | Medium | Proposed |
| [gog-docs-named-ranges](./gogcli-GIP-gog-docs-named-ranges.md) | `gog docs named-ranges` | Easy | High | Proposed |
| [gog-docs-comments](./gogcli-GIP-gog-docs-comments.md) | `gog docs comments` | Easy | High | Proposed |
| [gog-docs-revisions](./gogcli-GIP-gog-docs-revisions.md) | `gog docs revisions` | Easy | Medium | Proposed |
| [gog-docs-suggestions](./gogcli-GIP-gog-docs-suggestions.md) | `gog docs suggestions` | Easy | Medium | Proposed |

### Phase 2: Simple Modifications (Medium Risk, High Value)

| GIP | New Subcommand | Effort | Value | Status |
|-----|----------------|:------:|:-----:|--------|
| [gog-docs-replace](./gogcli-GIP-gog-docs-replace.md) | `gog docs replace` | Medium | High | Proposed |

### Phase 3: Full Editing (High Effort, Future)

Not proposed in this round. Would require:

* `documents.batchUpdate()` integration
* UTF-16 index management
* Conflict handling via `revisionId`

---

## Priority Rationale

### Why Phase 1 First?

1. **Zero write operations** - No risk of data loss
2. **Reuses existing `documents.get()`** - Already implemented
3. **High user value** - Navigation, automation, collaboration
4. **Low maintenance** - Read-only APIs rarely change

### Why `headings` and `named-ranges` are Highest Priority?

* **headings:** Enables document navigation, TOC generation, section extraction
* **named-ranges:** Enables template automation, a common enterprise use case

---

## Official Documentation References

### Google Docs API

* [API Overview](https://developers.google.com/workspace/docs/api/how-tos/overview)
* [Document Structure](https://developers.google.com/workspace/docs/api/concepts/structure)
* [documents.get](https://developers.google.com/workspace/docs/api/reference/rest/v1/documents/get)
* [documents.batchUpdate](https://developers.google.com/workspace/docs/api/reference/rest/v1/documents/batchUpdate)

### Google Drive API (for comments, revisions)

* [Manage Comments](https://developers.google.com/drive/api/guides/manage-comments)
* [Manage Revisions](https://developers.google.com/drive/api/guides/manage-revisions)

### Research Documentation

* [Feature Comparison YAML](../docs/datamodel/docs/google-docs-feature-comparison.yaml) - 104 features mapped
* [Gap Analysis](../docs/datamodel/docs/google-docs-gogcli-gap-analysis.md) - Detailed coverage analysis
* [UI Features Research](../docs/datamodel/docs/google-docs-ui-features-comprehensive.md) - 17 sections
* [Anchors & Bookmarks](../docs/datamodel/docs/google-docs-anchors-bookmarks.md) - Navigation patterns
* [Reading & History](../docs/datamodel/docs/google-docs-reading-history-changes.md) - Revisions, webhooks

---

## Implementation Notes

### All Phase 1 proposals share these characteristics:

1. **Use existing `documents.get()` response** - Already fetched for `cat` and `info`
2. **Parse different sections of Document structure:**
   * `body.content[].paragraph.paragraphStyle.headingId` → headings
   * `namedRanges{}` → named ranges
   * `body.content[].paragraph.elements[].textRun.textStyle.link.bookmarkId` → bookmarks
3. **Output formats:** `--json` (default), `--plain` (TSV), table (TTY)

### Comments and Revisions use Drive API:

* Separate service initialization (already exists in gogcli)
* Different authentication scope may be needed

---

## Related Issues

* [steipete/gogcli#174](https://github.com/steipete/gogcli/issues/174) - Gmail Filter Export (similar pattern)

---

## Index of GIP Documents

| Document | Description |
|----------|-------------|
| [gogcli-GIP-gog-docs-overview.md](./gogcli-GIP-gog-docs-overview.md) | This document |
| [gogcli-GIP-gog-docs-headings.md](./gogcli-GIP-gog-docs-headings.md) | `gog docs headings` subcommand |
| [gogcli-GIP-gog-docs-bookmarks.md](./gogcli-GIP-gog-docs-bookmarks.md) | `gog docs bookmarks` subcommand |
| [gogcli-GIP-gog-docs-named-ranges.md](./gogcli-GIP-gog-docs-named-ranges.md) | `gog docs named-ranges` subcommand |
| [gogcli-GIP-gog-docs-comments.md](./gogcli-GIP-gog-docs-comments.md) | `gog docs comments` subcommand |
| [gogcli-GIP-gog-docs-revisions.md](./gogcli-GIP-gog-docs-revisions.md) | `gog docs revisions` subcommand |
| [gogcli-GIP-gog-docs-suggestions.md](./gogcli-GIP-gog-docs-suggestions.md) | `gog docs suggestions` subcommand |
| [gogcli-GIP-gog-docs-replace.md](./gogcli-GIP-gog-docs-replace.md) | `gog docs replace` subcommand |

---

*Research conducted: 2026-02-05*
*Documentation archived in: google-api-datamodel-gogcli-mapping repository*
