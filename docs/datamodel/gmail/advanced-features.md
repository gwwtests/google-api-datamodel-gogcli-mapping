# Gmail API Advanced Features

**Last Updated**: 2026-01-30

**Research Sources**: See `docs/web/gmail/features/` for detailed archival materials

This document synthesizes research on Gmail API features that are either not fully documented or have limited/no API support.

## Executive Summary

Many user-facing Gmail features have limited or no API support, requiring workarounds or alternative approaches:

* **Snooze**: No API support (blocked feature requests)
* **Categories/Tabs**: Supported via CATEGORY_* labels
* **Priority Inbox/Important**: Supported via IMPORTANT label with ML algorithm
* **Send As**: Full API support via users.settings.sendAs
* **Delegation**: Full API support via users.settings.delegates
* **Confidential Mode**: No API support
* **Client-Side Encryption**: Limited API support via users.settings.cse.identities
* **Scheduled Send**: No API support (blocked feature request)

## 1. Snooze Feature

### User-Facing Feature

Gmail allows users to "snooze" messages, temporarily hiding them from the inbox until a specified time. Snoozed messages appear in a dedicated "Snoozed" folder and automatically return to the inbox at the scheduled time.

### API Support Status

**NO API SUPPORT** - The Gmail API does not expose snooze functionality.

### What the API Provides

* **SNOOZED** system label - Indicates a message is currently snoozed
* No snooze time information
* No method to set or modify snooze state
* No method to query when a message will "unsnoozed"

### Feature Requests

Two active feature requests exist:

1. **Issue #109952618**: "Gmail API should expose snooze features"
   * Status: Blocked
   * Request: Expose native snooze functionality to prevent incompatible third-party implementations

2. **Issue #287304309**: "Gmail API should indicate the message's snoozed date"
   * Request: Add snooze timing metadata via custom headers or new API endpoint
   * Proposed: X-Snoozed headers or dedicated snooze objects

### Workarounds

Third-party applications typically implement proprietary snooze using:

* Custom labels to mark snoozed state
* External database to store snooze times
* Scheduled tasks to "unsnooze" at appropriate time
* Label manipulation to show/hide messages

**Limitation**: These workarounds are incompatible with Gmail's native snooze feature.

### API Example

Querying for snoozed messages:

```http
GET /gmail/v1/users/me/messages?labelIds=SNOOZED
```

Response includes messages with SNOOZED label, but no snooze time information.

### Recommendations

* Use external scheduling infrastructure
* Maintain separate database for snooze metadata
* Document incompatibility with Gmail's native snooze
* Monitor issue tracker for future API support

**Source**: `docs/web/gmail/features/snooze-*.md`

## 2. Categories and Tabs

### User-Facing Feature

Gmail automatically categorizes incoming messages into tabs:

* **Primary** - Personal emails and important messages
* **Social** - Social media notifications
* **Promotions** - Marketing emails and offers
* **Updates** - Automated confirmations and notifications
* **Forums** - Mailing lists and forum posts

### API Support Status

**FULL SUPPORT** - Categories are exposed as system labels.

### Category Label Names

In the Gmail API, categories appear as:

* **CATEGORY_PERSONAL** - Primary tab
* **CATEGORY_SOCIAL** - Social tab
* **CATEGORY_PROMOTIONS** - Promotions tab
* **CATEGORY_UPDATES** - Updates tab
* **CATEGORY_FORUMS** - Forums tab

### How Categorization Works

Gmail's machine learning algorithms automatically assign categories based on:

* Message content analysis
* Sender reputation and history
* User behavior patterns
* Historical interaction data
* Engagement signals

### API Access

Categories appear in the `labelIds` array of messages:

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

### Querying by Category

```http
GET /gmail/v1/users/me/messages?labelIds=CATEGORY_SOCIAL
```

### Search Operators

* `category:social` - Find social messages
* `category:promotions` - Find promotional messages
* `category:personal` - Find primary/personal messages

### Limitations

* Cannot create custom categories
* Cannot manually assign categories (auto-assigned only)
* Users with >250,000 emails cannot use categorized inbox
* Messages typically have only one category label

### 2026 Updates

Gmail's AI Inbox feature (launched early 2026) enhances categorization with:

