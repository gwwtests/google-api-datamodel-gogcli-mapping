# Managing Delegates

**URL Source**: https://developers.google.com/gmail/api/guides/delegate_settings

**Retrieved**: 2026-01-29

**Published**: 2025-12-11 UTC

## Overview

A Gmail user can grant mailbox access to another user in the same Google Workspace organization. The user granting access is referred to as the _delegator_ and the user receiving the access is the _delegate_.

Delegates can read, send, and delete messages, as well as view and add contacts, for the delegator's account. See Set up mail delegation for more information about delegates.

## Requirements

Google Workspace organizations can use the `Delegates` resource to manage the delegates of accounts in their organization. This **requires use of a service account that has been delegated domain-wide authority**.

## Operations

The Delegates reference contains more information on how to:

* `create` - Add a delegate
* `list` - List all delegates
* `get` - Get a specific delegate
* `delete` - Remove a delegate

## Key Constraints

* **Same organization only**: Delegation only works between users in the same Google Workspace organization
* **Service account required**: Requires service account with delegated domain-wide authority
* **Permissions**: Delegates can read, send, and delete messages, as well as view and add contacts

## Multi-Account Semantics

**Important for multi-account applications**:

* Delegates access the delegator's mailbox, but API calls must still be scoped to a specific userId
* When a delegate accesses a delegated mailbox, they use their own credentials but operate on the delegator's data
* Message IDs and thread IDs in a delegated mailbox belong to the delegator's account
* There is no indication in the API response that shows which account a message came from - the application must track context

## Unanswered Questions

The documentation does NOT specify:

* Whether message IDs and thread IDs are the same when viewed by delegator vs delegate
* How label IDs work in delegated access scenarios
* Whether history IDs are shared between delegator and delegate views
