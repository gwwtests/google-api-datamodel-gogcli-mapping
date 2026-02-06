# Google Sheets API v4 Capabilities - Comprehensive Research

**Research Date:** 2026-02-06
**API Version:** v4
**Purpose:** Understanding programmatic access capabilities for gogcli integration

---

## Executive Summary

Google Sheets API v4 provides extensive read/write capabilities for spreadsheet data, formatting, and structure. The API uses RESTful endpoints at `https://sheets.googleapis.com` with four primary resource collections. While most UI features are accessible, some edge cases exist (Apps Script execution, certain GOOGLEFINANCE operations, complex chart configurations).

---

## 1. API METHODS OVERVIEW

### 1.1 Primary Resource Collections

**v4.spreadsheets** - Core spreadsheet operations

* `spreadsheets.get` - Retrieves spreadsheet data by ID
* `spreadsheets.create` - Generates new spreadsheets
* `spreadsheets.batchUpdate` - Applies one or more updates atomically
* `spreadsheets.getByDataFilter` - Fetches spreadsheets matching specified filters

**v4.spreadsheets.values** - Data manipulation (largest method set)

* **Read:** `get`, `batchGet`, `batchGetByDataFilter`
* **Write:** `update`, `append`, `batchUpdate`, `batchUpdateByDataFilter`
* **Clear:** `clear`, `batchClear`, `batchClearByDataFilter`

**v4.spreadsheets.sheets** - Sheet-level management

* `sheets.copyTo` - Duplicates individual sheets across spreadsheets

**v4.spreadsheets.developerMetadata** - Metadata handling

* `developerMetadata.get` - Retrieves metadata by ID
* `developerMetadata.search` - Returns all developer metadata matching specified DataFilter

### 1.2 Values Methods Details

| Method | Endpoint | Purpose |
|--------|----------|---------|
| **get** | `GET /v4/spreadsheets/{id}/values/{range}` | Returns single range of values |
| **batchGet** | `GET /v4/spreadsheets/{id}/values:batchGet` | Returns multiple ranges (major dimension control: ROWS/COLUMNS) |
| **update** | `PUT /v4/spreadsheets/{id}/values/{range}` | Updates single range |
| **batchUpdate** | `POST /v4/spreadsheets/{id}/values:batchUpdate` | Updates multiple ranges |
| **append** | `POST /v4/spreadsheets/{id}/values/{range}:append` | Appends values to next row of detected table |
| **clear** | `POST /v4/spreadsheets/{id}/values/{range}:clear` | Clears values in single range |
| **batchClear** | `POST /v4/spreadsheets/{id}/values:batchClear` | Clears multiple ranges |

**Key Parameters:**

* `valueRenderOption`: `FORMATTED_VALUE` (default, UI display) | `UNFORMATTED_VALUE` | `FORMULA`
* `dateTimeRenderOption`: `SERIAL_NUMBER` (default) | `FORMATTED_STRING` (requires valueRenderOption != FORMATTED_VALUE)
* `majorDimension`: `ROWS` (default) | `COLUMNS`
* `valueInputOption`: `RAW` (literal strings) | `USER_ENTERED` (parse formulas, dates, currency)

---

## 2. WHAT CAN BE READ VIA API

### 2.1 Cell Data (`CellData` object)

**Core Values:**

* **User-entered value** - Original input
* **Effective value** - Calculated result (for formulas)
* **Formatted value** - Display representation in UI
* **Formulas** - Raw formula text (via `valueRenderOption=FORMULA`)

**Cell Metadata:**

* **Notes** - Cell annotations (requires `spreadsheets.get`, not available via `spreadsheets.values`)
* **Hyperlinks** - Links in cells (read-only; set via formulas like `=HYPERLINK()`)
* **Data source formulas** - References to DATA_SOURCE sheets
* **Smart chips** - Person links and rich links to Google resources

### 2.2 Formatting (`CellFormat` object)

**Text Formatting:**

* Number formatting (currency, date, time, scientific notation, etc.)
* Text alignment (horizontal and vertical)
* Text rotation angles
* Text wrapping and direction strategies
* Rich text runs with character-level styling

**Visual Formatting:**

* Background colors and styles
* Border styles and properties
* Cell padding
* Text color

**Advanced Formatting:**

* **Conditional formatting rules** - Read/write via `spreadsheets.get` and `batchUpdate`
  - Boolean rules: `{ "condition": { object(BooleanCondition) }, "format": { object(CellFormat) } }`
  - Gradient rules: Calculate background color based on cell value
  - **Supported in conditional format:** bold, italic, strikethrough, text color, background color
  - **NOT supported (400 error):** underline, alignment, borders