* Personalized briefings
* Advanced relevance scoring
* Semantic context analysis

**Source**: `docs/web/gmail/features/category-labels.md`

## 3. Priority Inbox and Important Label

### User-Facing Feature

Gmail's Priority Inbox uses machine learning to identify important messages, displaying them prominently in a dedicated section.

### API Support Status

**FULL SUPPORT** - Important messages marked with IMPORTANT label.

### The IMPORTANT Label

System label automatically applied by Gmail's ML model to messages predicted to be important to the user.

### Machine Learning Algorithm

**Model**: Per-user logistic regression trained on user behavior

**Accuracy**: ~80% ± 5%

**Key Signals Analyzed**:

* Which emails user opens
* Which emails user replies to
* Which emails user ignores
* Sender frequency and interaction history
* Message content and keywords
* Semantic context

**Performance Impact** (from Google Research study):

* 6% less time reading mail overall
* 13% less time reading unimportant mail

### Technical Implementation

* **Storage**: Google Bigtable for models and training data
* **Update frequency**: Near-online, millions of models per day
* **Personalization**: Individual per-user models with personalized thresholds
* **Learning**: Continuous feedback loop from user actions

### API Access

Query important messages:

```http
GET /gmail/v1/users/me/messages?labelIds=IMPORTANT
```

Search operators:

* `is:important` - Find important messages
* `-is:important` - Find non-important messages

### Manual Override

Applications can add/remove the IMPORTANT label:

```http
POST /gmail/v1/users/me/messages/{id}/modify
{
  "addLabelIds": ["IMPORTANT"],
  "removeLabelIds": []
}
```

This provides user feedback to the algorithm.

### API Limitations

* No access to importance score or probability
* No ability to manually trigger re-scoring
* No access to underlying ML features or weights
* Cannot query the algorithm's reasoning

### Priority Inbox Organization

Three sections:

1. **Important and unread** - ML-predicted important messages
2. **Starred** - User-marked messages
3. **Everything else** - Remaining messages

### 2026 Updates

March 2025: Gmail replaced chronological search with AI relevance model

* "Most Relevant" sorting by default
* Based on engagement signals and semantic context

**Source**: `docs/web/gmail/features/priority-inbox-algorithm.md`

**Research Paper**: `docs/web/gmail/features/priority-inbox-paper.pdf` (Aberdeen & Pacovsky)

## 4. Send As (Multiple From Addresses)

### User-Facing Feature

"Send Mail As" allows users to send email from different addresses or aliases, appearing in the From: header.

### API Support Status

**FULL SUPPORT** - Complete API via `users.settings.sendAs` resource.

### Send-As Resource Structure

**Resource**: `users.settings.sendAs`

**Key Fields**:

* `sendAsEmail` (string) - The email in "From:" header
* `displayName` (string) - Name in "From:" header
* `replyToAddress` (string) - Optional "Reply-To:" header
* `signature` (string) - HTML signature for this alias
* `isPrimary` (boolean) - Is this the primary account address?
* `isDefault` (boolean) - Default for composing new messages
* `treatAsAlias` (boolean) - Treated as alias of primary email
* `verificationStatus` (enum) - accepted, pending, verificationStatusUnspecified

### SMTP Configuration

For external addresses, configure outbound SMTP relay:

```json
{
  "smtpMsa": {
    "host": "smtp.example.com",
    "port": 587,
    "username": "smtp_user",
    "password": "smtp_password",
    "securityMode": "starttls"
  }
}
```

### Available Methods

* **create** - Add new send-as alias
* **delete** - Remove alias
* **get** - Retrieve specific alias
* **list** - Enumerate all aliases
* **patch** - Partial update
* **update** - Complete update
* **verify** - Send verification email

### Verification Process

External addresses require verification:

1. Create alias → returns status `pending`
2. Gmail sends verification email to target address
3. User clicks verification link
4. Status changes to `accepted`

### API Examples

List all send-as aliases:

```http
GET /gmail/v1/users/me/settings/sendAs
```

Create a new alias:

```http
POST /gmail/v1/users/me/settings/sendAs
{
  "sendAsEmail": "alias@example.com",
  "displayName": "My Alias",
  "signature": "<div>My Signature</div>"
}
```

### Sending from an Alias

When sending via API, set the From header:

