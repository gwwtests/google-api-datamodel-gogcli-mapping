# Gmail API Snooze Date Feature Request - Issue #287304309

**Source**: https://issuetracker.google.com/issues/287304309
**Retrieved**: 2026-01-30

## Issue Overview

This is a feature request asking Google to expose snooze information through the Gmail API, which currently lacks any indication of when snoozed messages will reenter the inbox.

## Core Problem

The requester identifies three main issues:

1. **Visibility gap**: "Snoozed messages does not have any indication as to when the message re-entered the inbox," making messages appear out of order.

2. **Missing metadata**: Messages in the snoozed state don't reveal their reentry time, though this information exists in Gmail's web UI.

3. **Third-party integration**: Snooze functionality is widespread in third-party clients but lacks standardized API support.

## Proposed Solutions

The requester suggests multiple implementation approaches:

* **Custom headers**: Add X-Snoozed headers with snooze timing information
* **New API endpoint**: Create a dedicated method returning message and snooze objects
* **Hybrid approach**: Provide snooze data through both headers and REST API

## Status Information

The issue includes structured metadata fields tracking: assignee, status classification ("processed," "triaged," "blocked"), quality scoring, and related component tags. The document indicates ongoing triage and tracking but reveals no final resolution.

## API Implications

Currently, the Gmail API:

* Does not expose snooze state or timing
* Cannot set snooze on messages
* Cannot query when a message will "unsnoozed"
* Treats snoozed messages as having the SNOOZED system label only

## Workarounds

Third-party applications typically implement their own snooze mechanisms using:

* Custom labels for snooze state
* External databases to track snooze times
* Scheduled tasks to "unsnooze" messages at the appropriate time
* Label manipulation to show/hide messages

However, these workarounds are incompatible with Gmail's native snooze feature.
