# Gmail API Advanced Features - Archived Research

**Last Updated**: 2026-01-30

This directory contains archived research on Gmail API features that are either not fully documented or have limited/no API support.

## Directory Contents

### 1. Snooze Feature

* `snooze-api-limitation.*` - Feature request #109952618 for API snooze support
* `snooze-date-request.*` - Feature request #287304309 for snooze date metadata

**Status**: No API support. Both feature requests blocked.

### 2. Categories and Tabs

* `category-labels.*` - CATEGORY_* system labels (Primary, Social, Promotions, Updates, Forums)
* `priority-inbox-algorithm.*` - IMPORTANT label and machine learning algorithm
* `priority-inbox-paper.pdf` - Google Research paper (Aberdeen & Pacovsky)

**Status**: Full API support via system labels.

### 3. Send As and Delegation

* `sendas-resource.*` - users.settings.sendAs API resource documentation
* `delegation-resource.*` - users.settings.delegates API resource documentation

**Status**: Full API support for both features.

### 4. Confidential Mode and Encryption

* `confidential-mode.*` - Gmail confidential mode overview and limitations
* `cse-identities.*` - Client-Side Encryption (CSE) API resource documentation

**Status**: Confidential mode has no API support. CSE has limited API support.

### 5. Scheduled Send

* `scheduled-send-request.*` - Feature request #140922183 for scheduled send API
* `draft-resource.*` - Draft resource structure and limitations

**Status**: No API support. Feature request blocked.

## File Naming Convention

Each research topic has three files:

* `{topic}.url` - Source URL (single line)
* `{topic}.meta.json` - Metadata including extraction method, date, description
* `{topic}.md` - Clean markdown content with analysis

Some topics also include:

* `{topic}.pdf` - Original research papers or documents
* `{topic}.html` - Original HTML when relevant

## Synthesis Document

For a comprehensive overview of all features with examples and recommendations, see:

**`docs/datamodel/gmail/advanced-features.md`**

## Research Methodology

All materials gathered using:

* **WebSearch** - Initial discovery
* **WebFetch** - Content extraction from official docs
* **Direct download** - PDF research papers
* **Issue tracker** - Google Issue Tracker feature requests
* **jina.ai_reader** - Enhanced content extraction

## Sources

### Official Google Documentation

* https://developers.google.com/workspace/gmail/api/
* Gmail API reference documentation

### Google Issue Tracker

* https://issuetracker.google.com/issues?q=componentid:191625+gmail+api

### Google Research

* Priority Inbox paper: https://research.google.com/pubs/archive/36955.pdf

### Community Resources

* Gmail API guides and tutorials
* Third-party implementation examples
* Security analysis and best practices

## Update Protocol

When updating this research:

1. Download new source materials
2. Create .url, .meta.json, and .md files
3. Update synthesis document `docs/datamodel/gmail/advanced-features.md`
4. Commit batch with descriptive message
5. Update this INDEX.md

## Related Documentation

* `docs/web/gmail/INDEX.md` - Main Gmail API documentation index
* `docs/datamodel/gmail/` - Gmail data model documentation
* `docs/web/gmail/semantics/` - Gmail semantics and behavior