```
From: alias@example.com
```

Gmail validates the From address against configured send-as aliases.

### Required Scopes

* `https://www.googleapis.com/auth/gmail.settings.basic`
* `https://www.googleapis.com/auth/gmail.settings.sharing`

**Source**: `docs/web/gmail/features/sendas-resource.md`

## 5. Delegation

### User-Facing Feature

Delegation allows one user (delegator) to grant another user (delegate) full access to their mailbox.

### API Support Status

**FULL SUPPORT** - Complete API via `users.settings.delegates` resource.

### Delegate Permissions

Delegates can:

* Read all messages
* Send messages on behalf of delegator
* Delete messages
* View contacts
* Add contacts

### API Resource

**Resource**: `users.settings.delegates`

**Fields**:

* `delegateEmail` (string) - Email of the delegate
* `verificationStatus` (enum) - accepted, pending, rejected, expired

### Available Methods

* **create** - Add new delegate
* **delete** - Remove delegate
* **get** - Retrieve specific delegate info
* **list** - List all delegates

### API Examples

List delegates:

```http
GET /gmail/v1/users/me/settings/delegates
```

Add delegate:

```http
POST /gmail/v1/users/me/settings/delegates
{
  "delegateEmail": "delegate@example.com"
}
```

Remove delegate:

```http
DELETE /gmail/v1/users/me/settings/delegates/{delegateEmail}
```

### Delegation vs Send-As Comparison

| Feature | Delegation | Send-As Aliases |
|---------|-----------|-----------------|
| Read messages | ✓ Yes | ✗ No |
| Send messages | ✓ Yes | ✓ Yes |
| Delete messages | ✓ Yes | ✗ No |
| Access contacts | ✓ Yes | ✗ No |
| Multiple users | ✗ No | ✗ No |
| Requires acceptance | ✓ Yes | ✗ No (for owned) |

### Key Distinction

* **Delegation**: Grants another user complete mailbox access
* **Send-As**: Allows you to send from different addresses yourself

### Use Cases

* **Delegation**: Executive assistant managing executive's email
* **Send-As**: Individual sending from multiple addresses (personal + business)

### Limitations

* Only works within same Google Workspace organization
* Consumer Gmail has limited delegation
* Must use primary email addresses (not aliases)
* Requires domain-wide delegation for API access

### Required Scopes

* `https://www.googleapis.com/auth/gmail.settings.sharing`
* Requires service account with domain-wide authority

**Source**: `docs/web/gmail/features/delegation-resource.md`

## 6. Confidential Mode

### User-Facing Feature

Confidential Mode allows sending emails that:

* Expire after a set time (1 day to 5 years)
* Cannot be forwarded, copied, printed, or downloaded
* Can be revoked at any time
* Optionally require SMS passcode

### API Support Status

**NO API SUPPORT** - Cannot set confidential mode via API.

### How It Works

Gmail replaces message body and attachments with a link:

1. Recipient clicks link to view message
2. Optionally enters SMS passcode
3. Views in restricted web interface
4. Access expires or is revoked

### Critical Limitations

**Not Truly Secure**:

* **NOT end-to-end encrypted** - Google can read the message
* **NOT truly deleted** - Remains on Google servers after expiration
* **NOT protected from screenshots** - Recipients can screenshot
* **NOT protected from manual copying** - Recipients can copy text

**Information Rights Management (IRM)**:

Confidential mode implements IRM (Digital Rights Management) which prevents certain actions but does not prevent unauthorized access.

### API Implications

Messages sent with confidential mode:

* Have no special label or flag in API
* Cannot be identified as confidential via API
* Appear as normal messages
* Link-based delivery is transparent to API

### Alternative: Client-Side Encryption (CSE)

For true security, use CSE instead:

* **End-to-end encrypted** - Google cannot read
* **Customer-controlled keys** - Keys stored outside Google
* **API support** - Via `users.settings.cse.identities`
* **S/MIME standard** - Based on IETF S/MIME 3.2

### CSE vs Confidential Mode

| Feature | Confidential Mode | Client-Side Encryption |
|---------|------------------|------------------------|
| End-to-end encryption | ✗ No | ✓ Yes |
| Google can read | ✓ Yes | ✗ No |
| API support | ✗ No | ✓ Yes (limited) |
| Prevents forwarding | ✓ Yes | ✗ No |
| Prevents screenshots | ✗ No | ✗ No |
| Availability | All users | Enterprise Plus only |

