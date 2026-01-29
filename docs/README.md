# Documentation

This directory contains research documentation for understanding Google Workspace API data models.

## Quick Reference

**For Gmail API data model**: Start here:

* `gmail-data-model-findings.md` - Comprehensive human-readable analysis
* `gmail-data-model.json` - Structured machine-readable data
* `web/gmail/INDEX.md` - Archive inventory and source URLs

## Directory Structure

```
docs/
├── README.md                          # This file
├── gmail-data-model-findings.md       # Comprehensive Gmail analysis
├── gmail-data-model.json              # Structured Gmail data model
└── web/                               # Archived source documentation
    └── gmail/                         # Gmail API documentation
        ├── INDEX.md                   # Archive inventory
        ├── overview/                  # API overview
        ├── messages/                  # Message resource + guides
        ├── threads/                   # Thread resource + guides
        ├── labels/                    # Label resource + guides
        ├── history/                   # History resource
        └── sync/                      # Synchronization guides
```

## Gmail API Documentation

### Analysis Documents

1. **gmail-data-model-findings.md**
   * Comprehensive analysis of Gmail API data model
   * Answers to research questions
   * Multi-account export considerations
   * Unanswered questions requiring testing
   * Recommended data model design

2. **gmail-data-model.json**
   * Structured JSON format for programmatic access
   * Field specifications and formats
   * Multi-account recommendations
   * Testing requirements

### Archived Source Documentation

Located in `web/gmail/`, organized by topic:

* **messages/** - Message resource reference and guides
* **threads/** - Thread resource reference and guides
* **labels/** - Label resource reference and guides
* **history/** - History resource for incremental sync
* **sync/** - Synchronization and push notification guides
* **overview/** - General API overview

Each document has three files:

* `.md` - Clean markdown content (via jina.ai reader)
* `.url` - Source URL (single line)
* `.yaml` - Metadata (timestamp, key concepts, covered APIs, notes)

See `web/gmail/INDEX.md` for complete inventory.

## Archive Metadata

**Archive Date**: 2026-01-29

**Source**: Google Developers documentation (developers.google.com)

**Extraction Method**: jina.ai reader for clean markdown conversion

**Coverage**:

* Message resource and methods
* Thread resource and methods
* Label resource and methods
* History resource and synchronization
* Push notifications
* Search/filtering

## Key Findings Summary

### Identifiers

* **messageId**: Immutable, opaque string, uniqueness scope unspecified
* **threadId**: Unique per thread, opaque string, uniqueness scope unspecified
* **labelId**: Immutable, opaque string, system vs user types
* **historyId**: Monotonically increasing, ~1 week retention

### Timestamps

* **internalDate**: Epoch milliseconds (UTC), determines inbox ordering

### Threading

* Based on: threadId + RFC 2822 headers + Subject matching
* Independent per account (no cross-account threading)

### Synchronization

* **Full Sync**: messages.list + batch messages.get
* **Partial Sync**: history.list with startHistoryId
* **Push**: Pub/Sub notifications trigger partial sync

### Multi-Account

* Composite keys recommended: (userId, messageId), (userId, threadId)
* Track historyId independently per account
* Store both labelId and name for labels

### Unanswered Questions

* Global vs per-user ID uniqueness
* Multi-account collision potential
* Complete system label list
* Threading edge cases

See analysis documents for complete details.

## Related Files

* `../research/RESEARCH_REQUESTS.md` - Research question tracking
* Questions marked with source references link to this documentation

## Usage Examples

### For Data Model Design

1. Read `gmail-data-model-findings.md` for comprehensive understanding
2. Reference `gmail-data-model.json` for field specifications
3. Check archived sources in `web/gmail/` for official details

### For Specific API Questions

1. Check `web/gmail/INDEX.md` to find relevant document
2. Read `.yaml` metadata for quick summary
3. Read `.md` content for full details
4. Check `.url` for original source

### For Multi-Account Export

See "Multi-Account Export Considerations" section in:

* `gmail-data-model-findings.md` (detailed analysis)
* `gmail-data-model.json` (structured recommendations)

## Maintenance

When updating this archive:

1. Download new documentation using jina.ai reader
2. Create `.md`, `.url`, and `.yaml` files
3. Update `web/gmail/INDEX.md` with new entries
4. Update analysis documents if findings change
5. Commit in separate batches by topic
6. Use descriptive commit messages with source attribution

## Archive Format

Each archived document follows this pattern:

```
{basename}.md        # Clean markdown content
{basename}.url       # Source URL (one line)
{basename}.yaml      # Metadata:
                     #   - source_url
                     #   - download_timestamp
                     #   - document_title
                     #   - covered_api_calls
                     #   - key_concepts
                     #   - related_docs
                     #   - notes
```

This format ensures:

* Every artifact is traceable to source
* Metadata is machine-readable
* Content is human-readable
* Updates can be detected (timestamp)
* Related documents are linked

## Future Work

* Test unanswered questions empirically
* Document system label IDs via testing
* Add Calendar API documentation (similar structure)
* Add Drive API documentation (if needed)
* Create RDF/Turtle semantic web representations
