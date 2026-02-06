# Google Drive Feature Comparison Tables

**Generated from**: `google-drive-feature-comparison.yaml`
**Analysis Date**: 2026-02-06

## Summary Statistics

| Interface | Full Support | Partial | None |
|-----------|-------------|---------|------|
| **UI** | 95 | 10 | 15 |
| **API** | 100 | 5 | 15 |
| **gogcli** | 40 | 3 | 77 |

---

## File Operations

| Feature | UI | API | gogcli | Notes |
|---------|:--:|:---:|:------:|-------|
| Upload file | ✅ | ✅ | ✅ | 750GB daily limit |
| Upload folder | ✅ | ⚠️ | ❌ | API requires manual recursion |
| Download binary file | ✅ | ✅ | ✅ | |
| Export Google Docs | ✅ | ✅ | ✅ | PDF, DOCX, TXT |
| Export Google Sheets | ✅ | ✅ | ✅ | PDF, XLSX, CSV |
| Export Google Slides | ✅ | ✅ | ✅ | PDF, PPTX |
| Copy file | ✅ | ✅ | ✅ | |
| Move file | ✅ | ✅ | ✅ | |
| Rename file | ✅ | ✅ | ✅ | |
| Delete to trash | ✅ | ✅ | ✅ | |
| Permanent delete | ✅ | ✅ | ❌ | gogcli only trashes |
| Restore from trash | ✅ | ✅ | ❌ | |
| Empty trash | ✅ | ✅ | ❌ | |
| Create folder | ✅ | ✅ | ✅ | |
| Get file metadata | ✅ | ✅ | ✅ | |
| List files | ✅ | ✅ | ✅ | |
| Search files | ✅ | ✅ | ✅ | Full-text search |
| Get web URL | ✅ | ✅ | ✅ | |

**Legend**: ✅ Full | ⚠️ Partial | ❌ None

---

## Organization

| Feature | UI | API | gogcli | Notes |
|---------|:--:|:---:|:------:|-------|
| Star file | ✅ | ✅ | ❌ | gogcli reads only |
| View recent files | ✅ | ✅ | ⚠️ | Default sort order |
| Create shortcut | ✅ | ✅ | ❌ | |
| Set folder color | ✅ | ✅ | ❌ | |
| Set file description | ✅ | ✅ | ⚠️ | gogcli reads only |
| Custom properties | ❌ | ✅ | ❌ | API-only |
| App properties | ❌ | ✅ | ❌ | API-only |

---

## Sharing & Permissions

| Feature | UI | API | gogcli | Notes |
|---------|:--:|:---:|:------:|-------|
| Share with user | ✅ | ✅ | ✅ | |
| Share with anyone (link) | ✅ | ✅ | ✅ | |
| Share with domain | ✅ | ✅ | ❌ | Workspace only |
| Share with group | ✅ | ✅ | ❌ | |
| Set viewer role | ✅ | ✅ | ✅ | |
| Set commenter role | ✅ | ✅ | ❌ | |
| Set editor role | ✅ | ✅ | ✅ | |
| Transfer ownership | ✅ | ✅ | ❌ | |
| Remove permission | ✅ | ✅ | ✅ | |
| List permissions | ✅ | ✅ | ✅ | |
| Set expiration date | ✅ | ✅ | ❌ | Max 365 days |
| Disable copy/download | ✅ | ✅ | ❌ | |
| Allow file discovery | ✅ | ✅ | ✅ | |

---

## Shared Drives (Team Drives)

| Feature | UI | API | gogcli | Notes |
|---------|:--:|:---:|:------:|-------|
| List shared drives | ✅ | ✅ | ✅ | |
| Create shared drive | ✅ | ✅ | ❌ | |
| Delete shared drive | ✅ | ✅ | ❌ | |
| Update shared drive | ✅ | ✅ | ❌ | |
| Hide/unhide drive | ✅ | ✅ | ❌ | |
| Access files in drive | ✅ | ✅ | ✅ | supportsAllDrives |
| Move to shared drive | ✅ | ✅ | ✅ | |

---

## Version History

| Feature | UI | API | gogcli | Notes |
|---------|:--:|:---:|:------:|-------|
| List revisions | ✅ | ✅ | ❌ | |
| Get revision | ✅ | ✅ | ❌ | |
| Download revision | ✅ | ✅ | ❌ | |
| Keep revision forever | ✅ | ✅ | ❌ | Max 200 per file |
| Delete revision | ⚠️ | ⚠️ | ❌ | Binary files only |
| Name revision | ✅ | ❌ | ❌ | UI-only |

---

## Comments & Replies

| Feature | UI | API | gogcli | Notes |
|---------|:--:|:---:|:------:|-------|
| List comments | ✅ | ✅ | ✅ | |
| Get comment | ✅ | ✅ | ✅ | |
| Create comment | ✅ | ✅ | ✅ | |
| Create anchored comment | ✅ | ✅ | ✅ | --quoted flag |
| Update comment | ✅ | ✅ | ✅ | |
| Delete comment | ✅ | ✅ | ✅ | |
| Reply to comment | ✅ | ✅ | ✅ | |
| Resolve comment | ✅ | ✅ | ❌ | |
| @mention in comment | ✅ | ❌ | ❌ | UI-only |

