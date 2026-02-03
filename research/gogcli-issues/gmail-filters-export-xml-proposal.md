# Feature Proposal: Gmail Filter Export in WebUI-Compatible XML Format

**Target Repository:** https://github.com/steipete/gogcli
**GitHub Issue:** https://github.com/steipete/gogcli/issues/174 ✅
**Related Documentation:** `docs/web/gmail/filters/`

## Summary

Add ability to export Gmail filters in the Atom XML format that Gmail WebUI can import, enabling users to:

1. Share filter configurations between Gmail accounts
2. Distribute standardized filter sets within teams
3. Backup filters in a format that can be restored via Gmail Settings UI
4. Create reusable filter templates for common workflows

## Current State

gogcli currently supports:

```bash
gog gmail filters list          # JSON or table output (API format)
gog gmail filters get <id>      # Single filter details
gog gmail filters create        # Create new filter
gog gmail filters delete <id>   # Delete filter
```

**Problem:** The `--json` output uses Gmail API's JSON format, which is **incompatible** with Gmail's WebUI import feature.

## Proposed Commands

### Option A: New `export` subcommand

```bash
# Export all filters to WebUI-compatible XML
gog gmail filters export > mailFilters.xml

# Export specific filters by ID
gog gmail filters export --id=ABC123 --id=DEF456 > selected.xml

# Export filters matching criteria
gog gmail filters export --from="*@github.com" > github-filters.xml
gog gmail filters export --label="Work/*" > work-filters.xml
```

### Option B: Format flag on existing `list` command

```bash
# Current behavior (default)
gog gmail filters list --json

# New: WebUI-compatible XML
gog gmail filters list --format=xml > mailFilters.xml
gog gmail filters list --format=webui > mailFilters.xml
```

**Recommendation:** Option A (`export` subcommand) is clearer for users and allows filter selection options.

## Technical Implementation

### XML Format Specification

Gmail uses Atom Syndication Format (RFC 4287) with Google Apps namespace:

```xml
<?xml version='1.0' encoding='UTF-8'?>
<feed xmlns='http://www.w3.org/2005/Atom'
      xmlns:apps='http://schemas.google.com/apps/2006'>
  <title>Mail Filters</title>
  <author>
    <name>User Name</name>
    <email>user@gmail.com</email>
  </author>
  <updated>2026-02-03T12:00:00Z</updated>

  <entry>
    <category term='filter'/>
    <title>Mail Filter</title>
    <id>tag:mail.google.com,2008:filter:1234567890</id>
    <updated>2026-02-03T12:00:00Z</updated>
    <content/>
    <apps:property name='from' value='notifications@github.com'/>
    <apps:property name='hasTheWord' value='&quot;was assigned to you&quot;'/>
    <apps:property name='label' value='GitHub/Assigned'/>
    <apps:property name='shouldArchive' value='true'/>
    <apps:property name='shouldMarkAsRead' value='true'/>
  </entry>
</feed>
```

### API to XML Field Mapping

| API JSON Field | XML Property | Notes |
|----------------|--------------|-------|
| `criteria.from` | `from` | Direct mapping |
| `criteria.to` | `to` | Direct mapping |
| `criteria.subject` | `subject` | Direct mapping |
| `criteria.query` | `hasTheWord` | Direct mapping |
| `criteria.negatedQuery` | `doesNotHaveTheWord` | Direct mapping |
| `criteria.hasAttachment` | `hasAttachment` | Boolean string |
| `criteria.excludeChats` | `excludeChats` | Boolean string |
| `criteria.size` + `sizeComparison` | `size` + `sizeOperator` + `sizeUnit` | Requires conversion |
| `action.addLabelIds` | `label` / `shouldStar` / `shouldAlwaysMarkAsImportant` | **Requires label name resolution** |
| `action.removeLabelIds` containing `INBOX` | `shouldArchive='true'` | Semantic conversion |
| `action.removeLabelIds` containing `UNREAD` | `shouldMarkAsRead='true'` | Semantic conversion |
| `action.forward` | `forwardTo` | Direct mapping |

### Critical Implementation Details

1. **Label ID → Name Resolution**
   - API returns label IDs (e.g., `Label_123`)
   - XML requires label names (e.g., `Work/Projects`)
   - Must call `users.labels.list` to build ID→name map
   - Handle system labels: `STARRED` → `shouldStar`, `IMPORTANT` → `shouldAlwaysMarkAsImportant`

2. **Size Filter Conversion**
   - API: `size: 5000000, sizeComparison: "larger"`
   - XML: `size='5', sizeOperator='s_sl', sizeUnit='s_smb'`
   - sizeOperator: `s_sl` (larger), `s_ss` (smaller)
   - sizeUnit: `s_sb` (bytes), `s_skb` (KB), `s_smb` (MB)

3. **XML Escaping**
   - Quotes in values: `"urgent"` → `&quot;urgent&quot;`
   - Ampersands: `A & B` → `A &amp; B`
   - Less/greater than: `<` → `&lt;`, `>` → `&gt;`

