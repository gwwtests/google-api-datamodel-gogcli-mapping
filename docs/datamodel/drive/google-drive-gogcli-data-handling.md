# Google Drive API Implementation in gogcli

**Source**: Analysis of https://github.com/steipete/gogcli source code
**Analysis Date**: 2026-02-06

## Overview

gogcli implements comprehensive support for Google Drive API v3, providing command-line access to file operations, permissions, comments, and metadata management. The implementation emphasizes support for shared drives (Team Drives) through consistent use of `SupportsAllDrives(true)` flags.

## Commands Overview

| Command | API Method(s) | Purpose | Parameters |
|---------|---------------|---------|-----------|
| **ls** | `Files.List` | List files in a folder (default: root) | `--max`, `--page`, `--query`, `--parent` |
| **search** | `Files.List` | Full-text search across Drive | `query`, `--max`, `--page` |
| **get** | `Files.Get` | Get file metadata | `fileId` |
| **download** | `Files.Get`, `Files.Export` | Download a file (exports Google Docs) | `fileId`, `--output`, `--format` |
| **copy** | `Files.Copy` | Copy a file | `fileId`, `name`, `--parent` |
| **upload** | `Files.Create` | Upload a file | `localPath`, `--name`, `--parent` |
| **mkdir** | `Files.Create` | Create a folder | `name`, `--parent` |
| **delete** | `Files.Delete` | Delete a file (moves to trash) | `fileId` |
| **move** | `Files.Update` | Move a file to a different folder | `fileId`, `--parent` (required) |
| **rename** | `Files.Update` | Rename a file or folder | `fileId`, `newName` |
| **share** | `Permissions.Create` | Share a file or folder | `fileId`, `--anyone`, `--email`, `--role`, `--discoverable` |
| **unshare** | `Permissions.Delete` | Remove a permission | `fileId`, `permissionId` |
| **permissions** | `Permissions.List` | List permissions on a file | `fileId`, `--max`, `--page` |
| **url** | `Files.Get` | Print web URLs for files | `fileId...` (variadic) |
| **drives** | `Drives.List` | List shared drives (Team Drives) | `--max`, `--page`, `--query` |

### Comments Management

| Command | API Method | Purpose |
|---------|-----------|---------|
| `comments list` | `Comments.List` | List comments on a file with optional quoted content |
| `comments get` | `Comments.Get` | Get a specific comment by ID |
| `comments create` | `Comments.Create` | Create a comment (optionally anchored to text) |
| `comments update` | `Comments.Update` | Update comment content |
| `comments delete` | `Comments.Delete` | Delete a comment |
| `comments reply` | `Replies.Create` | Reply to a comment |

## File Operations

### List Operations

**Command**: `gog drive ls [--parent FOLDER_ID] [--query QUERY] [--max N] [--page TOKEN]`

Fields retrieved:

* `id` - File ID
* `name` - File name
* `mimeType` - MIME type
* `size` - File size in bytes
* `modifiedTime` - Last modification timestamp (RFC3339)
* `parents` - Parent folder ID(s)
* `webViewLink` - Web view URL

Sorting: By `modifiedTime` descending (newest first)

Behavior:

* Automatically filters out trashed files (`trashed = false`)
* Supports pagination with `nextPageToken`
* Supports custom Drive queries (e.g., `name contains 'report'`)

### Search Operations

**Command**: `gog drive search QUERY [--max N] [--page TOKEN]`

Features:

* Full-text search across Drive content
* Query string escaping for special characters (backslashes, quotes)
* Same pagination and sorting as `ls`
* Filters out trashed files

### Get Metadata

**Command**: `gog drive get FILE_ID`

Fields retrieved:

* `id`
* `name`
* `mimeType`
* `size`
* `modifiedTime`
* `createdTime`
* `parents`
* `webViewLink`
* `description`
* `starred`

### Download Operations

**Command**: `gog drive download FILE_ID [--output PATH] [--format FORMAT]`

Supports:

* **Regular files**: Downloaded as-is via `Files.Get().Download()`
* **Google Docs**: Exported via `Files.Export(fileId, mimeType)`

Export formats:

* **Google Docs** → pdf (default), docx, txt
* **Google Sheets** → pdf (default), csv, xlsx
* **Google Slides** → pdf (default), pptx
* **Google Drawing** → pdf (default), png

Output path resolution:

* If `--output` is a directory, saves with auto-generated filename: `{fileId}_{safeName}`
* If `--output` is a file path, uses that path
* If no `--output`, saves to `~/.config/gog/drive-downloads/{fileId}_{safeName}`
* Filename is sanitized to prevent path traversal attacks

