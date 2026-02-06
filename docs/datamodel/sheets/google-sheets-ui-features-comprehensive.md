# Google Sheets UI/UX Features - Comprehensive Documentation

**Last Updated**: 2026-02-06

This document catalogs all features available in the Google Sheets web interface, organized for comparison with API and gogcli capabilities.

## 1. Cell Content Types

### 1.1 Basic Data Types

* **Text**: Plain text content, supports Unicode
* **Numbers**: Integers, decimals, negative numbers
* **Dates**: Multiple formats (MM/DD/YYYY, DD/MM/YYYY, ISO 8601)
* **Times**: 12-hour, 24-hour, with seconds
* **Boolean**: TRUE/FALSE values

### 1.2 Formulas

Google Sheets supports **400+ functions** across 14 categories:

| Category | Example Functions |
|----------|-------------------|
| Array | ARRAYFORMULA, FLATTEN, UNIQUE |
| Database | DSUM, DAVERAGE, DCOUNT |
| Date | DATE, TODAY, EDATE, WORKDAY |
| Engineering | BIN2DEC, CONVERT |
| Filter | FILTER, SORT, SORTN |
| Financial | NPV, IRR, PMT, FV |
| Google | GOOGLEFINANCE, GOOGLETRANSLATE, IMAGE |
| Info | ISBLANK, ISERROR, TYPE |
| Logical | IF, IFS, AND, OR, SWITCH |
| Lookup | VLOOKUP, XLOOKUP, INDEX, MATCH |
| Math | SUM, SUMIF, ROUND, RAND |
| Operator | ADD, DIVIDE, EQ, GT |
| Statistical | AVERAGE, MEDIAN, STDEV, CORREL |
| Text | CONCAT, SPLIT, REGEXMATCH, TRIM |

### 1.3 Cell Notes vs Comments

**Cell Notes** (yellow corner indicator):

* Simple text annotations
* View by hovering over cell
* Non-collaborative (no author tracking)
* Insert via: Insert > Note or right-click > Insert note
* No replies or resolution workflow

**Cell Comments** (blue indicator):

* Threaded conversations
* Author attribution and timestamps
* @mention users for notifications
* Task assignment capability
* Replies and resolution workflow
* Insert via: Insert > Comment or Ctrl+Alt+M

### 1.4 Checkboxes

* Insert via: Insert > Checkbox
* Returns TRUE (checked) / FALSE (unchecked)
* Custom checked/unchecked values supported
* Compatible with formulas, charts, filters, pivot tables
* Use in conditional logic: `=IF(A1, "Yes", "No")`

### 1.5 Dropdown Lists

**From Range**:

```
Data > Data validation > Dropdown (from a range)
=A1:A10 or named range
```

**From Custom Values**:

```
Data > Data validation > Dropdown
Enter comma-separated values
```

**Multi-select Dropdowns** (chip format):

* Allow selecting multiple items
* Display as chips/tags in cell

### 1.6 Images

**IMAGE Function**:

```
=IMAGE(url, [mode], [height], [width])
```

Modes:

* 1 = Resize to fit cell (default)
* 2 = Stretch to fill cell
* 3 = Original size
* 4 = Custom dimensions

**Insert Image in Cell**: Insert > Image > Image in cell

* Embeds image data directly
* Moves with cell during sort/filter

**Insert Image Over Cells**: Insert > Image > Image over cells

* Floating image
* Does not move with data

---

## 2. Dynamic Functions (Special Interest)

### 2.1 GOOGLEFINANCE

Real-time and historical financial data:

```
=GOOGLEFINANCE("NASDAQ:AAPL", "price")           // Current price
=GOOGLEFINANCE("NASDAQ:AAPL", "high")            // Today's high
=GOOGLEFINANCE("USD/EUR")                         // Currency rate
=GOOGLEFINANCE("AAPL", "price", DATE(2025,1,1), DATE(2025,12,31), "DAILY")  // Historical
```

Attributes: price, high, low, open, close, volume, marketcap, pe, eps, high52, low52

**API Note**: Historical data returns #N/A via API (Google restriction since 2016).

### 2.2 GOOGLETRANSLATE

```
=GOOGLETRANSLATE(text, source_lang, target_lang)
=GOOGLETRANSLATE(A1, "en", "es")    // English to Spanish
=GOOGLETRANSLATE(A1, "auto", "fr")  // Auto-detect to French
```

Supports 100+ languages.

### 2.3 IMPORT Functions Family

All IMPORT functions have shared limits:

* 50 MB data limit per spreadsheet
* 50 URL fetch calls per spreadsheet
* Auto-refresh every hour