### Go Implementation Sketch

```go
type AtomFeed struct {
    XMLName xml.Name `xml:"feed"`
    Xmlns   string   `xml:"xmlns,attr"`
    Apps    string   `xml:"xmlns:apps,attr"`
    Title   string   `xml:"title"`
    Author  Author   `xml:"author"`
    Updated string   `xml:"updated"`
    Entries []Entry  `xml:"entry"`
}

type Entry struct {
    Category Category   `xml:"category"`
    Title    string     `xml:"title"`
    ID       string     `xml:"id"`
    Updated  string     `xml:"updated"`
    Content  string     `xml:"content"`
    Props    []Property `xml:"http://schemas.google.com/apps/2006 property"`
}

type Property struct {
    XMLName xml.Name `xml:"http://schemas.google.com/apps/2006 property"`
    Name    string   `xml:"name,attr"`
    Value   string   `xml:"value,attr"`
}

func (c *GmailFiltersExportCmd) Run(ctx context.Context, flags *RootFlags) error {
    // 1. Fetch filters via API
    filters, err := svc.Users.Settings.Filters.List("me").Do()

    // 2. Fetch labels for ID→name mapping
    labels, err := svc.Users.Labels.List("me").Do()
    labelMap := buildLabelMap(labels.Labels)

    // 3. Convert each filter to XML entry
    entries := make([]Entry, 0, len(filters.Filter))
    for _, f := range filters.Filter {
        entry := convertFilterToEntry(f, labelMap)
        entries = append(entries, entry)
    }

    // 4. Output XML
    feed := AtomFeed{
        Xmlns:   "http://www.w3.org/2005/Atom",
        Apps:    "http://schemas.google.com/apps/2006",
        Title:   "Mail Filters",
        Updated: time.Now().UTC().Format(time.RFC3339),
        Entries: entries,
    }

    return xml.NewEncoder(os.Stdout).Encode(feed)
}
```

## Use Cases

### 1. Team Filter Sharing

```bash
# Team lead exports curated filters for system notifications
gog gmail filters export --label="System/*" > team-system-filters.xml

# Team members import via Gmail Settings → Filters → Import filters
# Or via company wiki/shared drive
```

### 2. Account Migration

```bash
# Export from old account
gog gmail filters export --account old@gmail.com > all-filters.xml

# Import to new account via Gmail WebUI
# (API-based import would require separate feature)
```

### 3. Filter Templates

```bash
# Create template filters in a "template" account
gog gmail filters export > newsletter-management.xml
gog gmail filters export > github-workflow.xml
gog gmail filters export > sales-leads.xml

# Share templates with organization
```

### 4. Backup & Version Control

```bash
# Regular backup of filter configuration
gog gmail filters export > filters-$(date +%Y%m%d).xml
git add filters-*.xml && git commit -m "Filter backup"
```

## References

### Official Documentation

- [Gmail Help: Create rules to filter emails](https://support.google.com/mail/answer/6579) - Import/Export section
- [Gmail API: Managing Filters](https://developers.google.com/workspace/gmail/api/guides/filter_settings)
- [Gmail API: users.settings.filters](https://developers.google.com/gmail/api/reference/rest/v1/users.settings.filters)

### XML Format References

- [Atom Syndication Format (RFC 4287)](https://www.ietf.org/rfc/rfc4287.txt)
- [Google Apps XML namespace](http://schemas.google.com/apps/2006)

### Related Tools

- [gmailctl](https://github.com/mbrt/gmailctl) - Jsonnet-based filter management with XML export
- [gmail-yaml-filters](https://github.com/mesozoic/gmail-yaml-filters) - YAML → API sync
- [Gefilte Fish](https://github.com/nedbat/gefilte) - Python DSL for filter generation

### Local Documentation

- `docs/web/gmail/filters/filter-xml-format-specification.md` - Complete XML schema
- `docs/web/gmail/filters/filters-api-vs-xml.md` - Format comparison
- `docs/web/gmail/filters/INDEX.md` - Documentation index

## Acceptance Criteria

- [ ] `gog gmail filters export` outputs valid Atom XML
- [ ] Exported XML can be imported via Gmail Settings → Import filters
- [ ] Label names correctly resolved from IDs
- [ ] System labels (`STARRED`, `IMPORTANT`) converted to XML properties
- [ ] Size filters correctly converted
- [ ] Special characters properly escaped
- [ ] `--id` flag allows selecting specific filters
- [ ] `--label` flag allows filtering by applied label
- [ ] Documentation added to README
- [ ] Tests cover edge cases (empty filters, complex criteria)

## Priority

**Medium-High** - Enables powerful team collaboration and account management workflows that are currently only possible via WebUI manual export.

---

*Research conducted: 2026-02-03*
*Documentation archived in: gogcli-api-datamodel repository*
