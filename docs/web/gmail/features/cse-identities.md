# Client-Side Encryption (CSE) Identities Resource

**Source**: https://developers.google.com/workspace/gmail/api/reference/rest/v1/users.settings.cse.identities
**Retrieved**: 2026-01-30

## Overview

The CSE identities resource manages email encryption configurations for Gmail users. It enables saving drafts of encrypted messages and signing/sending encrypted emails.

## Resource Path

```
users.settings.cse.identities
```

Full path: `https://gmail.googleapis.com/gmail/v1/users/{userId}/settings/cse/identities`

## Key Fields

**CseIdentity** object contains:

* `emailAddress` (string): Primary email address for the sending identity
* `primaryKeyPairId` (string): Associated key pair ID, if configured
* `signAndEncryptKeyPairs` (object): Separate key pairs for signing and encryption

**SignAndEncryptKeyPairs** configuration includes:

* `signingKeyPairId`: "The ID of the CseKeyPair that signs outgoing mail"
* `encryptionKeyPairId`: "The ID of the CseKeyPair that encrypts signed outgoing mail"

## Available Methods

The resource supports five operations:

### 1. create

Establishes a new encrypted identity authorized to send mail.

```http
POST https://gmail.googleapis.com/gmail/v1/users/{userId}/settings/cse/identities
```

### 2. delete

Removes an encryption identity.

```http
DELETE https://gmail.googleapis.com/gmail/v1/users/{userId}/settings/cse/identities/{cseEmailAddress}
```

### 3. get

Retrieves identity configuration details.

```http
GET https://gmail.googleapis.com/gmail/v1/users/{userId}/settings/cse/identities/{cseEmailAddress}
```

### 4. list

Enumerates all encrypted identities for a user.

```http
GET https://gmail.googleapis.com/gmail/v1/users/{userId}/settings/cse/identities
```

### 5. patch

Associates different key pairs with existing identities.

```http
PATCH https://gmail.googleapis.com/gmail/v1/users/{userId}/settings/cse/identities/{emailAddress}
```

## Authorization Requirements

### For Administrators

Service accounts with domain-wide delegation and the following scope:

* `https://www.googleapis.com/auth/gmail.settings.basic`

### For Users

* Hardware key encryption turned on and configured
* Appropriate CSE licenses (Workspace Enterprise Plus or higher)

## CSE Key Management

CSE identities work with the related resource `users.settings.cse.keypairs`:

* Key pairs are created separately from identities
* Key pairs contain the actual encryption keys
* Identities reference key pairs by ID
* Multiple identities can use the same key pair
* Key pairs can be rotated by updating identity associations

## Security Model

Client-Side Encryption (CSE) provides:

* **End-to-end encryption**: Data encrypted on client before transmission
* **Customer-controlled keys**: Keys stored outside Google infrastructure
* **Zero Google access**: No Google system or employee can decrypt
* **S/MIME 3.2 standard**: Based on IETF standard for secure MIME data

## Use Cases

* Sending encrypted emails that Google cannot read
* Compliance with data sovereignty requirements
* Protecting sensitive business communications
* Meeting regulatory requirements (HIPAA, GDPR, etc.)
* Preventing insider threats (even from cloud provider)

## Limitations

* Only available to Workspace Enterprise Plus customers
* Requires hardware security keys for key management
* More complex setup than standard Gmail
* Not compatible with some Gmail features (e.g., Smart Compose)
* Recipients must also have CSE capability to read encrypted messages

## Relationship to Confidential Mode

CSE and Confidential Mode are separate, incompatible features:

| Feature | CSE | Confidential Mode |
|---------|-----|-------------------|
| True encryption | Yes | No |
| API support | Yes | No |
| Google access | No | Yes |
| Key management | Customer | N/A |
| Availability | Enterprise Plus only | All users |

## Example: Creating a CSE Identity

```json
POST /gmail/v1/users/me/settings/cse/identities

{
  "emailAddress": "secure@example.com",
  "primaryKeyPairId": "keypair-123456"
}
```

Response:

```json
{
  "emailAddress": "secure@example.com",
  "primaryKeyPairId": "keypair-123456"
}
```

## Example: Listing CSE Identities

```json
GET /gmail/v1/users/me/settings/cse/identities

{
  "cseIdentities": [
    {
      "emailAddress": "secure@example.com",
      "primaryKeyPairId": "keypair-123456"
    },
    {
      "emailAddress": "admin@example.com",
      "signAndEncryptKeyPairs": {
        "signingKeyPairId": "keypair-789",
        "encryptionKeyPairId": "keypair-101"
      }
    }
  ]
}
```

## Best Practices

* Implement proper key lifecycle management
* Regularly rotate encryption keys
* Maintain secure backup of key material
* Test CSE configuration before production rollout
* Train users on CSE workflows and limitations
* Document which identities use CSE
* Monitor CSE identity changes via admin audit logs
