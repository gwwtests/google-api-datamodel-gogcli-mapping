# Gmail Category Labels in the API

**Sources**:

* https://bergvca.github.io/2019/04/13/gmail-analysis.html
* https://clean.email/gmail-categories
* https://support.google.com/mail/answer/3094499

**Retrieved**: 2026-01-30

## Overview

Gmail has been adding labels to emails since 2010 that classify different types of email. These categories correspond to the tabs visible in Gmail's web interface.

## Category Label Names

In the Gmail API, these categories appear as system label names:

* **CATEGORY_PERSONAL** - Personal emails (appears as "Primary" tab in UI)
* **CATEGORY_SOCIAL** - Social media updates and notifications (appears as "Social" tab)
* **CATEGORY_PROMOTIONS** - Marketing emails and promotions (appears as "Promotions" tab)
* **CATEGORY_FORUMS** - Forum and mailing list emails (appears as "Forums" tab)
* **CATEGORY_UPDATES** - Updates and confirmations (appears as "Updates" tab)

## API Access

These labels can be retrieved using the Gmail API's `users().labels().list()` function, and they appear alongside other standard Gmail labels like INBOX, SENT, TRASH, SPAM, etc.

## Category Descriptions

**Primary (CATEGORY_PERSONAL)**: Emails from known contacts and messages not appearing in other tabs

**Social**: Social networks and media-sharing sites

**Promotions**: Deals, offers, and promotional emails

**Updates**: Automated confirmations, notifications, and reminders

**Forums**: Messages from online groups and discussion boards

## Search Operators

You can enter the category name before your search term in Gmail's search, for example: `category:social party`

This search operator works across Gmail's interface and API queries.

## Limitations

* Users can customize which categories to display but cannot create entirely custom categories beyond these five predetermined options
* If you have more than 250,000 emails in your inbox, you can't use the "Default" inbox type with categories
* Categories are automatically assigned by Gmail's machine learning algorithms

## Automatic Classification

Gmail automatically sorts incoming messages into these categories using:

* Machine learning algorithms
* Analysis of message content
* Sender reputation
* User behavior patterns
* Historical interaction data

## 2026 AI Updates

In early 2026, Gmail unveiled its AI Inbox feature, designed to provide personalized briefings, enhancing how these categories work with machine learning.

## API Usage Example

When querying messages through the API, category labels appear in the `labelIds` array:

```json
{
  "id": "18d1e2f3a4b5c6d7",
  "threadId": "18d1e2f3a4b5c6d7",
  "labelIds": [
    "INBOX",
    "CATEGORY_PROMOTIONS",
    "UNREAD"
  ]
}
```

Messages can have multiple category labels, though typically only one category label is applied per message.
