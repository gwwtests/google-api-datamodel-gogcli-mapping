# Google Drive API v3 Capabilities

This document provides a comprehensive analysis of Google Drive API v3 capabilities for use in understanding the data model, semantics, and operational constraints when working with the gogcli tool.

**Last Updated:** 2026-02-06

**Primary Source:** [Google Drive API v3 Documentation](https://developers.google.com/workspace/drive/api/reference/rest/v3)

---

## Table of Contents

1. [Core Resources](#1-core-resources)
2. [File Metadata Fields](#2-file-metadata-fields)
3. [MIME Types & Export Formats](#3-mime-types--export-formats)
4. [Permissions Model](#4-permissions-model)
5. [Shared Drives](#5-shared-drives)
6. [Search & Query](#6-search--query)
7. [Export & Download](#7-export--download)
8. [Pagination & Fields](#8-pagination--fields)
9. [Rate Limits & Quotas](#9-rate-limits--quotas)
10. [Additional Resources](#10-additional-resources)

---

## 1. Core Resources

The Google Drive API v3 exposes several primary resources for working with files, permissions, and organizational structures.

### 1.1 Files Resource

**Resource URI:** `https://www.googleapis.com/drive/v3/files`

The files resource represents metadata and content for files stored in Google Drive. A "file" can be:

* Binary files (documents, images, videos)
* Google Workspace documents (Docs, Sheets, Slides, Forms)
* Folders (special MIME type `application/vnd.google-apps.folder`)
* Shortcuts (special MIME type `application/vnd.google-apps.shortcut`)

**Available Methods:**

* `copy` - Duplicate file with patch semantics updates
* `create` - Create new file
* `delete` - Permanently remove owned file (bypass trash)
* `download` - Retrieve file content (returns Long-Running Operation as of 2026)
* `emptyTrash` - Permanently delete all trashed user files
* `export` - Convert Google Workspace doc to requested MIME type
* `generateIds` - Produce file IDs for create/copy requests
* `get` - Retrieve metadata or content by ID
* `list` - Query user's files
* `listLabels` - Enumerate file labels
* `modifyLabels` - Update applied labels
* `update` - Modify metadata, content, or both
* `watch` - Subscribe to file changes

**Reference:** [REST Resource: files](https://developers.google.com/workspace/drive/api/reference/rest/v3/files)

### 1.2 Permissions Resource

**Resource URI:** `https://www.googleapis.com/drive/v3/files/{fileId}/permissions`

The permissions resource grants access to files, folders, or shared drives. According to the documentation: "A permission grants a user, group, domain, or the world access to a file or a folder hierarchy."

**Available Methods:**

* `create` - Add permission
* `delete` - Remove permission
* `get` - Retrieve by ID
* `list` - View all permissions
* `update` - Modify with patch semantics

**Important:** Concurrent permissions operations on the same file aren't supported; only the last update is applied.

**Reference:** [REST Resource: permissions](https://developers.google.com/workspace/drive/api/reference/rest/v3/permissions)

### 1.3 Revisions Resource

**Resource URI:** `https://www.googleapis.com/drive/v3/files/{fileId}/revisions`

The revisions resource tracks file version history with metadata and content links.

**Available Methods:**

* `delete` - Permanently removes a file version (binary files only, not last version)
* `get` - Retrieves revision metadata or content
* `list` - Enumerates all file revisions
* `update` - Modifies revision with patch semantics

**Retention Policy:**

* Revisions are automatically purged 30 days after newer content is uploaded
* Revisions flagged with `keepForever=true` are exempt (max 200 per file)
* For Docs Editors files with large revision history, the list may be incomplete (older revisions omitted)

**Reference:** [REST Resource: revisions](https://developers.google.com/drive/api/reference/rest/v3/revisions)

### 1.4 Comments Resource

**Resource URI:** `https://www.googleapis.com/drive/v3/files/{fileId}/comments`

The comments resource represents discussions on files.

**Available Methods:**

* `create` - Generates a new comment on a file
* `delete` - Removes a comment
* `get` - Retrieves a specific comment by ID
* `list` - Returns all comments for a file
* `update` - Modifies comment using patch semantics

**Reference:** [REST Resource: comments](https://developers.google.com/workspace/drive/api/reference/rest/v3/comments)

### 1.5 Replies Resource

**Resource URI:** `https://www.googleapis.com/drive/v3/files/{fileId}/comments/{commentId}/replies`

The replies resource represents threaded responses to comments.

**Available Methods:**

* `create` - Adds a reply to a comment
* `delete` - Removes a reply
* `get` - Retrieves a specific reply by ID
* `list` - Returns all replies for a comment
* `update` - Modifies reply using patch semantics

**Special Actions:**

* Use `action=resolve` in the request body to resolve a comment

**Reference:** [REST Resource: replies](https://developers.google.com/workspace/drive/api/reference/rest/v3/replies)

### 1.6 Drives Resource (Shared Drives)

**Resource URI:** `https://www.googleapis.com/drive/v3/drives`

The drives resource represents shared drives (formerly Team Drives). According to the documentation: "Representation of a shared drive. Some resource methods (such as drives.update) require a driveId. Use the drives.list method to retrieve the ID for a shared drive."

The drive ID also serves as the ID of the top-level folder of the shared drive.

**Available Methods:**

* `create` - Create new shared drive
* `delete` - Permanently remove shared drive (organizer only)
* `get` - Retrieve metadata by ID
* `list` - View user's shared drives
* `hide` - Hide from default view
* `unhide` - Restore to default view
* `update` - Modify shared drive metadata

**Reference:** [REST Resource: drives](https://developers.google.com/drive/api/v3/reference/drives)

### 1.7 Changes Resource

**Resource URI:** `https://www.googleapis.com/drive/v3/changes`

The changes resource tracks modifications to files and shared drives.

**Available Methods:**

* `list` - Query changes
* `getStartPageToken` - Get starting point for change tracking
* `watch` - Subscribe to changes via push notifications

**Reference:** [Google Drive API Reference](https://developers.google.com/workspace/drive/api/reference/rest/v3)

---

## 2. File Metadata Fields

The files resource contains extensive metadata fields. All timestamps use RFC 3339 format.

### 2.1 Identifiers & Names

| Field | Type | Notes |
|-------|------|-------|
| `id` | string | Unique file identifier |
| `name` | string | File name (not necessarily unique within folders) |
| `fileExtension` | string | Final component of full extension (binary files only) |
| `fullFileExtension` | string | Complete extension including concatenated types like "tar.gz" |
| `originalFilename` | string | Original uploaded filename or initial name value |
| `kind` | string | Always "drive#file" |

**Important:** The `id` field is the unique identifier for files. File names are NOT unique within a folder.

### 2.2 Ownership & Sharing

| Field | Type | Notes |
|-------|------|-------|
| `ownedByMe` | boolean | Whether user owns the file |
| `owners[]` | User objects | File owner(s), typically one; not populated for shared drives |
| `shared` | boolean | Whether file has been shared |
| `sharingUser` | User object | User who shared file with requester, if applicable |
| `writersCanShare` | boolean | Whether writers can modify sharing permissions |
| `lastModifyingUser` | User object | Most recent modifier |

### 2.3 Timestamps

All timestamps use **RFC 3339 format** (e.g., `2026-01-15T10:30:00.000Z`).

| Field | Type | Notes |
|-------|------|-------|
| `createdTime` | RFC 3339 | File creation datetime |
| `modifiedTime` | RFC 3339 | Last modification by anyone |
| `modifiedByMeTime` | RFC 3339 | Last user modification |
| `modifiedByMe` | boolean | Whether user modified file |
| `viewedByMeTime` | RFC 3339 | Last user view |
| `viewedByMe` | boolean | Whether user has viewed file |
| `sharedWithMeTime` | RFC 3339 | When file was shared with user |
| `trashedTime` | RFC 3339 | When item entered trash |

**Timezone:** All timestamps are in UTC (Coordinated Universal Time).

### 2.4 Content & Storage

| Field | Type | Notes |
|-------|------|-------|
| `mimeType` | string | File MIME type (auto-detected from uploads) |
| `size` | int64 | Blob size in bytes; excludes shortcut/folder files |
| `md5Checksum` | string | MD5 hash (binary files only) |
| `sha1Checksum` | string | SHA1 hash (Drive-stored content only) |
| `sha256Checksum` | string | SHA256 hash (Drive-stored content only) |
| `quotaBytesUsed` | int64 | Storage quota bytes consumed |

**Note:** Checksums are only available for binary files stored in Drive.

### 2.5 Organization & Location

| Field | Type | Notes |
|-------|------|-------|
| `parents[]` | string[] | Parent folder ID (single parent maximum) |
| `driveId` | string | Shared drive containing file |
| `spaces[]` | string[] | Available spaces—"drive", "appDataFolder", or "photos" |
| `description` | string | Brief file summary |
| `starred` | boolean | User-marked starred status |
| `folderColorRgb` | string | Folder/shortcut hex RGB color code |

**Important:** Files can have only ONE parent folder in Drive API v3.

### 2.6 Trash & Deletion

| Field | Type | Notes |
|-------|------|-------|
| `trashed` | boolean | Deleted status (explicit or inherited) |
| `explicitlyTrashed` | boolean | User-deleted versus inherited trashing |
| `trashedTime` | RFC 3339 | When item entered trash |
| `trashingUser` | User object | User who deleted item (shared drives only) |

### 2.7 Permissions & Access Control

| Field | Type | Notes |
|-------|------|-------|
| `permissions[]` | Permission objects | Complete permission list (shareable files) |
| `permissionIds[]` | string[] | User IDs with file access |
| `hasAugmentedPermissions` | boolean | Direct permissions on item (shared drives) |
| `inheritedPermissionsDisabled` | boolean | Inheritance status (enabled by default) |
| `capabilities` | object | 40+ fine-grained user actions supported |

**Capabilities Object:** Contains boolean flags for user actions like `canEdit`, `canShare`, `canComment`, `canDownload`, `canCopy`, `canDelete`, etc.

### 2.8 Restrictions

| Field | Type | Notes |
|-------|------|-------|
| `contentRestrictions[]` | ContentRestriction objects | Access limitations |
| `copyRequiresWriterPermission` | boolean | Disable copy/print for readers/commenters |
| `downloadRestrictions` | DownloadRestrictionsMetadata | Copy/download constraints |

### 2.9 Links & Display

| Field | Type | Notes |
|-------|------|-------|
| `webViewLink` | string | Editor/viewer link in browser |
| `webContentLink` | string | Download link (binary files) |
| `iconLink` | string | Static unauthenticated file icon |
| `thumbnailLink` | string | Short-lived thumbnail URL (credentialed access) |
| `hasThumbnail` | boolean | Whether thumbnail exists |
| `thumbnailVersion` | int64 | Cache invalidation version |

### 2.10 Versioning & Integrity

| Field | Type | Notes |
|-------|------|-------|
| `version` | int64 | Monotonic version for all server changes |
| `headRevisionId` | string | Current revision ID (binary files) |
| `isAppAuthorized` | boolean | App creation/opening status |

### 2.11 Properties & Labels

| Field | Type | Notes |
|-------|------|-------|
| `properties` | map | User-visible custom key-value pairs |
| `appProperties` | map | Private app-specific properties (authenticated access) |
| `labelInfo.labels[]` | Label objects | Applied labels (requested via includeLabels) |

### 2.12 Media Metadata

| Field | Type | Notes |
|-------|------|-------|
| `imageMediaMetadata` | object | EXIF data including camera settings, location, rotation, dimensions |
| `videoMediaMetadata` | object | Video dimensions and duration in milliseconds |

### 2.13 Shortcut Details

| Field | Type | Notes |
|-------|------|-------|
| `shortcutDetails.targetId` | string | Target file ID |
| `shortcutDetails.targetMimeType` | string | Target MIME type snapshot |
| `shortcutDetails.targetResourceKey` | string | Target resource key |

### 2.14 Security & Links

| Field | Type | Notes |
|-------|------|-------|
| `resourceKey` | string | Shared link access requirement |
| `linkShareMetadata.securityUpdateEligible` | boolean | Update qualification |
| `linkShareMetadata.securityUpdateEnabled` | boolean | Security update activation |

**Resource Keys:** Protect link-shared files from unintended access. Users who haven't previously accessed a file must provide the resource key.

**Reference:** [Access link-shared Drive files using resource keys](https://developers.google.com/workspace/drive/api/guides/resource-keys)

---

## 3. MIME Types & Export Formats

Google Drive distinguishes between native Google Workspace documents and binary files.

### 3.1 Google Workspace MIME Types

Native Google Workspace documents use `application/vnd.google-apps.*` MIME types:

* `application/vnd.google-apps.document` - Google Docs
* `application/vnd.google-apps.spreadsheet` - Google Sheets
* `application/vnd.google-apps.presentation` - Google Slides
* `application/vnd.google-apps.drawing` - Google Drawings
* `application/vnd.google-apps.form` - Google Forms
* `application/vnd.google-apps.script` - Apps Script
* `application/vnd.google-apps.folder` - Folder (not a file)
* `application/vnd.google-apps.shortcut` - Shortcut to another file

**Reference:** [Google Workspace and Google Drive supported MIME types](https://developers.google.com/workspace/drive/api/guides/mime-types)

### 3.2 Export Formats by Document Type

Google Workspace documents can be exported to various formats using the `files.export` method. The exported content is limited to **10 MB**.

#### Google Docs Export Formats

* Microsoft Word: `application/vnd.openxmlformats-officedocument.wordprocessingml.document` (.docx)
* OpenDocument: `application/vnd.oasis.opendocument.text` (.odt)
* Rich Text: `application/rtf` (.rtf)
* PDF: `application/pdf` (.pdf)
* Plain Text: `text/plain` (.txt)
* Web Page (HTML): `application/zip` (.zip)
* EPUB: `application/epub+zip` (.epub)
* Markdown: `text/markdown` (.md)

#### Google Sheets Export Formats

* Microsoft Excel: `application/vnd.openxmlformats-officedocument.spreadsheetml.sheet` (.xlsx)
* OpenDocument: `application/vnd.oasis.opendocument.spreadsheet` (.ods)
* PDF: `application/pdf` (.pdf)
* Web Page (HTML): `application/zip` (.zip)
* CSV (first sheet): `text/csv` (.csv)
* TSV (first sheet): `text/tab-separated-values` (.tsv)

#### Google Slides Export Formats

* Microsoft PowerPoint: `application/vnd.openxmlformats-officedocument.presentationml.presentation` (.pptx)
* ODP: `application/vnd.oasis.opendocument.presentation` (.odp)
* PDF: `application/pdf` (.pdf)
* Plain Text: `text/plain` (.txt)
* JPEG (first slide): `image/jpeg` (.jpg)
* PNG (first slide): `image/png` (.png)
* SVG (first slide): `image/svg+xml` (.svg)

#### Google Drawings Export Formats

* PDF: `application/pdf` (.pdf)
* JPEG: `image/jpeg` (.jpg)
* PNG: `image/png` (.png)
* SVG: `image/svg+xml` (.svg)

#### Additional Formats

* Apps Script (JSON): `application/vnd.google-apps.script+json` (.json)
* Google Vids (MP4): `video/mp4` (.mp4)

**Reference:** [Export MIME types for Google Workspace documents](https://developers.google.com/workspace/drive/api/guides/ref-export-formats)

### 3.3 Import Conversions

The Drive API can convert uploaded binary files to Google Workspace formats during the `files.create` operation by specifying the target `mimeType` in the request body.

---

## 4. Permissions Model

The permissions model controls who can access files, folders, and shared drives.

### 4.1 Permission Resource Structure

**Key Fields:**

* `id` - Unique identifier for the grantee
* `type` - Grantee type (user, group, domain, anyone)
* `role` - Permission level granted
* `emailAddress` - For user/group types
* `domain` - For domain type
* `displayName` - Human-readable name
* `allowFileDiscovery` - Whether file is discoverable via search
* `expirationTime` - Optional expiration (RFC 3339 format)
* `deleted` - Account deletion status
* `pendingOwner` - Pending ownership status
* `view` - "published" or "metadata" (for views)

**Reference:** [REST Resource: permissions](https://developers.google.com/workspace/drive/api/reference/rest/v3/permissions)

### 4.2 Role Types

#### My Drive Roles

* `owner` - Grants full control over the file or folder
* `writer` - Grants the ability to view the file, add comments, and edit
* `commenter` - Grants the ability to view the file and add comments
* `reader` - Grants the ability to view the file

#### Shared Drive Roles

* `organizer` - Grants the ability to manage files, folders, people, and settings
* `fileOrganizer` - Grants the ability to contribute and manage content
* `writer` - Contributor role for shared drives
* `commenter` - Same as My Drive
* `reader` - Same as My Drive

**Reference:** [Roles and permissions](https://developers.google.com/workspace/drive/api/guides/ref-roles)

### 4.3 Permission Types

* **user** - Requires `emailAddress` field
* **group** - Requires `emailAddress` field
* **domain** - Requires `domain` parameter (Google Workspace only)
* **anyone** - Public access (no additional information needed)

### 4.4 Capabilities by Role

| Capability | owner | writer | commenter | reader |
|-----------|-------|--------|-----------|--------|
| Read metadata | ✓ | ✓ | ✓ | ✓ |
| Read content | ✓ | ✓ | ✓ | ✓ |
| Add comments | ✓ | ✓ | ✓ | ✗ |
| Modify metadata | ✓ | ✓ | ✗ | ✗ |
| Modify content | ✓ | ✓ | ✗ | ✗ |
| Share items | ✓ | ✗ | ✗ | ✗ |
| Delete files | ✓ | ✗ | ✗ | ✗ |

### 4.5 Permission Views

Permissions may include a `view` restriction:

* `view=published` - Grants access only to published file versions
* `view=metadata` - Grants access only to folder metadata, not contents

### 4.6 Sharing Settings

Files can have restrictions on sharing behavior:

* `copyRequiresWriterPermission` - Disable copy/print for readers/commenters
* `writersCanShare` - Whether writers can modify sharing permissions
* `allowFileDiscovery` - Whether file is discoverable via search (for domain/anyone permissions)

---

## 5. Shared Drives

Shared drives (formerly Team Drives) support files owned by an organization rather than an individual user. They feature distinct models for organization, permissions, and ownership compared to My Drive.

### 5.1 Core Requirement

Apps must include `supportsAllDrives=true` query parameter when performing file operations on shared drives.

**Affected Methods:**

* File operations: `files.get`, `files.list`, `files.create`, `files.update`, `files.copy`, `files.delete`
* Change tracking: `changes.list`, `changes.getStartPageToken`
* Permissions: `permissions.list`, `permissions.get`, `permissions.create`, `permissions.update`, `permissions.delete`

**Reference:** [Implement shared drive support](https://developers.google.com/workspace/drive/api/guides/enable-shareddrives)

### 5.2 Drives Resource Structure

**Key Fields:**

* `id` (string) - Unique shared drive identifier (also the ID of the top-level folder)
* `name` (string) - The shared drive's name
* `themeId` (string) - Theme determining background image and color
* `colorRgb` (string) - RGB hex color value
* `backgroundImageLink` (string) - Temporary background image URL
* `createdTime` (string) - RFC 3339 timestamp
* `hidden` (boolean) - Visibility status in default view
* `orgUnitId` (string) - Organizational unit (populated with domain admin access)

### 5.3 Capabilities Object (21 boolean flags)

Users' permissions on shared drives include:

* File operations: `canAddChildren`, `canCopy`, `canDelete`, `canDownload`, `canEdit`, `canTrashChildren`
* Collaboration: `canComment`, `canManageMembers`, `canShare`
* Drive management: `canRename`, `canChangeDriveBackground`, `canChangeDriveMembersOnlyRestriction`, `canChangeCopyRequiresWriterPermissionRestriction`, `canResetDriveRestrictions`
* Other: `canReadRevisions`, `canDeleteChildren`, and more

### 5.4 Restrictions Object

Administrators can enforce organizational policies:

* `copyRequiresWriterPermission` - Override reader/commenter copy/print/download permissions
* `domainUsersOnly` - Domain-restricted access
* `driveMembersOnly` - Member-only access
* `sharingFoldersRequiresOrganizerPermission` - Organizer-only folder sharing
* `downloadRestriction` - Manager-applied download controls
* `adminManagedRestrictions` - Administrative privilege requirement flag

### 5.5 Search-Specific Parameters

To locate content on shared drives:

* `driveId` - Specifies which shared drive to search
* `corpora` - Bodies of items to query—`user`, `domain`, `drive`, or `allDrives` (prefer `user`/`drive` for efficiency)
* `includeItemsFromAllDrives` - Boolean to include both My Drive and shared drive results
* `supportsAllDrives` - Confirms application capability

### 5.6 Change Tracking Parameters

Monitor shared drive modifications using:

* `driveId` - Returns changes from specified shared drive
* `includeItemsFromAllDrives` - Boolean to include shared drive changes
* `supportsAllDrives` - Enables shared drive change tracking

### 5.7 Key Differences from My Drive

* **Ownership:** Files are owned by the organization, not individuals
* **Permissions:** Different role structure (organizer, fileOrganizer vs. owner)
* **Retention:** Deleted files bypass user trash and go directly to shared drive trash
* **Member Management:** Requires organizer role
* **Settings:** Organizational policies can restrict operations

---

## 6. Search & Query

The Drive API provides powerful search capabilities via the `q` parameter on the `files.list` method.

### 6.1 Query Operators

The API supports these logical and comparison operators:

* **Comparison:** `contains`, `=`, `!=`, `<`, `<=`, `>`, `>=`
* **Logical:** `and`, `or`, `not`, `in`, `has`

### 6.2 Searchable Fields

| Field | Operators | Notes |
|-------|-----------|-------|
| `name` | contains, =, != | Use single quotes; escape with `\'` |
| `fullText` | contains | Searches name, description, content, metadata |
| `mimeType` | contains, =, != | Identify file types |
| `modifiedTime` | <=, <, =, !=, >, >= | RFC 3339 format timestamps |
| `trashed` | =, != | Boolean: true/false |
| `starred` | =, != | Boolean: true/false |
| `parents` | in | Check folder membership by ID |
| `owners`, `writers`, `readers` | in | User/group permissions |
| `sharedWithMe` | =, != | "Shared with me" collection status |
| `createdTime` | <=, <, =, !=, >, >= | Creation timestamp |
| `properties`, `appProperties` | has | Custom metadata |
| `visibility` | =, != | Values: anyoneCanFind, anyoneWithLink, domainCanFind, domainWithLink, limited |

**Reference:** [Search query terms and operators](https://developers.google.com/workspace/drive/api/guides/ref-search-terms)

### 6.3 Query Syntax Examples

**Prefix matching:**
```
name contains 'Hello'
```
Matches "HelloWorld" but NOT "WorldHello"

**Phrase matching (fullText):**
```
fullText contains '"Hello there"'
```
Finds exact phrases

**Compound queries:**
```
name = 'report.pdf' and trashed = false
```

**Folder membership:**
```
'1234567890' in parents
```

**MIME type filtering:**
```
mimeType = 'application/vnd.google-apps.folder'
```

**Date range:**
```
modifiedTime > '2026-01-01T00:00:00' and modifiedTime < '2026-02-01T00:00:00'
```

**Shared with me:**
```
sharedWithMe = true and trashed = false
```

### 6.4 Special Syntax Rules

* **Escape special characters:** Use backslash to escape apostrophes and backslashes
  * Example: `name contains 'quinn\'s paper\\essay'`
* **Trashed files:** By default, `files.list` returns all files including trashed. Use `trashed=false` to exclude.
* **Contains operator:** Performs prefix matching for `name` terms, full-text search for `fullText` term
* **Quote matching:** Surround right operand with double quotes for exact alphanumeric phrase matching

### 6.5 Shared Drive Query Terms

Additional fields for shared drive searches:

* `hidden` - Boolean visibility
* `name` - Shared drive name
* `createdTime` - Creation timestamp
* `memberCount`, `organizerCount` - Numeric comparison
* `orgUnitId` - String matching

**Reference:** [Search for shared drives](https://developers.google.com/drive/api/v3/search-shareddrives)

---

## 7. Export & Download

The Drive API provides different methods for exporting/downloading depending on file type.

### 7.1 Export Google Workspace Files

Use `files.export` for Google Workspace documents (Docs, Sheets, Slides, Drawings).

**Endpoint:**
```
GET https://www.googleapis.com/drive/v3/files/{fileId}/export?mimeType={exportMimeType}
```

**Limitations:**

* Exported content is limited to **10 MB**
* Returns exported byte content directly
* Requires specifying target MIME type (see Section 3.2)

**Example:**
```
GET /drive/v3/files/1abc123/export?mimeType=application/pdf
```

**Reference:** [Method: files.export](https://developers.google.com/workspace/drive/api/reference/rest/v3/files/export)

### 7.2 Download Binary Files

Use `files.get` with `alt=media` for binary files.

**Endpoint:**
```
GET https://www.googleapis.com/drive/v3/files/{fileId}?alt=media
```

**Long-Running Operations (LRO):**

As of 2026, the Drive API returns a Long-Running Operation (LRO) every time you call `files.download` for downloading blob file content or exporting Google Workspace documents. This improves handling of large file downloads.

**Example:**
```
GET /drive/v3/files/1abc123?alt=media
```

### 7.3 Download via webContentLink

Binary files have a `webContentLink` field that provides a direct download URL. This link includes authentication and can be used for browser-based downloads.

### 7.4 Export Links

Google Workspace files have an `exportLinks` map in their metadata, providing pre-generated export URLs for various formats.

**Example:**
```json
{
  "exportLinks": {
    "application/pdf": "https://docs.google.com/document/d/1abc123/export?format=pdf",
    "application/vnd.openxmlformats-officedocument.wordprocessingml.document": "https://docs.google.com/document/d/1abc123/export?format=docx"
  }
}
```

---

## 8. Pagination & Fields

### 8.1 Pagination

List operations support pagination via these parameters:

* `pageSize` - Number of results per page (max varies by method)
* `pageToken` - Token for retrieving next page (from previous response)

**Example:**
```
GET /drive/v3/files?pageSize=100
```

Response includes `nextPageToken` if more results exist:
```json
{
  "files": [...],
  "nextPageToken": "abc123xyz"
}
```

Retrieve next page:
```
GET /drive/v3/files?pageSize=100&pageToken=abc123xyz
```

### 8.2 Fields Parameter (Partial Response)

The `fields` parameter uses FieldMask for response filtering, allowing you to specify which fields to return. This significantly improves performance by reducing unnecessary data transfer.

**Syntax:**

* **Comma-separated selections:** `fields=name,starred,shared`
* **Nested field access:** `fields=capabilities/canDownload`
* **Sub-selectors:** `fields=permissions(id,role)` returns only ID and role from permissions array
* **Wildcards:** `fields=permissions/permissionDetails/*` (⚠️ may degrade performance)

**Examples:**

Simple request:
```
GET /drive/v3/files/FILE_ID?fields=name,starred,shared
```

Nested resource request:
```
GET /drive/v3/files/FILE_ID?fields=name,permissions(kind,type,role)
```

List with specific fields:
```
GET /drive/v3/files?fields=files(id,name,mimeType,modifiedTime)
```

**Important Notes:**

* Methods for `about`, `comments`, and `replies` resources **require** explicit fields specification (no defaults)
* Invalid fields selections return HTTP 400 with specific error messages
* Using field masks is considered good design practice

**Reference:** [Return specific fields](https://developers.google.com/workspace/drive/api/guides/fields-parameter)

### 8.3 Default Fields

If you don't specify the `fields` parameter, methods return defaults:

* `files.list` - Returns only `kind`, `id`, `name`, and `mimeType`
* `files.get` - Returns most fields (but can be bandwidth-intensive)

### 8.4 Performance Best Practices

According to the documentation: "using a field mask is good design practice to avoid requesting unnecessary data." Combined with pagination parameters like `pageSize` and `nextPageToken`, the fields parameter helps realize meaningful performance gains.

**Reference:** [Improve performance](https://developers.google.com/workspace/drive/api/guides/performance)

---

## 9. Rate Limits & Quotas

### 9.1 Quota Limits

**Per 60 seconds:** 12,000 queries
**Per 60 seconds per user:** 12,000 queries

**Daily Limits:** There is no daily request limit if you stay within the per-minute quotas.

**Reference:** [Usage limits](https://developers.google.com/workspace/drive/api/guides/limits)

### 9.2 Storage Limits

Google Workspace users face these restrictions:

* **Daily upload cap:** 750 GB per day across My Drive and shared drives
* **Maximum file size for upload:** 5 TB (only the first file exceeding the limit uploads)
* **Maximum file size for copying:** 750 GB per day

Users hitting the 750 GB limit cannot upload or copy additional files for 24 hours.

### 9.3 Write Request Limitations

The rate of Drive API write requests is limited—avoid exceeding **3 requests per second** of sustained write or insert requests, per account.

### 9.4 Error Responses

Exceeding quotas triggers these HTTP responses:

* **403 User rate limit exceeded** - Standard quota breach
* **429 Too many requests** - Additional backend rate limit checks

### 9.5 Handling Rate Limits

The documentation recommends: "use a _truncated exponential backoff_ to make sure your devices don't generate excessive load."

**Exponential Backoff Algorithm:**

1. Wait time formula: `min(((2^n) + random_number_milliseconds), maximum_backoff)`
2. Increment `n` with each retry
3. Add randomization (≤1,000ms) to prevent synchronized retry waves
4. Set `maximum_backoff` to 32-64 seconds typically
5. Continue retrying at maximum interval if needed

**Example Implementation (pseudocode):**
```
n = 0
while (request_fails):
    wait_time = min(((2^n) + random(0, 1000)), 32000)
    sleep(wait_time)
    n += 1
    retry_request()
```

### 9.6 Quota Increases

* Quota increases can be requested via Google Cloud Console but aren't guaranteed
* View quotas at: IAM & Admin > Quotas & System Limits
* Service account API calls count as single-account usage

### 9.7 Push Notification Quotas

* Push notifications themselves don't count toward quotas
* However, `changes.watch`, `channels.stop`, and `files.watch` calls DO count toward quotas

---

## 10. Additional Resources

### 10.1 Revisions

**Retention:**

* Automatic purge: 30 days after newer content uploaded
* Keep forever: Flag `keepForever=true` (max 200 per file)
* Deletion: Only binary file revisions can be deleted (not Docs Editors files, not last revision)

**Incomplete History:**

For files with large revision history (frequently edited Docs/Sheets/Slides), the `revisions.list` response may be incomplete—older revisions might be omitted.

**Reference:** [Manage file revisions](https://developers.google.com/drive/api/guides/manage-revisions)

### 10.2 Comments & Replies

**Comment Structure:**

* `content` - Plain text input
* `htmlContent` - Formatted output for display
* `anchor` - JSON string representing document region
* `resolved` - Boolean indicating resolution status
* `replies[]` - Chronologically ordered Reply objects

**Special Actions:**

* Use `action=resolve` in reply creation to resolve a comment

**Reference:** [Manage comments and replies](https://developers.google.com/workspace/drive/api/guides/manage-comments)

### 10.3 Push Notifications

**Setup Requirements:**

1. HTTPS webhook receiver with valid SSL certificate
2. Notification channel configuration via `watch` method

**Channel Properties:**

* `id` - Unique identifier (UUID recommended, max 64 characters)
* `type` - Must be "web_hook"
* `address` - HTTPS URL for receiving notifications
* `token` - Custom value for verification (max 256 characters, optional)
* `expiration` - Unix timestamp in milliseconds (optional)

**Notification Headers:**

* `X-Goog-Channel-ID`
* `X-Goog-Message-Number`
* `X-Goog-Resource-State` (values: sync, add, remove, update, trash, untrash, change)
* `X-Goog-Changed` (optional: content, parents, children, permissions)

**Expiration & Renewal:**

* Maximum expiration: 86400 seconds (1 day) for `files` resource, 604800 seconds (1 week) for `changes`
* No automatic renewal; replace channels by calling `watch` with new unique ID
* Stop notifications via `channels.stop` endpoint

**Reference:** [Notifications for resource changes](https://developers.google.com/workspace/drive/api/guides/push)

### 10.4 Resource Keys

**Purpose:**

Resource keys protect link-shared files from unintended access. They are required for files with `type=domain` or `type=anyone` permissions where `allowFileDiscovery=false` (v3) or `withLink=true` (v2).

**Affected Files:**

* Old files (pre-September 2021) with link sharing enabled
* Users who haven't previously accessed the file must provide the resource key
* Users with recent viewing history or direct access don't require it

**API Implementation:**

* Returned on read-only `resourceKey` field of files resource
* Included in `shortcutDetails.targetResourceKey` for shortcuts
* Included in URL-returning fields: `exportLinks`, `webContentLink`, `webViewLink`

**Header Syntax:**

```
X-Goog-Drive-Resource-Keys: fileId1/resourceKey1,fileId2/resourceKey2
```

File ID and resource key pairs use forward slash separators; multiple pairs use commas.

**Reference:** [Access link-shared Drive files using resource keys](https://developers.google.com/workspace/drive/api/guides/resource-keys)

### 10.5 Changes API

The changes resource tracks modifications to files and shared drives over time.

**Methods:**

* `changes.list` - Query changes since a start page token
* `changes.getStartPageToken` - Get starting point for change tracking
* `changes.watch` - Subscribe to changes via push notifications

**Use Cases:**

* Synchronizing local state with Drive
* Building notification systems
* Tracking file modifications across accounts

**Reference:** [Changes and revisions overview](https://developers.google.com/workspace/drive/api/guides/change-overview)

### 10.6 Labels

The Drive API supports labels for organizing and categorizing files.

**Methods:**

* `files.listLabels` - Enumerate file labels
* `files.modifyLabels` - Update applied labels

**Fields:**

* `labelInfo.labels[]` - Applied labels (must request via `includeLabels` parameter)

### 10.7 Folders with Limited Access

As of 2026, developers can set the boolean `inheritedPermissionsDisabled` field on the files resource to `true` to restrict folders to specific users. This allows folders with limited access separate from inherited permissions.

---

## Sources

This document was compiled from official Google Drive API v3 documentation and web research conducted on 2026-02-06:

* [Google Drive API v3 Reference](https://developers.google.com/workspace/drive/api/reference/rest/v3)
* [REST Resource: files](https://developers.google.com/workspace/drive/api/reference/rest/v3/files)
* [Export MIME types for Google Workspace documents](https://developers.google.com/workspace/drive/api/guides/ref-export-formats)
* [Google Workspace and Google Drive supported MIME types](https://developers.google.com/workspace/drive/api/guides/mime-types)
* [REST Resource: permissions](https://developers.google.com/workspace/drive/api/reference/rest/v3/permissions)
* [Roles and permissions](https://developers.google.com/workspace/drive/api/guides/ref-roles)
* [Share files, folders, and drives](https://developers.google.com/workspace/drive/api/guides/manage-sharing)
* [REST Resource: drives](https://developers.google.com/drive/api/v3/reference/drives)
* [Implement shared drive support](https://developers.google.com/workspace/drive/api/guides/enable-shareddrives)
* [Manage shared drives](https://developers.google.com/workspace/drive/api/guides/manage-shareddrives)
* [Search query terms and operators](https://developers.google.com/workspace/drive/api/guides/ref-search-terms)
* [Search for files and folders](https://developers.google.com/workspace/drive/api/guides/search-files)
* [Usage limits](https://developers.google.com/workspace/drive/api/guides/limits)
* [REST Resource: revisions](https://developers.google.com/drive/api/reference/rest/v3/revisions)
* [Manage file revisions](https://developers.google.com/drive/api/guides/manage-revisions)
* [REST Resource: comments](https://developers.google.com/workspace/drive/api/reference/rest/v3/comments)
* [Manage comments and replies](https://developers.google.com/workspace/drive/api/guides/manage-comments)
* [Notifications for resource changes](https://developers.google.com/workspace/drive/api/guides/push)
* [Access link-shared Drive files using resource keys](https://developers.google.com/workspace/drive/api/guides/resource-keys)
* [Return specific fields](https://developers.google.com/workspace/drive/api/guides/fields-parameter)
* [Improve performance](https://developers.google.com/workspace/drive/api/guides/performance)
* [Changes and revisions overview](https://developers.google.com/workspace/drive/api/guides/change-overview)
* [Google Drive API release notes](https://developers.google.com/workspace/drive/release-notes)

---

## Revision History

* 2026-02-06 - Initial comprehensive documentation of Google Drive API v3 capabilities