### Recommendations

* **For casual privacy**: Use confidential mode (web UI only)
* **For true security**: Use Client-Side Encryption
* **For API automation**: Implement your own encryption layer
* **For compliance**: Document that confidential mode is not truly secure

**Source**: `docs/web/gmail/features/confidential-mode.md`

## 7. Client-Side Encryption (CSE)

### User-Facing Feature

CSE provides true end-to-end encryption where:

* Messages encrypted on client before transmission
* Encryption keys under customer control
* Keys stored outside Google infrastructure
* Google cannot decrypt messages

### API Support Status

**LIMITED SUPPORT** - Via `users.settings.cse.identities` resource.

### CSE Identities Resource

**Resource**: `users.settings.cse.identities`

**Fields**:

* `emailAddress` (string) - Primary email for sending identity
* `primaryKeyPairId` (string) - Associated key pair ID
* `signAndEncryptKeyPairs` (object) - Separate keys for signing and encryption
  * `signingKeyPairId` - Key for signing outgoing mail
  * `encryptionKeyPairId` - Key for encrypting outgoing mail

### Available Methods

* **create** - Create new encrypted identity
* **delete** - Remove encryption identity
* **get** - Retrieve identity details
* **list** - List all encrypted identities
* **patch** - Update key pair associations

### API Examples

Create CSE identity:

```http
POST /gmail/v1/users/me/settings/cse/identities
{
  "emailAddress": "secure@example.com",
  "primaryKeyPairId": "keypair-123456"
}
```

List CSE identities:

```http
GET /gmail/v1/users/me/settings/cse/identities
```

Response:

```json
{
  "cseIdentities": [
    {
      "emailAddress": "secure@example.com",
      "primaryKeyPairId": "keypair-123456"
    }
  ]
}
```

### Key Management

CSE identities work with `users.settings.cse.keypairs`:

* Key pairs created separately from identities
* Identities reference key pairs by ID
* Multiple identities can use same key pair
* Key pairs can be rotated by updating associations

### Requirements

* **License**: Workspace Enterprise Plus or higher
* **Hardware keys**: Required for key management
* **Admin setup**: Complex configuration required
* **Service account**: With domain-wide delegation

### Scope Requirements

* `https://www.googleapis.com/auth/gmail.settings.basic`

### Security Model

* **End-to-end encryption**: Data encrypted before leaving client
* **Customer-controlled keys**: Organization owns and manages keys
* **Zero Google access**: No Google system can decrypt
* **S/MIME 3.2 standard**: Industry-standard secure MIME

### Limitations

* Only Workspace Enterprise Plus
* Requires hardware security keys
* Complex setup and key management
* Not compatible with some Gmail features (e.g., Smart Compose)
* Recipients must have CSE to read encrypted messages

### Use Cases

* Protecting sensitive business communications
* Meeting regulatory requirements (HIPAA, GDPR)
* Data sovereignty compliance
* Preventing insider threats
* Government and legal communications

**Source**: `docs/web/gmail/features/cse-identities.md`

## 8. Scheduled Send

### User-Facing Feature

Gmail web UI allows scheduling messages for future delivery:

1. Compose message
2. Click "Schedule send" instead of "Send"
3. Select date/time
4. Gmail automatically sends at scheduled time

### API Support Status

**NO API SUPPORT** - Cannot schedule messages via API.

### Feature Request

**Issue #140922183**: "Expose functionality for creating scheduled emails"

* Status: Blocked
* Request: Create messages scheduled for later delivery via API
* Gap: Web UI has feature, but not exposed in API

### Draft Resource Limitations

The Draft resource contains only:

```json
{
  "id": "string",
  "message": {
    // Message object
  }
}
```

**Notable absence**: No `scheduledTime`, `scheduledSend`, or similar fields.

### Current Workarounds

Developers must implement external scheduling:

1. **External Database**:
   * Store draft ID and scheduled time
   * Use cron jobs or task schedulers
   * Call `drafts.send` at scheduled time

2. **Third-Party Services**:
   * Use email scheduling services
   * Services maintain own infrastructure

