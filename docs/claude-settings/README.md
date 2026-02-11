# Claude Code Permission Settings for gogcli

> **Official Documentation**: [Claude Code Settings](https://docs.anthropic.com/en/docs/claude-code/settings)

This directory contains pre-configured permission settings for [Claude Code](https://claude.ai/code) to safely use [gogcli](https://github.com/steipete/gogcli) commands.

## Quick Start

### Recommended: Use the Default All-Tiers Settings

The **`default-all-tiers.claude.settings.json`** file is the recommended starting point. It includes all gogcli operations properly classified into three tiers:

* **allow** - Read-only operations (auto-approved)
* **ask** - Non-destructive modifications (prompted each time)
* **deny** - Dangerous operations (blocked)

```bash
# Copy as your project settings (recommended)
cp default-all-tiers.claude.settings.json .claude/settings.json

# Or as global settings
cp default-all-tiers.claude.settings.json ~/.claude/settings.json
```

### Alternative: Per-Service or Per-Tier Files

For more granular control, use individual files:

```bash
# Project-wide (shared with team)
cp allow-readonly-gmail.claude.settings.json .claude/settings.json

# Personal overrides
cp allow-readonly-gmail.claude.settings.json .claude/settings.local.json

# Global (applies everywhere)
cp allow-readonly-gmail.claude.settings.json ~/.claude/settings.json
```

### Generate Custom Settings with Multiple Clients

If you use multiple client names (e.g., `default`, `prod`, `staging`), use the settings generator:

```bash
# Expand default template for your client names
./scripts/generate-claude-settings.py \
  --template default-all-tiers.claude.settings.json \
  --clients default,prod,staging \
  --add-variants with-client \
  --output .claude/settings.json
```

This generates rules for all combinations of your clients and variants:
- `gog gmail search` (base)
- `gog --client default gmail search` (with your clients)
- `gog --client prod gmail search`
- `gog --client staging gmail search`

See [GENERATION.md](GENERATION.md) for complete guide to customizing settings for your environment.

## File Naming Convention

```
{permission}-{category}-{service}.claude.settings.json
```

| Prefix | Tier | Permission | Description |
|--------|------|------------|-------------|
| `default-all-tiers` | ALL | all three | **Recommended** - Complete settings with allow/ask/deny |
| `allow-readonly-` | ✅ SAFE | `allow` | Read-only operations, auto-approved |
| `ask-modify-` | ❓ GRAY | `ask` | Non-destructive modifications, prompted each time |
| `deny-dangerous-` | ❌ DANGEROUS | `deny` | External impact or irreversible, blocked |
| `allow-drafts-` | Special | `allow` | Draft create/update for human-in-the-loop workflow |

Services: `gmail`, `calendar`, `drive`, `tasks`, `contacts`, `chat`, `keep`, `sheets`, `docs`, `slides`, `all`

## Permission Classification Framework

### Guiding Principles

Operations are classified based on two key questions:

1. **External Impact?** - Does it affect others outside my account?
2. **Reversible?** - Can I undo it (especially with operation logs)?

### Classification Tiers

| Tier | Criteria | Default | Examples |
|------|----------|---------|----------|
| **DANGEROUS** | External impact OR permanently irreversible | `deny` | Send email, delete permanently, share/unshare |
| **GRAY AREA** | Reversible with logging, locally contained | `ask` | Create, update, move, copy, drafts create/update |
| **SAFE** | Read-only, no modifications | `allow` | Search, list, get, download, export |

### Permission Evaluation Order

Claude Code evaluates permissions in this order: **deny → allow → ask**

- `deny` takes highest precedence and blocks the operation
- `allow` auto-approves matching operations
- `ask` prompts the user each time (default for unmatched operations)

## Operations Matrices

### Gmail

| Operation | Tier | Rationale |
|-----------|------|-----------|
| search/get/list/history | ✅ SAFE | Read-only |
| labels list/get | ✅ SAFE | Read-only |
| drafts list/get | ✅ SAFE | Read-only |
| url/attachment | ✅ SAFE | Read-only |
| labels create | ❓ GRAY | Adds noise, reversible |
| thread modify (labels) | ❓ GRAY | Reversible with logging |
| drafts create/update | ❓ GRAY | No send, reversible |
| send | ❌ DANGEROUS | External impact (recipients) |
| drafts send | ❌ DANGEROUS | External impact (recipients) |
| drafts delete | ❌ DANGEROUS | May lose work permanently |
| batch delete | ❌ DANGEROUS | Permanent data loss |
| filters/forwarding delete | ❌ DANGEROUS | Configuration loss |

### Calendar

| Operation | Tier | Rationale |
|-----------|------|-----------|
| calendars/events list/get | ✅ SAFE | Read-only |
| freebusy/search/team | ✅ SAFE | Read-only |
| create/update/respond | ❓ GRAY | May notify attendees, but reversible |
| focus-time/out-of-office | ❓ GRAY | Personal calendar blocks |
| delete | ❌ DANGEROUS | May affect attendees |

### Drive

| Operation | Tier | Rationale |
|-----------|------|-----------|
| ls/search/get/download | ✅ SAFE | Read-only |
| permissions (read) | ✅ SAFE | Read-only |
| upload/mkdir | ❓ GRAY | Adds content, reversible |
| copy/move/rename | ❓ GRAY | Reversible with logging |
| comments create/update/reply | ❓ GRAY | Adds content, reversible |
| delete/rm/del | ❌ DANGEROUS | May affect shared access |
| share/unshare | ❌ DANGEROUS | External impact (access) |
| comments delete | ❌ DANGEROUS | Loses information |

### Tasks

| Operation | Tier | Rationale |
|-----------|------|-----------|
| lists list, list, get | ✅ SAFE | Read-only |
| lists create, add, update | ❓ GRAY | Locally contained |
| done/undo | ❓ GRAY | Reversible state change |
| delete/clear | ❌ DANGEROUS | Permanent data loss |

### Contacts

| Operation | Tier | Rationale |
|-----------|------|-----------|
| search/list/get | ✅ SAFE | Read-only |
| directory/other search | ✅ SAFE | Read-only |
| create/update | ❓ GRAY | Locally contained |
| delete | ❌ DANGEROUS | Permanent data loss |

### Chat

| Operation | Tier | Rationale |
|-----------|------|-----------|
| spaces list/find | ✅ SAFE | Read-only |
| messages/threads list | ✅ SAFE | Read-only |
| spaces create | ❓ GRAY | Creates container only |
| messages send | ❓ GRAY | Visible to space members |
| dm send/space | ❓ GRAY | Direct message (requires user approval via ask) |

### Keep

| Operation | Tier | Rationale |
|-----------|------|-----------|
| list/search/get/attachment | ✅ SAFE | Read-only |
| (no write operations in gogcli) | - | - |

### Sheets

| Operation | Tier | Rationale |
|-----------|------|-----------|
| get/metadata/export | ✅ SAFE | Read-only |
| update/append | ❓ GRAY | Modifies data, reversible |
| create/copy | ❓ GRAY | Adds content |
| clear | ❌ DANGEROUS | Data loss |

### Docs & Slides

| Operation | Tier | Rationale |
|-----------|------|-----------|
| info/cat/export | ✅ SAFE | Read-only |
| create/copy | ❓ GRAY | Adds content |

## Usage Examples

### Complete All-Tiers Configuration (Recommended)

Use `default-all-tiers.claude.settings.json` for balanced security:

* ✅ Read-only operations auto-approved
* ❓ Modifications require confirmation each time
* ❌ Dangerous operations blocked entirely

```bash
cp default-all-tiers.claude.settings.json .claude/settings.json
```

This file structure (allow → ask → deny order):

```json
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "permissions": {
    "allow": [
      "Bash(gog gmail search *)",
      "Bash(gog gmail get *)",
      ...
    ],
    "ask": [
      "Bash(gog gmail drafts create *)",
      "Bash(gog drive upload *)",
      ...
    ],
    "deny": [
      "Bash(gog gmail send *)",
      "Bash(gog drive delete *)",
      ...
    ]
  }
}
```

### Read-Only Access (Safest)

```json
// .claude/settings.json
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "permissions": {
    "allow": [
      "Bash(gog gmail search *)",
      "Bash(gog gmail get *)"
    ]
  }
}
```

Or copy `allow-readonly-gmail.claude.settings.json` directly.

### Block Dangerous Operations

```json
// .claude/settings.json
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "permissions": {
    "deny": [
      "Bash(gog gmail send *)",
      "Bash(gog gmail drafts send *)"
    ]
  }
}
```

Or copy `deny-dangerous-gmail.claude.settings.json` directly.

### Human-in-the-Loop Drafts Workflow

Use `allow-drafts-gmail.claude.settings.json` for a workflow where:

1. Claude creates/updates drafts
2. User reviews in Gmail WebUI
3. User manually clicks Send

```json
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "permissions": {
    "allow": [
      "Bash(gog gmail drafts create *)",
      "Bash(gog gmail drafts update *)",
      "Bash(gog gmail drafts list *)",
      "Bash(gog gmail drafts get *)"
    ]
  }
}
```

### Combining Multiple Files

Merge permissions from multiple files:

```bash
# Using jq to merge allow arrays
jq -s '.[0].permissions.allow = ([.[].permissions.allow] | add | unique | sort) | .[0]' \
  allow-readonly-gmail.claude.settings.json \
  allow-readonly-calendar.claude.settings.json \
  > combined.claude.settings.json
```

## File Summary

| Category | Files | Purpose |
|----------|-------|---------|
| **default-all-tiers** | 1 | **Recommended** - Complete settings with all tiers combined |
| allow-readonly-* | 11 | Pure read-only operations |
| ask-modify-* | 10 | Non-destructive modifications |
| deny-dangerous-* | 11 | Block irreversible/external operations |
| allow-drafts-gmail | 1 | Special drafting workflow |

**Note**: `deny-dangerous-chat`, `deny-dangerous-docs`, `deny-dangerous-keep`, `deny-dangerous-slides` have empty deny arrays because those services have no truly dangerous operations in gogcli's current implementation.

## See Also

* **[GENERATION.md](GENERATION.md)** - Complete guide to generating customized settings
* **[scripts/](scripts/)** - Settings generator tool:
  - `generate-claude-settings.py` - Main script for transforming/regenerating settings
  - `generate-claude-settings.README.md` - User guide with examples
  - `generate-claude-settings.DEV_NOTES.md` - Implementation details
* [Claude Code Official Documentation](https://docs.anthropic.com/en/docs/claude-code/settings)
* [gogcli Repository](https://github.com/steipete/gogcli)
* [gogcli Commands Classification](../gogcli-commands-classification.yaml)