### Upload Operations

**Command**: `gog drive upload LOCAL_PATH [--name NAME] [--parent FOLDER_ID]`

Features:

* Auto-detects MIME type from file extension
* Supported extensions and MIME types:
  * `.pdf` → `application/pdf`
  * `.docx` → `application/vnd.openxmlformats-officedocument.wordprocessingml.document`
  * `.xlsx` → `application/vnd.openxmlformats-officedocument.spreadsheetml.sheet`
  * `.pptx` → `application/vnd.openxmlformats-officedocument.presentationml.presentation`
  * `.png` → `image/png`
  * `.jpg`/`.jpeg` → `image/jpeg`
  * `.gif` → `image/gif`
  * `.txt` → `text/plain`
  * `.html` → `text/html`
  * `.csv` → `text/csv`
  * `.md` → `text/markdown`
  * `.zip` → `application/zip`
  * Plus old Office formats (.doc, .xls, .ppt) and code files (.js, .json, .css)
  * Fallback: `application/octet-stream`

### Copy Operations

**Command**: `gog drive copy FILE_ID NAME [--parent FOLDER_ID]`

Features:

* Uses `Files.Copy()` API call
* Copies entire file with metadata
* Can specify destination folder
* Returns copied file metadata including `webViewLink`

### Create Folder

**Command**: `gog drive mkdir NAME [--parent FOLDER_ID]`

Features:

* Creates folder with MIME type `application/vnd.google-apps.folder`
* Can specify parent folder

### Move Operations

**Command**: `gog drive move FILE_ID --parent FOLDER_ID`

Implementation details:

* Uses `Files.Update()` with `AddParents()` and `RemoveParents()`
* Automatically removes file from previous parent(s)
* Parent ID is required

### Rename Operations

**Command**: `gog drive rename FILE_ID NEW_NAME`

Features:

* Updates file name via `Files.Update()`
* Works for both files and folders

### Delete Operations

**Command**: `gog drive delete FILE_ID`

Features:

* Deletes files (moves to trash, not permanent)
* Requires confirmation with `--confirm` or interactive prompt
* Returns deletion confirmation

## Permission Handling

### Share Operations

**Command**: `gog drive share FILE_ID (--anyone | --email EMAIL) [--role ROLE] [--discoverable]`

Permission types:

* `--anyone` - Makes file publicly accessible (type: "anyone")
* `--email EMAIL` - Share with specific user (type: "user")

Roles:

* `reader` - Read-only access (default)
* `writer` - Read and write access

Discoverable option:

* `--discoverable` - Allow file discovery in search (for "anyone" type only)

Features:

* Returns `webViewLink` for shared resource
* Returns `permissionId` for the created permission
* Doesn't send notification email by default (`SendNotificationEmail(false)`)

### Unshare Operations

**Command**: `gog drive unshare FILE_ID PERMISSION_ID`

Features:

* Removes specific permission by ID
* Requires confirmation for safety
* Returns removed permission confirmation

### List Permissions

**Command**: `gog drive permissions FILE_ID [--max N] [--page TOKEN]`

Fields returned per permission:

* `id` - Permission ID
* `type` - "user", "group", "domain", "anyone"
* `role` - "owner", "writer", "reader", "commenter"
* `emailAddress` - Email address (if applicable)

## URL Operations

**Command**: `gog drive url FILE_ID [FILE_ID ...]` (variadic - accepts multiple IDs)

Features:

* Maps file IDs to web view URLs
* Retrieves `webViewLink` from Drive API
* Falls back to constructed URL if `webViewLink` not available: `https://drive.google.com/file/d/{fileId}/view`

## Comments Management

### List Comments

**Command**: `gog drive comments list FILE_ID [--max N] [--page TOKEN] [--include-quoted]`

Fields retrieved:

* `id` - Comment ID
* `author` - Author display name
* `content` - Comment text
* `createdTime` - RFC3339 timestamp
* `modifiedTime` - RFC3339 timestamp
* `resolved` - Boolean flag
* `quotedFileContent` - Optional: text the comment is anchored to
* `replies` - Reply objects with id, author, content, createdTime

Behavior:

* Excludes deleted comments by default (`IncludeDeleted(false)`)
* `--include-quoted` adds quoted content field to responses

### Get Comment

**Command**: `gog drive comments get FILE_ID COMMENT_ID`

Additional fields:

* `anchor` - Position/anchor information in document

### Create Comment

**Command**: `gog drive comments create FILE_ID CONTENT [--quoted TEXT]`

Features:

* Creates comment on file
* `--quoted TEXT` anchors comment to specific text (for Google Docs)
* Uses `QuotedFileContent.Value` field

