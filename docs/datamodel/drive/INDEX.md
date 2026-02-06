# Google Drive Data Model Documentation

**Last Updated**: 2026-02-06

This directory contains synthesized documentation about the Google Drive data model, API capabilities, and gogcli support.

## Documentation Index

| Document | Purpose | Key Insights |
|----------|---------|--------------|
| `google-drive-ui-features-comprehensive.md` | Complete UI feature catalog | 10 sections, 100+ features |
| `google-drive-api-capabilities.md` | API v3 reference | 7 resources, all methods |
| `google-drive-feature-comparison.yaml` | Machine-readable feature mapping | 120 features, 10 categories |
| `google-drive-feature-comparison-tables.md` | Generated comparison tables | UI vs API vs gogcli |
| `google-drive-gogcli-data-handling.md` | How gogcli handles Drive | 21 commands documented |

## Key Findings Summary

### Feature Coverage

| Interface | Full Support | Partial | None |
|-----------|-------------|---------|------|
| **UI** | 95 | 10 | 15 |
| **API** | 100 | 5 | 15 |
| **gogcli** | 40 | 3 | 77 |

### Critical Insights

1. **File IDs Are Globally Unique**
   * Unlike Gmail/Calendar, Drive file IDs are globally unique
   * No composite key needed for multi-account scenarios
   * Drive ID = top-level folder ID of shared drive

2. **Google Workspace Files vs Binary Files**
   * Workspace files (Docs, Sheets, Slides) use `files.export` with MIME conversion
   * Binary files use `files.get?alt=media` for direct download
   * Export limit: 10 MB per file

3. **Shared Drive Support**
   * All operations require `supportsAllDrives=true` parameter
   * Files owned by organization, not individuals
   * Different permission model (organizer, fileOrganizer vs owner)

4. **Comments via Drive API**
   * Comments/replies are Drive API resources, not per-service
   * Same comment system for Docs, Sheets, Slides
   * gogcli has full comment CRUD support

5. **Version History**
   * Unlimited for Google Workspace files
   * 30-day retention or 100 versions for binary files
   * gogcli has NO revision access

### gogcli Strengths

| Capability | Support Level |
|------------|---------------|
| File CRUD (upload, download, copy, move, delete) | ✅ Full |
| Export Workspace files | ✅ Full |
| Basic sharing (user, anyone, reader, writer) | ✅ Full |
| List/search files | ✅ Full |
| Shared drive file access | ✅ Full |
| Comments management | ✅ Full |

### gogcli Gaps

| Category | Missing Features |
|----------|------------------|
| **Trash** | Permanent delete, restore, empty trash |
| **Revisions** | All version history operations |
| **Shared Drives** | Create, delete, update drives |
| **Permissions** | Domain/group sharing, ownership transfer, expiration |
| **Changes** | Change tracking, push notifications |
| **Organization** | Shortcuts, starring, colors |
| **Storage** | Quota information |

## Identifier Semantics

| Identifier | Scope | Format | Uniqueness |
|------------|-------|--------|------------|
| File ID | Global | Opaque string | Globally unique |
| Drive ID | Global | Opaque string | Globally unique |
| Permission ID | Per file | Opaque string | Unique per file |
| Revision ID | Per file | Opaque string | Unique per file |
| Comment ID | Per file | Integer string | Unique per file |

**Multi-account safe**: All Drive IDs are globally unique. No composite keys needed.

## API Rate Limits

| Limit Type | Rate |
|------------|------|
| Queries per 60 seconds | 12,000 |
| Per-user per 60 seconds | 12,000 |
| Write requests sustained | 3/second |
| Daily upload cap | 750 GB |
| Export file size limit | 10 MB |

## Timestamp Handling

* All timestamps use **RFC 3339 format** in UTC
* Example: `2026-02-06T14:30:45.123Z`
* Fields: `createdTime`, `modifiedTime`, `viewedByMeTime`, `trashedTime`

## Related Documentation

* `../gmail/` - Gmail API data model
* `../calendar/` - Calendar API data model
* `../docs/` - Google Docs API data model
* `../sheets/` - Google Sheets API data model

## How to Use This Documentation

### For Understanding Drive Capabilities

1. Start with `google-drive-ui-features-comprehensive.md`
2. Cross-reference with `google-drive-feature-comparison-tables.md`

### For Building Applications

1. Check feature in `google-drive-feature-comparison.yaml`
2. Verify API support level
3. If using gogcli, check `google-drive-gogcli-data-handling.md`

### For Querying Features Programmatically

```bash
# Count gogcli-supported features
yq '.categories[].features[] | select(.gogcli_support == "full")' \
  google-drive-feature-comparison.yaml | grep -c "^id:"

# Find features with API but not gogcli support
yq '.categories[].features[] | select(.api_support == "full" and .gogcli_support == "none") | .name' \
  google-drive-feature-comparison.yaml

# List all API methods used
yq '.categories[].features[].api_method' \
  google-drive-feature-comparison.yaml | sort -u
```

## Sources

* Google Drive API v3 Documentation
* gogcli source code (https://github.com/steipete/gogcli)
* Google Workspace Updates Blog
