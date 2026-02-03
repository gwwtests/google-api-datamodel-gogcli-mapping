# Gmail Filter XML Export Format

**Sources**:

* [Gmail Filter Tips - Draconian Overlord](https://www.draconianoverlord.com/2017/02/04/gmail-filter-tips.html)
* [GitHub - dimagi/gmail-filters](https://github.com/dimagi/gmail-filters/blob/master/gmailfilterxml/tests/many-filters.xml)
* [GitHub - clouserw/gmailfilters](https://github.com/clouserw/gmailfilters/blob/master/mailFilters.xml)
* [Official Gmail Blog - Filter import/export](https://gmail.googleblog.com/2009/03/new-in-labs-filter-importexport.html)

**Downloaded**: 2026-02-03

---

## Overview

Gmail's WebUI allows exporting and importing filters as **XML files** using the **Atom feed format**. This format differs significantly from the JSON format used by the Gmail API.

**Access**: Gmail Settings → Filters and Blocked Addresses → Export/Import

**File Format**: Atom feed XML with Google Apps namespace extensions

---

## XML Structure

### Root Element

```xml
<?xml version='1.0' encoding='UTF-8'?>
<feed xmlns='http://www.w3.org/2005/Atom'
      xmlns:apps='http://schemas.google.com/apps/2006'>
```

**Namespaces**:

* `atom`: `http://www.w3.org/2005/Atom` - Standard Atom syndication format
* `apps`: `http://schemas.google.com/apps/2006` - Google Apps extensions

### Feed Metadata

```xml
<feed>
  <title>Mail Filters</title>
  <id>tag:mail.google.com,2008:filters:1234567890,0987654321</id>
  <updated>2026-02-03T12:00:00Z</updated>
  <author>
    <name>User Name</name>
    <email>user@example.com</email>
  </author>

  <!-- Filter entries follow -->
</feed>
```

| Element | Description |
|---------|-------------|
| `<title>` | Container title (typically "Mail Filters") |
| `<id>` | Unique identifier with comma-separated filter IDs |
| `<updated>` | ISO 8601 timestamp of last modification |
| `<author>` | Account owner information |

### Filter Entry Structure

Each filter is represented as an `<entry>` element:

```xml
<entry>
  <category term='filter'/>
  <title>Mail Filter</title>
  <id>tag:mail.google.com,2008:filter:1234567890</id>
  <updated>2026-02-03T12:00:00Z</updated>
  <content/>

  <!-- Matching criteria -->
  <apps:property name='from' value='sender@example.com'/>
  <apps:property name='subject' value='Important'/>
  <apps:property name='hasTheWord' value='urgent OR critical'/>

  <!-- Actions -->
  <apps:property name='label' value='Work/Urgent'/>
  <apps:property name='shouldArchive' value='true'/>
  <apps:property name='shouldMarkAsRead' value='true'/>
</entry>
```

**Entry Elements**:

| Element | Description |
|---------|-------------|
| `<category term='filter'/>` | Designates entry as a filter |
| `<title>` | Always "Mail Filter" |
| `<id>` | Unique filter identifier |
| `<updated>` | ISO 8601 timestamp |
| `<content/>` | Empty element (required by Atom spec) |

---

## Property Reference

Filters use `<apps:property>` elements with `name` and `value` attributes.

### Matching Criteria Properties

#### Basic Matching

| Property Name | Description | Example Value |
|---------------|-------------|---------------|
| `from` | Sender email address(es) | `sender@example.com` |
| `to` | Recipient address | `recipient@example.com` |
| `subject` | Subject line pattern | `Important Message` |
| `hasTheWord` | Content search (supports operators) | `urgent OR critical` |
| `doesNotHaveTheWord` | Negated content search | `spam OR junk` |

#### Advanced Matching

| Property Name | Description | Example Value |
|---------------|-------------|---------------|
| `hasAttachment` | Has attachments | `true` |
| `sizeOperator` | Size comparison | `s_sl` (smaller), `s_ss` (larger) |
| `sizeUnit` | Size unit with value | `s_smb` (MB), `s_skb` (KB) |

### Action Properties

| Property Name | Description | Example Value |
|---------------|-------------|---------------|
| `label` | Apply label | `Work/Project` |
| `shouldArchive` | Skip inbox (archive) | `true` |
| `shouldMarkAsRead` | Mark as read | `true` |
| `shouldStar` | Star message | `true` |
| `shouldTrash` | Move to trash | `true` |
| `shouldNeverSpam` | Never send to spam | `true` |
| `shouldAlwaysMarkAsImportant` | Always mark important | `true` |
| `shouldNeverMarkAsImportant` | Never mark important | `true` |
| `forwardTo` | Forward to address | `other@example.com` |

---

## Search Syntax in hasTheWord

The `hasTheWord` property supports **Gmail search operators**:

### Boolean Operators

```xml
<apps:property name='hasTheWord' value='urgent OR critical'/>
<apps:property name='hasTheWord' value='meeting -cancelled'/>
```

* `OR` - Logical OR (must be uppercase)
* `-` - Negation prefix
* Implicit AND between terms

### Quoted Phrases

```xml
<apps:property name='hasTheWord' value='"action required"'/>
```

### Label References

```xml
<apps:property name='hasTheWord' value='label:inbox has:attachment'/>
```

### Complex Queries

```xml
<apps:property name='hasTheWord'
               value='from:github.com (type:issue OR type:pr) -label:archived'/>
```

---

## Complete Example

```xml
<?xml version='1.0' encoding='UTF-8'?>
<feed xmlns='http://www.w3.org/2005/Atom'
      xmlns:apps='http://schemas.google.com/apps/2006'>
  <title>Mail Filters</title>
  <id>tag:mail.google.com,2008:filters:1708627200</id>
  <updated>2026-02-03T12:00:00Z</updated>
  <author>
    <name>John Doe</name>
    <email>john.doe@example.com</email>
  </author>

  <!-- Filter 1: GitHub notifications -->
  <entry>
    <category term='filter'/>
    <title>Mail Filter</title>
    <id>tag:mail.google.com,2008:filter:1708627201</id>
    <updated>2026-02-03T12:00:00Z</updated>
    <content/>
    <apps:property name='from' value='notifications@github.com'/>
    <apps:property name='hasTheWord' value='type:pr OR type:issue'/>
    <apps:property name='label' value='GitHub'/>
    <apps:property name='shouldArchive' value='true'/>
  </entry>

  <!-- Filter 2: Newsletter management -->
  <entry>
    <category term='filter'/>
    <title>Mail Filter</title>
    <id>tag:mail.google.com,2008:filter:1708627202</id>
    <updated>2026-02-03T12:00:00Z</updated>
    <content/>
    <apps:property name='subject' value='Newsletter'/>
    <apps:property name='hasTheWord' value='unsubscribe'/>
    <apps:property name='label' value='Newsletters'/>
    <apps:property name='shouldMarkAsRead' value='true'/>
  </entry>

  <!-- Filter 3: Important work emails -->
  <entry>
    <category term='filter'/>
    <title>Mail Filter</title>
    <id>tag:mail.google.com,2008:filter:1708627203</id>
    <updated>2026-02-03T12:00:00Z</updated>
    <content/>
    <apps:property name='from' value='boss@company.com'/>
    <apps:property name='hasTheWord' value='urgent OR important'/>
    <apps:property name='shouldAlwaysMarkAsImportant' value='true'/>
    <apps:property name='shouldStar' value='true'/>
  </entry>
</feed>
```

---

## Key Differences from API JSON

See: [Gmail Filter Format Comparison](filters-api-vs-xml.md)

1. **Format**: XML (Atom) vs JSON
2. **Property names**: `hasTheWord` (XML) vs `query` (JSON)
3. **Actions**: Different naming (`shouldArchive` vs `removeLabelIds: ["INBOX"]`)
4. **Label reference**: Label name (XML) vs Label ID (JSON)
5. **Multiple values**: OR syntax in single property (XML) vs multiple fields (JSON)

---

## Usage Notes

### Editing XML Filters

* **Manual editing**: XML can be edited in text editor before import
* **Version control**: XML format enables filter versioning with git
* **Sharing**: Easy to share filter configurations across accounts
* **Bulk operations**: Create many similar filters by duplicating entries

### Import Behavior

* **Duplicates**: Importing same filter again creates duplicate (no merge)
* **Label auto-creation**: Non-existent labels are created automatically
* **Forward addresses**: Must be verified before import (otherwise ignored)
* **Validation**: Invalid XML or syntax errors cause import failure

### Best Practices

1. **Backup before editing**: Export current filters before making changes
2. **Test with small batches**: Import a few filters first to verify syntax
3. **Use meaningful IDs**: Keep `<id>` values unique when creating new filters
4. **Update timestamps**: Modify `<updated>` fields when editing
5. **Validate XML**: Use XML validator before importing

---

## Metadata

```yaml
source_urls:
  - "https://www.draconianoverlord.com/2017/02/04/gmail-filter-tips.html"
  - "https://github.com/dimagi/gmail-filters"
  - "https://github.com/clouserw/gmailfilters"
  - "https://gmail.googleblog.com/2009/03/new-in-labs-filter-importexport.html"
download_timestamp: "2026-02-03T00:00:00Z"
document_title: "Gmail Filter XML Export Format"
key_concepts:
  - "Atom feed format"
  - "apps:property elements"
  - "hasTheWord vs query"
  - "label names vs IDs"
  - "XML editing workflow"
related_docs:
  - "filters-api-reference.md"
  - "filters-api-vs-xml.md"
```
