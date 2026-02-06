# gogcli Google Sheets Data Handling

How the gogcli tool handles Google Sheets API data structures.

**Source**: Analysis of https://github.com/steipete/gogcli source code
**Analysis Date**: 2026-02-06

## Commands Overview

| Command | Purpose | API Method |
|---------|---------|------------|
| `gog sheets get` | Read cell values | `spreadsheets.values.get` |
| `gog sheets update` | Write cell values | `spreadsheets.values.update` |
| `gog sheets append` | Add rows to table | `spreadsheets.values.append` |
| `gog sheets clear` | Remove cell values | `spreadsheets.values.clear` |
| `gog sheets format` | Apply cell formatting | `spreadsheets.batchUpdate` |
| `gog sheets metadata` | Get spreadsheet info | `spreadsheets.get` |
| `gog sheets create` | Create new spreadsheet | `spreadsheets.create` |
| `gog sheets copy` | Copy spreadsheet | Drive API `files.copy` |
| `gog sheets export` | Export to XLSX/PDF/CSV | Drive API export |

## A1 Notation Parsing

gogcli includes a robust A1 notation parser (`sheets_a1.go`):

### Supported Formats

```
Sheet1!A1:B10          # Standard range
'My Sheet'!A1:B10      # Quoted sheet name (spaces)
Sheet1!A:C             # Full columns
Sheet1!1:5             # Full rows
$A$1                   # Absolute reference
$A1, A$1               # Mixed references
A1                     # Single cell (no sheet = active sheet)
```

### Key Functions

```go
parseA1Range(a1 string) (*A1Range, error)
parseA1Cell(cell string) (*A1Cell, error)
colLettersToIndex(letters string) int
splitA1Sheet(a1 string) (sheetName, rangeSpec string)
unquoteSheetName(name string) string
```

### Shell Escape Handling

The `cleanRange()` function handles bash history expansion:

```go
// Removes \! to allow ! in range specs
// Example: "'Sheet 1'\!A1" → "'Sheet 1'!A1"
```

## Value Input/Output

### Reading Values

```bash
gog sheets get <spreadsheet_id> [range]

# Options:
--dimension ROWS|COLUMNS    # Major dimension
--render FORMATTED_VALUE    # UI display format (default)
--render UNFORMATTED_VALUE  # Raw underlying value
--render FORMULA            # Show formula text
--json                      # JSON output
```

### Writing Values

```bash
gog sheets update <spreadsheet_id> <range> [values]

# Value input options:
--values-json '[["A1","B1"],["A2","B2"]]'    # JSON 2D array
"row1col1|row1col2,row2col1|row2col2"        # Pipe-delimited

# Input interpretation:
--input USER_ENTERED    # Parse as UI input (default, interprets formulas)
--input RAW             # Literal values only
```

### Appending Values

```bash
gog sheets append <spreadsheet_id> <range> [values]

# Options:
--insert INSERT_ROWS    # Add new rows (default)
--insert OVERWRITE      # Overwrite existing data
--copy-validation-from <range>  # Copy data validation rules
```

### Clearing Values

```bash
gog sheets clear <spreadsheet_id> <range>
```

## Data Structures

### Output Formats

**JSON Mode** (`--json`):

```json
{
  "range": "Sheet1!A1:B2",
  "majorDimension": "ROWS",
  "values": [
    ["Header1", "Header2"],
    ["Value1", "Value2"]
  ]
}
```

**Text Mode** (default):

```
Header1    Header2
Value1     Value2
```

**Metadata Output**:

```
ID        1234567890abcdef
Title     My Spreadsheet
Locale    en_US
Timezone  America/New_York
URL       https://docs.google.com/spreadsheets/d/...

Sheets:
ID           Title       Rows    Columns
0            Sheet1      1000    26
123456789    Data        500     10
```

### Input Formats

**JSON Array** (`--values-json`):

```json
[
  ["row1col1", "row1col2"],
  ["row2col1", "row2col2"]
]
```

**Pipe-Delimited** (CLI argument):

```
"row1col1|row1col2,row2col1|row2col2"
```

* Pipe (`|`) separates cells in a row
* Comma (`,`) separates rows

## Cell Formatting

### Format Command

```bash
gog sheets format <spreadsheet_id> <range> --format-json <json> --format-fields <fields>
```

### Format JSON Structure

Uses Google Sheets CellFormat object:

```json
{
  "textFormat": {
    "bold": true,
    "italic": false,
    "strikethrough": false,
    "underline": false,
    "fontSize": 12,
    "fontFamily": "Arial",
    "foregroundColor": {"red": 1, "green": 0, "blue": 0}
  },
  "backgroundColor": {"red": 1, "green": 1, "blue": 0.8},
  "horizontalAlignment": "CENTER",
  "verticalAlignment": "MIDDLE",
  "wrapStrategy": "WRAP",
  "numberFormat": {
    "type": "CURRENCY",
    "pattern": "$#,##0.00"
  }
}
```

### Format Fields

The `--format-fields` parameter specifies which properties to apply:

