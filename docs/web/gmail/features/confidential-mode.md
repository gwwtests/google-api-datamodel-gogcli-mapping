# Gmail Confidential Mode

**Sources**:

* https://mailmeteor.com/blog/gmail-confidential-mode
* https://support.google.com/mail/thread/8673709
* https://www.getmailbird.com/private-mode-email-security-myth/
* https://support.google.com/a/answer/7684332

**Retrieved**: 2026-01-30

## Overview

Gmail confidential mode lets you set an expiration date for your emails, after which the recipient will no longer be able to view the content of the message and its attachments.

## Key Features

* **Expiration dates**: Set email expiration from one day, one week, one month, three months, or up to five years
* **Access control**: Messages don't have options to forward, copy, print, or download messages or attachments
* **Revocation**: You can revoke the recipient's access to that email at any given time
* **SMS passcode**: Optionally require SMS passcode for access

## API Support

**CRITICAL LIMITATION**: The Gmail API does not support setting confidential mode on a message. There is currently no programmatic way to enable confidential mode through the API.

From Gmail Community support thread: "Trying to use confidential mode programmatically" - confirmed that the API does not expose this functionality.

## How Confidential Mode Works

When a message is sent in Gmail confidential mode, Gmail replaces the message body and attachments with a link. Recipients must:

1. Click the link to view the message
2. Optionally enter an SMS passcode
3. View the message in a restricted interface

## Important Limitations

### Not Truly "Self-Destructing"

Gmail doesn't actually delete confidential messages:

* The email won't self-destruct after the period of time chosen by the sender
* The confidential email remains in your "Sent" folder until you delete it
* It stays on Google's servers after expiration

### Not End-to-End Encrypted

* **Google can still see your confidential message**, so your email is not private
* Confidential Mode has a complete absence of end-to-end encryption
* Emails remain completely unencrypted on Google's servers throughout their entire lifecycle

### Information Rights Management (IRM)

Gmail Confidential Mode implements Information Rights Management (IRM)—a Digital Rights Management approach designed to prevent certain actions rather than prevent unauthorized access. This means it restricts actions like forwarding, copying, and printing, but doesn't provide true encryption.

## Security Implications

Confidential mode provides:

* **Limited protection** against casual forwarding
* **No protection** against screenshots
* **No protection** against Google's access
* **No protection** against recipient copying text manually
* **No protection** against court orders or government requests

## Alternative: Client-Side Encryption (CSE)

For true security, Gmail offers a separate feature called Client-Side Encryption (CSE):

* Emails encrypted on the client before transmission
* Encryption keys under organization's sole control
* Keys stored outside of Google's infrastructure
* No Google system or employee can access CSE content
* Based on S/MIME 3.2 IETF standard

### CSE vs Confidential Mode

| Feature | Confidential Mode | Client-Side Encryption |
|---------|------------------|------------------------|
| End-to-end encryption | No | Yes |
| Google can read | Yes | No |
| API support | No | Yes (limited) |
| Prevents forwarding | Yes | No |
| Prevents screenshots | No | No |
| Requires recipient cooperation | Yes | Yes |
| Available to | All users | Workspace Enterprise Plus |

## CSE API Support

Client-Side Encryption has limited API support through:

* `users.settings.cse.identities` - Manage CSE identities
* `users.settings.cse.keypairs` - Manage encryption key pairs

See: https://developers.google.com/workspace/gmail/api/reference/rest/v1/users.settings.cse.identities

## 2026 Updates

In 2026, CSE default mode allows IT admins to set a policy that makes E2EE messages a default setting in Gmail for teams that regularly deal with sensitive data.

## Confidential Mode in API Messages

Messages sent with confidential mode enabled:

* Do not have any special label or flag in the API
* Cannot be identified as confidential through the API
* Appear as normal messages with standard fields
* The link-based content delivery is transparent to the API

## Workarounds for Developers

Since the API doesn't support confidential mode:

1. **Use CSE instead** - Provides true encryption with API support
2. **External encryption** - Encrypt content before sending via API
3. **Third-party services** - Use external secure message services
4. **PGP/GPG** - Implement your own end-to-end encryption

## Best Practices

* **For casual privacy**: Use confidential mode in web interface
* **For true security**: Use Client-Side Encryption or external encryption
* **For API automation**: Implement your own encryption layer
* **For compliance**: Document that confidential mode is not truly secure

## Admin Controls

Workspace administrators can:

* Enable or disable confidential mode for the domain
* Set default expiration times
* Require or disable SMS passcode requirements
* Monitor confidential mode usage (but not content)

See: https://support.google.com/a/answer/7684332
