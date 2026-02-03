# Future Work Roadmap

## Study Order

Services are prioritized by common usage and complexity:

### Phase 1: Core Communication (Current Focus)

- [x] Repository setup and methodology
- [ ] **Gmail API** ← START HERE
  - [ ] Messages data model
  - [ ] Threads data model (messages vs threads relationship)
  - [ ] Labels (system vs user labels)
  - [x] Filters (import/export format, API vs WebUI)
  - [ ] Identifiers (message ID, thread ID uniqueness)
  - [ ] Multi-account considerations
  - [ ] History and sync

### Phase 2: Productivity Suite

- [ ] **Calendar API**
  - [ ] Events data model
  - [ ] Calendars and ACLs
  - [ ] Timezone handling (critical!)
  - [ ] Recurring events
  - [ ] Shared calendars and event IDs
  - [ ] Free/busy queries

- [ ] **Tasks API**
  - [ ] Task lists
  - [ ] Tasks data model
  - [ ] Due dates and timezones
  - [ ] Repeat schedules

### Phase 3: Files and Documents

- [ ] **Drive API**
  - [ ] Files and folders
  - [ ] Shared drives (Team Drives)
  - [ ] Permissions model
  - [ ] File IDs and uniqueness
  - [ ] Export formats

- [ ] **Docs API**
  - [ ] Document structure
  - [ ] Export via Drive

- [ ] **Sheets API**
  - [ ] Spreadsheet structure
  - [ ] Cells, ranges, formatting
  - [ ] Data types and formatting

- [ ] **Slides API**
  - [ ] Export via Drive

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

- [ ] **Identifier Patterns**: Common patterns across Google APIs
- [ ] **Pagination**: How each API paginates
- [ ] **Rate Limits**: Quotas and backoff strategies
- [ ] **Timestamps**: RFC3339 patterns, timezone handling
- [ ] **Error Responses**: Common error codes and handling
- [ ] **Multi-Account**: Patterns for combining data safely

## gogcli Feature Proposals

Feature requests for [gogcli](https://github.com/steipete/gogcli) identified during research:

| Proposal | Status | File |
|----------|--------|------|
| Gmail filter export in WebUI-compatible XML | Pending issue creation | `research/gogcli-issues/gmail-filters-export-xml-proposal.md` |

## Adding New Services

When a new service is studied:

1. Create `research/gogcli-analysis/{service}-api-usage.md`
2. Add research requests to `research/RESEARCH_REQUESTS.md`
3. Archive official docs to `docs/web/{service}/`
4. Create data model docs in `docs/datamodel/{service}/`
5. Add examples to `examples/{service}/`
6. Update this file and `CURRENT_WORK.md`
