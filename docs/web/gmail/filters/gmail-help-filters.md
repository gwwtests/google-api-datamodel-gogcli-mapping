# Gmail Help - Create Rules to Filter Your Emails

**Source**: https://support.google.com/mail/answer/6579

**Note**: This document could not be fully archived via automated tools. The Gmail Help page uses dynamic content loading that prevents complete extraction. The information below is based on known Gmail UI functionality.

## Overview

Gmail filters allow users to automatically organize incoming emails based on criteria such as sender, subject, keywords, and more.

## Creating Filters in Gmail UI

Users can create filters through the Gmail web interface by:

1. Using the search bar to define criteria
2. Clicking "Create filter" link
3. Selecting actions to apply to matching messages

## Import Filters Functionality

Gmail provides the ability to import filters from XML files:

1. Navigate to Settings > Filters and Blocked Addresses
2. Click "Import filters" link at the bottom of the filters list
3. Select an XML file containing filter definitions
4. Review filters to import and confirm

### Import File Format

The import file must be in XML format following Gmail's filter schema. See `filter-xml-format-specification.md` for detailed format information.

### Import Behavior

* Imported filters are added to existing filters (not replaced)
* Filter IDs are reassigned by Gmail during import
* Duplicate filters may be created if importing the same file multiple times

## Export Filters Functionality

Gmail allows users to export their current filters:

1. Navigate to Settings > Filters and Blocked Addresses
2. Select filters to export (checkboxes)
3. Click "Export" button
4. Download XML file containing selected filters

### Export Use Cases

* Backup of filter configuration
* Migration to another Gmail account
* Sharing filter sets with team members
* Version control of filter rules

## Filter Criteria Options (UI)

Available criteria in Gmail's filter creation UI:

* From - Sender email address
* To - Recipient email address
* Subject - Words in subject line
* Has the words - Content search
* Doesn't have - Negative content search
* Has attachment - Messages with attachments
* Size - Message size comparisons

## Filter Actions (UI)

Actions that can be applied to matching messages:

* Skip the Inbox (Archive it)
* Mark as read
* Star it
* Apply label
* Forward it to (requires verified forwarding address)
* Delete it
* Never send it to Spam
* Always mark it as important
* Never mark it as important
* Categorize as (Primary, Social, Updates, Forums, Promotions)

## Relationship to Gmail API

The UI filter import/export functionality uses XML format, while the Gmail API uses JSON for the same operations. The XML format is specific to the web UI import/export feature and is NOT used by the API.

## Limitations

* Maximum number of filters per account: 1000 (as of 2024)
* Filters apply to incoming messages, not existing messages (unless "Also apply filter to matching conversations" is checked during creation)
* Forwarding actions require email address verification
* Import does not validate all criteria before adding filters

## Related Documentation

* `filters-xml-export-format.md` - Technical details of XML format
* `filter-settings-guide.md` - Programmatic filter management via API
* `filters-api-vs-xml.md` - Comparison of XML and API approaches