### Update Comment

**Command**: `gog drive comments update FILE_ID COMMENT_ID NEW_CONTENT`

Features:

* Updates comment text
* Returns updated timestamp

### Delete Comment

**Command**: `gog drive comments delete FILE_ID COMMENT_ID`

Features:

* Requires confirmation for safety
* Removes comment from file

### Reply to Comment

**Command**: `gog drive comments reply FILE_ID COMMENT_ID REPLY_TEXT`

Features:

* Creates reply object attached to comment
* Tracked as separate `Reply` in API model

## Shared Drive Support

**Command**: `gog drive drives [--max N] [--page TOKEN] [--query Q]`

Features:

* Lists all shared drives (Team Drives) user has access to
* Retrieves: `id`, `name`, `createdTime`
* Supports search query filtering
* Pagination support

### Shared Drive Integration

All file operations support shared drives:

* `SupportsAllDrives(true)` - Set on all file operation calls
* `IncludeItemsFromAllDrives(true)` - Included in `ls` and `search`
* Files can be moved between My Drive and shared drives

## Export Functionality

### Drive-Based Exports

Google Docs, Sheets, Slides, and Drawings use Drive API's `Export()` method:

**Google Docs**: `application/vnd.google-apps.document`

* pdf (default)
* docx
* txt

**Google Sheets**: `application/vnd.google-apps.spreadsheet`

* pdf (default)
* csv
* xlsx

**Google Slides**: `application/vnd.google-apps.presentation`

* pdf (default)
* pptx

**Google Drawing**: `application/vnd.google-apps.drawing`

* pdf (default)
* png

### Export Via Drive Integration

Three helper functions coordinate Drive API with other services:

1. **exportViaDrive()** - Used by docs/sheets/slides export commands
   * Validates expected MIME type
   * Determines export format
   * Downloads via Drive API
   * Resolves output path
   * Returns file path and size

2. **copyViaDrive()** - Used by docs/sheets/slides copy commands
   * Validates MIME type
   * Uses `Files.Copy()` API
   * Supports parent folder specification
   * Used for: Docs copy, Sheets copy, Slides copy

3. **infoViaDrive()** - Used by docs/sheets/slides info commands
   * Retrieves file metadata
   * Validates MIME type
   * Returns id, name, mime, link, created/modified times, parents

## Metadata Handling

### Fields Read

Standard fields requested by operations:

* **File ID** (`id`) - Unique identifier
* **Name** (`name`) - File/folder name
* **MIME Type** (`mimeType`) - Content type (e.g., `application/vnd.google-apps.document`)
* **Size** (`size`) - File size in bytes (null for folders and Google Docs)
* **Timestamps**:
  * `createdTime` - RFC3339 format
  * `modifiedTime` - RFC3339 format
* **Parents** (`parents`) - Array of parent folder IDs
* **Web Link** (`webViewLink`) - URL to view in web UI
* **Description** (`description`) - File description (optional)
* **Starred** (`starred`) - Boolean favorite flag

### Time Formatting

Timestamps are displayed:

* Original: RFC3339 (e.g., "2025-01-28T14:30:45.123Z")
* Displayed: ISO-like format without timezone (e.g., "2025-01-28 14:30")
* Implementation: Truncate to 16 characters and replace 'T' with space

### Size Formatting

File sizes use human-readable units:

* Format: "%.1f UNIT" (e.g., "1.5 MB", "250.0 KB")
* Units: B, KB, MB, GB, TB
* Folders: Displayed as "-"

## Data Structures

### File Struct

Uses `google.golang.org/api/drive/v3.File` with fields:

* `Id` - File ID
* `Name` - Display name
* `MimeType` - Content type
* `Size` - Byte count (int64)
* `CreatedTime` - RFC3339 timestamp
* `ModifiedTime` - RFC3339 timestamp
* `Parents` - []string of parent IDs
* `WebViewLink` - URL string
* `Description` - Text description
* `Starred` - Boolean

### Permission Struct

Uses `google.golang.org/api/drive/v3.Permission`:

* `Id` - Permission ID
* `Type` - "user", "group", "domain", "anyone"
* `Role` - "owner", "writer", "reader", "commenter"
* `EmailAddress` - User email (for type "user")
* `AllowFileDiscovery` - Boolean (for type "anyone")

### Comment Struct

Uses `google.golang.org/api/drive/v3.Comment`:

* `Id` - Comment ID
* `Author` - User object with DisplayName
* `Content` - Comment text
* `CreatedTime` - RFC3339 timestamp
* `ModifiedTime` - RFC3339 timestamp
* `Resolved` - Boolean
* `QuotedFileContent` - Object with `Value` field
* `Anchor` - Position information
* `Replies` - Array of Reply objects