### 2.3 Data Validation Rules

**Criteria Types:**

* Dropdown (manual list)
* Dropdown from range
* Checkbox (boolean, rendered as checkbox)
* Text (contains, equals, etc.)
* Date (between, before, after, etc.)
* Number (greater than, less than, between, etc.)
* Custom formula

**API Access:**

* Read via `spreadsheets.get`
* Write via `SetDataValidationRequest` in `batchUpdate`
* Apps Script: `DataValidationBuilder` with methods like `requireValueInList`, `requireCheckbox`, `requireDateBetween`

### 2.4 Charts

**Access:**

* Read chart configuration via `spreadsheets.get` (EmbeddedChart objects)
* Create via `AddChartRequest` in `batchUpdate`
* Update via `UpdateChartSpec` in `batchUpdate`
* Delete via `DeleteEmbeddedObjectRequest`

**Limitations:**

* Apps Script chart classes don't cover every configuration option
* Google Charts API has separate limitations
* Recommended: Create basic charts via API, then manually tune formatting in Sheets UI

### 2.5 Named Ranges

**Operations:**

* **Read:** `spreadsheets.get` retrieves all named ranges (as grid ranges, convertible to A1 notation)
* **Create:** `AddNamedRangeRequest` via `batchUpdate`
* **Update:** `UpdateNamedRangeRequest` (changes name or range)
* **Delete:** `DeleteNamedRangeRequest`

**Properties:**

* Named range ID (read-only)
* Name/alias
* Associated range (grid range or A1 notation)

### 2.6 Protected Ranges

**Read Properties:**

* Protected range ID (read-only)
* Range specification
* Protection type: warning-only or restricted editing
* Editors list (emails of users with edit access) - visible only to users with edit access
* `requestingUserCanEdit` flag (read-only)

**Write Operations:**

* Create: `AddProtectedRangeRequest`
* Update: `UpdateProtectedRangeRequest`
* Delete: `DeleteProtectedRangeRequest`

**Key Constraints:**

* Warning-only protection: prompts user confirmation but allows all users to edit
* Restricted editing: only listed editors can modify
* Editors must already have write access to spreadsheet
* Spreadsheet owner automatically added as editor

### 2.7 Other Readable Features

* **Pivot tables** - Anchored at specific cells with dynamic sizing (Apps Script: PivotTable classes since 2018)
* **Data source tables** - Imported static data with filters and sorts (cannot modify underlying BigQuery query via API)
* **Filters and filter views** - Read/write via API
* **Banding** (alternating row colors) - Read/write via API
* **Dimension groups** (collapsible rows/columns) - Read/write via API
* **Slicers** - Interactive filter controls (read/write via API)
* **Developer metadata** - Custom metadata for automation

---

## 3. WHAT CAN BE WRITTEN VIA API

### 3.1 Cell Values and Formulas

**Methods:**

* `spreadsheets.values.update` - Single range
* `spreadsheets.values.batchUpdate` - Multiple ranges
* `spreadsheets.values.append` - Append to next row of table
* `UpdateCellsRequest` in `batchUpdate` - With formatting

**Input Options:**

* `RAW` - Treat as literal strings (`"=1+2"` remains text)
* `USER_ENTERED` - Parse as user input (formulas calculate, dates format, `"$100.15"` gets currency formatting)

### 3.2 Cell Notes

**Access:** Via `UpdateCellsRequest` in `batchUpdate` (not available via `spreadsheets.values` methods)

### 3.3 Formatting

**All formatting writable via `batchUpdate` requests:**

* `RepeatCellRequest` - Apply formatting across range
* `UpdateCellsRequest` - Cell-by-cell formatting
* `UpdateBordersRequest` - Border styling
* `UpdateDimensionPropertiesRequest` - Row/column properties (width, height)
* `AutoResizeDimensionsRequest` - Auto-fit dimensions

**Conditional Formatting:**

* `AddConditionalFormatRuleRequest`
* `UpdateConditionalFormatRuleRequest`
* `DeleteConditionalFormatRuleRequest`

### 3.4 Data Validation

**Write via `batchUpdate`:**

* `SetDataValidationRequest` - Apply validation rules to range

**Supported criteria:**

* Boolean (checkbox)
* Date validation (between, before, after)
* Number validation (greater than, less than, between)
* Text validation (contains, equals)
* List validation (dropdown from values or range)
* Custom formula validation

### 3.5 Charts

**Write operations:**

