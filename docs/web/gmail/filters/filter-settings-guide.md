# Gmail Filters API Guide

**Source**: https://developers.google.com/workspace/gmail/api/guides/filter_settings

## Overview

The Gmail Filters API allows developers to configure advanced filtering rules programmatically. According to the documentation, "Filters can automatically add or remove labels or forward emails to verified aliases based on the attributes or content of the incoming message."

## Core Operations

The API supports four primary operations through the Filters resource:

* **Create** - Establish new filter rules
* **List** - Retrieve existing filters
* **Get** - Access specific filter details
* **Delete** - Remove filters

## Matching Criteria

Filters evaluate incoming messages using various properties including sender, subject, date, size, and content. The system accepts Gmail's advanced search syntax patterns. Common matching examples include:

| Criteria | Effect |
|----------|--------|
| `criteria.from='sender@example.com'` | Messages from specific address |
| `criteria.hasAttachment=true` | Messages containing attachments |
| `criteria.size=10485760` with `sizeComparison='larger'` | Large messages (10MB+) |
| `criteria.query='"text string"'` | Content matching |

**Important**: When multiple criteria exist, a message must satisfy all conditions for the filter to apply.

## Actions

Messages matching filter criteria can be modified through these actions:

| Action | Result |
|--------|--------|
| `removeLabelIds=['INBOX']` | Archive message |
| `removeLabelIds=['UNREAD']` | Mark as read |
| `addLabelIds=['IMPORTANT']` | Mark important |
| `addLabelIds=['TRASH']` | Delete |
| `addLabelIds=['<user label id>']` | Apply custom label |

## Code Examples

### Java Implementation

The provided Java example demonstrates filter creation:

```java
Filter filter = new Filter()
    .setCriteria(new FilterCriteria()
        .setFrom("gduser2@workspacesamples.dev"))
    .setAction(new FilterAction()
        .setAddLabelIds(Arrays.asList(labelId))
        .setRemoveLabelIds(Arrays.asList("INBOX")));

Filter result = service.users().settings()
    .filters().create("me", filter).execute();
```

### Python Implementation

The Python example shows similar functionality:

```python
filter_content = {
    "criteria": {"from": "gsuder1@workspacesamples.dev"},
    "action": {
        "addLabelIds": ["IMPORTANT"],
        "removeLabelIds": ["INBOX"],
    },
}

result = service.users().settings()
    .filters().create(userId="me", body=filter_content).execute()
```

Both examples label messages from a specific sender while archiving them automatically.
