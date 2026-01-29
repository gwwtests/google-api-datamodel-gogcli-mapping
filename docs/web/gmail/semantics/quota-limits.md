# Gmail API Usage Limits

**URL Source**: https://developers.google.com/gmail/api/reference/quota

**Retrieved**: 2026-01-29

**Published**: 2025-12-11 UTC

## Overview

The Gmail API is subject to usage limits which restrict the rate at which methods of the API can be called. Limits are defined in terms of quota units, an abstract unit of measurement representing Gmail resource usage. There are two usage limits which are applied simultaneously: a per project usage limit and a per user usage limit.

## Usage Limits

| Usage limit type | Limit | Exceeded reason |
| --- | --- | --- |
| Per project rate limit | **1,200,000 quota units per minute** | rateLimitExceeded |
| Per user rate limit | **15,000 quota units per user per minute** | userRateLimitExceeded |

**Note**: For information on handling limit errors, refer to Resolve errors guide.

## Per-method quota usage

The number of quota units consumed by a request varies depending on the method called. The following table outlines the per-method quota unit usage:

| Method | Quota Units |
| --- | --- |
| `drafts.create` | 10 |
| `drafts.delete` | 10 |
| `drafts.get` | 5 |
| `drafts.list` | 5 |
| `drafts.send` | 100 |
| `drafts.update` | 15 |
| `getProfile` | 1 |
| `history.list` | 2 |
| `labels.create` | 5 |
| `labels.delete` | 5 |
| `labels.get` | 1 |
| `labels.list` | 1 |
| `labels.update` | 5 |
| `messages.attachments.get` | 5 |
| `messages.batchDelete` | 50 |
| `messages.batchModify` | 50 |
| `messages.delete` | 10 |
| `messages.get` | 5 |
| `messages.import` | 25 |
| `messages.insert` | 25 |
| `messages.list` | 5 |
| `messages.modify` | 5 |
| `messages.send` | 100 |
| `messages.trash` | 5 |
| `messages.untrash` | 5 |
| `settings.delegates.create` | 100 |
| `settings.delegates.delete` | 5 |
| `settings.delegates.get` | 1 |
| `settings.delegates.list` | 1 |
| `settings.filters.create` | 5 |
| `settings.filters.delete` | 5 |
| `settings.filters.get` | 1 |
| `settings.filters.list` | 1 |
| `settings.forwardingAddresses.create` | 100 |
| `settings.forwardingAddresses.delete` | 5 |
| `settings.forwardingAddresses.get` | 1 |
| `settings.forwardingAddresses.list` | 1 |
| `settings.getAutoForwarding` | 1 |
| `settings.getImap` | 1 |
| `settings.getPop` | 1 |
| `settings.getVacation` | 1 |
| `settings.sendAs.create` | 100 |
| `settings.sendAs.delete` | 5 |
| `settings.sendAs.get` | 1 |
| `settings.sendAs.list` | 1 |
| `settings.sendAs.update` | 100 |
| `settings.sendAs.verify` | 100 |
| `settings.updateAutoForwarding` | 5 |
| `settings.updateImap` | 5 |
| `settings.updatePop` | 100 |
| `settings.updateVacation` | 5 |
| `stop` | 50 |
| `threads.delete` | 20 |
| `threads.get` | 10 |
| `threads.list` | 10 |
| `threads.modify` | 10 |
| `threads.trash` | 10 |
| `threads.untrash` | 10 |
| `watch` | 100 |