```bash
# Apply only bold
gog sheets format <id> A1:B10 \
  --format-json '{"textFormat":{"bold":true}}' \
  --format-fields "textFormat.bold"

# Apply number format
gog sheets format <id> A1:B10 \
  --format-json '{"numberFormat":{"type":"CURRENCY"}}' \
  --format-fields "numberFormat.type"
```

Supports both full paths and shorthand:

* `userEnteredFormat.textFormat.bold` (full)
* `textFormat.bold` (shorthand)

### Field Mask Implementation

gogcli uses `ForceSendFields` for zero-value handling:

```go
// sheets_format_fields.go
// Dynamically sets ForceSendFields based on --format-fields
// Prevents zero values from being omitted
```

## Data Validation

### Copy Validation

gogcli can copy existing data validation rules between ranges:

```bash
gog sheets update <id> Sheet1!A1:B10 \
  --values-json '[["val1","val2"]]' \
  --copy-validation-from Sheet1!A15
```

This uses `CopyPasteRequest` with `PASTE_DATA_VALIDATION` type.

**Limitation**: Cannot create new validation rules, only copy existing ones.

## Spreadsheet Lifecycle

### Create

```bash
gog sheets create --title "New Spreadsheet" --sheets "Sheet1,Sheet2,Data"
```

Returns:

* Spreadsheet ID
* Title
* Web URL

### Metadata

```bash
gog sheets metadata <spreadsheet_id>
```

Returns:

* ID, Title, Locale, Timezone
* List of sheets with ID, Title, Row count, Column count

### Copy

```bash
gog sheets copy <spreadsheet_id> --title "Copy of Spreadsheet" [--parent folder_id]
```

Uses Drive API `files.copy`.

### Export

```bash
gog sheets export <spreadsheet_id> --format xlsx|pdf|csv --out filename
```

Uses Drive API export. Default format: XLSX.

## API Optimization

### Value Render Options

| Option | Returns | Use Case |
|--------|---------|----------|
| `FORMATTED_VALUE` | Display string | Human-readable output |
| `UNFORMATTED_VALUE` | Raw value | Programmatic processing |
| `FORMULA` | Formula text | Audit formulas |

### Value Input Options

| Option | Behavior |
|--------|----------|
| `USER_ENTERED` | Parse like UI input (formulas execute) |
| `RAW` | Store literal strings |

### Major Dimension

| Option | Structure |
|--------|-----------|
| `ROWS` | `[[row1...], [row2...]]` |
| `COLUMNS` | `[[col1...], [col2...]]` |

## Key Source Files

| File | Purpose |
|------|---------|
| `sheets.go` | Main command implementations |
| `sheets_a1.go` | A1 notation parser |
| `sheets_format.go` | Format command, RepeatCellRequest |
| `sheets_format_fields.go` | Field mask handling |
| `sheets_validation.go` | Data validation copy |
| `googleapi/sheets.go` | API service wrapper |

## Limitations

### Not Implemented in gogcli

| Category | Missing Features |
|----------|------------------|
| **Cell Content** | Notes, comments, rich text |
| **Sheet Operations** | Add/delete/rename sheets after creation |
| **Row/Column Ops** | Insert, delete, resize, hide |
| **Structure** | Named ranges, protected ranges, freeze, merge |
| **Advanced** | Charts, pivot tables, filters, sorting, slicers |
| **Formatting** | Borders, conditional formatting, alternating colors |
| **Multi-range** | batchGet, batchUpdate (multiple ranges) |

### Design Focus

gogcli focuses on **data manipulation**:

* Read/write cell values
* Basic cell formatting
* Copy data validation
* Spreadsheet lifecycle (create, copy, export)

It does **not** focus on:

* Sheet structure management
* Advanced formatting
* Visualization (charts, pivots)
* Automation (macros, triggers)

## Implications for Data Model

1. **Value Rendering**: Always specify render option for consistent data
2. **Formula Handling**: Use `USER_ENTERED` to interpret, `RAW` for literal
3. **Date Handling**: API returns serial numbers; use `FORMATTED_STRING` for human-readable
4. **Validation**: Can only copy existing rules, not create new
5. **Multi-range**: Requires multiple commands (no batch support)
6. **Notes/Comments**: Not accessible via gogcli; use API directly

## Example Workflows

### Read and Write Cycle

```bash
# Read current values
gog sheets get ABC123 'Sheet1!A1:C10' --json > data.json

# Modify data.json...

# Write back
gog sheets update ABC123 'Sheet1!A1:C10' \
  --values-json "$(cat data.json | jq '.values')"
```

### Create Formatted Report

```bash
# Create spreadsheet
ID=$(gog sheets create --title "Report" --sheets "Summary,Data" --json | jq -r '.spreadsheetId')

# Add data
gog sheets update $ID 'Summary!A1:B3' \
  --values-json '[["Metric","Value"],["Total","1000"],["Average","250"]]'

# Format header
gog sheets format $ID 'Summary!A1:B1' \
  --format-json '{"textFormat":{"bold":true},"backgroundColor":{"red":0.9,"green":0.9,"blue":0.9}}' \
  --format-fields "textFormat.bold,backgroundColor"
```

### Export for Distribution

```bash
# Export to Excel
gog sheets export ABC123 --format xlsx --out report.xlsx

# Export to PDF
gog sheets export ABC123 --format pdf --out report.pdf
```
