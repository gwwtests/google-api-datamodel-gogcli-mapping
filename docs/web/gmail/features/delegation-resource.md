# Gmail Delegation Settings - API Guide

**Source**: https://developers.google.com/workspace/gmail/api/guides/delegate_settings
**Retrieved**: 2026-01-30

## Overview

Gmail delegation allows users within the same Google Workspace organization to grant mailbox access to another user. The account owner is the "delegator" and the recipient is the "delegate."

## Delegate Permissions

Delegates can perform the following actions on the delegator's account:

* Read messages
* Send messages
* Delete messages
* View contacts
* Add contacts

## Important Limitations

* Delegation only works within the same Google Workspace organization
* Consumer Gmail accounts (non-Workspace) have limited delegation capabilities
* A delegate user must be referred to by their primary email address
* An email alias cannot be used as the delegate email input
* You can't add delegates to an alternate email address or alias because it's not a Google Account

## API Management

Organizations managing delegation must use the `Delegates` resource, which requires "a service account that has been delegated domain-wide authority."

## Available API Methods

The Delegates reference documentation supports four operations:

* **Create** - Add a new delegate
* **List** - View existing delegates
* **Get** - Retrieve specific delegate information
* **Delete** - Remove delegate access

## API Endpoints

### List Delegates

```http
GET https://gmail.googleapis.com/gmail/v1/users/{userId}/settings/delegates
```

Returns all delegates for the specified user.

### Create Delegate

```http
POST https://gmail.googleapis.com/gmail/v1/users/{userId}/settings/delegates
```

With body:

```json
{
  "delegateEmail": "delegate@example.com"
}
```

### Get Delegate

```http
GET https://gmail.googleapis.com/gmail/v1/users/{userId}/settings/delegates/{delegateEmail}
```

### Delete Delegate

```http
DELETE https://gmail.googleapis.com/gmail/v1/users/{userId}/settings/delegates/{delegateEmail}
```

## Resource Structure

The Delegate resource contains:

* **delegateEmail** (string): The email address of the delegate
* **verificationStatus** (enum): The verification status of the delegation

Verification status values:

* `verificationStatusUnspecified`
* `accepted` - Delegate has accepted the delegation
* `pending` - Delegation request sent but not yet accepted
* `rejected` - Delegate rejected the delegation
* `expired` - Delegation request expired

## Delegation vs Send-As Aliases

**Key Distinction**: "Delegates can read, send, and delete messages, as well as view and add contacts, for the delegator's account." This distinguishes delegation from send-as aliases, which only permit sending mail under an alternative address without granting full mailbox access.

| Feature | Delegation | Send-As Aliases |
|---------|-----------|-----------------|
| Read messages | Yes | No |
| Send messages | Yes | Yes |
| Delete messages | Yes | No |
| Access contacts | Yes | No |
| Multiple users | No (one delegate per account) | No (one user per alias) |
| Requires acceptance | Yes | No (for owned addresses) |

## Use Cases

**Delegation**: When you need someone else to manage your entire mailbox (e.g., executive assistant managing executive's email)

**Send-As Aliases**: When you need to send from different addresses yourself (e.g., personal + business addresses, department addresses)

## Scope Requirements

Requires domain-wide delegation and the following OAuth scope:

* `https://www.googleapis.com/auth/gmail.settings.sharing`

## Best Practices

* Only grant delegation to trusted users within your organization
* Regularly audit delegate access
* Remove delegation when no longer needed
* Use send-as aliases instead of delegation when full mailbox access is not required
* Document delegation relationships for security and compliance
