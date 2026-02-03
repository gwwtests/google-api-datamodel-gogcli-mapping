# Gmail Filter Export/Import XML Format Specification

**Research Date:** 2026-02-03
**Primary Official Source:** [Gmail API - Managing Filters](https://developers.google.com/workspace/gmail/api/guides/filter_settings)
**User Support Source:** [Gmail Help - Create Rules to Filter Emails](https://support.google.com/mail/answer/6579)

## Executive Summary

Gmail filters can be exported and imported using an **Atom feed-based XML format** with Google Apps namespace extensions. The format uses `<apps:property>` elements to encode filter criteria and actions. **No official XML schema specification document exists** - the format is reverse-engineered from Gmail's export functionality and documented through community tools.

## 1. File Format Overview

**Format:** XML (Atom Feed + Google Apps namespace)
**File Extension:** `.xml` (commonly named `mailFilters.xml`)
**Character Encoding:** UTF-8
**MIME Type:** `application/xml` or `text/xml`

## 2. XML Document Structure

### 2.1 Root Element and Namespaces

```xml
<?xml version='1.0' encoding='UTF-8'?>
<feed xmlns='http://www.w3.org/2005/Atom'
      xmlns:apps='http://schemas.google.com/apps/2006'>
```

**Namespaces:**
- `xmlns` (default): `http://www.w3.org/2005/Atom` - Atom Syndication Format
- `xmlns:apps`: `http://schemas.google.com/apps/2006` - Google Apps proprietary extensions

### 2.2 Feed Metadata (Optional)

```xml
<title>Mail Filters</title>
<id>tag:mail.google.com,2008:filter:1234567890,9876543210</id>
<updated>2026-02-03T12:00:00Z</updated>
<author>
  <name>User Name</name>
  <email>user@example.com</email>
</author>
```

Elements:
- `<title>`: Human-readable title (typically "Mail Filters")
- `<id>`: Unique identifier (concatenated filter IDs)
- `<updated>`: ISO 8601 timestamp of last modification
- `<author>`: Creator information (name and email)

### 2.3 Filter Entry Structure

Each filter is represented as an `<entry>` element:

```xml
<entry>
  <category term='filter'/>
  <title>Mail Filter</title>
  <id>tag:mail.google.com,2008:filter:1234567890</id>
  <updated>2026-02-03T12:00:00Z</updated>
  <content/>
  <apps:property name='from' value='sender@example.com'/>
  <apps:property name='label' value='Important'/>
  <apps:property name='shouldArchive' value='true'/>
</entry>
```

**Required Elements:**
- `<category term='filter'/>` - Identifies entry as a filter
- `<title>` - Typically "Mail Filter"
- `<id>` - Unique filter ID (format: `tag:mail.google.com,2008:filter:[NUMERIC_ID]`)
- `<updated>` - ISO 8601 timestamp
- `<content/>` - Empty element (required but unused)

**Property Elements:**
- `<apps:property>` - Each criterion or action is one property element
  - Attribute `name`: Property identifier (see §3 and §4)
  - Attribute `value`: Property value (string, boolean as 'true'/'false', or enum)

## 3. Filter Criteria Properties

Criteria define **matching conditions**. If multiple criteria are present, **ALL must be satisfied** (logical AND).

### 3.1 Basic Criteria

| Property Name | Type | Description | Example Value |
|---------------|------|-------------|---------------|
| `from` | String | Sender email address or pattern | `sender@example.com` |
| `to` | String | Recipient email address or pattern | `recipient@example.com` |
| `subject` | String | Subject line substring | `[URGENT]` |
| `hasTheWord` | String | Search query (Gmail search syntax) | `"assigned to you" AND important` |
| `doesNotHaveTheWord` | String | Exclusion query (Gmail search syntax) | `spam OR unsubscribe` |

**Search Syntax:** The `hasTheWord` and `doesNotHaveTheWord` properties accept full [Gmail advanced search operators](https://support.google.com/mail/answer/7190?hl=en):
- Quoted phrases: `"exact phrase"`
- Logical operators: `AND`, `OR`
- Wildcards: `project*`
- Label matching: `label:^smartlabel_group`

### 3.2 Attachment and Chat Criteria

| Property Name | Type | Valid Values | Description |
|---------------|------|--------------|-------------|
| `hasAttachment` | Boolean | `true`, `false` | Filter emails with attachments |
| `excludeChats` | Boolean | `true`, `false` | Exclude Google Chat messages |

### 3.3 Size Criteria

Size filtering requires **three properties** working together:

| Property Name | Type | Valid Values | Description |
|---------------|------|--------------|-------------|
| `size` | Integer | Numeric value | Message size threshold |
| `sizeOperator` | Enum | `s_sl` (greater), `s_ss` (smaller) | Comparison operator |
| `sizeUnit` | Enum | `s_sb` (bytes), `s_skb` (KB), `s_smb` (MB) | Size unit |

**Example:** Messages larger than 5MB:
```xml
<apps:property name='size' value='5'/>
<apps:property name='sizeOperator' value='s_sl'/>
<apps:property name='sizeUnit' value='s_smb'/>
```

## 4. Filter Action Properties

Actions define **operations applied** to matching messages.

### 4.1 Label Operations

| Property Name | Type | Description | Example Value |
|---------------|------|-------------|---------------|
| `label` | String | Apply user-defined label | `Work/Important` |

**Notes:**
- Multiple `label` properties can be used in one filter to apply multiple labels
- Nested labels use forward slash: `ParentLabel/ChildLabel`
- System labels use caret prefix: `^smartlabel_*` (see §4.6)

### 4.2 Read/Archive Actions

| Property Name | Type | Valid Values | Description |
|---------------|------|--------------|-------------|
| `shouldMarkAsRead` | Boolean | `true`, `false` | Mark message as read |
| `shouldArchive` | Boolean | `true`, `false` | Skip inbox (archive) |

### 4.3 Importance and Starring

| Property Name | Type | Valid Values | Description |
|---------------|------|--------------|-------------|
| `shouldStar` | Boolean | `true`, `false` | Star the message |
| `shouldAlwaysMarkAsImportant` | Boolean | `true`, `false` | Always mark as important |
| `shouldNeverMarkAsImportant` | Boolean | `true`, `false` | Never mark as important |

**Mutual Exclusivity:** Only one importance property should be used per filter.

### 4.4 Spam and Trash Operations

| Property Name | Type | Valid Values | Description |
|---------------|------|--------------|-------------|
| `shouldNeverSpam` | Boolean | `true`, `false` | Never send to spam |
| `shouldTrash` | Boolean | `true`, `false` | Delete (send to trash) |

### 4.5 Forwarding

| Property Name | Type | Description | Example Value |
|---------------|------|-------------|---------------|
| `forwardTo` | String | Forward to verified email address | `forward@example.com` |

**Important:** Gmail only accepts forwarding addresses that have been verified in Settings. Typo note: Some documentation shows `forwrdTo` (missing 'a') - this is incorrect.

### 4.6 Smart Label Categorization

| Property Name | Type | Valid Values | Description |
|---------------|------|--------------|-------------|
| `smartLabelToApply` | Enum | See table below | Assign to Gmail category tab |

**Smart Label Values:**

| Category | Value |
|----------|-------|
| Primary (Personal) | `^smartlabel_personal` |
| Social | `^smartlabel_social` |
| Promotions | `^smartlabel_promo` |
| Updates (Notifications) | `^smartlabel_notification` |
| Forums (Groups) | `^smartlabel_group` |
| Newsletter | `^smartlabel_newsletter` |

**Note:** Smart labels can also be used in criteria via `hasTheWord='label:^smartlabel_*'` to create filters based on Gmail's automatic categorization.

## 5. Complete Property Reference Table

### 5.1 Criteria Properties

| Property | Type | Values/Format | Description |
|----------|------|---------------|-------------|
| `from` | String | Email pattern | Sender address |
| `to` | String | Email pattern | Recipient address |
| `subject` | String | Text pattern | Subject line content |
| `hasTheWord` | String | Search query | Content must match (Gmail search syntax) |
| `doesNotHaveTheWord` | String | Search query | Content must NOT match |
| `hasAttachment` | Boolean | `true`/`false` | Has file attachments |
| `excludeChats` | Boolean | `true`/`false` | Exclude Google Chat |
| `size` | Integer | Numeric | Size threshold value |
| `sizeOperator` | Enum | `s_sl`, `s_ss` | Greater/smaller comparison |
| `sizeUnit` | Enum | `s_sb`, `s_skb`, `s_smb` | Bytes, KB, MB |

### 5.2 Action Properties

| Property | Type | Values/Format | Description |
|----------|------|---------------|-------------|
| `label` | String | Label name | Apply label |
| `shouldArchive` | Boolean | `true`/`false` | Skip inbox |
| `shouldMarkAsRead` | Boolean | `true`/`false` | Mark as read |
| `shouldStar` | Boolean | `true`/`false` | Star message |
| `shouldTrash` | Boolean | `true`/`false` | Delete (trash) |
| `forwardTo` | String | Email address | Forward to address |
| `shouldNeverSpam` | Boolean | `true`/`false` | Never send to spam |
| `shouldAlwaysMarkAsImportant` | Boolean | `true`/`false` | Always important |
| `shouldNeverMarkAsImportant` | Boolean | `true`/`false` | Never important |
| `smartLabelToApply` | Enum | `^smartlabel_*` | Assign to category |

## 6. Complete Example

```xml
<?xml version='1.0' encoding='UTF-8'?>
<feed xmlns='http://www.w3.org/2005/Atom'
      xmlns:apps='http://schemas.google.com/apps/2006'>
  <title>Mail Filters</title>
  <id>tag:mail.google.com,2008:filter:1234567890</id>
  <updated>2026-02-03T12:00:00Z</updated>

  <!-- Filter 1: Label and archive GitHub notifications -->
  <entry>
    <category term='filter'/>
    <title>Mail Filter</title>
    <id>tag:mail.google.com,2008:filter:1234567890</id>
    <updated>2026-02-03T12:00:00Z</updated>
    <content/>
    <apps:property name='from' value='notifications@github.com'/>
    <apps:property name='hasTheWord' value='"was assigned to you"'/>
    <apps:property name='label' value='GitHub/Assigned'/>
    <apps:property name='shouldArchive' value='true'/>
  </entry>

  <!-- Filter 2: Star urgent emails from boss -->
  <entry>
    <category term='filter'/>
    <title>Mail Filter</title>
    <id>tag:mail.google.com,2008:filter:1234567891</id>
    <updated>2026-02-03T12:00:00Z</updated>
    <content/>
    <apps:property name='from' value='boss@company.com'/>
    <apps:property name='subject' value='URGENT'/>
    <apps:property name='shouldStar' value='true'/>
    <apps:property name='shouldAlwaysMarkAsImportant' value='true'/>
  </entry>

  <!-- Filter 3: Delete large promotional emails -->
  <entry>
    <category term='filter'/>
    <title>Mail Filter</title>
    <id>tag:mail.google.com,2008:filter:1234567892</id>
    <updated>2026-02-03T12:00:00Z</updated>
    <content/>
    <apps:property name='hasTheWord' value='label:^smartlabel_promo'/>
    <apps:property name='size' value='5'/>
    <apps:property name='sizeOperator' value='s_sl'/>
    <apps:property name='sizeUnit' value='s_smb'/>
    <apps:property name='shouldTrash' value='true'/>
  </entry>

</feed>
```

## 7. Import/Export Workflow

### 7.1 Export Filters

**Gmail Web UI:**
1. Settings → See all settings → Filters and Blocked Addresses
2. Select filters to export (checkboxes)
3. Click "Export"
4. Downloads `mailFilters.xml`

**Result:** XML file containing selected filters with unique IDs and timestamps.

### 7.2 Import Filters

**Gmail Web UI:**
1. Settings → See all settings → Filters and Blocked Addresses
2. Click "Import filters"
3. Choose XML file
4. Select filters to import
5. Click "Create filters"

**Behavior:**
- Imported filters are **duplicated** (new IDs assigned)
- Existing filters are **not overwritten**
- Filter IDs from export are ignored on import
- Timestamps are updated to import time

### 7.3 Programmatic Access

**Not Available:** Gmail API does **not** support XML import/export. The XML format is only accessible through the web UI.

**Alternative:** Use [Gmail API Filter methods](https://developers.google.com/workspace/gmail/api/guides/filter_settings):
- `users.settings.filters.create()`
- `users.settings.filters.list()`
- `users.settings.filters.get()`
- `users.settings.filters.delete()`

## 8. API vs XML Mapping

### 8.1 Structural Differences

| Concept | XML Format | Gmail API (JSON) |
|---------|------------|------------------|
| Filter ID | `<id>tag:mail.google.com,2008:filter:123</id>` | `"id": "ANe1Bmg..."` (opaque string) |
| Criteria | `<apps:property name='from' value='x'/>` | `"criteria": {"from": "x"}` |
| Actions | `<apps:property name='label' value='y'/>` | `"action": {"addLabelIds": ["Label_1"]}` |
| Labels | Label name string | Label ID string |

### 8.2 Property Mapping

#### Criteria Mapping

| XML Property | API Field | Notes |
|--------------|-----------|-------|
| `from` | `criteria.from` | Direct mapping |
| `to` | `criteria.to` | Direct mapping |
| `subject` | `criteria.subject` | Direct mapping |
| `hasTheWord` | `criteria.query` | Search syntax identical |
| `doesNotHaveTheWord` | `criteria.negatedQuery` | Exclusion query |
| `hasAttachment` | `criteria.hasAttachment` | Boolean |
| `excludeChats` | `criteria.excludeChats` | Boolean |
| `size` + `sizeOperator` + `sizeUnit` | `criteria.size` + `criteria.sizeComparison` | API uses "larger"/"smaller" strings |

#### Action Mapping

| XML Property | API Field | Notes |
|--------------|-----------|-------|
| `label` | `action.addLabelIds[]` | XML uses label name, API uses label ID |
| `shouldArchive` | `action.removeLabelIds` (INBOX) | Archive = remove INBOX label |
| `shouldMarkAsRead` | `action.removeLabelIds` (UNREAD) | Mark read = remove UNREAD label |
| `shouldTrash` | `action.addLabelIds` (TRASH) | Trash = add TRASH label |
| `shouldStar` | `action.addLabelIds` (STARRED) | Star = add STARRED label |
| `forwardTo` | `action.forward` | Email address |
| `shouldNeverSpam` | `action.removeLabelIds` (SPAM) | Never spam = remove SPAM label |
| `shouldAlwaysMarkAsImportant` | `action.addLabelIds` (IMPORTANT) | Add IMPORTANT label |
| `shouldNeverMarkAsImportant` | `action.removeLabelIds` (IMPORTANT) | Remove IMPORTANT label |
| `smartLabelToApply` | `action.addLabelIds` (CATEGORY_*) | Categories = system labels |

**Critical Difference:** XML uses human-readable **label names**, API uses opaque **label IDs**. To convert, you must query `users.labels.list()` to map names to IDs.

## 9. Limitations and Edge Cases

### 9.1 Known Limitations

1. **No Official Schema:** Google has never published an XSD or formal specification
2. **Web UI Only:** API does not support XML import/export
3. **Label Names vs IDs:** XML uses names (human-readable), API uses IDs (opaque)
4. **Filter ID Ignored:** Import assigns new IDs, exported IDs are not preserved
5. **No Versioning:** No version attribute in XML format
6. **Limited Validation:** Invalid properties are silently ignored on import

### 9.2 Multi-Account Considerations

**Filter IDs are NOT globally unique:**
- Filter IDs are unique **within one Gmail account**
- Same filter exported from two accounts will have **different IDs**
- Filters reference labels by **name**, which may differ between accounts

**Merging filters from multiple accounts:**
1. Export filters from each account separately
2. Merge XML files manually (combine `<entry>` elements)
3. Ensure label names are consistent across accounts
4. Import merged file into target account

### 9.3 Timezone Handling

**Timestamps:** All `<updated>` timestamps are in **ISO 8601 format** with UTC timezone:
```xml
<updated>2026-02-03T12:00:00Z</updated>
```

The 'Z' suffix indicates UTC. No local timezone information is preserved.

## 10. Tools and Libraries

### 10.1 Community Tools

| Tool | Language | URL | Capabilities |
|------|----------|-----|--------------|
| gmail_filter_manager | Python | [rcmdnk/gmail_filter_manager](https://github.com/rcmdnk/gmail_filter_manager) | XML ↔ YAML conversion |
| gmailfilters | Python | [larsks/gmailfilters](https://github.com/larsks/gmailfilters) | XML generation |
| gmail-filters | Python | [dimagi/gmail-filters](https://github.com/dimagi/gmail-filters) | XML generation |
| gmail-filter | Python | [esommer/gmail-filter](https://github.com/esommer/gmail-filter) | XML generation |
| gmail-filter-builder | PHP | [opdavies/gmail-filter-builder](https://github.com/opdavies/gmail-filter-builder) | XML generation |
| gmailctl | Go | [mbrt/gmailctl](https://github.com/mbrt/gmailctl) | Declarative filter config |

### 10.2 Validation

**No official validator exists.** Best practice:
1. Export filters from Gmail
2. Modify exported XML (preserves structure)
3. Import back into Gmail (acts as validator)
4. Delete test filters if needed

## 11. Security Considerations

### 11.1 Sensitive Data

Filter XML files may contain:
- Email addresses (personal, work contacts)
- Label names (project names, client names)
- Search patterns (keywords indicating confidential topics)
- Forwarding addresses

**Recommendation:** Treat filter exports as **confidential data**.

### 11.2 Forwarding Security

- Gmail **requires email verification** for `forwardTo` addresses
- Unverified addresses are **silently ignored** on import
- No error message or warning is shown
- Verify forwarding addresses in Settings → Forwarding and POP/IMAP **before** creating filters

### 11.3 XML Injection

**Not Vulnerable:** Gmail's import parser appears robust against:
- XML entity expansion attacks
- XXE (XML External Entity) attacks
- CDATA injection

However, **never import filter XML files from untrusted sources** as:
- Filters can auto-delete emails (`shouldTrash`)
- Filters can forward emails to third parties (`forwardTo`)
- Malicious filters could leak sensitive information

## 12. Best Practices

### 12.1 Version Control

**Track filter changes:**
1. Export filters regularly
2. Commit to version control (Git)
3. Use descriptive commit messages
4. Review diffs before applying changes

**Example Git workflow:**
```bash
# Export from Gmail UI → save as mailFilters.xml
git add mailFilters.xml
git commit -m "Add filter: Auto-label GitHub PRs assigned to me"
git push
```

### 12.2 Documentation

**Document complex filters:**
```xml
<!-- Filter: Auto-process code review requests
     Criteria: GitHub review request emails
     Action: Label as "Review/Pending", mark important, keep in inbox
     Last updated: 2026-02-03 by user@example.com
-->
<entry>
  <category term='filter'/>
  <title>Mail Filter</title>
  <!-- ... properties ... -->
</entry>
```

**Note:** XML comments are **preserved on export but lost on import**. Keep separate documentation.

### 12.3 Testing

**Test filters safely:**
1. Create test filter with unique criteria (e.g., subject contains `[TEST-FILTER]`)
2. Send test email to yourself
3. Verify actions applied correctly
4. Delete test filter after validation

### 12.4 Maintenance

**Periodic review:**
- Export filters quarterly
- Review for outdated criteria (old email addresses, obsolete projects)
- Consolidate overlapping filters
- Remove unused filters (check via Settings UI - shows "X messages affected")

## 13. Frequently Asked Questions

### Q1: Can I use regular expressions in filter criteria?

**No.** Gmail filters do **not** support true regular expressions. However, Gmail search operators provide some pattern matching:
- Wildcard suffix: `project*` matches "project", "projects", "projecting"
- Quotes for exact phrases: `"code review"`
- Logical operators: `AND`, `OR`

### Q2: How many filters can I have?

**Limit:** Gmail supports up to **1,000 filters per account** (as of 2026).

### Q3: Why do imported filters have different IDs than exported ones?

**By design.** Filter IDs are auto-generated on import. Gmail treats import as "create new filters based on template" rather than "restore exact filters".

### Q4: Can I import filters into multiple accounts at once?

**No.** Gmail UI requires importing into one account at a time. For Google Workspace admins managing multiple users, consider using the Admin SDK Directory API or third-party tools.

### Q5: What happens if a filter references a non-existent label?

**Auto-creation:** Gmail automatically creates the label if it doesn't exist during import.

### Q6: Can I export only some filters?

**Yes.** In Settings → Filters, use checkboxes to select specific filters before clicking "Export".

### Q7: Do filters apply retroactively to existing emails?

**No.** Filters only apply to **incoming emails** received after the filter is created. To apply filters retroactively:
1. Use Gmail search to find matching emails
2. Select all (checkbox at top)
3. Click "More" menu → Choose action (label, archive, etc.)

## 14. Related Documentation

**Official Google Documentation:**
- [Gmail API - Managing Filters](https://developers.google.com/workspace/gmail/api/guides/filter_settings) - API methods
- [Gmail Help - Create Rules to Filter Emails](https://support.google.com/mail/answer/6579) - Web UI guide
- [Gmail Search Operators](https://support.google.com/mail/answer/7190) - Query syntax for `hasTheWord`

**Community Resources:**
- [Edit Gmail Filters with XML - Make Magazine](https://makezine.com/article/technology/edit-gmail-filters-with-xml/) - Walkthrough
- [Gmail Filter Tips - Draconian Overlord](https://www.draconianoverlord.com/2017/02/04/gmail-filter-tips.html/) - Advanced techniques
- [Gmail Filters - Tcl Wiki](https://wiki.tcl-lang.org/page/Gmail+Filters) - Technical reference

**GitHub Examples:**
- [clouserw/gmailfilters](https://github.com/clouserw/gmailfilters/blob/master/mailFilters.xml) - Real-world filter XML
- [dimagi/gmail-filters](https://github.com/dimagi/gmail-filters/blob/master/gmailfilterxml/tests/many-filters.xml) - Comprehensive test cases
- [larsks/gmail-tools](https://github.com/larsks/gmail-tools/blob/master/smartlabels.xml) - Smart label examples

## 15. Revision History

| Date | Version | Changes |
|------|---------|---------|
| 2026-02-03 | 1.0 | Initial comprehensive specification based on web research and community examples |

## 16. Acknowledgments

This specification is based on:
- Reverse-engineering of Gmail's export functionality
- Community-maintained open-source tools
- Empirical testing by developers
- No official Google specification document exists

**Accuracy Note:** While every effort has been made to document the format accurately, **Google may change the format without notice**. Always test imports with non-critical filters first.
