# Google Sheets Feature Comparison Tables

Generated from `google-sheets-feature-comparison.yaml` on 2026-02-06.

## Summary Statistics

| Metric | Count |
|--------|-------|
| **Total Features** | 156 |
| **Categories** | 12 |

### Support by Interface

| Interface | Full | Partial | Read-Only | Workaround | None |
|-----------|------|---------|-----------|------------|------|
| **UI** | 140 | 0 | 0 | 0 | 16 |
| **API** | 98 | 12 | 10 | 2 | 18 |
| **gogcli** | 32 | 8 | 8 | 0 | 108 |

---

## 1. Cell Content Types

| Feature | UI | API | gogcli | Notes |
|---------|:--:|:---:|:------:|-------|
| Text values | ✅ | ✅ | ✅ | ValueInputOption=RAW for literal text |
| Numeric values | ✅ | ✅ | ✅ | |
| Date values | ✅ | ✅ | ✅ | API returns serial numbers |
| Time values | ✅ | ✅ | ✅ | |
| Formulas | ✅ | ✅ | ✅ | `--render FORMULA` to read |
| **Cell notes** | ✅ | ✅ | ❌ | API: CellData.note field |
| **Cell comments (threaded)** | ✅ | ⚠️ | ❌ | Via Drive API, not Sheets API |
| Checkboxes | ✅ | ✅ | ⚠️ | gogcli can copy, not create |
| Dropdown lists (from range) | ✅ | ✅ | ⚠️ | gogcli can copy validation |
| Dropdown lists (custom) | ✅ | ✅ | ⚠️ | gogcli can copy validation |
| Multi-select dropdowns | ✅ | ✅ | ❌ | |
| Images in cells | ✅ | ⚠️ | ❌ | IMAGE() function works |
| Images over cells | ✅ | ❌ | ❌ | UI-only feature |
| Hyperlinks | ✅ | ✅ | ✅ | HYPERLINK() function |
| Rich text (mixed formatting) | ✅ | ✅ | ❌ | API: textFormatRuns |

**Legend**: ✅ Full | ⚠️ Partial | 📖 Read-only | 🔧 Workaround | ❌ None

---

## 2. Dynamic Functions (Real-time Data)

| Feature | UI | API | gogcli | Notes |
|---------|:--:|:---:|:------:|-------|
| GOOGLEFINANCE (current prices) | ✅ | 📖 | 📖 | Can read calculated values |
| **GOOGLEFINANCE (historical)** | ✅ | 🔧 | 📖 | API returns #N/A since 2016; Apps Script workaround |
| GOOGLETRANSLATE | ✅ | 📖 | 📖 | Can read translated results |
| IMPORTHTML | ✅ | 📖 | 📖 | 50 URL fetch limit |
| IMPORTXML | ✅ | 📖 | 📖 | |
| IMPORTDATA | ✅ | 📖 | 📖 | 50MB data limit |
| IMPORTFEED | ✅ | 📖 | 📖 | |
| IMPORTRANGE | ✅ | 📖 | 📖 | Requires UI permission grant |
| IMAGE function | ✅ | ✅ | ✅ | =IMAGE(url, mode, height, width) |
| SPARKLINE | ✅ | ✅ | ✅ | line, bar, column, winloss types |

**Key Finding**: Dynamic functions execute server-side. API can read results but cannot trigger recalculation or access historical GOOGLEFINANCE data directly.

---

## 3. Data Validation

| Feature | UI | API | gogcli | Notes |
|---------|:--:|:---:|:------:|-------|
| Number validation | ✅ | ✅ | ⚠️ | gogcli: `--copy-validation-from` |
| Date validation | ✅ | ✅ | ⚠️ | |
| Text validation | ✅ | ✅ | ⚠️ | |
| Custom formula validation | ✅ | ✅ | ⚠️ | e.g., =REGEXMATCH() |
| Reject invalid input | ✅ | ✅ | ⚠️ | |
| Show validation help text | ✅ | ✅ | ⚠️ | |

**gogcli Limitation**: Can only copy existing validation rules between ranges, cannot create new validation rules.

---

## 4. Cell Formatting

