# Gmail Filter Format Comparison: API JSON vs WebUI XML

**Downloaded**: 2026-02-03

**Sources**:

* [Gmail API - users.settings.filters](https://developers.google.com/gmail/api/reference/rest/v1/users.settings.filters)
* [Gmail API - Managing Filters](https://developers.google.com/workspace/gmail/api/guides/filter_settings)
* [Gmail API - Migrating from Email Settings API](https://developers.google.com/workspace/gmail/api/guides/migrate-from-email-settings)

---

## Overview

Gmail provides **two distinct formats** for filter management:

1. **JSON format** - Used by Gmail API for programmatic access
2. **XML format** - Used by WebUI for manual import/export

**These formats are NOT directly compatible** and require conversion.

---

## Format Comparison

### Serialization Format

| Aspect | API (JSON) | WebUI (XML) |
|--------|-----------|-------------|
| **Format** | JSON | Atom feed XML |
| **Namespace** | N/A | `xmlns:apps="http://schemas.google.com/apps/2006"` |
| **Access Method** | REST API calls | WebUI import/export |
| **Programmatic** | Yes | Limited (manual editing) |
| **Version Control** | Via API wrapper | Direct git tracking |

---

## Field Mapping

### Structure Organization

**API JSON** - Flat structure with nested objects:

```json
{
  "id": "ANe1Bmj...",
  "criteria": { ... },
  "action": { ... }
}
```

**WebUI XML** - Atom entry with property elements:

```xml
<entry>
  <id>tag:mail.google.com,2008:filter:123</id>
  <apps:property name="..." value="..."/>
  <apps:property name="..." value="..."/>
</entry>
```

### Matching Criteria

| Concept | API JSON Field | WebUI XML Property | Notes |
|---------|---------------|-------------------|-------|
| **Sender** | `criteria.from` | `<apps:property name="from">` | Same semantics |
| **Recipient** | `criteria.to` | `<apps:property name="to">` | Same semantics |
| **Subject** | `criteria.subject` | `<apps:property name="subject">` | Same semantics |
| **Query** | `criteria.query` | `<apps:property name="hasTheWord">` | **Different name!** |
| **Negated Query** | `criteria.negatedQuery` | `<apps:property name="doesNotHaveTheWord">` | **Different name!** |
| **Has Attachment** | `criteria.hasAttachment` (boolean) | `<apps:property name="hasAttachment" value="true">` | Same semantics |
| **Exclude Chats** | `criteria.excludeChats` (boolean) | N/A (not supported in XML) | **API only** |
| **Size** | `criteria.size` (integer) + `criteria.sizeComparison` (enum) | `<apps:property name="sizeOperator">` + `<apps:property name="sizeUnit">` | Different representation |

### Actions

| Concept | API JSON Field | WebUI XML Property | Notes |
|---------|---------------|-------------------|-------|
| **Apply Label** | `action.addLabelIds: ["LABEL_ID"]` | `<apps:property name="label" value="Label/Name">` | **ID vs Name!** |
| **Remove Label** | `action.removeLabelIds: ["LABEL_ID"]` | N/A | Use specific action properties |
| **Archive** | `action.removeLabelIds: ["INBOX"]` | `<apps:property name="shouldArchive" value="true">` | **Different semantics!** |
| **Mark Read** | `action.addLabelIds: ["UNREAD"]` removal | `<apps:property name="shouldMarkAsRead" value="true">` | **Different semantics!** |
| **Star** | `action.addLabelIds: ["STARRED"]` | `<apps:property name="shouldStar" value="true">` | **Different semantics!** |
| **Trash** | `action.addLabelIds: ["TRASH"]` | `<apps:property name="shouldTrash" value="true">` | **Different semantics!** |
| **Never Spam** | System label manipulation | `<apps:property name="shouldNeverSpam" value="true">` | **Different semantics!** |
| **Mark Important** | `action.addLabelIds: ["IMPORTANT"]` | `<apps:property name="shouldAlwaysMarkAsImportant" value="true">` | **Different semantics!** |
| **Never Important** | `action.removeLabelIds: ["IMPORTANT"]` | `<apps:property name="shouldNeverMarkAsImportant" value="true">` | **Different semantics!** |
| **Forward** | `action.forward: "email@example.com"` | `<apps:property name="forwardTo" value="email@example.com">` | Same semantics |

---

## Critical Differences

### 1. Label References

**API JSON** uses **label IDs**:

```json
{
  "action": {
    "addLabelIds": ["Label_1234567890"],
    "removeLabelIds": ["INBOX"]
  }
}
```

**WebUI XML** uses **label names** (with hierarchy):

```xml
<apps:property name="label" value="Work/Projects/Active"/>
```

**Conversion requirement**: Must resolve label names to IDs using `users.labels.list`

### 2. Action Semantics

**API JSON** uses label manipulation:

```json
{
  "action": {
    "removeLabelIds": ["INBOX"],        // Archive
    "addLabelIds": ["STARRED"]          // Star
  }
}
```

**WebUI XML** uses boolean action flags:

```xml
<apps:property name="shouldArchive" value="true"/>
<apps:property name="shouldStar" value="true"/>
```

**Conversion requirement**: Map action flags to label operations

### 3. Query Field Naming

**API JSON**: `criteria.query`

**WebUI XML**: `<apps:property name="hasTheWord">`

**These are semantically equivalent** but differently named.

### 4. Multiple Criteria

**API JSON** - Separate fields:

```json
{
  "criteria": {
    "from": "sender1@example.com",
    "query": "urgent"
  }
}
```

**WebUI XML** - OR syntax in single property:

```xml
<apps:property name="from" value="sender1@example.com OR sender2@example.com"/>
<apps:property name="hasTheWord" value="urgent"/>
```

### 5. Size Comparison

**API JSON** - Integer + enum:

```json
{
  "criteria": {
    "size": 10485760,
    "sizeComparison": "larger"
  }
}
```

**WebUI XML** - Operator + unit:

```xml
<apps:property name="sizeOperator" value="s_sl"/>
<apps:property name="sizeUnit" value="s_smb"/>
```

---

## Behavioral Differences

### 1. Alias Expansion

* **WebUI**: Performs alias expansion for Google Workspace accounts
* **API**: Does not expand aliases

**Example**: Email sent by `myalias@company.net` (alias of `user@company.net`)

* WebUI filter on `to:myalias@company.net` → **matches**
* API filter with `criteria.to: "myalias@company.net"` → **may not match**

### 2. Thread-wide Search

* **WebUI**: Searches across entire threads
* **API**: Searches individual messages only

**Impact**: Filter matching can differ for threaded conversations.

### 3. Filter Application Scope

* **API**: Explicitly applies to **messages**, not threads
* **WebUI**: Applies to messages but UI may suggest thread-level behavior

---

## Conversion Strategies

### JSON → XML Conversion

**Steps**:

1. Map `criteria.query` → `<apps:property name="hasTheWord">`
2. Map `criteria.negatedQuery` → `<apps:property name="doesNotHaveTheWord">`
3. Resolve **label IDs to label names** using `users.labels.list`
4. Map label operations to action flags:
   * `removeLabelIds: ["INBOX"]` → `shouldArchive="true"`
   * `addLabelIds: ["STARRED"]` → `shouldStar="true"`
   * etc.
5. Convert size comparison to XML format
6. Wrap in Atom feed structure

**Challenges**:

* Must query API to resolve label IDs
* Complex label operations may not map cleanly
* Loss of `excludeChats` criteria (not supported in XML)

### XML → JSON Conversion

**Steps**:

1. Map `hasTheWord` → `criteria.query`
2. Map `doesNotHaveTheWord` → `criteria.negatedQuery`
3. Parse `label` property and resolve **names to IDs** using `users.labels.list`
4. Map action flags to label operations:
   * `shouldArchive="true"` → `removeLabelIds: ["INBOX"]`
   * `shouldStar="true"` → `addLabelIds: ["STARRED"]`
   * etc.
5. Convert size format
6. Handle OR syntax in properties (may need multiple API filters)

**Challenges**:

* Must query API to resolve label names to IDs
* OR syntax in single XML property requires splitting into multiple filters
* Label hierarchy in XML may not match API label structure
* Must handle non-existent labels (create or error)

---

## Use Case Comparison

| Use Case | Recommended Format | Rationale |
|----------|-------------------|-----------|
| **Programmatic Management** | API JSON | Full programmatic control, no manual steps |
| **Bulk Import/Export** | WebUI XML | Simple export/import through UI |
| **Version Control** | WebUI XML | Human-readable, diff-friendly |
| **Automation** | API JSON | No manual UI interaction required |
| **Sharing Filters** | WebUI XML | Easy to share file, no API credentials needed |
| **Filter Composition** | API JSON | Precise control over criteria and actions |
| **Manual Editing** | WebUI XML | Text editor friendly |
| **Multi-Account Sync** | API JSON | Programmatic label resolution |

---

## Recommendation for gogcli

**For filter export/backup**:

1. **Retrieve via API** - Use `users.settings.filters.list` for structured data
2. **Store as JSON** - Keep API format for programmatic processing
3. **Optional XML export** - Convert to XML for WebUI compatibility if requested

**For filter import**:

1. **Accept both formats** - Detect format by file content
2. **Convert to API format** - Normalize to JSON internally
3. **Resolve labels** - Use `users.labels.list` for ID ↔ name mapping
4. **Create via API** - Use `users.settings.filters.create`

**Conversion library considerations**:

* Build bidirectional converter (JSON ↔ XML)
* Handle label resolution via caching
* Support label auto-creation for import
* Validate converted filters before creation
* Provide dry-run mode for conversion testing

---

## Metadata

```yaml
source_urls:
  - "https://developers.google.com/gmail/api/reference/rest/v1/users.settings.filters"
  - "https://developers.google.com/workspace/gmail/api/guides/filter_settings"
  - "https://developers.google.com/workspace/gmail/api/guides/migrate-from-email-settings"
download_timestamp: "2026-02-03T00:00:00Z"
document_title: "Gmail Filter Format Comparison"
key_concepts:
  - "JSON vs XML format"
  - "label ID vs label name"
  - "action semantics differences"
  - "query field naming"
  - "conversion strategies"
related_docs:
  - "filters-api-reference.md"
  - "filters-xml-export-format.md"
  - "../labels/labels-reference.md"
```