3. **Apps Script**:
   * Use Google Apps Script
   * Time-driven triggers
   * Limited to Apps Script environment

### Example Workaround Architecture

```
1. Create draft via API → get draft ID
2. Store {draftId, scheduledTime, userId} in database
3. Background job polls for due messages
4. When time arrives, call drafts.send(draftId)
5. Update database with sent status
```

### Potential Future Implementation

If implemented, might include:

**Extended Draft Resource**:

```json
{
  "id": "string",
  "message": { },
  "scheduledSendTime": "2026-02-01T10:00:00.000Z"
}
```

**New Methods**:

* `drafts.schedule(draftId, scheduledTime)` - Schedule draft
* `drafts.unschedule(draftId)` - Cancel scheduled send
* `drafts.list` - Filter for scheduled drafts
* `scheduledMessages.list()` - List all scheduled messages

**System Label**: `SCHEDULED` to identify scheduled messages

### DateTime Format

Based on Gmail API patterns, would likely use:

* **Format**: RFC 3339 / ISO 8601
* **Example**: `2026-01-31T14:30:00.000Z`
* **Timezone**: UTC with Z suffix
* **Precision**: Milliseconds

### Use Cases Blocked

Without API support, cannot:

* Build email clients with native scheduled send
* Automate scheduled campaigns via API
* Migrate scheduled emails programmatically
* Integrate scheduling with business systems
* Build workflow automation with scheduled emails

### Recommendations

* Implement external scheduling infrastructure
* Document limitations for users
* Consider Apps Script for Workspace users
* Monitor issue tracker for updates
* Educate users that scheduling is web-UI only

**Source**: `docs/web/gmail/features/scheduled-send-request.md`, `docs/web/gmail/features/draft-resource.md`

## Summary of API Support

| Feature | API Support | System Label | Workaround Available |
|---------|-------------|--------------|---------------------|
| Snooze | ✗ None | SNOOZED | External scheduling |
| Categories | ✓ Full | CATEGORY_* | N/A |
| Important | ✓ Full | IMPORTANT | N/A |
| Send As | ✓ Full | N/A | N/A |
| Delegation | ✓ Full | N/A | N/A |
| Confidential Mode | ✗ None | None | Use CSE |
| Client-Side Encryption | ⚠ Limited | None | N/A |
| Scheduled Send | ✗ None | None | External scheduling |

## Key Takeaways

1. **Category and Priority features** work well via API with CATEGORY_* and IMPORTANT labels

2. **Send-as and Delegation** have complete API support for managing multiple identities

3. **Snooze and Scheduled Send** require external infrastructure as API support is blocked

4. **Confidential Mode** has no API support; use CSE for true security

5. **Client-Side Encryption** provides real security but requires Enterprise Plus license

6. **Machine Learning features** (categories, importance) are transparent - you can query results but not control the algorithm

7. **Feature requests exist** for snooze and scheduled send, but are blocked pending other work

## Development Recommendations

### For Maximum Compatibility

* Use CATEGORY_* and IMPORTANT labels for organization
* Implement external scheduling for snooze and scheduled send
* Use CSE instead of confidential mode for security
* Document API limitations to users
* Monitor Gmail API release notes for new features

### For Enterprise Applications

* Leverage delegation for administrative access
* Use send-as aliases for departmental addresses
* Implement CSE for sensitive communications
* Build external scheduling infrastructure
* Maintain compatibility with web UI features

### For Third-Party Clients

* Query CATEGORY_* labels to recreate tab view
* Show IMPORTANT label for priority inbox
* Implement custom snooze (document incompatibility)
* Build scheduled send using external scheduler
* Warn users about confidential mode limitations

## References

All detailed research materials available in:

* `docs/web/gmail/features/` - Archived source materials
* Each feature has .url, .meta.json, and .md files
* Includes Google Issue Tracker feature requests
* Official Gmail API documentation
* Google Research papers on Priority Inbox

## Related Documentation

* `docs/datamodel/gmail/ux-to-data-mapping.md` - UI to API mapping
* `docs/datamodel/gmail/identifiers.md` - Gmail identifier system
* `docs/web/gmail/semantics/labels-guide.md` - Label system details
* `docs/web/gmail/semantics/delegation-guide.md` - Delegation semantics