* `AddChartRequest` - Insert new chart
* `UpdateChartSpec` - Modify chart configuration
* `UpdateEmbeddedObjectPositionRequest` - Reposition chart
* `UpdateEmbeddedObjectBorderRequest` - Adjust chart borders
* `DeleteEmbeddedObjectRequest` - Remove chart

---

## 4. BATCHUPDATE REQUEST TYPES (Complete List)

Total: 69 request types available

### Data and Values

* `updateCells` - Changes cell content and formatting
* `appendCells` - Adds data after final row
* `repeatCell` - Duplicates cell content across area
* `autoFill` - Extends patterns based on existing data
* `pasteData` - Inserts HTML or delimited data
* `textToColumns` - Splits cell text into columns
* `copyPaste` - Duplicates data to new location
* `cutPaste` - Moves data between locations
* `findReplace` - Searches and substitutes text
* `trimWhitespace` - Removes extra spacing from cells
* `deleteDuplicates` - Removes duplicate rows

### Sheet Management

* `addSheet` - Inserts new sheet
* `updateSheetProperties` - Changes sheet configuration
* `duplicateSheet` - Clones sheet content
* `deleteSheet` - Removes sheet

### Rows and Columns (Dimensions)

* `insertDimension` - Adds rows or columns
* `deleteDimension` - Removes rows or columns
* `appendDimension` - Extends sheet dimensions
* `moveDimension` - Relocates rows/columns
* `updateDimensionProperties` - Adjusts row/column attributes (width, height, hide)
* `autoResizeDimensions` - Adjusts dimensions automatically
* `insertRange` - Adds cells with shift
* `deleteRange` - Removes cells with shift

### Formatting

* `updateBorders` - Modifies cell border styling
* `addBanding` - Creates alternating row styling
* `updateBanding` - Modifies alternating row colors
* `deleteBanding` - Removes alternating row styling
* `addConditionalFormatRule` - Creates conditional formatting
* `updateConditionalFormatRule` - Edits conditional formatting
* `deleteConditionalFormatRule` - Removes conditional formatting

### Cell Operations

* `mergeCells` - Combines adjacent cells
* `unmergeCells` - Separates merged cells
* `setDataValidation` - Applies validation rules

### Charts and Objects

* `addChart` - Inserts chart
* `updateChartSpec` - Changes chart configuration
* `updateEmbeddedObjectPosition` - Repositions charts/images
* `updateEmbeddedObjectBorder` - Adjusts chart/image borders
* `deleteEmbeddedObject` - Removes charts/images

### Filters and Views

* `setBasicFilter` - Enables basic filtering
* `clearBasicFilter` - Removes active filter
* `addFilterView` - Creates filtered view of data
* `updateFilterView` - Modifies filter properties
* `duplicateFilterView` - Copies filter view
* `deleteFilterView` - Deletes filter view
* `addSlicer` - Inserts interactive slicer
* `updateSlicerSpec` - Modifies slicer configuration

### Named and Protected Ranges

* `addNamedRange` - Creates named range
* `updateNamedRange` - Edits named range definition
* `deleteNamedRange` - Removes named range
* `addProtectedRange` - Creates protected area
* `updateProtectedRange` - Modifies protection settings
* `deleteProtectedRange` - Removes protection

### Data Sources (BigQuery, Connected Sheets)

* `addDataSource` - Connects external data source
* `updateDataSource` - Modifies data source connection
* `deleteDataSource` - Removes data source
* `refreshDataSource` - Updates data from source
* `cancelDataSourceRefresh` - Stops ongoing data refresh
* `addTable` - Creates formatted table
* `updateTable` - Edits table properties
* `deleteTable` - Removes table

### Sorting and Manipulation

* `sortRange` - Organizes data by column
* `randomizeRange` - Shuffles row order

### Dimension Groups

* `addDimensionGroup` - Creates collapsible row/column groups
* `updateDimensionGroup` - Modifies group state (collapsed/expanded)
* `deleteDimensionGroup` - Removes dimension grouping

### Spreadsheet Properties

* `updateSpreadsheetProperties` - Modifies spreadsheet-level settings (title, locale, timezone, etc.)

### Developer Metadata

* `createDeveloperMetadata` - Adds custom metadata
* `updateDeveloperMetadata` - Edits custom metadata
* `deleteDeveloperMetadata` - Removes custom metadata

---

## 5. LIMITATIONS

### 5.1 Rate Limits and Quotas

**Per-Minute Quotas:**

* **Read requests:** 300 per minute per project, 60 per minute per user per project
* **Write requests:** 300 per minute per project, 60 per minute per user per project

**No Daily Limits:** Unlimited requests per day if within per-minute quotas

