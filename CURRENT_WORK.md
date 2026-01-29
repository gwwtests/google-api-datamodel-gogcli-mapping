# Current Work

**Last Updated**: 2025-01-29

## Current Focus: Gmail API Data Model

We are starting with Gmail as it's the most commonly used feature of `gog` and has complex data model questions (messages vs threads, labels, identifiers).

### Status

```
[■■■■■■■■□□] 80% - Gmail API Research (Documentation Phase)
```

### Completed

- [x] Repository structure created
- [x] Agent methodology documented (AGENTS.md)
- [x] Analyzed gogcli source for Gmail API usage
- [x] Created initial research requests
- [x] Archived Gmail API official documentation
  - Messages, Threads, Labels, History references
  - Sync guide, Push notifications guide
  - Filtering guide
- [x] Created comprehensive data model analysis (`docs/gmail-data-model-findings.md`)
- [x] Updated research requests with findings

### Key Findings

**Answered Questions** (12 of 25):
- Identifiers are immutable (messageId, threadId, labelId)
- Timestamps are epoch milliseconds in UTC
- Threading based on References/In-Reply-To headers + Subject
- History available for ~1 week, monotonically increasing
- Labels: system vs user types, max 10K user labels

**Critical Gap** (9 questions need empirical testing):
- **ID uniqueness scope NOT documented** - we don't know if messageId/threadId are globally unique or per-user
- Recommendation: Always use composite keys `(userId, messageId)` until verified

### Next Steps

1. [ ] Create test harness to empirically verify:
   - ID uniqueness across accounts
   - System label ID consistency
   - Thread behavior edge cases

2. [ ] Move to Calendar API research (Phase 2)

### Research Tracking

See: `research/RESEARCH_REQUESTS.md` - 12 completed, 4 partial, 9 need testing

### Key Files

* `docs/gmail-data-model-findings.md` - **Main findings document**
* `docs/web/gmail/INDEX.md` - Archive inventory
* `research/RESEARCH_REQUESTS.md` - Question tracking
* `research/gogcli-analysis/gmail-api-usage.md` - How gogcli uses Gmail API

## How to Resume Work

If starting a new session:

1. Read this file (CURRENT_WORK.md)
2. Read `docs/gmail-data-model-findings.md` for current understanding
3. Check `research/RESEARCH_REQUESTS.md` for open questions
4. Continue from "Next Steps" above

## Quick Context

**gogcli Gmail commands** (from source analysis):
- `gog gmail search` - Search messages
- `gog gmail messages` - List messages
- `gog gmail thread` - View thread
- `gog gmail get` - Get message details
- `gog gmail labels` - Manage labels
- `gog gmail send` - Send email
- Plus admin commands: filters, forwarding, delegates, vacation, watch

**Multi-Account Recommendation**:
Always use composite keys until ID uniqueness is verified:
- Message: `(userId, messageId)`
- Thread: `(userId, threadId)`
- Label: `(userId, labelId)`
