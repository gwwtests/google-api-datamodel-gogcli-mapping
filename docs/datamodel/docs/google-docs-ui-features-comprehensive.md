# Google Docs Web UI Features - Comprehensive Reference

**Research Date:** 2026-02-05
**Purpose:** Catalog all Google Docs web UI features with API support status for gogcli integration

## Executive Summary

Google Docs provides extensive UI features, most of which are accessible via the Google Docs API v1. Key limitations include: checkbox state detection, programmatic acceptance/rejection of suggestions (read-only in API), and limited smart chip API support (person/date chips readable but limited write operations).

---

## 1. Editing Modes

### 1.1 Mode Types

* **Editing Mode** (default) - Direct document modification with full permissions
* **Suggesting Mode** - Track changes equivalent, creates `SuggestedTextStyle` and `SuggestedDeletionIds`/`SuggestedInsertionIds` annotations
* **Viewing Mode** - Read-only, prevents modifications until mode change

### 1.2 API Support: Suggesting Mode

**Status:** ✅ Partial Support

* **Reading Suggestions:** `documents.get` with `SuggestionsViewMode` parameter
  * `SUGGESTIONS_INLINE` - Shows pending edits (provides correct indexes for batchUpdate)
  * `PREVIEW_WITH_SUGGESTIONS_ACCEPTED` - Preview with all accepted
  * `PREVIEW_WITHOUT_SUGGESTIONS` - Preview with all rejected
* **Creating Suggestions:** Supported via `WriteControl.requiredRevisionId` in batchUpdate
* **Accepting/Rejecting:** ❌ No direct API methods (UI-only as of 2026-02-05)
  * Workaround: Re-apply suggested changes as direct edits

**API Documentation:**

