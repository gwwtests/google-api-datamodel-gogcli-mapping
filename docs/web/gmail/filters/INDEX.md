# Gmail Filters Documentation Index

This directory contains archived official documentation about Gmail filters, including both the web UI (XML-based) and API (JSON-based) approaches.

## Quick Reference

| Document | Focus | Format | Key Topics |
|----------|-------|--------|------------|
| `gmail-help-filters.md` | End-user UI | XML | Import/Export, UI workflow |
| `filter-settings-guide.md` | Developer API | JSON | Programmatic management |
| `filters-api-reference.md` | API Reference | JSON | Resource structure, methods |
| `filters-api-vs-xml.md` | Comparison | Both | Format incompatibilities |
| `filters-xml-export-format.md` | XML Schema | XML | Export format details |
| `filter-xml-format-specification.md` | XML Spec | XML | Complete XML reference |

## By Use Case

### I want to understand Gmail filter import/export via UI

Start with:

1. `gmail-help-filters.md` - User-facing documentation
2. `filters-xml-export-format.md` - Export format specifics
3. `filter-xml-format-specification.md` - Complete XML schema

### I want to manage filters programmatically via API

Start with:

1. `filter-settings-guide.md` - API guide with examples
2. `filters-api-reference.md` - Complete API reference
3. `filters-api-vs-xml.md` - Understand UI vs API differences

### I want to build a tool that converts between formats

Read:

1. `filters-api-vs-xml.md` - Conversion challenges
2. `filter-xml-format-specification.md` - XML structure
3. `filters-api-reference.md` - API structure

## API Methods Covered

All documentation references these Gmail API methods:

* `users.settings.filters.create` - Create new filter
* `users.settings.filters.delete` - Delete filter by ID
* `users.settings.filters.get` - Retrieve specific filter
* `users.settings.filters.list` - List all filters

## Key Concepts by Document

### Filter Criteria

* **Matching logic**: All criteria must match (AND logic)
* **Query syntax**: Supports Gmail search box syntax
* **Size comparisons**: larger/smaller operators
* **Attachment detection**: hasAttachment boolean
* **Negation**: negatedQuery field

### Filter Actions

* **Label operations**: addLabelIds, removeLabelIds
* **Forwarding**: requires verified email address
* **Special actions**: Archive (remove INBOX), Mark read (remove UNREAD)
* **System labels**: INBOX, UNREAD, IMPORTANT, TRASH, SPAM

### Format Differences (XML vs JSON)

* **Label references**: Names (XML) vs IDs (JSON)
* **Action syntax**: Boolean flags (XML) vs label arrays (JSON)
* **Query field names**: hasTheWord (XML) vs query (JSON)
* **OR operations**: Single XML property vs multiple API filters

## Important Limitations

* Maximum 1000 filters per account
* Filter IDs are server-assigned (cannot be specified on create)
* Filters apply to messages, not threads
* XML import/export not available via API (web UI only)
* API does not support alias expansion (UI does)
* API message-level search vs UI thread-wide search

## Source URLs

All documents include source URLs in their .yaml metadata files and .url files:

* Gmail Help: https://support.google.com/mail/answer/6579
* API Guide: https://developers.google.com/workspace/gmail/api/guides/filter_settings
* API Reference: https://developers.google.com/gmail/api/reference/rest/v1/users.settings.filters

## Searchability

Use `yq` to query metadata files:

```bash
# Find docs covering specific API call
yq '.covered_api_calls[]' *.yaml | grep "filters.create"

# Find docs about concepts
yq 'select(.key_concepts[] | contains("XML"))' *.yaml

# List all source URLs
yq '.source_url' *.yaml
```

## Related Documentation

* `../labels/` - Label management (required for filter label resolution)
* `../../datamodel/gmail/filters.md` - Synthesized data model documentation
* `../../../research/gmail-filter-tools-ecosystem.md` - Tool analysis

## Archival Notes

* Most documents archived on 2026-02-03
* Gmail Help page partially archived (dynamic content limitations)
* All API documentation fully archived
* Extraction method: WebFetch tool
* Metadata format: YAML with source URLs, timestamps, covered APIs

## Next Steps

For developers working on filter-related tools:

1. Read API guide for basic understanding
2. Study format comparison for conversion challenges
3. Review XML specification if supporting UI import/export
4. Check data model docs for synthesized insights
