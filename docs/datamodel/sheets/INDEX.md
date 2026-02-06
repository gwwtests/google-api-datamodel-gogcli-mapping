# Google Sheets Data Model Documentation

**Last Updated**: 2026-02-06

This directory contains synthesized documentation about the Google Sheets data model, API capabilities, and gogcli support.

## Documentation Index

| Document | Purpose | Key Insights |
|----------|---------|--------------|
| `google-sheets-ui-features-comprehensive.md` | Complete UI feature catalog | 8 categories, 150+ features |
| `google-sheets-feature-comparison.yaml` | Machine-readable feature mapping | 156 features, 12 categories |
| `google-sheets-feature-comparison-tables.md` | Generated comparison tables | UI vs API vs gogcli |
| `google-sheets-gogcli-data-handling.md` | How gogcli handles Sheets | 8 commands, data structures |

## Key Findings Summary

### Feature Coverage

| Interface | Full Support | Partial | None |
|-----------|-------------|---------|------|
| **UI** | 140 | 0 | 16 |
| **API** | 98 | 12 | 18 |
| **gogcli** | 32 | 8 | 108 |

### Critical Insights

1. **Notes vs Comments**
   - **Notes**: Simple annotations (yellow corner), API: `CellData.note`, gogcli: not supported
   - **Comments**: Threaded discussions, via Drive API, gogcli: not supported

2. **Dynamic Functions (GOOGLEFINANCE, etc.)**
   - Execute server-side
   - API can **read results** but not trigger recalculation
   - GOOGLEFINANCE historical data returns #N/A via API (since 2016)

3. **Data Validation**
   - API: Full create/update support
   - gogcli: Can only **copy** existing rules, not create new

4. **Conditional Formatting**
   - API: Supports bold, italic, strikethrough, colors
   - API: Does **NOT** support underline, alignment, borders (returns 400)

5. **Apps Script / Macros**
   - Separate API (Apps Script API)
   - Sheets API cannot execute macros

### gogcli Strengths

| Capability | Support Level |
|------------|---------------|
| Read/write values | ✅ Full |
| Read formulas | ✅ Full |
| Cell formatting | ✅ Full |
| Create spreadsheets | ✅ Full |
| Export (XLSX/PDF/CSV) | ✅ Full |
| Copy validation | ⚠️ Copy only |

### gogcli Gaps

| Category | Missing Features |
|----------|------------------|
| Cell Content | Notes, comments, rich text |
| Structure | Sheet add/delete, row/column ops, merge, freeze |
| Advanced | Charts, pivot tables, filters, sorting |
| Formatting | Borders, conditional formatting |
| Multi-range | batchGet, batchUpdate |

## Identifier Semantics

| Identifier | Scope | Format |
|------------|-------|--------|
| Spreadsheet ID | Global | Opaque string (from URL) |
| Sheet ID | Per spreadsheet | Integer |
| Named Range ID | Per spreadsheet | Integer |
| Protected Range ID | Per spreadsheet | Integer |

**Multi-account safe**: Spreadsheet IDs are globally unique. Sheet IDs within a spreadsheet cannot collide across different spreadsheets.

## API Rate Limits

| Limit Type | Rate |
|------------|------|
| Read requests/minute | 300 per project, 60 per user |
| Write requests/minute | 300 per project, 60 per user |
| Request timeout | 180 seconds |
| Payload size | 2MB recommended |

## Related Documentation

* `../gmail/` - Gmail API data model
* `../calendar/` - Calendar API data model
* `../docs/` - Google Docs API data model
* `../../web/sheets/` - Archived API documentation (if populated)

## How to Use This Documentation

### For Understanding Sheets Capabilities

1. Start with `google-sheets-ui-features-comprehensive.md`
2. Cross-reference with `google-sheets-feature-comparison-tables.md`

### For Building Applications

1. Check feature in `google-sheets-feature-comparison.yaml`
2. Verify API support level
3. If using gogcli, check `google-sheets-gogcli-data-handling.md`

### For Contributing

1. Update YAML when features change
2. Regenerate tables from YAML
3. Update analysis dates
4. Add new insights to this INDEX
