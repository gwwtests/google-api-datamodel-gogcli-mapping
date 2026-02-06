# Gmail API Semantics Documentation Index

**Purpose**: Deep semantics and behavioral documentation for Gmail API

**Retrieved**: 2026-01-29

## Archive Structure

Each archived resource consists of:
* `.md` - Clean, readable markdown content
* `.url` - Source URL (single line)
* `.yaml` - Metadata including API calls covered, key concepts, and research questions addressed

## Archived Resources

### Labels Guide
**File**: `labels-guide.*`

**URL**: https://developers.google.com/gmail/api/guides/labels

**Key Content**:
* Complete list of system labels (13 documented)
* System vs user label types
* Label behavior on messages and threads
* Label inheritance rules

**Critical Finding**: Documentation notes list is "not exhaustive" - other reserved labels exist but are not documented

### Batch Operations Guide
**File**: `batch-guide.*`

**URL**: https://developers.google.com/gmail/api/guides/batch

**Key Content**:
* Batch request format (multipart/mixed)
* 100 call limit per batch
* Recommended max: 50 calls (rate limiting above this)
* Batch calls count as N requests for quota

**Critical Finding**: Server may execute batch calls in ANY ORDER (non-deterministic)

### Quota and Rate Limits
**File**: `quota-limits.*`

**URL**: https://developers.google.com/gmail/api/reference/quota

**Key Content**:
* Per-project limit: 1,200,000 quota units/minute
* Per-user limit: 15,000 quota units/minute
* Complete per-method quota costs table
* Highest cost operations (100 units): send, delegates, watch

### Bandwidth Limits
**File**: `bandwidth-limits.*`

**URL**: https://support.google.com/a/answer/1071518

**Type**: Google Workspace Admin documentation (NOT Gmail API)

**Key Content**:
* Web client limits: 750 MB/hour download, 300 MB/hour upload
* IMAP limits: 2500 MB/day download, 500 MB/day upload
* POP limits: 1250 MB/day download
* Best practice: max 500 labels for IMAP sync

### Delegation Guide
**File**: `delegation-guide.*`

**URL**: https://developers.google.com/gmail/api/guides/delegate_settings

**Key Content**:
* Delegator/delegate model
* Requires service account with domain-wide authority
* Same Google Workspace organization only
* Delegate permissions: read, send, delete messages; view/add contacts

**Unanswered Questions**:
* Do delegator and delegate see same message IDs?
* How do label IDs work in delegated access?
* Are history IDs shared?

## Usage Patterns

### Find Documentation by API Call

```bash
# Search metadata for specific API call
grep -r "messages.list" *.yaml

# Example output shows which docs cover that call
```

### Find Documentation by Concept

```bash
# Search metadata for concepts
grep -r "rate_limiting" *.yaml

# Or search content
grep -r "thread" *.md
```

### Check Research Question Coverage

```bash
# Find which docs address specific research questions
grep -r "GM-LB-001" *.yaml
```

## Key Findings Summary

### Limits and Quotas
* **API rate limits**: 1.2M/min per project, 15K/min per user
* **Batch limits**: 100 max, 50 recommended
* **Label limits**: 10,000 user labels per mailbox
* **IMAP best practice**: 500 labels max for sync

### Behavioral Semantics
* **Batch execution**: Non-deterministic order
* **Batch quota**: Counts as N separate requests
* **Label inheritance**: New thread messages don't inherit existing labels
* **System labels**: 13 documented (list incomplete)

### Multi-Account Considerations
* **Delegation scope**: Same organization only
* **Service account**: Required for delegation API
* **ID uniqueness**: NOT SPECIFIED (see `docs/datamodel/gmail/identifiers.md`)

## Related Documentation

* **Basic reference**: `../messages/`, `../threads/`, `../labels/`
* **Sync guide**: `../sync/`
* **History reference**: `../history/`
* **Synthesized analysis**: `../../datamodel/gmail/identifiers.md`
* **Research tracking**: `../../../research/RESEARCH_REQUESTS.md`

## Contributing

When adding new semantic documentation:

1. Use jina.ai_reader to fetch clean markdown
2. Create `.md`, `.url`, and `.yaml` files
3. Update this INDEX.md with key findings
4. Link to research questions in RESEARCH_REQUESTS.md
5. Commit with descriptive message including key findings