**Size Limits:**

* **Recommended payload:** 2 MB maximum (no hard limit, but performance degrades)
* **Timeout:** 180 seconds per request (returns timeout error after)

**Atomicity:**

* All requests in a batch applied atomically
* If any request fails, entire batch rejected (nothing applied)
* Each batch request (including subrequests) counts as 1 API call

**Error Handling:**

* Exceeding quotas: `429: Too many requests` HTTP status
* Recommended retry: Truncated exponential backoff `min(((2^n)+random_ms), maximum_backoff)`

**Quota Increases:**

* Available via Google Cloud console
* No guarantee of approval

### 5.2 UI Features NOT Accessible via API

**Apps Script and Macros:**

* Cannot execute macros via API (read-only access to Apps Script container)
* Cannot read/write Apps Script code via Sheets API
* Workaround: Macro recorder can generate Apps Script code, but execution requires Apps Script API or manual trigger

**GOOGLEFINANCE Function:**

* **Historical data:** Cannot be accessed via API (returns `#N/A` error in API responses)
* **Current data:** Workaround exists as of May 2022 - use `SpreadsheetApp.getDataRange().getDisplayValues()` in Apps Script to retrieve calculated GOOGLEFINANCE results
* **Official restriction:** Google announced in 2016 that historical GOOGLEFINANCE data not accessible via API
* **Deprecated Finance API:** Google deprecated official Finance API in 2012

**Chart Limitations:**

* Apps Script chart classes don't cover all configuration options
* Complex chart customization may require manual UI tuning after API creation

**Connected Sheets (BigQuery):**

* API can read data from Connected Sheets
* API can apply formatting or build pivot tables
* **Cannot modify underlying BigQuery query** via API
* **Cannot write data back to BigQuery-backed ranges**

**Other Limitations:**

* **Comments system:** Separate from notes; uses different API endpoints (not part of Sheets API v4)
* **Drawing objects:** Limited API support; complex drawings may not be fully accessible
* **Some UI-only features:** Certain advanced UI interactions may not have API equivalents

### 5.3 Conditional Formatting Constraints

**Supported CellFormat properties in conditional formatting:**

* Bold, italic, strikethrough
* Text color (foreground color)
* Background color

**NOT supported (causes 400 error):**

* Underline
* Text alignment
* Borders

### 5.4 Protected Range Constraints

* Editors must already have write access to spreadsheet
* Cannot grant new permissions via protected range API
* Spreadsheet owner automatically added as editor
* Warning-only protection cannot have editors list

---

## 6. SPECIAL CONSIDERATIONS

### 6.1 GOOGLEFINANCE Results

**Official Limitation:** Historical data cannot be downloaded via API

**Workaround (as of May 2022):**

```javascript
// Apps Script workaround
const sheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName("Sheet1");
const values = sheet.getDataRange().getDisplayValues();
// Returns calculated GOOGLEFINANCE values as strings
```

**Status:** Unofficial workaround; may not be supported long-term

### 6.2 Apps Script Access

**What's Possible:**

* Sheets API can trigger Apps Script execution (via Apps Script API, not Sheets API)
* Apps Script can use Spreadsheet service (`SpreadsheetApp`) to access all Sheets features
* Apps Script macros can be recorded to automate Connected Sheets refreshes

**What's Not Possible:**

* Reading Apps Script code via Sheets API v4
* Writing/modifying Apps Script via Sheets API v4
* Executing macros directly via Sheets API v4

### 6.3 Macros

**Macro Recorder:**

* Can record operations (create, edit, delete, refresh Connected Sheets)
* Generates Apps Script code

**Execution:**

* Requires Apps Script API or manual trigger
* Not executable via Sheets API v4

### 6.4 Multi-Account Considerations (for gogcli)

**Identifier Uniqueness:**

* Spreadsheet IDs: Globally unique
* Sheet IDs: Unique within spreadsheet only
* Named range IDs: Unique within spreadsheet only
* Protected range IDs: Unique within spreadsheet only

**Multi-Account Export:**

* No ID collision risk for spreadsheets across accounts
* Sheet IDs, named ranges, protected ranges - scope limited to parent spreadsheet

### 6.5 Timestamp and Timezone Handling

**Spreadsheet Properties:**

* `timeZone` - IANA timezone (e.g., "America/New_York")
* `autoRecalc` - When formulas recalculate (ON_CHANGE, MINUTE, HOUR)

**Date/Time in Cells:**

