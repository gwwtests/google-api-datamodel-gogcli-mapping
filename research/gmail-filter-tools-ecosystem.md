# Gmail Filter Tools & Libraries Ecosystem

**Research Date:** 2026-02-03
**Research Context:** Understanding programmatic Gmail filter creation for gogcli integration

## Executive Summary

Gmail filters can be managed programmatically through **two distinct pathways**:

1. **Gmail API (JSON format)** - Direct API integration using `users.settings.filters` endpoints
2. **XML Import/Export (Atom feed format)** - WebUI-compatible XML files using Atom syndication + Google Apps schema

**Critical Finding:** The Gmail API uses JSON and cannot export XML. Tools that output XML require manual WebUI import unless they implement their own API sync.

## Format Architecture

### Gmail API Format (JSON)

```json
{
  "id": "filter_id",
  "criteria": {
    "from": "sender@example.com",
    "subject": "text",
    "query": "search syntax",
    "hasAttachment": true,
    "size": 1000000,
    "sizeComparison": "larger"
  },
  "action": {
    "addLabelIds": ["LABEL_ID"],
    "removeLabelIds": ["INBOX", "UNREAD"],
    "forward": "forward@example.com"
  }
}
```

**Endpoints:** `users().settings().filters()` - create, list, get, delete

**Limitation:** Only one user-defined label per filter via `addLabelIds`

### WebUI XML Format (Atom + Google Apps)

```xml
<?xml version='1.0' encoding='UTF-8'?>
<feed xmlns='http://www.w3.org/2005/Atom'
      xmlns:apps='http://schemas.google.com/apps/2006'>
  <title>Mail Filters</title>
  <id>tag:mail.google.com,2008:filters:...</id>
  <updated>2026-02-03T12:00:00Z</updated>
  <author>
    <name>User Name</name>
    <email>user@example.com</email>
  </author>
  <entry>
    <category term='filter'/>
    <title>Mail Filter</title>
    <id>tag:mail.google.com,2008:filter:1234567890</id>
    <updated>2026-02-03T12:00:00Z</updated>
    <content/>
    <apps:property name='from' value='sender@example.com'/>
    <apps:property name='subject' value='important'/>
    <apps:property name='label' value='work'/>
    <apps:property name='shouldArchive' value='true'/>
    <apps:property name='shouldMarkAsRead' value='true'/>
  </entry>
</feed>
```

**Namespaces:**
- Atom: `http://www.w3.org/2005/Atom` (RFC 4287)
- Google Apps: `http://schemas.google.com/apps/2006`

**Property Names (apps:property):**

*Filter Criteria:*
- `from`, `to`, `subject`
- `hasTheWord`, `doesNotHaveTheWord`
- `sizeOperator` (s_sl, s_ss, s_se), `sizeUnit` (s_smb, s_skb)

*Filter Actions:*
- `label`, `shouldArchive`, `shouldMarkAsRead`, `shouldTrash`
- `shouldNeverSpam`, `shouldAlwaysMarkAsImportant`, `shouldNeverMarkAsImportant`

## Command-Line Tools

### 1. gmailctl (Go) ⭐ Most Popular

**Repository:** https://github.com/mbrt/gmailctl
**Language:** Go
**Config Format:** Jsonnet (`.jsonnet`)

