# Future Work Roadmap

## Study Order

Services are prioritized by common usage and complexity:

### Phase 1: Core Communication (95% Complete)

- [x] Repository setup and methodology
- [~] **Gmail API** (95% - needs empirical testing)
  - [x] Messages data model
  - [x] Threads data model (messages vs threads relationship)
  - [x] Labels (system vs user labels)
  - [x] Filters (import/export format, API vs WebUI)
  - [x] Identifiers (message ID, thread ID uniqueness) - documented, needs testing
  - [x] Multi-account considerations - documented composite key approach
  - [x] History and sync

### Phase 2: Productivity Suite

- [x] **Calendar API** (100% - documentation complete)
  - [x] Events data model
  - [x] Calendars and ACLs
  - [x] Timezone handling (critical!) - comprehensive docs in datamodel/calendar/timezones.md
  - [x] Recurring events
  - [x] Shared calendars and event IDs - composite key documented
  - [ ] Free/busy queries (optional - not core)

- [ ] **Tasks API**
  - [ ] Task lists
  - [ ] Tasks data model
  - [ ] Due dates and timezones
  - [ ] Repeat schedules

### Phase 3: Files and Documents

- [x] **Drive API** (100% - comprehensive feature mapping)
  - [x] Files and folders - 120 features mapped in YAML
  - [x] Shared drives (Team Drives) - supportsAllDrives documented
  - [x] Permissions model - 4 types, 6 roles documented
  - [x] File IDs and uniqueness - globally unique (no composite key needed)
  - [x] Export formats - MIME type mapping complete
  - [x] Comments via Drive API - 6 comment commands in gogcli
  - [x] UI vs API vs gogcli comparison

- [x] **Docs API** (100% - comprehensive feature mapping)
  - [x] Document structure - 104 features mapped in YAML
  - [x] Export via Drive - gogcli gap analysis complete
  - [x] UI vs API vs gogcli comparison
  - [x] UTF-16 indexing semantics documented

- [x] **Sheets API** (100% - comprehensive feature mapping)
  - [x] Spreadsheet structure - 156 features mapped in YAML
  - [x] Cells, ranges, formatting - gogcli supports 8 commands
  - [x] Data types and formatting - notes vs comments documented
  - [x] Dynamic functions (GOOGLEFINANCE, GOOGLETRANSLATE, IMPORT*) - limitations documented
  - [x] Data validation - API full, gogcli copy-only
  - [x] UI vs API vs gogcli comparison

- [ ] **Slides API** ← NEXT
  - [ ] Presentation structure
  - [ ] Slides, shapes, text
  - [ ] Export via Drive
  - [ ] UI vs API vs gogcli comparison

### Phase 4: Contacts and People

- [ ] **People API**
  - [ ] Contact data model
  - [ ] Other contacts vs my contacts
  - [ ] Directory (Workspace)
  - [ ] Contact groups
  - [ ] Resource names and IDs

### Phase 5: Collaboration (Workspace-focused)

- [ ] **Chat API**
  - [ ] Spaces data model
  - [ ] Messages and threads
  - [ ] Direct messages
  - [ ] Membership

- [ ] **Classroom API**
  - [ ] Courses
  - [ ] Roster
  - [ ] Coursework
  - [ ] Submissions

- [ ] **Cloud Identity API** (Groups)
  - [ ] Group membership
  - [ ] Workspace-only features

- [ ] **Keep API**
  - [ ] Notes data model
  - [ ] Workspace-only (service account required)

## Cross-Cutting Concerns

To be documented across all services:

- [~] **Identifier Patterns**: Documented for Gmail, Calendar, Drive - composite keys vs global IDs
- [ ] **Pagination**: How each API paginates
- [~] **Rate Limits**: Gmail, Drive quotas documented
- [~] **Timestamps**: Gmail (epoch ms), Calendar/Drive (RFC3339) documented
- [ ] **Error Responses**: Common error codes and handling
- [~] **Multi-Account**: Composite key pattern documented for Gmail/Calendar; Drive IDs globally unique

## gogcli Feature Proposals

Feature requests for [gogcli](https://github.com/steipete/gogcli) identified during research:

| Proposal | Status | Link |
|----------|--------|------|
| Gmail filter export in WebUI-compatible XML | [Issue #174](https://github.com/steipete/gogcli/issues/174) | `research/gogcli-issues/gmail-filters-export-xml-proposal.md` |

## Adding New Services

When a new service is studied:

1. Create `research/gogcli-analysis/{service}-api-usage.md`
2. Add research requests to `research/RESEARCH_REQUESTS.md`
3. Archive official docs to `docs/web/{service}/`
4. Create data model docs in `docs/datamodel/{service}/`
5. Add examples to `examples/{service}/`
6. Update this file and `CURRENT_WORK.md`