| Feature | UI | API | gogcli | Notes |
|---------|:--:|:---:|:------:|-------|
| Font family | ✅ | ✅ | ✅ | `gog sheets format` |
| Font size | ✅ | ✅ | ✅ | |
| Bold | ✅ | ✅ | ✅ | `--format-fields textFormat.bold` |
| Italic | ✅ | ✅ | ✅ | |
| Underline | ✅ | ✅ | ✅ | NOT in conditional formatting |
| Strikethrough | ✅ | ✅ | ✅ | |
| Text color | ✅ | ✅ | ✅ | |
| Background color | ✅ | ✅ | ✅ | |
| Text alignment | ✅ | ✅ | ✅ | NOT in conditional formatting |
| Text wrapping | ✅ | ✅ | ✅ | |
| Text rotation | ✅ | ✅ | ✅ | |
| **Cell borders** | ✅ | ✅ | ❌ | gogcli does not expose |
| Number formats | ✅ | ✅ | ✅ | CURRENCY, PERCENT, etc. |
| Conditional formatting | ✅ | ⚠️ | ❌ | API: no underline/alignment/borders |
| Alternating row colors | ✅ | ✅ | ❌ | |

**Conditional Formatting API Limitation**: Cannot apply underline, alignment, or borders via conditional formatting rules (returns 400 error).

---

## 5. Sheet Structure

| Feature | UI | API | gogcli | Notes |
|---------|:--:|:---:|:------:|-------|
| Multiple sheets/tabs | ✅ | ✅ | ⚠️ | gogcli: create with `--sheets`, no add/remove after |
| Sheet rename | ✅ | ✅ | ❌ | |
| Sheet delete | ✅ | ✅ | ❌ | |
| Sheet duplicate | ✅ | ✅ | ❌ | |
| Sheet reorder | ✅ | ✅ | ❌ | |
| **Named ranges** | ✅ | ✅ | ❌ | |
| **Protected ranges** | ✅ | ✅ | ❌ | |
| Protected sheets | ✅ | ✅ | ❌ | |
| Hidden rows/columns | ✅ | ✅ | ❌ | |
| Hidden sheets | ✅ | ✅ | ❌ | |
| Freeze panes | ✅ | ✅ | ❌ | |
| Merged cells | ✅ | ✅ | ❌ | |
| Insert rows/columns | ✅ | ✅ | ❌ | |
| Delete rows/columns | ✅ | ✅ | ❌ | |
| Resize rows/columns | ✅ | ✅ | ❌ | |

**gogcli Focus**: Data operations only; no structural modifications after creation.

---

## 6. Advanced Features

| Feature | UI | API | gogcli | Notes |
|---------|:--:|:---:|:------:|-------|
| **Pivot tables** | ✅ | ✅ | ❌ | 100k row limit for Connected Sheets |
| Charts - basic | ✅ | ✅ | ❌ | Column, bar, line, area, pie |
| Charts - advanced | ✅ | ✅ | ❌ | Scatter, histogram, candlestick, geo |
| Filters | ✅ | ✅ | ❌ | |
| Filter views | ✅ | ✅ | ❌ | |
| Slicers | ✅ | ✅ | ❌ | |
| Sorting | ✅ | ✅ | ❌ | |
| Find and replace | ✅ | ✅ | ❌ | |
| Auto-fill | ✅ | ✅ | ❌ | |
| Connected Sheets (BigQuery) | ✅ | ⚠️ | ❌ | API read-only; can't modify queries |

---

## 7. Collaboration

| Feature | UI | API | gogcli | Notes |
|---------|:--:|:---:|:------:|-------|
| Share with users | ✅ | ✅ | ❌ | Via Drive API |
| Share with link | ✅ | ✅ | ❌ | Via Drive API |
| Permission levels | ✅ | ✅ | ❌ | Owner/Editor/Commenter/Viewer |
| Version history | ✅ | ⚠️ | ❌ | Via Drive API revisions |
| **Cell-level edit history** | ✅ | ❌ | ❌ | UI-only feature |

---

## 8. Automation & Scripts