**Features:**
- Declarative configuration with variables, functions, conditionals
- Built-in query simplifier (Gmail's 1500 char/filter limit)
- Automatic Gmail API synchronization (no manual import)
- Unit testing framework for filters
- XML export capability

**Commands:**
```bash
gmailctl init              # OAuth setup
gmailctl edit              # Open config in $EDITOR
gmailctl diff              # Compare local vs Gmail
gmailctl apply             # Sync to Gmail via API
gmailctl export            # Generate XML for manual import
gmailctl download          # Reverse-engineer existing filters
gmailctl test              # Run config tests
```

**Installation:**
```bash
go install github.com/mbrt/gmailctl/cmd/gmailctl@latest
brew install gmailctl                    # macOS
sudo snap install gmailctl               # Linux
```

**Configuration Example:**
```jsonnet
{
  version: 'v1alpha3',
  author: { name: 'User', email: 'user@example.com' },
  rules: [
    {
      filter: { from: 'github.com' },
      actions: { archive: true, labels: ['github'] }
    },
    {
      filter: {
        or: [
          { from: 'alerts@' },
          { subject: 'URGENT' }
        ]
      },
      actions: { markImportant: true, star: true }
    }
  ]
}
```

**Key Advantage:** Only tool providing full bidirectional Gmail API sync without manual steps.

### 2. Gefilte Fish (Python)

**Repository:** https://github.com/nedbat/gefilte
**Language:** Python
**Config Format:** Python DSL

**Features:**
- Pythonic DSL using context managers (`with` statements)
- Generates Gmail-compatible XML
- Extensible via subclassing `GFilter`
- Data-driven filter generation (loops, conditionals)

**Workflow:**
```python
from gefilte import GFilter

with GFilter() as fish:
    with fish.from_("noreply@github.com"):
        fish.has(exact("[notifications]")).label("github/notifications").skip_inbox()

    with fish.from_("security@github.com"):
        fish.label("github/security").star().mark_important()

# Output XML
print(fish.xml())
```

**Usage:**
```bash
python myfilters.py > filters.xml
# Manual import via Gmail Settings → Import Filters
```

**Strengths:** Excellent for programmatic generation from data sources.

### 3. gmail-yaml-filters (Python)

**Repository:** https://github.com/mesozoic/gmail-yaml-filters
**PyPI:** https://pypi.org/project/gmail-yaml-filters/
**Language:** Python
**Config Format:** YAML

**Features:**
- Simple YAML syntax
- Boolean operators (`any`/`all`)
- Template loops (`for_each`)
- Both XML export AND API sync

**Commands:**
```bash
gmail-yaml-filters config.yaml > filters.xml    # Generate XML
gmail-yaml-filters --upload config.yaml         # Sync via API
gmail-yaml-filters --sync config.yaml           # Upload + prune
gmail-yaml-filters --dry-run config.yaml        # Preview changes
```

**Configuration Example:**
```yaml
- from: example@gmail.com
  label: important
  archive: true
  read: true

- any:
    - from: alerts@
    - subject: URGENT
  important: true
  star: true

- for_each:
    repo: [repo1, repo2, repo3]
  from: "notifications@github.com"
  has: "{repo}"
  label: "github/{repo}"
```

**Setup:** Requires `client_secret.json` for API access.

### 4. gmail-tools / gmailcli (Go)

**Repository:** https://github.com/tsiemens/gmail-tools
**Language:** Go
**Binary:** `gmailcli`

**Features:**
- Filter management + advanced message search
- Custom "interest" categorization
- Search capabilities beyond Gmail WebUI

**Focus:** More message search/management than filter creation.

### 5. gmail-filters (dimagi) - Python Library

**Repository:** https://github.com/dimagi/gmail-filters
**Language:** Python
**Module:** `gmailfilterxml`

**Features:**
- Library for reading/writing Gmail filter XML
- Web frontend for filter creation
- Programmatic XML manipulation

**API Example:**
```python
from gmailfilterxml import GmailFilterSet, GmailFilter
import datetime

filter_set = GmailFilterSet(
    author_name='User',
    author_email='user@example.com',
    updated_timestamp=datetime.datetime.now(),
    filters=[
        GmailFilter(
            id='1286460749536',
            from_='noreply@github.com',
            label='github',
            shouldArchive=True,
        )
    ]
)

xml_output = filter_set.to_xml(pretty=True)
```

**Use Case:** Embedding filter generation in Python applications.

### 6. Other Notable Tools

**gmail-filter-organiser (Node.js/Go):**
https://github.com/woojiahao/gmail-filter-organiser
CLI to deduplicate and organize existing filters.

**gmail-filter-manager (Node.js):**
https://github.com/sergiopvilar/gmail-filter-manager
JavaScript tool for managing filters outside Gmail. Parses XML from `/input`, generates optimized XML to `/output`.

**Gmail filter generator (Ruby):**
https://github.com/esommer/gmail-filter
Generates XML from desired labels/addresses/phrases.

**watermint toolbox:**
https://watermint.org/2020/07/28/gmail-filter-cli-en/
Batch filter creation CLI.

**GAMADV-XTD3:**
https://github.com/taers232c/GAMADV-XTD3/wiki/Users-Gmail-Filters
Admin tool for Google Workspace bulk filter management.

## Programming Libraries

### Python

**gmailfilterxml** (dimagi/gmail-filters):
```python
from gmailfilterxml import GmailFilterSet, GmailFilter
# Read/write XML programmatically
```

**Gefilte Fish DSL:**
```python
from gefilte import GFilter
with GFilter() as fish:
    # Python-based filter definition
```

**Official Gmail API Client:**
```python
from googleapiclient.discovery import build
service = build('gmail', 'v1', credentials=creds)
service.users().settings().filters().create(userId='me', body=filter_obj).execute()
```

### Go

**Official Gmail API Client:**
```go
import "google.golang.org/api/gmail/v1"
service, _ := gmail.NewService(ctx, option.WithCredentials(creds))
filter := &gmail.Filter{...}
service.Users.Settings.Filters.Create("me", filter).Do()
```

**gmailctl library** (not standalone):
https://pkg.go.dev/github.com/mbrt/gmailctl
Jsonnet parsing + Gmail API integration.

**go-gmail-query-parser:**
https://pkg.go.dev/github.com/thedustin/go-gmail-query-parser
Parse Gmail query syntax (useful for criteria generation).

**encoding/xml (stdlib):**
Generate XML manually using structs + `xml.Marshal()`.

### Node.js

**@googleapis/gmail (npm):**
Official Gmail API client.
```javascript
const {google} = require('googleapis');
const gmail = google.gmail({version: 'v1', auth});
await gmail.users.settings.filters.create({userId: 'me', requestBody: filter});
```

**gmail-filter-manager:**
JavaScript XML parser/generator for Gmail filters.

**gmail-js (npm):**
DOM manipulation + XMLHttpRequest observation (browser extension context).

### Other Languages

**No specialized libraries found for:**
- Rust
- Ruby (only CLI tools)
- PHP (opdavies/gmail-filter-builder - generates XML from YAML)

## API vs WebUI: Critical Differences

### Search Behavior Divergence

1. **Alias Expansion:**
   - WebUI: Automatically expands Google Workspace account aliases
   - API: Does not expand aliases (must query each explicitly)

2. **Thread-wide Search:**
   - WebUI: Supports thread-level search
   - API: Message-level only

### Format Incompatibility

**Gmail API → XML Export:** Not supported by Google. Tools like gmailctl implement XML generation independently.

**XML Import → Gmail API:** WebUI parses XML and creates filters internally. API has no "import XML" endpoint.

### Workflow Implications

**Pure API Approach (gmailctl, gmail-yaml-filters --sync):**
- Filters stored as Jsonnet/YAML configs
- `apply`/`--sync` pushes directly to Gmail
- No manual WebUI interaction
- Requires OAuth setup

**XML Generation Approach (Gefilte, XML-only tools):**
- Generates compliant Atom XML
- Manual WebUI import required
- Simpler setup (no OAuth)
- Less automation

**Hybrid Approach (gmail-yaml-filters):**
- YAML config → XML OR API sync
- User chooses workflow
- Maximum flexibility

## Recommendations by Use Case

### For gogcli Integration

**Scenario A: Read-only Filter Inspection**
- Use Gmail API `users().settings().filters().list()`
- Parse JSON directly
- No XML handling needed

**Scenario B: Filter Export for Backup**
- Option 1: API list → convert to XML (implement Atom generation)
- Option 2: Use gmailctl library as dependency
- Option 3: Shell out to `gmailctl export`

**Scenario C: Programmatic Filter Creation**
- Use Gmail API `create()` directly (JSON)
- Avoid XML unless WebUI import is requirement

### For Developers

**Python Developers:**
- **Production:** `gmailfilterxml` library + Gmail API client
- **Rapid Prototyping:** Gefilte Fish DSL
- **Config-driven:** gmail-yaml-filters with `--sync`

**Go Developers:**
- **Full Solution:** gmailctl as library or shell subprocess
- **API Only:** Official `google.golang.org/api/gmail/v1`
- **XML Generation:** `encoding/xml` with custom structs

**Node.js Developers:**
- **API:** `@googleapis/gmail`
- **XML:** gmail-filter-manager for parsing/generation

**Any Language:**
- **Universal Tool:** gmailctl (Go binary, any language can shell out)
- **Simple Scripting:** Generate XML manually (Atom format well-documented)

## XML Schema Reference

### Complete Atom Structure

```xml
<?xml version='1.0' encoding='UTF-8'?>
<feed xmlns='http://www.w3.org/2005/Atom'
      xmlns:apps='http://schemas.google.com/apps/2006'>

  <title>Mail Filters</title>

  <id>tag:mail.google.com,2008:filters:FILTER_IDS_COMMA_SEPARATED</id>

  <updated>2026-02-03T12:00:00.000Z</updated>

  <author>
    <name>Your Name</name>
    <email>your.email@gmail.com</email>
  </author>

  <!-- Repeat <entry> for each filter -->
  <entry>
    <category term='filter'/>
    <title>Mail Filter</title>
    <id>tag:mail.google.com,2008:filter:UNIQUE_FILTER_ID</id>
    <updated>2026-02-03T12:00:00.000Z</updated>
    <content/>

    <!-- Filter criteria properties -->
    <apps:property name='from' value='sender@example.com'/>
    <apps:property name='to' value='recipient@example.com'/>
    <apps:property name='subject' value='keyword'/>
    <apps:property name='hasTheWord' value='important OR urgent'/>
    <apps:property name='doesNotHaveTheWord' value='spam'/>

    <!-- Size filter (optional) -->
    <apps:property name='sizeOperator' value='s_sl'/>  <!-- s_sl=larger, s_ss=smaller -->
    <apps:property name='sizeUnit' value='s_smb'/>     <!-- s_smb=MB, s_skb=KB -->
    <apps:property name='size' value='5'/>

    <!-- Filter action properties -->
    <apps:property name='label' value='MyLabel'/>
    <apps:property name='shouldArchive' value='true'/>
    <apps:property name='shouldMarkAsRead' value='true'/>
    <apps:property name='shouldTrash' value='false'/>
    <apps:property name='shouldNeverSpam' value='true'/>
    <apps:property name='shouldAlwaysMarkAsImportant' value='true'/>
    <apps:property name='shouldNeverMarkAsImportant' value='false'/>
    <apps:property name='shouldStar' value='true'/>
    <apps:property name='forwardTo' value='forward@example.com'/>
  </entry>

</feed>
```

### Property Value Types

**Boolean Properties:** `'true'` or `'false'` (string, lowercase)

**String Properties:** Plain text or Gmail query syntax (supports `OR`, `AND`, quotes)

**Size Properties:**
- `sizeOperator`: `s_sl` (larger), `s_ss` (smaller)
- `sizeUnit`: `s_smb` (megabytes), `s_skb` (kilobytes)
- `size`: Numeric string

### Minimal Valid Filter

```xml
<?xml version='1.0' encoding='UTF-8'?>
<feed xmlns='http://www.w3.org/2005/Atom'
      xmlns:apps='http://schemas.google.com/apps/2006'>
  <title>Mail Filters</title>
  <author><name>User</name><email>user@gmail.com</email></author>
  <entry>
    <category term='filter'/>
    <title>Mail Filter</title>
    <apps:property name='from' value='sender@example.com'/>
    <apps:property name='label' value='work'/>
  </entry>
</feed>
```

**Notes:**
- `<id>` and `<updated>` can be omitted (Gmail generates on import)
- At least one criteria property required
- At least one action property required
- Multiple filters = multiple `<entry>` blocks

## Future Considerations

### Gmail API Evolution

**Current Limitations:**
- No XML export endpoint
- Single label per filter via `addLabelIds`
- No thread-level filtering in API

**Possible Future:**
- Native XML import/export endpoints
- Parity with WebUI search capabilities

### Tool Maturity

**gmailctl** appears most actively maintained with comprehensive feature set.

**gmail-yaml-filters** offers good balance of simplicity + power.

**Gefilte Fish** excellent for Python-native workflows.

### Integration Strategies

**For gogcli:**

1. **Use Gmail API exclusively** (avoid XML complexity)
2. **If XML export needed:** Implement Atom generation or depend on gmailctl
3. **Filter listing:** API JSON → parse directly
4. **Filter creation:** API JSON → push directly

**Avoid:** Converting between JSON ↔ XML (semantic mismatch risk)

## Sources

### Documentation

- [Gmail API - Managing Filters](https://developers.google.com/workspace/gmail/api/guides/filter_settings)
- [Gmail API - REST Resource: users.settings.filters](https://developers.google.com/gmail/api/reference/rest/v1/users.settings.filters)
- [RFC 4287 - The Atom Syndication Format](https://www.ietf.org/rfc/rfc4287.txt)
- [Google Data APIs Protocol Reference](https://developers.google.com/gdata/docs/1.0/reference)
- [Gmail Help - Create rules to filter emails](https://support.google.com/mail/answer/6579)

### Tools & Libraries

- [gmailctl (mbrt)](https://github.com/mbrt/gmailctl)
- [Gefilte Fish (nedbat)](https://github.com/nedbat/gefilte)
- [gmail-yaml-filters (mesozoic)](https://github.com/mesozoic/gmail-yaml-filters)
- [gmail-filters (dimagi)](https://github.com/dimagi/gmail-filters)
- [gmail-tools (tsiemens)](https://github.com/tsiemens/gmail-tools)
- [gmail-filter-organiser (woojiahao)](https://github.com/woojiahao/gmail-filter-organiser)
- [gmail-filter-manager (sergiopvilar)](https://github.com/sergiopvilar/gmail-filter-manager)

### Articles

- [Manage Gmail filters from Linux CLI](https://opensource.com/article/22/5/gmailctl-linux-command-line-tool)
- [Gmail filters as code (Medium)](https://medium.com/swlh/gmail-filters-as-a-code-670fd719f473)
- [Gefilte Fish announcement](https://nedbatchelder.com/blog/202103/gefilte_fish_gmail_filter_creation.html)
- [Gmail Filter Tips (Draconian Overlord)](https://www.draconianoverlord.com/2017/02/04/gmail-filter-tips.html/)

---

**Research Methodology:** Web search + documentation analysis + source code inspection + format reverse-engineering from test fixtures.

**Confidence Level:** High - Information corroborated across official docs, multiple independent tools, and RFC specifications.
