# Gmail Bandwidth Limits

**URL Source**: https://support.google.com/a/answer/1071518

**Retrieved**: 2026-01-29

**Note**: This is Google Workspace Admin documentation, not Gmail API documentation.

## Overview

All Google Workspace accounts have Gmail bandwidth limits that help ensure the health and safety of Google systems and accounts.

As an admin, you can check the User list in your Admin console for accounts that have been suspended because they've reached Gmail limits. You can also see when the accounts will be reset. In some cases, you can reset the Gmail suspension.

## Avoid large transfers of data

Activities that transfer large amounts of data in a short time can cause Gmail accounts to reach the bandwidth limit. For example, syncing a Gmail account to a third-party email client can use a large amount of data.

Reaching the sync limit triggers a safeguard that temporarily stops IMAP uploads for the account.

## Monitor bandwidth limits for all Google Workspace editions

The following Gmail bandwidth limits apply to all Google Workspace editions and may change without notice.

### Gmail bandwidth limits

| Limit | Per hour | Per day |
| --- | --- | --- |
| Download with web client | 750 MB | 1250 MB |
| Upload with web client (includes emails sent via Gmail SMTP) | 300 MB | 1500 MB |

### POP and IMAP bandwidth limits

| Limit | Per day |
| --- | --- |
| Download with IMAP | 2500 MB |
| Download with POP | 1250 MB |
| Upload with IMAP | 500 MB |

## Manage IMAP bandwidth limits

These guidelines apply to any application that uses IMAP to sync email with Gmail. These applications include third-party email clients and backup tools.

### Manage your IMAP clients

Using multiple IMAP clients with the same account means every message is downloaded multiple times. This increases Gmail bandwidth use exponentially.

To help reduce bandwidth use by IMAP clients:

* Remove or turn off unused IMAP clients.
* Quit IMAP clients when not in use.
* Make sure all clients are set up as described in Recommended IMAP client settings.

### Check for unwanted IMAP clients

Tools or services that back up Google Workspace data often use IMAP to access email. Sometimes, users or admins set up an IMAP client, then stop using it. Or, they're not aware that a service or tool uses IMAP to access Google Workspace.

Here are some ways to identify IMAP clients being used with Google Workspace:

* You can check your Admin console to find out whether any Google Workspace Marketplace apps are using IMAP.
* Account owners can check their Google Accounts authorizations page, and turn off any unwanted items under Connected Sites, Apps, and Services and Application-specific passwords.
* Account owners can change their Google Workspace password so clients that sync with the password can no longer sign into the account. Add IMAP clients back one at a time, using the new password.

### Update IMAP sync settings

To avoid reaching the IMAP download bandwidth limit, change Gmail settings to:

* Increase or remove folder size limits.
* Sync fewer folders in IMAP. **As a best practice, limit this setting to 500 labels.**