**IMPORTHTML** - Web page tables/lists:

```
=IMPORTHTML(url, "table", index)
=IMPORTHTML("https://example.com/data", "table", 1)
```

**IMPORTXML** - XPath queries:

```
=IMPORTXML(url, xpath_query)
=IMPORTXML("https://example.com/feed.xml", "//item/title")
```

**IMPORTDATA** - CSV/TSV files:

```
=IMPORTDATA(url)
=IMPORTDATA("https://example.com/data.csv")
```

**IMPORTFEED** - RSS/ATOM feeds:

```
=IMPORTFEED(url, [query], [headers], [num_items])
=IMPORTFEED("https://blog.example.com/feed", "items title", FALSE, 10)
```

**IMPORTRANGE** - Cross-spreadsheet linking:

```
=IMPORTRANGE(spreadsheet_url, range_string)
=IMPORTRANGE("https://docs.google.com/spreadsheets/d/...", "Sheet1!A1:B10")
```

Requires one-time permission grant on first use.

### 2.4 SPARKLINE

Miniature in-cell charts:

```
=SPARKLINE(data, [options])
=SPARKLINE(A1:A10)                                    // Basic line
=SPARKLINE(A1:A10, {"charttype","bar"})               // Bar chart
=SPARKLINE(A1:A10, {"charttype","column";"color","blue"})
=SPARKLINE(GOOGLEFINANCE("AAPL","price",TODAY()-30,TODAY(),"DAILY"))  // Stock sparkline
```

Types: line, bar, column, winloss

---

## 3. Data Validation

### 3.1 Validation Types

| Type | Description | Example |
|------|-------------|---------|
| Dropdown from range | List from cells | =A1:A10 |
| Dropdown from values | Manual list | "Option1,Option2,Option3" |
| Checkbox | TRUE/FALSE toggle | Custom values optional |
| Text contains | Substring match | "must contain" |
| Text does not contain | Exclude substring | |
| Text is email | Valid email format | |
| Text is URL | Valid URL format | |
| Date is valid | Parseable date | |
| Date is before/after/between | Date range | |
| Number greater/less/between | Numeric range | |
| Custom formula | Any formula returning TRUE/FALSE | =LEN(A1)>5 |

### 3.2 Custom Formula Validation Examples

```
=LEN(A1) >= 8                           // Minimum length
=REGEXMATCH(A1, "@company\.com$")       // Email domain
=AND(A1>=0, A1<=100)                    // Range
=ISNUMBER(A1)                           // Must be number
=ISDATE(A1)                             // Must be date
```

### 3.3 Validation Behaviors

* **Reject input**: Strict enforcement, invalid data blocked
* **Show warning**: Allow override with warning
* **Show help text**: Custom message when cell selected

---

## 4. Formatting

### 4.1 Cell Formatting

| Property | Options |
|----------|---------|
| Font family | Arial, Times, Roboto, etc. |
| Font size | 6pt - 400pt |
| Bold | On/Off |
| Italic | On/Off |
| Underline | On/Off |
| Strikethrough | On/Off |
| Text color | Any color (hex/RGB) |
| Background color | Any color |
| Horizontal align | Left, Center, Right |
| Vertical align | Top, Middle, Bottom |
| Text wrap | Overflow, Wrap, Clip |
| Text rotation | 0-90 degrees or vertical |
| Borders | Style, color, width per side |

### 4.2 Number Formats

| Format | Example |
|--------|---------|
| Automatic | Detects type |
| Plain text | Forces text |
| Number | 1,234.56 |
| Percent | 12.5% |
| Scientific | 1.23E+03 |
| Accounting | ($1,234.56) |
| Currency | $1,234.56 |
| Date | 01/29/2026 |
| Time | 2:30:00 PM |
| Duration | 12:30:45 |
| Custom | User-defined pattern |

**Custom Number Format Patterns**:

```
[Green]$#,##0.00;[Red]-$#,##0.00    // Green positive, red negative
0.00%                                // Percentage with 2 decimals
#,##0" units"                        // Number with suffix
```

### 4.3 Conditional Formatting

**Rule Types**:

* Cell is empty/not empty
* Text contains/does not contain/starts with/ends with/is exactly
* Date is (before/after/between/equal)
* Greater than/less than/between/equal to
* Custom formula is

**Formats Available**:

* Background color
* Text color
* Bold, Italic, Strikethrough
* **NOT available**: Underline, alignment, borders

### 4.4 Alternating Colors

Format > Alternating colors:

* Header color (optional)
* Color 1 (odd rows)
* Color 2 (even rows)
* Footer color (optional)

---

## 5. Sheet Structure

### 5.1 Sheets/Tabs