* [Work with suggestions | Google Docs API](https://developers.google.com/workspace/docs/api/how-tos/suggestions)

**Sources:**

* [Suggest edits in Google Docs - Computer](https://support.google.com/docs/answer/6033474?hl=en&co=GENIE.Platform%3DDesktop)
* [How to Track Changes in Google Docs [2026 Guide]](https://spreadsheetpoint.com/how-to-track-changes-in-google-docs/)

---

## 2. Comments and Collaboration

### 2.1 Features

* **Adding Comments** - Attach to specific text ranges or document elements
* **Reply Threads** - Nested comment conversations
* **Resolving Comments** - Mark discussions as complete
* **@Mentions in Comments** - Notify specific users via email
* **Comment History** - View all comment activity and changes

### 2.2 API Support

**Status:** ✅ Full Support (via Drive API, not Docs API)

* **API Location:** Google Drive API v3 `comments` resource
* **Methods:**
  * `comments.create` - Add comment to file
  * `comments.list` - Retrieve all comments
  * `comments.get` - Get specific comment
  * `comments.update` - Modify comment (e.g., resolve)
  * `comments.delete` - Remove comment
  * `replies.create/list/update/delete` - Manage reply threads

**Key Property for Resolution:**

```json
{
  "resolved": true/false
}
```

**API Documentation:**

* [REST Resource: comments | Google Drive](https://developers.google.com/drive/api/reference/rest/v3/comments)
* [Manage comments | Google Drive](https://developers.google.com/drive/api/guides/manage-comments)

**Sources:**

* [Google Docs Collaboration: Writers, Authors, & Content Teams](https://wordable.io/google-docs-collaboration/)

---

## 3. Content Insertion

### 3.1 Tables

**Features:**

* Insert tables (specify rows × columns)
* Merge cells (horizontal/vertical)
* Table properties (borders, padding, alignment)
* Insert/delete rows and columns
* Insert content into table cells

**API Support:** ✅ Full Support

* **Insert:** `InsertTableRequest` (requires dimensions, location/index)
* **Modify:** `InsertTableRowRequest`, `InsertTableColumnRequest`, `DeleteTableRowRequest`, `DeleteTableColumnRequest`
* **Content:** Insert text/elements into cells using cell's content range index
* **Merge:** `MergeTableCellsRequest`
* **Style:** `UpdateTableCellStyleRequest`, `UpdateTableRowStyleRequest`, `UpdateTableColumnPropertiesRequest`

**API Documentation:**

* [Working with tables | Google Docs API](https://developers.google.com/workspace/docs/api/how-tos/tables)

**Sources:**

* [Creating New Table and Putting Values to Cells using Google Docs API](https://gist.github.com/tanaikech/3b5ac06747c8771f70afd3496278b04b)

### 3.2 Images

**Features:**

* Upload from device
* Insert from URL
* Insert from Google Drive
* Resize and crop
* Text wrapping options
* Alt text for accessibility

**API Support:** ✅ Full Support

* **Insert Inline:** `InsertInlineImageRequest` (requires URI or base64-encoded data)
* **Insert Positioned:** `CreatePositionedObjectRequest` for anchored images
* **Modify:** `UpdateImagePropertiesRequest` (cropping, size, angle, transparency, contrast, brightness)
* **Embed from Drive:** Use Drive file ID as image source URI

**Image Properties:**

* `sourceUri` - HTTPS URL or `data:` URI
* `imageProperties.contentUri` - Actual rendered URI (may differ from source)
* `imageProperties.cropProperties` - Crop offsets and angles
* `size` - Width/height dimensions

**API Documentation:**

* [Insert inline images | Google Docs API](https://developers.google.com/docs/api/how-tos/images)

**Sources:**

* [Google Docs API Examples](https://www.mikesallese.me/blog/google-docs-api-examples/)

### 3.3 Drawings

**Features:**

* Create drawings within document (shapes, lines, arrows, callouts, text boxes)
* Edit drawings inline
* Group/ungroup elements

**API Support:** ⚠️ Limited Support

* **Read:** `InlineObjectElement` with `inlineObjectProperties.embeddedObject.embeddedDrawingProperties`
* **Insert:** ❌ No direct API to create drawings programmatically (as of 2026-02-05)
* **Modify:** ❌ Drawing content not editable via API
* **Workaround:** Create drawings in UI, reference in API

**API Documentation:**

* [REST Resource: documents - EmbeddedDrawingProperties](https://developers.google.com/workspace/docs/api/reference/rest/v1/documents#embeddeddrawingproperties)

**Sources:**

* [How to Make Lines on Google Docs](https://www.oreateai.com/blog/how-to-make-lines-on-google-docs/8542d4c2f26ebee921de47d7cf78a351)

### 3.4 Charts (from Google Sheets)

**Features:**

* Embed Sheets charts into Docs
* Link to source data
* Update chart when source changes
* Chart types: bar, line, pie, scatter, etc.

**API Support:** ✅ Supported

* **Read:** `EmbeddedObject.linkedContentReference` with `sheetsChartReference`
* **Insert:** Create chart in Sheets first, then reference in Docs via chart ID
* **Property:** `sheetsChartReference.chartId`, `sheetsChartReference.spreadsheetId`

**API Documentation:**

* [REST Resource: documents - SheetsChartReference](https://developers.google.com/workspace/docs/api/reference/rest/v1/documents#sheetschartreference)

**Sources:**

* [Google Docs content insertion tables images charts API 2026](https://developers.google.com/workspace/docs/api/how-tos/tables)

### 3.5 Links

**Features:**

* Hyperlinks to external URLs
* Internal bookmarks (jump to section)
* Links to headings (for TOC navigation)
* Links to other Google Drive files

**API Support:** ✅ Full Support

* **Hyperlinks:** `TextStyle.link.url` property on TextRun
* **Bookmarks:** `BookmarkLink` with `bookmarkId` and `tabId`
* **Headings:** `HeadingLink` with `headingId` and `tabId`
* **Insert:** Set `TextStyle.link` in `UpdateTextStyleRequest`
* **Named Ranges:** `NamedRange` for programmatically labeled sections

**API Documentation:**

* [REST Resource: documents - Link](https://developers.google.com/workspace/docs/api/reference/rest/v1/documents#link)

**Sources:**

* [Work with links & bookmarks - Computer](https://support.google.com/docs/answer/45893?hl=en&co=GENIE.Platform%3DDesktop)
* [Google Docs can make a table of contents for you](https://blog.google/products/docs/how-to-google-docs-table-of-contents/)

### 3.6 Table of Contents

**Features:**

* Auto-generated from heading styles (Heading 1-6)
* Two formats: "With page numbers" or "With blue links"
* Updates automatically when headings change

**API Support:** ⚠️ Read-Only

* **Read:** `StructuralElement.tableOfContents` with `content` array
* **Insert:** ❌ No `InsertTableOfContentsRequest` (as of 2026-02-05)
* **Workaround:** Insert in UI, read structure via API

**API Documentation:**

* [REST Resource: documents - TableOfContents](https://developers.google.com/workspace/docs/api/reference/rest/v1/documents#tableofcontents)

**Sources:**

* [Google Docs Table of Contents: How to Create, Format & Update in 2026](https://www.automateed.com/google-docs-table-of-contents)

### 3.7 Headers and Footers

**Features:**

* Section-specific headers/footers
* Different first page header/footer
* Insert page numbers, dates, document title

**API Support:** ✅ Full Support

* **Structure:** `Document.headers` and `Document.footers` (indexed by ID)
* **Section Link:** `SectionStyle.headerId`, `SectionStyle.footerId`
* **Create:** `CreateHeaderRequest`, `CreateFooterRequest`
* **Delete:** `DeleteHeaderRequest`, `DeleteFooterRequest`
* **Content:** Headers/footers contain their own `StructuralElement` array

**API Documentation:**

* [REST Resource: documents - Header/Footer](https://developers.google.com/workspace/docs/api/reference/rest/v1/documents#header)

**Sources:**

* [Use headers, footers, page numbers & footnotes - Computer](https://support.google.com/docs/answer/86629?hl=en&co=GENIE.Platform%3DDesktop)

### 3.8 Page Numbers

**Features:**

* Insert via header/footer
* Format: "Page X", "Page X of Y"
* Restart numbering at section breaks

**API Support:** ✅ Via AutoText

* **Element Type:** `ParagraphElement.autoText` with `type: "PAGE_NUMBER"` or `"PAGE_COUNT"`
* **Insert:** Add AutoText element to header/footer
* **Rendering:** Google Docs handles dynamic value updates

**AutoText Types:**

* `TYPE_UNSPECIFIED`
* `PAGE_NUMBER`
* `PAGE_COUNT`

**API Documentation:**

* [AutoText | Google Docs API](https://developers.google.com/resources/api-libraries/documentation/docs/v1/java/latest/com/google/api/services/docs/v1/model/AutoText.html)

**Sources:**

* [Adding Page Numbers in Google Docs (2026): A Practical, Developer-Friendly Guide](https://thelinuxcode.com/adding-page-numbers-in-google-docs-2026-a-practical-developer-friendly-guide/)

### 3.9 Footnotes and Endnotes

**Features:**

* Insert footnote reference (superscript number)
* Footnote content at bottom of page
* Automatic numbering and renumbering

**API Support:** ✅ Full Support

* **Structure:** `Document.footnotes` (indexed by ID)
* **Reference:** `ParagraphElement.footnoteReference` with `footnoteId`
* **Create:** `CreateFootnoteRequest` (inserts reference and creates footnote)
* **Content:** Footnote contains `content` array of StructuralElements

**API Documentation:**

* [REST Resource: documents - Footnote](https://developers.google.com/workspace/docs/api/reference/rest/v1/documents#footnote)

**Sources:**

* [Use headers, footers, page numbers & footnotes](https://support.google.com/docs/answer/86629?hl=en&co=GENIE.Platform%3DDesktop)

### 3.10 Equations

**Features:**

* LaTeX-style equation editor
* Inline and display equations
* Math symbols and operators

**API Support:** ✅ Full Support

* **Element Type:** `ParagraphElement.equation`
* **Content:** `Equation.suggestedInsertionIds`, `Equation.suggestedDeletionIds`
* **Insert:** Add equation element to paragraph (exact insertion method varies)

**API Documentation:**

* [REST Resource: documents - Equation](https://developers.google.com/workspace/docs/api/reference/rest/v1/documents#equation)

**Sources:**

* [Use equations in a document - Computer](https://support.google.com/docs/answer/160749?hl=en&co=GENIE.Platform%3DDesktop)

### 3.11 Horizontal Lines

**Features:**

* Visual separator line spanning page width
* Formatting options (color, thickness)

**API Support:** ✅ Supported

* **Element Type:** `ParagraphElement.horizontalRule`
* **Insert:** Insert horizontal rule as paragraph element
* **Style:** `HorizontalRule.suggestedTextStyleChanges`, `textStyle`

**API Documentation:**

* [REST Resource: documents - HorizontalRule](https://developers.google.com/workspace/docs/api/reference/rest/v1/documents#horizontalrule)

**Sources:**

* [Can you add a Horizontal Line to a Google Document using their API?](https://community.latenode.com/t/can-you-add-a-horizontal-line-to-a-google-document-using-their-api/8244)

### 3.12 Page Breaks and Section Breaks

**Features:**

* **Page Break:** Start next content on new page
* **Section Break (Next Page):** New section on new page with independent formatting
* **Section Break (Continuous):** New section on same page

**API Support:** ✅ Full Support

* **Page Break:** `ParagraphElement.pageBreak`
  * **Insert:** `InsertPageBreakRequest`
* **Section Break:** `StructuralElement.sectionBreak`
  * **Insert:** `InsertSectionBreakRequest` with `sectionType`:
    * `SECTION_TYPE_UNSPECIFIED`
    * `CONTINUOUS` - Section starts after previous paragraph
    * `NEXT_PAGE` - Section starts on new page

**API Documentation:**

* [InsertSectionBreakRequest | Google Docs API](https://developers.google.com/resources/api-libraries/documentation/docs/v1/java/latest/com/google/api/services/docs/v1/model/InsertSectionBreakRequest.html)

**Sources:**

* [Requests and responses | Google Docs](https://developers.google.com/workspace/docs/api/concepts/request-response)

---

## 4. Formatting

### 4.1 Text Formatting

**Features:**

* **Font Face:** Font family selection (Arial, Times New Roman, etc.)
* **Font Size:** Point size (6-96 pt)
* **Font Weight:** Bold, normal
* **Font Style:** Italic, normal
* **Text Decoration:** Underline, strikethrough
* **Small Caps:** Transform lowercase to small capitals
* **Text Color:** Foreground color
* **Background Color:** Highlight color
* **Baseline Offset:** Superscript, subscript

**API Support:** ✅ Full Support

* **Property:** `TextStyle` on TextRun
* **Update:** `UpdateTextStyleRequest`

**TextStyle Fields:**

* `bold`, `italic`, `underline`, `strikethrough`, `smallCaps`
* `fontSize.magnitude`, `fontSize.unit`
* `weightedFontFamily.fontFamily`, `weightedFontFamily.weight`
* `foregroundColor`, `backgroundColor` (RGB or theme color)
* `baselineOffset` (enum: `BASELINE_OFFSET_UNSPECIFIED`, `NONE`, `SUPERSCRIPT`, `SUBSCRIPT`)
* `link` (for hyperlinks)

**API Documentation:**

* [Format Text | Google Docs API](https://developers.google.com/workspace/docs/api/how-tos/format-text)

**Sources:**

* [Google Docs formatting styles headings lists API documentation 2026](https://developers.google.com/workspace/docs/api/how-tos/format-text)

### 4.2 Paragraph Formatting

**Features:**

* **Alignment:** Left, center, right, justified
* **Indentation:** First-line, hanging, left, right
* **Spacing:** Before paragraph, after paragraph
* **Line Spacing:** Single, 1.15, 1.5, double, custom
* **Direction:** LTR (left-to-right), RTL (right-to-left)

**API Support:** ✅ Full Support

* **Property:** `ParagraphStyle` on Paragraph
* **Update:** `UpdateParagraphStyleRequest`

**ParagraphStyle Fields:**

* `alignment` (enum: `START`, `CENTER`, `END`, `JUSTIFIED`)
* `indentStart`, `indentEnd`, `indentFirstLine`
* `spaceAbove`, `spaceBelow`
* `lineSpacing` (percentage: 100 = single, 200 = double)
* `direction` (enum: `LEFT_TO_RIGHT`, `RIGHT_TO_LEFT`)
* `spacingMode` (enum: `SPACING_MODE_UNSPECIFIED`, `NEVER_COLLAPSE`, `COLLAPSE_LISTS`)
* `namedStyleType` (for headings, title, etc.)

**API Documentation:**

* [REST Resource: documents - ParagraphStyle](https://developers.google.com/workspace/docs/api/reference/rest/v1/documents#paragraphstyle)

**Sources:**

* [Format Text | Google Docs API](https://developers.google.com/workspace/docs/api/how-tos/format-text)

### 4.3 Headings and Styles

**Features:**

* **Named Styles:** Normal text, Title, Subtitle, Heading 1-6
* **Style Properties:** Font, size, color, spacing inherited from style
* **Update Default Styles:** Modify document-wide style definitions

**API Support:** ✅ Full Support

* **Set Style:** `ParagraphStyle.namedStyleType` with enum values:
  * `NAMED_STYLE_TYPE_UNSPECIFIED`
  * `NORMAL_TEXT`
  * `TITLE`
  * `SUBTITLE`
  * `HEADING_1` through `HEADING_6`
* **Document Styles:** `DocumentStyle.namedStyles` array defines default formatting for each style type
* **Update Default:** `UpdateParagraphStyleRequest` or `UpdateTextStyleRequest` on the named style in `Document.namedStyles`

**API Documentation:**

* [REST Resource: documents - NamedStyle](https://developers.google.com/workspace/docs/api/reference/rest/v1/documents#namedstyle)

**Sources:**

* [Add a title, heading, or table of contents in a document](https://support.google.com/docs/answer/116338?hl=en&co=GENIE.Platform%3DDesktop)

### 4.4 Lists

**Features:**

* **Bulleted Lists:** Standard bullets, custom glyphs
* **Numbered Lists:** Arabic numerals, Roman numerals, letters
* **Checklist:** Interactive checkboxes (toggle on/off)
* **Nested Lists:** Up to 9 nesting levels
* **Custom Formatting:** Bullet/number style per nesting level

**API Support:** ✅ Full Support (except checkbox state)

* **Create:** `CreateParagraphBulletsRequest` with `bulletPreset`:
  * `BULLET_DISC_CIRCLE_SQUARE`
  * `BULLET_DIAMONDX`
  * `BULLET_CHECKBOX` (creates checkboxes)
  * `BULLET_ARROW_DIAMOND_DISC`
  * `NUMBERED_DECIMAL_ALPHA_ROMAN`
  * `NUMBERED_DECIMAL_ALPHA_ROMAN_PARENS`
  * `NUMBERED_DECIMAL_NESTED`
  * `NUMBERED_UPPERALPHA_ALPHA_ROMAN`
  * `NUMBERED_UPPERROMAN_UPPERALPHA_DECIMAL`
  * `NUMBERED_ZERODECIMAL_ALPHA_ROMAN`
* **Delete:** `DeleteParagraphBulletsRequest`
* **Structure:** `Paragraph.bullet` with `listId` and `nestingLevel`
* **List Definition:** `Document.lists` (indexed by listId) defines glyph types per level

**⚠️ Checkbox State Limitation:**

* Checkbox checked/unchecked state is **not exposed** in API as of 2026-02-05
* `glyphType` remains `GLYPH_TYPE_UNSPECIFIED` for checkboxes
* Cannot programmatically check/uncheck boxes

**API Documentation:**

* [Work with lists | Google Docs API](https://developers.google.com/docs/api/how-tos/lists)

**Sources:**

* [Add a numbered list, bulleted list, or checklist](https://support.google.com/docs/answer/3300615?hl=en&co=GENIE.Platform%3DDesktop)
* [Is there a way to detect checkbox status in Google Docs API?](https://community.latenode.com/t/is-there-a-way-to-detect-checkbox-status-in-google-docs-api/7820)

### 4.5 Columns

**Features:**

* Multi-column layout (1-3 columns typically)
* Column breaks (force text to next column)
* Column separator lines

**API Support:** ✅ Full Support

* **Section Columns:** `SectionStyle.columnProperties` with:
  * `columnCount` (number of columns)
  * `paddingEnd` (space between columns)
* **Column Break:** `ParagraphElement.columnBreak`
  * **Insert:** Insert column break as paragraph element
* **Separator Style:** `SectionStyle.columnSeparatorStyle` (enum: `NONE`, `BETWEEN_EACH_COLUMN`)

**API Documentation:**

* [REST Resource: documents - SectionColumnProperties](https://developers.google.com/workspace/docs/api/reference/rest/v1/documents#sectioncolumnproperties)

**Sources:**

* [Add or delete columns in a document - Computer](https://support.google.com/docs/answer/7029052?hl=en&co=GENIE.Platform%3DDesktop)
* [How to add column breaks with Google Docs API v1](https://community.latenode.com/t/how-to-add-column-breaks-with-google-docs-api-v1/27390)

---

## 5. Page Setup

### 5.1 Page Size

**Features:**

* **Presets:** Letter (8.5×11"), A4 (210×297mm), Legal (8.5×14"), Tabloid (11×17"), etc.
* **Custom:** Width and height in points, inches, or mm

**API Support:** ✅ Full Support

* **Document-Level:** `DocumentStyle.pageSize` (applies if section doesn't override)
* **Section-Level:** `SectionStyle.pageSize` (overrides document default)

**PageSize Structure:**

```json
{
  "height": {
    "magnitude": 792,
    "unit": "PT"  // PT, IN, MM
  },
  "width": {
    "magnitude": 612,
    "unit": "PT"
  }
}
```

**Update:** `UpdateDocumentStyleRequest` or `UpdateSectionStyleRequest`

**API Documentation:**

* [REST Resource: documents - Size](https://developers.google.com/workspace/docs/api/reference/rest/v1/documents#size)

**Sources:**

* [Change page settings on Google Docs - Computer](https://support.google.com/docs/answer/10296604?hl=en&co=GENIE.Platform%3DDesktop)

### 5.2 Margins

**Features:**

* Top, bottom, left, right margins
* Header and footer margins (distance from edge to header/footer content)

**API Support:** ✅ Full Support

* **Document-Level:** `DocumentStyle.marginTop/Bottom/Left/Right`, `marginHeader`, `marginFooter`
* **Section-Level:** `SectionStyle.marginTop/Bottom/Left/Right`, `marginHeader`, `marginFooter` (overrides document)

**Margin Type:** `Dimension` with `magnitude` and `unit` (PT, IN, MM)

**Update:** `UpdateDocumentStyleRequest` or `UpdateSectionStyleRequest`

**API Documentation:**

* [DocumentStyle | Google Docs API](https://developers.google.com/resources/api-libraries/documentation/docs/v1/java/latest/com/google/api/services/docs/v1/model/DocumentStyle.html)

**Sources:**

* [How to Change Margins In Google Docs | 2026 Ultimate Guide](https://www.selecthub.com/resources/how-to-change-margins-in-google-docs/)

### 5.3 Orientation

**Features:**

* **Portrait:** Default, vertical orientation
* **Landscape:** Horizontal orientation
* Can mix orientations within document via section breaks

**API Support:** ✅ Full Support

* **Property:** `DocumentStyle.flipPageOrientation` or `SectionStyle.flipPageOrientation`
* **Boolean:** `true` = landscape (flips width/height), `false` = portrait

**Update:** `UpdateDocumentStyleRequest` or `UpdateSectionStyleRequest`

**API Documentation:**

* [DocumentStyle | Google Docs API](https://developers.google.com/resources/api-libraries/documentation/docs/v1/java/latest/com/google/api/services/docs/v1/model/DocumentStyle.html)

**Sources:**

* [How to Change to Landscape in Google Docs – Quick Format Guide](https://www.trupeer.ai/tutorials/how-to-change-to-landscape-in-google-docs)

### 5.4 Page Color

**Features:**

* Background color for entire page (not just text highlight)
* RGB or theme color selection

**API Support:** ✅ Full Support

* **Property:** `DocumentStyle.background.color`
* **Type:** `OptionalColor` with `color` field (RGB or theme color)

**Update:** `UpdateDocumentStyleRequest`

**API Documentation:**

* [REST Resource: documents - Background](https://developers.google.com/workspace/docs/api/reference/rest/v1/documents#background)

**Sources:**

* [Change page settings on Google Docs - Computer](https://support.google.com/docs/answer/10296604?hl=en&co=GENIE.Platform%3DDesktop)

---

## 6. Special Fields / Variables

### 6.1 AutoText Fields

**Features:**

* **Page Number:** Current page number
* **Page Count:** Total pages in document
* **Date:** (May be available via AutoText, details unclear)
* **Document Title:** (May be available via AutoText, details unclear)

**API Support:** ✅ Partial Support

* **Supported AutoText Types:**
  * `PAGE_NUMBER`
  * `PAGE_COUNT`
* **Element Type:** `ParagraphElement.autoText` with `type` field
* **Insert:** Add autoText element to header/footer or body
* **Rendering:** Google Docs dynamically replaces with current value

**⚠️ Limitation:** Date and Document Title AutoText types may not be fully exposed (requires verification)

**API Documentation:**

* [AutoText | Google Docs API](https://developers.google.com/resources/api-libraries/documentation/docs/v1/java/latest/com/google/api/services/docs/v1/model/AutoText.html)

**Sources:**

* [Structure of a Google Docs document | Google for Developers](https://developers.google.com/workspace/docs/api/concepts/structure)

### 6.2 Smart Chips

**Features:**

* **Date Chips:** Insert date, updates if changed
* **People Chips:** @mention users with email, shows profile
* **File Chips:** Link to Google Drive files with preview
* **Calendar Event Chips:** Link to Google Calendar events
* **Third-Party Chips:** Extensible via Google Workspace add-ons

**API Support:** ⚠️ Limited Support

* **Person Links:** `ParagraphElement.person` with `personProperties`
  * **Read:** `personProperties.name`, `personProperties.email`
  * **Write:** Limited (Sheets API supports insertion, Docs API unclear)
* **Rich Links:** `ParagraphElement.richLink` with `richLinkProperties`
  * **Read:** `richLinkProperties.uri`, `richLinkProperties.title`
  * **Write:** Limited documentation
* **Date Chips:** API support unclear (may be readable but not writable)

**⚠️ Issue Tracker:** [API access to Smart Chips to create/read/write](https://issuetracker.google.com/issues/225584757) (ongoing request for full API support)

**API Documentation:**

* [REST Resource: documents - Person](https://developers.google.com/workspace/docs/api/reference/rest/v1/documents#person)
* [REST Resource: documents - RichLink](https://developers.google.com/workspace/docs/api/reference/rest/v1/documents#richlink)

**Sources:**

* [Insert smart chips in Google Docs](https://support.google.com/docs/answer/10710316?hl=en)
* [Create smart chips for link previewing in Google Docs](https://developers.googleblog.com/create-smart-chips-for-link-previewing-in-google-docs/)
* [How to use smart chips in Google Docs and Sheets](https://www.computerworld.com/article/1631765/how-to-use-smart-chips-in-google-docs-and-sheets.html)

---

## 7. Document Properties

### 7.1 Document Language

**Features:**

* Set document language for spell-check and grammar
* Affects autocorrect and suggestion behavior

**API Support:** ⚠️ Unknown

* Not explicitly documented in Google Docs API reference
* May be accessible via `DocumentStyle` or as separate property (requires verification)

### 7.2 Default Styles

**Features:**

* Document-wide style definitions for Normal Text, Headings, Title, Subtitle
* Defines default font, size, color, spacing for each style type

**API Support:** ✅ Full Support

* **Property:** `DocumentStyle.namedStyles` (map of style type to NamedStyle)
* **Update:** Modify `NamedStyle.textStyle` or `NamedStyle.paragraphStyle` for a given `namedStyleType`

**NamedStyle Structure:**

```json
{
  "namedStyleType": "HEADING_1",
  "textStyle": { "fontSize": { "magnitude": 20, "unit": "PT" }, "bold": true },
  "paragraphStyle": { "spaceAbove": { "magnitude": 12, "unit": "PT" } }
}
```

**API Documentation:**

* [REST Resource: documents - NamedStyles](https://developers.google.com/workspace/docs/api/reference/rest/v1/documents#namedstyles)

**Sources:**

* [Google Docs: Apply and Modify Heading Styles](https://it.umn.edu/services-technologies/how-tos/google-docs-apply-modify-heading-styles)

### 7.3 Page Numbering Restart

**Features:**

* Restart page numbering at specific section break
* Useful for multi-part documents (e.g., front matter starts at i, body starts at 1)

**API Support:** ⚠️ Unknown

* Not explicitly documented in API reference
* May require section-level properties (requires verification)

---

## 8. Version Control

### 8.1 Version History

**Features:**

* Auto-saved revisions at intervals
* View all changes over time
* Restore previous versions
* See who made changes and when

**API Support:** ✅ Full Support (via Drive API)

* **API Location:** Google Drive API v3 `revisions` resource
* **Methods:**
  * `revisions.list` - Get all revisions for file
  * `revisions.get` - Get specific revision
  * `revisions.update` - Modify revision properties (e.g., `keepForever`)
  * `revisions.delete` - Delete specific revision

**Revision Properties:**

* `id` - Revision ID
* `modifiedTime` - Timestamp
* `lastModifyingUser` - User who made changes
* `keepForever` - Pin revision (prevent auto-deletion)
* `exportLinks` - Download revision in various formats

**⚠️ Limitation:** Revision list may be incomplete for heavily edited documents (Google Drive UI shows more complete history)

**API Documentation:**

* [Manage file revisions | Google Drive](https://developers.google.com/drive/api/guides/manage-revisions)
* [REST Resource: revisions | Google Drive](https://developers.google.com/workspace/drive/api/reference/rest/v3/revisions)

**Sources:**

* [Google Docs: Version History](https://edu.gcfglobal.org/en/googledocuments/version-history/1/)
* [How to manage Google Docs version control in 2026](https://www.papermark.com/blog/google-docs-document-version-control)

### 8.2 Named Versions

**Features:**

* Label specific revisions with descriptive names (e.g., "Draft 1", "Final Review")
* Filter revision history to show only named versions
* Limit: 40 named versions per document

**API Support:** ⚠️ Limited Visibility

* **Via Drive API:** `revisions` resource may include named versions, but `description` field (for version name) is not prominently documented
* **Issue:** Users report that named versions created in UI are not easily distinguishable in API responses (as of 2025 reports)

**Workaround:**

* Use `keepForever: true` to pin revisions, then track version names externally

**Sources:**

* [Named versions: What you'll love about the new Version history for Google Docs](https://sites.google.com/site/scriptsexamples/home/announcements/named-versions-what-youll-love-about-the-new-version-history-for-google-docs)
* [Retrieve Named Version List of a Google Docs with the Script Editor & Drive API](https://www.experts-exchange.com/questions/29143743/Retrieve-Named-Version-List-of-a-Google-Docs-with-the-Script-Editor-Drive-API-or-any-other-API.html)

---

## 9. Document Modes

### 9.1 Pages vs. Pageless Format

**Features:**

* **Pages Format (default):** Document paginated with page breaks, supports headers/footers/page numbers
* **Pageless Format:** Continuous scroll, no page breaks, images/tables adapt to screen width

**API Support:** ✅ Full Support

* **Property:** `DocumentStyle.documentMode`
* **Enum Values:**
  * `DOCUMENT_MODE_UNSPECIFIED`
  * `PAGES` - Traditional page layout
  * `PAGELESS` - Continuous scroll layout

**⚠️ Limitations in Pageless Mode:**

* Cannot use: headers, footers, page numbers, columns, certain formatting options
* `DocumentStyle` margin properties not rendered in pageless mode

**Update:** `UpdateDocumentStyleRequest` to switch modes

**API Documentation:**

* [REST Resource: documents - DocumentStyle](https://developers.google.com/workspace/docs/api/reference/rest/v1/documents#documentstyle)

**Sources:**

* [Change a document's page setup: pages or pageless - Computer](https://support.google.com/docs/answer/11528737?hl=en&co=GENIE.Platform%3DDesktop)
* [How to remove page breaks in Google Docs with pageless view](https://zapier.com/blog/google-docs-pageless/)

---

## 10. Multi-Tab Documents

### 10.1 Tabs Feature

**Features:**

* Single document with multiple tabs (similar to spreadsheet tabs)
* Each tab has independent content
* Hierarchical structure: tabs can have child tabs

**API Support:** ✅ Full Support

* **Property:** `Document.tabs` array
* **Tab Structure:**
  * `tabProperties.tabId` - Unique identifier
  * `tabProperties.title` - Tab display name
  * `tabProperties.index` - Position in tab bar
  * `childTabs` - Array of nested tabs
  * `documentTab` - Contains text content (body, headers, footers, footnotes)

**API Documentation:**

* [Work with tabs | Google Docs API](https://developers.google.com/workspace/docs/api/how-tos/tabs)

**Sources:**

* [REST Resource: documents](https://developers.google.com/workspace/docs/api/reference/rest/v1/documents)

---

## 11. UI-Only Features (Not in API)

### 11.1 Confirmed UI-Only

1. **Programmatic Suggestion Accept/Reject**
   * Can read suggestions, cannot accept/reject via API
   * Workaround: Re-apply suggested changes as direct edits

2. **Checkbox State Detection**
   * Can create checkbox lists, cannot read checked/unchecked state
   * UI shows checked state via strikethrough, but API doesn't expose boolean

3. **Table of Contents Insertion**
   * Can read TOC structure, cannot insert TOC programmatically
   * Workaround: Insert in UI, manage headings via API (TOC auto-updates)

4. **Drawing Creation/Editing**
   * Can read embedded drawings, cannot create or edit drawing content
   * Workaround: Create drawings in UI, reference in API

5. **Named Version Names**
   * Can pin revisions with `keepForever`, but version names not exposed clearly
   * Workaround: Track version names externally

### 11.2 Possibly UI-Only (Requires Verification)

1. **Document Language Property**
   * Not explicitly documented in API reference

2. **Page Numbering Restart**
   * Not explicitly documented (may exist in section properties)

3. **Date/Title AutoText Fields**
   * Only PAGE_NUMBER and PAGE_COUNT explicitly documented

4. **Smart Chip Write Operations**
   * Read support confirmed for person/rich links, write support unclear

---

## 12. API Request Patterns

### 12.1 Reading Documents

**Method:** `documents.get`

**Parameters:**

* `documentId` - Document ID (from Drive API or URL)
* `suggestionsViewMode` - How to render suggestions (SUGGESTIONS_INLINE, PREVIEW_WITH_SUGGESTIONS_ACCEPTED, PREVIEW_WITHOUT_SUGGESTIONS)

**Response:** Complete `Document` object with:

* `documentId`, `title`, `body`
* `headers`, `footers`, `footnotes`
* `documentStyle`, `namedStyles`
* `lists`, `namedRanges`, `revisionId`
* `suggestionsViewMode`, `inlineObjects`, `positionedObjects`
* `tabs` (if multi-tab document)

### 12.2 Modifying Documents

**Method:** `documents.batchUpdate`

**Request Body:**

```json
{
  "requests": [
    { "insertText": { "location": { "index": 1 }, "text": "Hello" } },
    { "updateTextStyle": { "range": { "startIndex": 1, "endIndex": 6 }, "textStyle": { "bold": true }, "fields": "bold" } }
  ],
  "writeControl": {
    "requiredRevisionId": "current_revision_id"  // Optional: prevent concurrent edits
  }
}
```

**Request Types (Partial List):**

* Text: `InsertTextRequest`, `DeleteContentRangeRequest`
* Formatting: `UpdateTextStyleRequest`, `UpdateParagraphStyleRequest`
* Structure: `InsertPageBreakRequest`, `InsertSectionBreakRequest`, `InsertTableRequest`
* Lists: `CreateParagraphBulletsRequest`, `DeleteParagraphBulletsRequest`
* Headers/Footers: `CreateHeaderRequest`, `CreateFooterRequest`
* Images: `InsertInlineImageRequest`
* Footnotes: `CreateFootnoteRequest`
* Named Ranges: `CreateNamedRangeRequest`, `DeleteNamedRangeRequest`
* Positioned Objects: `CreatePositionedObjectRequest`, `DeletePositionedObjectRequest`

**Response:**

```json
{
  "documentId": "...",
  "replies": [ ... ],  // Per-request responses (e.g., created object IDs)
  "writeControl": {
    "requiredRevisionId": "new_revision_id"
  }
}
```

### 12.3 Index System

**Critical Concept:** UTF-16 code units

* Indexes reference positions within segments (body, header, footer, footnote)
* Index 0 = start of segment, index 1 = after first character
* Surrogate pairs (e.g., emoji) consume **two indexes**
* Newline characters (`\n`) consume one index
* Structural elements (tables, section breaks) consume one index at their start

**Example:**

```
"Hello\n" → indexes 0-5 (H=0, e=1, l=2, l=3, o=4, \n=5)
```

---

## 13. Rate Limits and Quotas

**API Limits:**

* **Read Requests:** 300 per minute per project
* **Write Requests:** 60 per minute per project
* **Concurrent Requests:** No documented hard limit, but rate limits apply
* **Batch Operations:** Single `batchUpdate` can contain multiple requests (saves quota)

**Best Practices:**

* Use `batchUpdate` to group multiple edits into one API call
* Handle 429 (Too Many Requests) with exponential backoff
* Cache `documents.get` responses when possible

**API Documentation:**

* [Usage limits | Google Docs API](https://developers.google.com/workspace/docs/api/limits)

**Sources:**

* [Usage limits | Google Docs | Google for Developers](https://developers.google.com/workspace/docs/api/limits)

---

## 14. Cross-References

### Related APIs

* **Google Drive API** - File metadata, permissions, comments, revisions
* **Google Sheets API** - Embed charts from Sheets
* **Google Workspace Add-ons** - Third-party smart chips, UI extensions

### Key Documentation Links

* [Google Docs API Overview](https://developers.google.com/workspace/docs/api/how-tos/overview)
* [Structure of a Google Docs document](https://developers.google.com/workspace/docs/api/concepts/structure)
* [REST Resource: documents](https://developers.google.com/workspace/docs/api/reference/rest/v1/documents)
* [Work with suggestions](https://developers.google.com/workspace/docs/api/how-tos/suggestions)
* [Work with lists](https://developers.google.com/docs/api/how-tos/lists)
* [Working with tables](https://developers.google.com/workspace/docs/api/how-tos/tables)
* [Insert inline images](https://developers.google.com/docs/api/how-tos/images)
* [Format Text](https://developers.google.com/workspace/docs/api/how-tos/format-text)
* [Work with tabs](https://developers.google.com/workspace/docs/api/how-tos/tabs)

---

## 15. Summary: Feature Coverage Matrix

| Feature Category | UI Availability | API Support | Notes |
|-----------------|----------------|-------------|-------|
| **Editing Modes** | ✅ | ⚠️ Partial | Read suggestions ✅, Accept/Reject ❌ |
| **Comments** | ✅ | ✅ Full | Via Drive API v3 |
| **Tables** | ✅ | ✅ Full | Insert, modify, merge cells |
| **Images** | ✅ | ✅ Full | Inline and positioned |
| **Drawings** | ✅ | ⚠️ Limited | Read-only, cannot create |
| **Charts (Sheets)** | ✅ | ✅ Full | Reference Sheets charts |
| **Links** | ✅ | ✅ Full | URLs, bookmarks, headings |
| **TOC** | ✅ | ⚠️ Read-Only | Cannot insert via API |
| **Headers/Footers** | ✅ | ✅ Full | Create, delete, edit content |
| **Page Numbers** | ✅ | ✅ Full | Via AutoText elements |
| **Footnotes** | ✅ | ✅ Full | Create, edit content |
| **Equations** | ✅ | ✅ Full | Insert equations |
| **Horizontal Rules** | ✅ | ✅ Full | Insert horizontal lines |
| **Page/Section Breaks** | ✅ | ✅ Full | Insert via requests |
| **Text Formatting** | ✅ | ✅ Full | All styles supported |
| **Paragraph Formatting** | ✅ | ✅ Full | Alignment, spacing, indentation |
| **Headings/Styles** | ✅ | ✅ Full | Named styles, custom defaults |
| **Lists** | ✅ | ⚠️ Partial | Create lists ✅, Checkbox state ❌ |
| **Columns** | ✅ | ✅ Full | Multi-column layout, column breaks |
| **Page Setup** | ✅ | ✅ Full | Size, margins, orientation, color |
| **Smart Chips** | ✅ | ⚠️ Limited | Read person/rich links ✅, Write unclear |
| **AutoText** | ✅ | ⚠️ Partial | Page #/count ✅, Date/title unclear |
| **Document Mode** | ✅ | ✅ Full | Pages vs. pageless |
| **Multi-Tab Docs** | ✅ | ✅ Full | Tab hierarchy, independent content |
| **Version History** | ✅ | ✅ Full | Via Drive API |
| **Named Versions** | ✅ | ⚠️ Limited | Names not clearly exposed |

---

## 16. Research Methodology

**Research Date:** 2026-02-05

**Search Queries Executed:**

1. Google Docs editing modes suggesting mode track changes 2026
2. Google Docs API comments collaboration features documentation 2026
3. Google Docs content insertion tables images charts API 2026
4. Google Docs formatting styles headings lists API documentation 2026
5. Google Docs page setup margins orientation page size API 2026
6. Google Docs smart chips dates people files variables API 2026
7. Google Docs version history named versions API documentation 2026
8. Google Docs headers footers page numbers footnotes API 2026
9. Google Docs table of contents bookmarks links API 2026
10. Google Docs drawings equations horizontal lines page breaks API 2026
11. "Google Docs API" InsertPageBreakRequest InsertSectionBreakRequest 2026
12. "Google Docs API" link bookmarkLink namedRange table of contents 2026
13. "Google Docs API" equation horizontalRule drawing embedded object 2026
14. Google Docs columns column layout section break API 2026
15. "Google Docs API" suggested edits suggestions mode accept reject 2026
16. "Google Docs API" limitations UI-only features not supported 2026
17. Google Docs pageless format document mode API 2026
18. "Google Docs API" person chip person link smart chip 2026
19. "Google Docs API" AutoText page number date document title 2026
20. Google Docs checklist checkbox list item API 2026

**Official Documentation Fetched:**

* https://developers.google.com/workspace/docs/api/reference/rest/v1/documents
* https://developers.google.com/workspace/docs/api/concepts/structure
* https://developers.google.com/workspace/docs/api/how-tos/suggestions

**Key Sources:**

* Google Workspace Docs API official documentation (developers.google.com/workspace/docs)
* Google Drive API documentation (developers.google.com/drive)
* Google Workspace support articles (support.google.com/docs)
* Community forums (Latenode, Google Docs Editors Community)
* Developer blogs (developers.googleblog.com)
* Technical guides (Medium, GeeksforGeeks, CustomGuide)

**Verification Status:**

* ✅ Core features verified via official API documentation
* ⚠️ Edge cases/limitations verified via community reports and issue trackers
* 🔍 Some features require hands-on testing for full verification (noted as "requires verification")

---

## 17. Recommendations for gogcli Integration

### High Priority (Core Features)

1. **Text and Paragraph Formatting** - Full API support, essential for document export
2. **Tables** - Full API support, common use case
3. **Images** - Full API support, critical for media-rich documents
4. **Headers/Footers/Page Numbers** - Full API support, necessary for formatted documents
5. **Lists** - Full API support (except checkbox state)
6. **Links and Bookmarks** - Full API support, essential for navigation

### Medium Priority (Advanced Features)

7. **Suggestions (Read-Only)** - Read via API, display in gogcli output
8. **Footnotes** - Full API support
9. **Equations** - Full API support
10. **Multi-Tab Documents** - Full API support
11. **Page Setup (margins, orientation, size)** - Full API support

### Low Priority (Limited API Support)

12. **Comments** - Via Drive API (separate integration)
13. **Version History** - Via Drive API (separate integration)
14. **Smart Chips** - Limited API, may require manual annotation
15. **Drawings** - Read-only API, cannot create programmatically

### Not Recommended (UI-Only)

16. **Checkbox State** - Cannot read via API
17. **Suggestion Accept/Reject** - UI-only operation
18. **TOC Insertion** - Cannot insert via API (read-only)
19. **Named Version Names** - Not clearly exposed in API

### API Integration Patterns

**For gogcli Export:**

* Use `documents.get` with `SUGGESTIONS_INLINE` mode for accurate indexes
* Parse all structural elements (paragraphs, tables, sections)
* Handle UTF-16 index calculations for text ranges
* Map named styles to output format (e.g., Markdown headers for Heading 1-6)
* Preserve inline formatting (bold, italic, links)
* Export images by downloading via `contentUri`

**For gogcli Import/Sync:**

* Use `batchUpdate` with grouped requests for efficiency
* Handle concurrent edit conflicts via `requiredRevisionId`
* Implement exponential backoff for 429 errors
* Map input format to Google Docs structures (e.g., Markdown headers → namedStyleType)

**Limitations to Document:**

* Clearly note that checkbox state cannot be read
* Warn users that suggestions are read-only (cannot accept/reject programmatically)
* Explain that TOC must be inserted in UI (but will auto-update based on headings)

---

## Appendix: Complete Sources List

* [Suggest edits in Google Docs - Computer](https://support.google.com/docs/answer/6033474?hl=en&co=GENIE.Platform%3DDesktop)
* [How to Track Changes in Google Docs [2026 Guide]](https://spreadsheetpoint.com/how-to-track-changes-in-google-docs/)
* [Work with suggestions | Google Docs API](https://developers.google.com/workspace/docs/api/how-tos/suggestions)
* [REST Resource: comments | Google Drive](https://developers.google.com/drive/api/reference/rest/v3/comments)
* [Manage comments | Google Drive](https://developers.google.com/drive/api/guides/manage-comments)
* [Working with tables | Google Docs API](https://developers.google.com/workspace/docs/api/how-tos/tables)
* [Insert inline images | Google Docs API](https://developers.google.com/docs/api/how-tos/images)
* [Format Text | Google Docs API](https://developers.google.com/workspace/docs/api/how-tos/format-text)
* [Work with lists | Google Docs API](https://developers.google.com/docs/api/how-tos/lists)
* [Work with tabs | Google Docs API](https://developers.google.com/workspace/docs/api/how-tos/tabs)
* [REST Resource: documents | Google Docs API](https://developers.google.com/workspace/docs/api/reference/rest/v1/documents)
* [Structure of a Google Docs document | Google for Developers](https://developers.google.com/workspace/docs/api/concepts/structure)
* [Requests and responses | Google Docs](https://developers.google.com/workspace/docs/api/concepts/request-response)
* [Google Docs API Overview](https://developers.google.com/workspace/docs/api/how-tos/overview)
* [Usage limits | Google Docs API](https://developers.google.com/workspace/docs/api/limits)
* [Manage file revisions | Google Drive](https://developers.google.com/drive/api/guides/manage-revisions)
* [REST Resource: revisions | Google Drive](https://developers.google.com/workspace/drive/api/reference/rest/v3/revisions)
* [Change page settings on Google Docs - Computer](https://support.google.com/docs/answer/10296604?hl=en&co=GENIE.Platform%3DDesktop)
* [Use headers, footers, page numbers & footnotes - Computer](https://support.google.com/docs/answer/86629?hl=en&co=GENIE.Platform%3DDesktop)
* [Work with links & bookmarks - Computer](https://support.google.com/docs/answer/45893?hl=en&co=GENIE.Platform%3DDesktop)
* [Google Docs can make a table of contents for you](https://blog.google/products/docs/how-to-google-docs-table-of-contents/)
* [Insert smart chips in Google Docs](https://support.google.com/docs/answer/10710316?hl=en)
* [Create smart chips for link previewing in Google Docs](https://developers.googleblog.com/create-smart-chips-for-link-previewing-in-google-docs/)
* [Change a document's page setup: pages or pageless - Computer](https://support.google.com/docs/answer/11528737?hl=en&co=GENIE.Platform%3DDesktop)
* [How to remove page breaks in Google Docs with pageless view](https://zapier.com/blog/google-docs-pageless/)
* [Add a numbered list, bulleted list, or checklist](https://support.google.com/docs/answer/3300615?hl=en&co=GENIE.Platform%3DDesktop)
* [Is there a way to detect checkbox status in Google Docs API?](https://community.latenode.com/t/is-there-a-way-to-detect-checkbox-status-in-google-docs-api/7820)
* [How to manage Google Docs version control in 2026](https://www.papermark.com/blog/google-docs-document-version-control)
* [Google Docs Table of Contents: How to Create, Format & Update in 2026](https://www.automateed.com/google-docs-table-of-contents)
* [Google Docs API Examples](https://www.mikesallese.me/blog/google-docs-api-examples/)
* [Adding Page Numbers in Google Docs (2026): A Practical, Developer-Friendly Guide](https://thelinuxcode.com/adding-page-numbers-in-google-docs-2026-a-practical-developer-friendly-guide/)
* [How to use smart chips in Google Docs and Sheets](https://www.computerworld.com/article/1631765/how-to-use-smart-chips-in-google-docs-and-sheets.html)
* [Google Docs: Version History](https://edu.gcfglobal.org/en/googledocuments/version-history/1/)
* [Add a title, heading, or table of contents in a document](https://support.google.com/docs/answer/116338?hl=en&co=GENIE.Platform%3DDesktop)
* [Use equations in a document - Computer](https://support.google.com/docs/answer/160749?hl=en&co=GENIE.Platform%3DDesktop)
* [Can you add a Horizontal Line to a Google Document using their API?](https://community.latenode.com/t/can-you-add-a-horizontal-line-to-a-google-document-using-their-api/8244)
* [How to Make Lines on Google Docs](https://www.oreateai.com/blog/how-to-make-lines-on-google-docs/8542d4c2f26ebee921de47d7cf78a351)
* [Add or delete columns in a document - Computer](https://support.google.com/docs/answer/7029052?hl=en&co=GENIE.Platform%3DDesktop)
* [How to add column breaks with Google Docs API v1](https://community.latenode.com/t/how-to-add-column-breaks-with-google-docs-api-v1/27390)
* [How to Change Margins In Google Docs | 2026 Ultimate Guide](https://www.selecthub.com/resources/how-to-change-margins-in-google-docs/)
* [How to Change to Landscape in Google Docs – Quick Format Guide](https://www.trupeer.ai/tutorials/how-to-change-to-landscape-in-google-docs)
* [Google Docs: Apply and Modify Heading Styles](https://it.umn.edu/services-technologies/how-tos/google-docs-apply-modify-heading-styles)
* [Named versions: What you'll love about the new Version history for Google Docs](https://sites.google.com/site/scriptsexamples/home/announcements/named-versions-what-youll-love-about-the-new-version-history-for-google-docs)
* [Creating New Table and Putting Values to Cells using Google Docs API](https://gist.github.com/tanaikech/3b5ac06747c8771f70afd3496278b04b)
* [Google Docs Collaboration: Writers, Authors, & Content Teams](https://wordable.io/google-docs-collaboration/)
* [AutoText | Google Docs API](https://developers.google.com/resources/api-libraries/documentation/docs/v1/java/latest/com/google/api/services/docs/v1/model/AutoText.html)
* [DocumentStyle | Google Docs API](https://developers.google.com/resources/api-libraries/documentation/docs/v1/java/latest/com/google/api/services/docs/v1/model/DocumentStyle.html)
* [InsertSectionBreakRequest | Google Docs API](https://developers.google.com/resources/api-libraries/documentation/docs/v1/java/latest/com/google/api/services/docs/v1/model/InsertSectionBreakRequest.html)
* [API access to Smart Chips to create/read/write [Issue Tracker]](https://issuetracker.google.com/issues/225584757)
* [Google Docs API Support for Suggested Edits [Issue Tracker]](https://issuetracker.google.com/issues/287903901)

---

**End of Document**