* Stored as serial numbers (days since December 30, 1899)
* `dateTimeRenderOption=SERIAL_NUMBER` - Returns numeric value
* `dateTimeRenderOption=FORMATTED_STRING` - Returns formatted string (requires `valueRenderOption != FORMATTED_VALUE`)

**Best Practice:** Always read spreadsheet timezone property when interpreting date/time values

---

## 7. API SCOPES

Google Sheets API requires OAuth 2.0 scopes for authorization:

* `https://www.googleapis.com/auth/spreadsheets` - Read/write access to all spreadsheet content
* `https://www.googleapis.com/auth/spreadsheets.readonly` - Read-only access
* `https://www.googleapis.com/auth/drive` - Broader Drive access (includes Sheets)
* `https://www.googleapis.com/auth/drive.readonly` - Read-only Drive access
* `https://www.googleapis.com/auth/drive.file` - Per-file access (user must have explicitly granted access)

---

## 8. SOURCES

### Official Google Documentation

1. [Google Sheets API Reference](https://developers.google.com/workspace/sheets/api/reference/rest) - Main API documentation
2. [Method: spreadsheets.batchUpdate](https://developers.google.com/workspace/sheets/api/reference/rest/v4/spreadsheets/batchUpdate) - batchUpdate documentation
3. [Requests Reference](https://developers.google.com/workspace/sheets/api/reference/rest/v4/spreadsheets/request) - Complete request types list
4. [Cells Reference](https://developers.google.com/workspace/sheets/api/reference/rest/v4/spreadsheets/cells) - Cell properties documentation
5. [Read & Write Cell Values](https://developers.google.com/sheets/api/guides/values) - Values guide
6. [Usage Limits](https://developers.google.com/workspace/sheets/api/limits) - Quotas and rate limits
7. [Conditional Formatting Guide](https://developers.google.com/sheets/api/guides/conditional-format) - Conditional formatting documentation
8. [Named & Protected Ranges](https://developers.google.com/workspace/sheets/api/samples/ranges) - Named and protected ranges guide
9. [Method: spreadsheets.values.batchGet](https://developers.google.com/workspace/sheets/api/reference/rest/v4/spreadsheets.values/batchGet) - batchGet documentation
10. [Method: spreadsheets.values.append](https://developers.google.com/workspace/sheets/api/reference/rest/v4/spreadsheets.values/append) - append documentation

### Third-Party Resources

11. [How to Use Google Sheets API: Complete Guide for 2026](https://coefficient.io/google-sheets-tutorials/how-to-use-google-sheets-api) - Tutorial overview
12. [Google Sheets API Pricing, Limits, & More](https://apipheny.io/google-sheets-api/) - Limits summary
13. [Report: Obtaining Values from GOOGLEFINANCE using Google Apps Script](https://gist.github.com/tanaikech/7bebb7c6d8ed6ddfdd825153ef71c47e) - GOOGLEFINANCE workaround
14. [Google Finance API: Is It Free? Complete Guide for 2025](https://marketxls.com/blog/google-finance-api-essential-tips-for-2024-updated-guide) - Finance API overview

### Community Discussions

15. [Working with Pivot Tables using Google Apps Script](https://hawksey.info/blog/2020/10/working-with-pivot-tables-in-google-sheets-using-google-apps-script/) - Pivot tables guide

---

## 9. KEY TAKEAWAYS FOR GOGCLI

**Full Read/Write Access:**

* Cell values (formatted, unformatted, formulas)
* Cell notes (via `spreadsheets.get`, not `spreadsheets.values`)
* All formatting (text, background, borders, alignment, etc.)
* Data validation rules
* Conditional formatting (limited to bold, italic, strikethrough, colors)
* Named ranges
* Protected ranges (read permissions, create/update protection)
* Charts (create, read, update, delete)
* Filters and filter views
* Pivot tables (via Apps Script or API)

**Limited/Workaround Access:**

* GOOGLEFINANCE calculated values (via Apps Script `getDisplayValues()` workaround)
* Comments (separate API, not part of Sheets API v4)
* Apps Script code (read-only; requires Apps Script API for execution)

**Not Accessible:**

* Apps Script execution via Sheets API (requires Apps Script API)
* GOOGLEFINANCE historical data (deprecated)
* Macro execution (requires Apps Script API or manual trigger)
* Some complex chart configurations (may require manual UI tuning)

**Rate Limits to Respect:**

* 300 read/write requests per minute per project
* 60 requests per minute per user per project
* 2 MB recommended payload size
* 180-second request timeout

**Identifier Scoping:**

* Spreadsheet IDs: Globally unique
* Sheet IDs, named ranges, protected ranges: Unique within spreadsheet only
