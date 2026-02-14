# Gmail UNREAD Label Is Per-Message, Not Per-Thread

**Date**: 2026-02-14
**Category**: Gmail API Data Model Observation

## Observation

Gmail's `UNREAD` label is applied at the **message level**, not the **thread level**. This means within a single thread (conversation), individual messages can have different read/unread states.

## What This Means

When you open a Gmail thread in the web UI, Gmail typically marks all visible messages as read. However, several scenarios produce threads where only *some* messages are unread:

* **New reply in an existing thread**: You've read the first 5 messages, then a 6th arrives. The thread now has 5 read + 1 unread messages (unread ratio: 0.1667).
* **Partial viewing**: In some clients, collapsing/expanding individual messages may not mark all of them as read.
* **API-level label manipulation**: Programmatic tools can add/remove `UNREAD` from individual messages via `users.messages.modify`.
* **Filters and rules**: Server-side filters that add/remove labels act per-message as they arrive.

## Data Model Implications

### Thread-Level "Unread" is Derived

The Gmail API does not have a `thread.isUnread` field. Instead:

* A thread **appears unread** in the UI if **any** of its messages have the `UNREAD` label
* The `threads.list` endpoint with `labelIds=UNREAD` returns threads that contain **at least one** unread message
* To determine the exact unread state, you must fetch all messages in the thread and check each one's `labelIds`

### Per-Message Label Structure

```
Thread (id: "18abc123")
├── Message 1 (labelIds: ["INBOX", "IMPORTANT"])          ← read
├── Message 2 (labelIds: ["INBOX"])                        ← read
├── Message 3 (labelIds: ["INBOX", "UNREAD"])              ← UNREAD
└── Message 4 (labelIds: ["INBOX", "UNREAD", "IMPORTANT"]) ← UNREAD
```

In this synthetic example, the thread has 4 messages with 2 unread — an unread ratio of 0.50.

### Unread Ratio Distribution (Synthetic Example)

For a hypothetical inbox of 100 multi-message threads:

| Unread Ratio | Count | Description |
|-------------|-------|-------------|
| 0.0000 | 45 | Fully read threads |
| 0.0001–0.4999 | 20 | Mostly read, few new replies |
| 0.5000–0.8999 | 8 | Partially read (the interesting range) |
| 0.9000–0.9999 | 2 | Almost entirely unread |
| 1.0000 | 25 | Fully unread threads |

The "interesting" threads are those with ratios between 0.5 and 0.9 — these conclusively demonstrate that UNREAD is per-message, because if it were per-thread, every thread would have ratio exactly 0.0 or 1.0.

## Reproducing This Observation

Two scripts are provided in `scripts/` to collect and analyze this data empirically:

1. **`scripts/gmail-thread-unread-stats.sh`** — Queries Gmail via gogcli, fetches thread details, computes per-thread unread ratios, outputs CSV
2. **`scripts/gmail-thread-unread-report.sh`** — Consumes the CSV and produces a formatted report with top/bottom ranked threads and summary statistics

Usage:

```bash
# Collect data (read-only, no modifications)
./scripts/gmail-thread-unread-stats.sh --account you@gmail.com --max 200 \
    > /tmp/claude/gogcli/thread-unread-stats.csv

# Generate report
./scripts/gmail-thread-unread-report.sh -i /tmp/claude/gogcli/thread-unread-stats.csv
```

## Implications for Multi-Account Data Merging

When combining Gmail data from multiple accounts:

* Thread IDs are unique within an account but NOT globally unique
* The same email thread shared between two accounts will have **different thread IDs** in each account
* Unread state is also per-account — the same message can be read in Account A but unread in Account B

## Cross-References

* [Gmail API Common Confusions](./2026-01-30--gmail-api-common-confusions-research.md) — covers other non-obvious Gmail API behaviors
* [Gmail API Labels Documentation](../docs/web/gmail/labels/) — archived label system documentation
* [Gmail API Messages vs Threads](../docs/datamodel/gmail/) — data model documentation