* Maximum 200 sheets per spreadsheet
* Operations: Create, rename, duplicate, delete, hide
* Tab colors for organization
* Sheet-level protection

### 5.2 Named Ranges

Data > Named ranges:

```
Name: sales_data
Range: Sheet1!A1:D100
```

Rules:

* Max 250 characters
* Cannot start with number or "true"/"false"
* No spaces or punctuation (use underscores)
* Cannot resemble cell addresses

Usage in formulas: `=SUM(sales_data)`

### 5.3 Protected Ranges/Sheets

Data > Protected sheets and ranges:

* Show warning when editing (soft)
* Restrict who can edit (hard):
  * Only you
  * Custom list of users

### 5.4 Structural Operations

* **Hide rows/columns**: Right-click > Hide
* **Freeze panes**: View > Freeze
* **Merge cells**: Format > Merge cells
* **Group rows/columns**: Data > Group
* **Insert/Delete rows/columns**: Right-click or Insert menu

---

## 6. Advanced Features

### 6.1 Pivot Tables

Insert > Pivot table:

* Rows: Grouping dimension
* Columns: Column dimension
* Values: Aggregation (SUM, COUNT, AVG, etc.)
* Filters: Data filtering

Features:

* Calculated fields
* Date/number grouping
* Show as % of total
* Drill-down

### 6.2 Charts

20+ chart types:

**Basic**: Column, Bar, Line, Area, Pie, Combo

**Statistical**: Scatter, Histogram, Candlestick, Waterfall

**Specialized**: Org chart, Tree map, Geo chart, Timeline, Gauge

### 6.3 Filters and Filter Views

**Basic Filter** (Data > Create a filter):

* Affects all users
* Persistent

**Filter Views** (Data > Filter views):

* Named, saveable filters
* Personal or shared
* Multiple simultaneous views

### 6.4 Slicers

Data > Add a slicer:

* Interactive filter controls
* Control multiple charts/pivots
* Visual dashboard elements

### 6.5 Connected Sheets

Data > Data connectors > Connect to BigQuery:

* Access BigQuery data in Sheets
* Up to 100,000 rows in pivot tables
* Scheduled refresh

---

## 7. Collaboration

### 7.1 Sharing

Share button > Access levels:

* **Owner**: Full control, can delete
* **Editor**: Modify content and structure
* **Commenter**: View and add comments
* **Viewer**: Read-only

### 7.2 Version History

File > Version history:

* All edits with timestamps
* Author attribution with color coding
* Restore previous versions
* Name versions for milestones
* Cell-level edit history (right-click cell)

### 7.3 Comments and Tasks

* Threaded discussions
* @mention notifications
* Task assignment
* Resolve/reopen workflow

---

## 8. Automation

### 8.1 Apps Script

Extensions > Apps Script:

* JavaScript-based automation
* Full access to Sheets API
* Custom menus and dialogs
* External API integration

### 8.2 Macros

Tools > Macros > Record macro:

* Record UI actions
* Assign keyboard shortcuts
* Stored as Apps Script

### 8.3 Triggers

**Simple Triggers**:

* `onOpen(e)` - Spreadsheet opened
* `onEdit(e)` - Cell edited

**Installable Triggers**:

* Time-driven (hourly, daily, weekly)
* Form submit
* Change (structure modifications)

### 8.4 Custom Functions

Define in Apps Script, use in cells:

```javascript
function DOUBLE(x) {
  return x * 2;
}
```

Use: `=DOUBLE(A1)`

### 8.5 Add-ons

Extensions > Add-ons:

* Third-party extensions
* Workspace Marketplace
* Per-user installation

---

## 9. Import/Export

### 9.1 Import Formats

* Excel (.xlsx, .xls)
* CSV, TSV
* PDF (limited)
* HTML tables (via IMPORTHTML)

### 9.2 Export Formats

File > Download:

* Excel (.xlsx)
* PDF
* CSV (current sheet)
* TSV
* HTML
* ODS (OpenDocument)

### 9.3 Publish to Web

File > Share > Publish to web:

* Live updating embed
* Or static snapshot
* Link or embed code

---

## 10. Mobile and Offline

### 10.1 Mobile Apps

* iOS and Android native apps
* Full editing capabilities
* Camera integration (scan documents)

### 10.2 Offline Mode

* Requires Chrome browser
* Enable in Google Drive settings
* Automatic sync when online

---

## See Also

* `google-sheets-feature-comparison.yaml` - Machine-readable feature mapping
* `google-sheets-feature-comparison-tables.md` - Comparison tables
* `google-sheets-gogcli-data-handling.md` - How gogcli handles Sheets