### Reply Struct

Uses `google.golang.org/api/drive/v3.Reply`:

* `Id` - Reply ID
* `Author` - User object
* `Content` - Reply text
* `CreatedTime` - RFC3339 timestamp

### Drive Struct

Uses `google.golang.org/api/drive/v3.Drive` for shared drives:

* `Id` - Shared drive ID
* `Name` - Display name
* `CreatedTime` - RFC3339 timestamp

## Limitations & Features NOT Implemented

### Missing Features

1. **File Revisions**
   * No access to `revisions` endpoint
   * Cannot list or revert to previous versions

2. **Advanced Permissions**
   * No domain-wide sharing
   * No group permissions management
   * No organization-specific permissions
   * Cannot set permission expiration dates
   * No `withLink` parameter support

3. **File Shortcuts**
   * No support for Drive shortcuts/aliases
   * Not treated differently from regular files

4. **Starred/Pinned Files**
   * Can read `starred` flag but cannot modify it
   * No bulk star/unstar operations

5. **Team Drives Management**
   * Can only list shared drives
   * Cannot create, update, or delete shared drives
   * No theme/organization settings

6. **Batch Operations**
   * No batch file operations
   * Operations are individual API calls

7. **Activity/Audit**
   * No access to file change history
   * No activity feed
   * No version history

8. **Search Refinement**
   * Basic full-text search only
   * No advanced search operators beyond Drive's native query language
   * Search is against `fullText` field only, not metadata

9. **Trash Management**
   * Files are deleted to trash, not permanently deleted
   * No `purge` to permanently delete
   * No listing trash contents
   * No restore from trash

10. **Folder Hierarchy**
    * No tree/recursive listing
    * Must manually traverse parent-child relationships
    * No "get full path" functionality

11. **MIME Type Operations**
    * No create/copy to specific format
    * Cannot change existing file MIME type
    * Native Google format conversions only available via export

12. **Access Control**
    * No role inheritance inspection
    * No effective permissions calculation
    * Cannot see who has implicit access via shared folder

13. **Comments Advanced Features**
    * No comment reactions/emoji
    * No mention/notification system for comments
    * Cannot resolve comments (but can query resolved status)
    * No filtering by status
    * Replies are flat, not threaded

14. **Metadata Features**
    * No custom properties/metadata
    * No indexable terms
    * No app-specific properties
    * No ACL/capabilities information
    * No size calculations for folders

15. **Quotas**
    * No quota information available
    * Cannot query storage usage

16. **WebView Link Generation**
    * Uses API-provided link or constructs fallback
    * Not customized for specific views/editors

## Key Implementation Patterns

### API Options Pattern

```go
// All Drive operations use consistent options
svc.Files.List().
    SupportsAllDrives(true).           // Enable shared drives
    IncludeItemsFromAllDrives(true).   // Include shared drive items in results
    Fields("...").                      // Specify fields to minimize data transfer
    Context(ctx).
    Do()
```

### Query Building

Drive uses query language for filtering:

```
'PARENT_ID' in parents AND trashed = false AND name contains 'search'
```

Escaping:

* Backslashes escaped as `\\`
* Single quotes escaped as `\'`

### Output Format Support

All commands support:

* **Table output** (default) - Human-readable table
* **JSON output** (with `--json` flag) - Machine-readable structured data

### Error Handling

* File not found returns structured API error
* Invalid format specification returns clear error message
* Destructive operations require confirmation with `--confirm` flag or interactive prompt

## Cross-Service Usage of Drive API

1. **Docs**: Export, create, copy operations use Drive API
2. **Sheets**: Export, create, copy operations use Drive API
3. **Slides**: Export, create, copy operations use Drive API

These services cannot be used independently for file management—they all delegate to Drive API for file operations.

## Performance Characteristics

* **Pagination**: Default max 20-100 results per request
* **Field Selection**: Minimizes data transfer with explicit `Fields()` specification
* **No Caching**: Fresh data on each API call
* **Sequential Calls**: No batch operations, single-threaded

## Security Considerations

1. **Path Traversal Prevention**
   * Filenames sanitized using `filepath.Base()` for downloads
   * `.` and `..` handled explicitly

2. **Confirmation on Destructive Operations**
   * Delete and unshare operations require `--confirm`
   * Interactive prompt if flag not provided

3. **Email Notification Suppression**
   * Share operations don't send notification emails by default

4. **Query String Escaping**
   * Prevents Drive query injection