---

## Changes & Notifications

| Feature | UI | API | gogcli | Notes |
|---------|:--:|:---:|:------:|-------|
| List changes | ⚠️ | ✅ | ❌ | UI shows activity |
| Get start page token | ❌ | ✅ | ❌ | |
| Watch for changes | ❌ | ✅ | ❌ | Push notifications |
| Watch file | ❌ | ✅ | ❌ | |
| Stop channel | ❌ | ✅ | ❌ | |

---

## Storage & Quotas

| Feature | UI | API | gogcli | Notes |
|---------|:--:|:---:|:------:|-------|
| View storage usage | ✅ | ✅ | ❌ | |
| View file size | ✅ | ✅ | ✅ | |
| View quota used by file | ⚠️ | ✅ | ❌ | |

---

## Labels (Enterprise)

| Feature | UI | API | gogcli | Notes |
|---------|:--:|:---:|:------:|-------|
| List file labels | ✅ | ✅ | ❌ | Enterprise |
| Modify file labels | ✅ | ✅ | ❌ | Enterprise |

---

## Advanced Features

| Feature | UI | API | gogcli | Notes |
|---------|:--:|:---:|:------:|-------|
| Generate file IDs | ❌ | ✅ | ❌ | |
| Resource keys for links | ❌ | ✅ | ❌ | Link security |
| Content restrictions | ⚠️ | ✅ | ❌ | |
| Workspaces (Priority) | ✅ | ❌ | ❌ | UI-only |
| Approval workflows | ✅ | ❌ | ❌ | UI-only |
| Offline access | ✅ | ❌ | ❌ | Client-side |
| Import conversions | ✅ | ✅ | ❌ | |
| File checksums | ❌ | ✅ | ❌ | MD5, SHA256 |
| Media metadata (EXIF) | ⚠️ | ✅ | ❌ | |
| Capabilities check | ❌ | ✅ | ❌ | Fine-grained perms |

---

## gogcli Command Reference

| Command | Purpose | API Method |
|---------|---------|------------|
| `gog drive ls` | List files | files.list |
| `gog drive search` | Full-text search | files.list (q) |
| `gog drive get` | Get metadata | files.get |
| `gog drive download` | Download/export | files.get / files.export |
| `gog drive upload` | Upload file | files.create |
| `gog drive copy` | Copy file | files.copy |
| `gog drive move` | Move file | files.update (parents) |
| `gog drive rename` | Rename file | files.update (name) |
| `gog drive delete` | Delete to trash | files.update (trashed) |
| `gog drive mkdir` | Create folder | files.create (folder) |
| `gog drive share` | Share file | permissions.create |
| `gog drive unshare` | Remove sharing | permissions.delete |
| `gog drive permissions` | List permissions | permissions.list |
| `gog drive url` | Get web URL | files.get (webViewLink) |
| `gog drive drives` | List shared drives | drives.list |
| `gog drive comments list` | List comments | comments.list |
| `gog drive comments get` | Get comment | comments.get |
| `gog drive comments create` | Create comment | comments.create |
| `gog drive comments update` | Update comment | comments.update |
| `gog drive comments delete` | Delete comment | comments.delete |
| `gog drive comments reply` | Reply to comment | replies.create |

---

## Key Gaps in gogcli

### Not Implemented

| Category | Missing Features |
|----------|------------------|
| **Trash** | Permanent delete, restore, empty trash |
| **Version History** | All revision operations |
| **Shared Drives** | Create, delete, update, hide/unhide |
| **Permissions** | Domain/group sharing, commenter role, ownership transfer, expiration |
| **Changes** | All change tracking and notifications |
| **Organization** | Shortcuts, starring, folder colors |
| **Storage** | Quota information |
| **Labels** | All label operations |
| **Advanced** | Content restrictions, file generation, checksums |

### Design Focus

gogcli focuses on **practical file operations**:

* Core file CRUD (create, read, update, delete)
* Export/download with format conversion
* Basic permission management (user, anyone, reader, writer)
* Comment management
* Shared drive file access

---

## Identifier Semantics

| Identifier | Scope | Format |
|------------|-------|--------|
| File ID | Global | Opaque string |
| Drive ID | Global | Opaque string (=top folder ID) |
| Permission ID | Per file | Opaque string |
| Revision ID | Per file | Opaque string |
| Comment ID | Per file | Integer string |
| Reply ID | Per comment | Integer string |

**Multi-account safe**: All Drive IDs are globally unique. No composite keys needed.

---

## API Rate Limits

| Limit | Rate |
|-------|------|
| Queries per 60s | 12,000 |
| Queries per 60s per user | 12,000 |
| Write requests sustained | 3/second |
| Daily upload cap | 750 GB |
| Export file limit | 10 MB |
