# Gmail SendAs Resource - API Reference

**Source**: https://developers.google.com/workspace/gmail/api/reference/rest/v1/users.settings.sendAs
**Retrieved**: 2026-01-30

## Overview

The `users.settings.sendAs` resource manages send-as aliases in Gmail, corresponding to the "Send Mail As" feature. These are custom "from" addresses or the primary login address.

## Core Fields

**sendAsEmail** (string)
The email in the "From:" header. Read-only except during creation.

**displayName** (string)
Name appearing in "From:" header. For custom addresses, Gmail populates this from the primary account name if empty.

**replyToAddress** (string)
Optional email for "Reply-To:" header. Omitted if empty.

**signature** (string)
Optional HTML signature added to new messages composed with this alias in Gmail's web interface.

**isPrimary** (boolean)
Indicates if this is the account's primary login address. Read-only; every Gmail account has exactly one primary address that cannot be deleted.

**isDefault** (boolean)
Whether selected as the default "From:" address for composing or auto-replies. Only one default exists per account.

**treatAsAlias** (boolean)
Whether Gmail treats this address as an alias for the primary email. Applies only to custom aliases.

**verificationStatus** (enum)
States: `verificationStatusUnspecified`, `accepted`, or `pending`. Read-only; applies to custom aliases only.

## SmtpMsa Configuration

Optional outbound SMTP relay settings (custom aliases only):

* **host** (string): SMTP hostname (required)
* **port** (integer): SMTP port (required)
* **username** (string): Authentication username (write-only)
* **password** (string): Authentication password (write-only)
* **securityMode** (enum): Protocol mode—`none`, `ssl`, or `starttls` (required)

## Available Methods

| Method | Purpose |
|--------|---------|
| **create** | Create custom "from" alias |
| **delete** | Remove specified alias |
| **get** | Retrieve specific alias |
| **list** | Enumerate account aliases |
| **patch** | Partial alias update |
| **update** | Complete alias update |
| **verify** | Send verification email to alias |

## Verification Process

When creating aliases for external addresses, Gmail may require ownership verification:

* Aliases return with status `pending` if verification is needed
* A verification message is automatically sent to the target email
* Aliases without verification requirements have status `accepted`
* Use the verify method to resend verification requests if necessary

## SMTP Configuration

External address aliases should route through a remote SMTP mail sending agent (MSA). Configure connection details using the `smtpMsa` field.

## API Usage

### Listing Aliases

```http
GET https://gmail.googleapis.com/gmail/v1/users/{userId}/settings/sendAs
```

Returns all send-as aliases including the primary account address.

### Creating an Alias

```http
POST https://gmail.googleapis.com/gmail/v1/users/{userId}/settings/sendAs
```

With body:

```json
{
  "sendAsEmail": "alias@example.com",
  "displayName": "My Alias Name",
  "replyToAddress": "reply@example.com",
  "signature": "<div>My Signature</div>",
  "smtpMsa": {
    "host": "smtp.example.com",
    "port": 587,
    "username": "smtp_user",
    "password": "smtp_password",
    "securityMode": "starttls"
  }
}
```

### Updating a Signature

```http
PATCH https://gmail.googleapis.com/gmail/v1/users/{userId}/settings/sendAs/{sendAsEmail}
```

With body:

```json
{
  "signature": "<div>Updated signature</div>"
}
```

## Delegation vs Aliases

**Important distinction**: Delegation and aliases differ:

* **Send-as aliases** control "From:" headers
* **Delegate settings** (separate resource) grant account access permissions

Delegation allows another user to read, send, and delete messages on behalf of the delegator. Send-as aliases only allow sending from different addresses without granting mailbox access.

## Scope Requirements

Requires one of the following OAuth scopes:

* `https://www.googleapis.com/auth/gmail.settings.basic`
* `https://www.googleapis.com/auth/gmail.settings.sharing`

## Limitations

* A delegate user must be referred to by their primary email address
* An email alias cannot be used as the delegate email input
* Only one user can use an email alias
* Addresses other than the primary address can only be updated by service account clients with domain-wide authority
