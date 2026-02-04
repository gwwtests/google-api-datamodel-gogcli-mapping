# Feature Proposal: Gmail Filter Export in WebUI-Compatible XML Format

**Target Repository:** https://github.com/steipete/gogcli
**GitHub Issue:** https://github.com/steipete/gogcli/issues/174 ✅
**Related Documentation:** `docs/web/gmail/filters/`
**Last Updated:** 2026-02-03 (verified with real sources)

## Verified Sources

### Real Gmail Filter XML Exports (Primary Evidence)

| Source | Date | Filters | URL |
|--------|------|---------|-----|
| clouserw/gmailfilters | 2009-12-09 | 7 | https://github.com/clouserw/gmailfilters/blob/master/mailFilters.xml |
| dimagi/gmail-filters | 2014-09-19 | 64 | https://github.com/dimagi/gmail-filters/blob/master/gmailfilterxml/tests/many-filters.xml |
| dims (K8s maintainer) | 2022-06-25 | 17 | https://gist.github.com/dims/c3f45c3158e883600f988d7a767fe16b |

### Working Implementation Reference

**gmailctl** (Go) - https://github.com/mbrt/gmailctl
- Command: `gmailctl export` converts Jsonnet config → Gmail XML
- XML export code: `internal/engine/export/xml/marshal.go`
- Property constants: `internal/engine/export/xml/consts.go`

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

### XML Format Specification (Verified from Real Exports)

Gmail uses Atom Syndication Format (RFC 4287) with Google Apps namespace.

**Real example from clouserw/gmailfilters (2009):**

```xml
<?xml version='1.0' encoding='UTF-8'?>
<feed xmlns='http://www.w3.org/2005/Atom' xmlns:apps='http://schemas.google.com/apps/2006'>
    <title>Mail Filters</title>
    <id>tag:mail.google.com,2008:filters:1206327421108,1228202452022</id>
    <updated>2009-12-09T20:44:01Z</updated>
    <author>
        <name>Wil Clouser</name>
        <email>clouserw@gmail.com</email>
    </author>
    <entry>
        <category term='filter'></category>
        <title>Mail Filter</title>
        <id>tag:mail.google.com,2008:filter:1206327421108</id>
        <updated>2009-12-09T20:44:01Z</updated>
        <content></content>
        <apps:property name='from' value='bugzilla-daemon@mozilla.org'/>
        <apps:property name='to' value='clouserw@gmail.com'/>
        <apps:property name='hasTheWord' value='blocker'/>
        <apps:property name='label' value='blocker'/>
    </entry>
</feed>
```

**Real example from dims' Kubernetes filters (2022) showing size properties:**

```xml
<entry>
    <category term='filter'></category>
    <title>Mail Filter</title>
    <id>tag:mail.google.com,2008:filter:1463531420708</id>
    <updated>2022-06-25T21:39:52Z</updated>
    <content></content>
    <apps:property name='hasTheWord' value='list:"kubernetes-dev@googlegroups.com"'/>
    <apps:property name='label' value='kubernetes'/>
    <apps:property name='shouldArchive' value='true'/>
    <apps:property name='sizeOperator' value='s_sl'/>
    <apps:property name='sizeUnit' value='s_smb'/>
</entry>
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

### Related Tools (Verified)

- [gmailctl](https://github.com/mbrt/gmailctl) - **Has working XML export**: `gmailctl export` command
  - Source: [`internal/engine/export/xml/marshal.go`](https://github.com/mbrt/gmailctl/blob/main/internal/engine/export/xml/marshal.go)
  - Uses Jsonnet config as input, outputs Gmail-compatible XML
- [gmail-yaml-filters](https://github.com/mesozoic/gmail-yaml-filters) - YAML → API sync
- [dimagi/gmail-filters](https://github.com/dimagi/gmail-filters) - Python XML library with test examples

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

## Alternative Workflow (gmailctl)

For users who need XML export today, [gmailctl](https://github.com/mbrt/gmailctl) provides this capability via a two-step workflow:

```bash
# Step 1: Download filters from Gmail API to Jsonnet config
gmailctl download > my-filters.jsonnet

# Step 2: Export Jsonnet config to WebUI-compatible XML
gmailctl export -f my-filters.jsonnet > mailFilters.xml
```

This produces valid Gmail WebUI-importable XML.

**Why gogcli feature still valuable:**

- Single-command workflow (`gog gmail filters export > filters.xml`)
- No intermediate format/tool required
- Consistent with gogcli's direct API access philosophy
- Users already using gogcli don't need a second tool

**Related issues:**

- [mbrt/gmailctl#323](https://github.com/mbrt/gmailctl/issues/323) - Requests the **reverse direction** (XML → Jsonnet import)
- These are complementary features enabling full XML round-trip

## Priority

**Medium-High** - Enables powerful team collaboration and account management workflows that are currently only possible via WebUI manual export.

---

*Research conducted: 2026-02-03*
*Last updated: 2026-02-04 (added gmailctl alternative workflow)*
*Documentation archived in: gogcli-api-datamodel repository*