| Feature | UI | API | gogcli | Notes |
|---------|:--:|:---:|:------:|-------|
| Apps Script | ✅ | ⚠️ | ❌ | Separate Apps Script API |
| **Macros (record)** | ✅ | ❌ | ❌ | UI-only |
| Macros (execute) | ✅ | 🔧 | ❌ | Via Apps Script API |
| Custom functions | ✅ | ❌ | ❌ | Defined in Apps Script |
| Triggers (time-driven) | ✅ | ❌ | ❌ | Apps Script feature |
| Triggers (onEdit) | ✅ | ❌ | ❌ | Apps Script feature |
| Add-ons | ✅ | ❌ | ❌ | UI-only |

**Key Limitation**: Sheets API cannot execute macros or Apps Script. Use separate Apps Script API for automation.

---

## 9. Spreadsheet Lifecycle

| Feature | UI | API | gogcli | Notes |
|---------|:--:|:---:|:------:|-------|
| Create spreadsheet | ✅ | ✅ | ✅ | `gog sheets create` |
| Create with initial sheets | ✅ | ✅ | ✅ | `--sheets 'Sheet1,Sheet2'` |
| Copy spreadsheet | ✅ | ✅ | ✅ | `gog sheets copy` (Drive API) |
| Delete spreadsheet | ✅ | ✅ | ✅ | `gog drive delete` |
| Get metadata | ✅ | ✅ | ✅ | `gog sheets metadata` |
| Export to XLSX | ✅ | ✅ | ✅ | `gog sheets export --format xlsx` |
| Export to PDF | ✅ | ✅ | ✅ | `gog sheets export --format pdf` |
| Export to CSV | ✅ | ✅ | ✅ | `gog sheets export --format csv` |

---

## 10. Data Operations

| Feature | UI | API | gogcli | Notes |
|---------|:--:|:---:|:------:|-------|
| Read single range | ✅ | ✅ | ✅ | `gog sheets get` |
| Read multiple ranges | ✅ | ✅ | ❌ | batchGet not in gogcli |
| Write single range | ✅ | ✅ | ✅ | `gog sheets update` |
| Write multiple ranges | ✅ | ✅ | ❌ | batchUpdate not in gogcli |
| Append rows | ✅ | ✅ | ✅ | `gog sheets append` |
| Clear range | ✅ | ✅ | ✅ | `gog sheets clear` |
| Read formulas | ✅ | ✅ | ✅ | `--render FORMULA` |
| Read formatted values | ✅ | ✅ | ✅ | `--render FORMATTED_VALUE` |
| Read unformatted values | ✅ | ✅ | ✅ | `--render UNFORMATTED_VALUE` |
| Major dimension control | n/a | ✅ | ✅ | `--dimension ROWS\|COLUMNS` |

---

## 11. Output & Input Formats (gogcli-specific)

| Feature | Description | gogcli Support |
|---------|-------------|----------------|
| JSON output | Structured JSON response | ✅ `--json` |
| Text output | Human-readable tables | ✅ Default |
| JSON array input | 2D array values | ✅ `--values-json` |
| Pipe-delimited input | CLI-friendly format | ✅ `'a\|b,c\|d'` |

---

## Key Gaps Summary

### gogcli Missing Features (High Impact)

| Category | Features |
|----------|----------|
| Cell Content | Notes, comments, rich text |
| Structure | Sheet add/delete/rename, rows/columns, merge, freeze |
| Data | Named ranges, protected ranges, sorting, filters |
| Visualization | Charts, pivot tables, conditional formatting |
| Multi-range | batchGet, batchUpdate |

### API Limitations

| Feature | Limitation |
|---------|------------|
| GOOGLEFINANCE historical | Returns #N/A (since 2016) |
| Apps Script execution | Separate API required |
| Macros | Cannot record via API |
| Cell-level history | UI-only |
| Floating images | UI-only |
| Conditional format styles | No underline, alignment, borders |

### What gogcli Does Well

| Area | Strength |
|------|----------|
| Data CRUD | Full get/update/append/clear support |
| Value rendering | Formulas, formatted, unformatted |
| Cell formatting | Comprehensive via JSON |
| Lifecycle | Create, copy, export (XLSX/PDF/CSV) |
| A1 notation | Robust parser with quoted sheet names |
| Validation copy | Copy existing rules between ranges |
