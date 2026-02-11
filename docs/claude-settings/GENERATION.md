# Generating Claude Settings for gogcli

This guide shows how to use `scripts/generate-claude-settings.py` to create customized settings files for your gogcli setup.

## Quick Start: Three Common Scenarios

### 1. Single client, all permissions (most permissive)

```bash
cd docs/claude-settings

# Generate from the recommended template
./scripts/generate-claude-settings.py \
  --template default-all-tiers.claude.settings.json \
  --output ~/.claude/settings.json
```

This gives you the baseline all-tiers settings for your single client.

### 2. Multiple clients (prod, staging, dev)

```bash
cd docs/claude-settings

# Expand template for multiple client names
./scripts/generate-claude-settings.py \
  --template default-all-tiers.claude.settings.json \
  --clients default,staging,prod \
  --add-variants with-client \
  --output .claude/settings.json
```

Now you can use `gog --client default`, `gog --client staging`, etc., and Claude Code will support all of them.

### 3. Read-only access only

```bash
cd docs/claude-settings

# Generate only safe read-only operations
./scripts/generate-claude-settings.py \
  --regenerate \
  --tier readonly \
  --clients default \
  --output .claude/settings.json
```

This is safest for exploration without risk of modifications.

## Understanding the Templates

Pre-generated templates are organized by permission level and service:

### By Permission Level

* **`default-all-tiers.claude.settings.json`** ← **Recommended starting point**
  - Safe default with allow/ask/deny balanced
  - Auto-approves read operations
  - Prompts for any modifications
  - Blocks dangerous operations

* **`allow-readonly-*.claude.settings.json`** - Read-only access
  - Only safe query/search/get/list operations
  - Safest option for exploration
  - No modifications allowed
  - Options: `allow-readonly-all.json` (all services) or per-service

* **`ask-modify-*.claude.settings.json`** - Write operations (with prompt)
  - Basic modification operations
  - Always prompts for confirmation
  - Options: `ask-modify-all.json` (all services) or per-service

* **`deny-dangerous-*.claude.settings.json`** - Dangerous operations list
  - Delete, permanent removal operations
  - Completely blocked (no prompt option)
  - Useful to see what's off-limits

### By Service

Each permission level comes in variants:

- `*-all.json` - All 14 services (Gmail, Calendar, Drive, People, Tasks, etc.)
- `*-gmail.json` - Gmail only
- `*-calendar.json` - Calendar only
- `*-drive.json` - Drive only
- `*-people.json` - People/Contacts only
- `*-tasks.json` - Tasks only
- ... and others

### By Usage Pattern

* **Per-operation granularity** (each rule is specific command + service)
  - `gog gmail search` - allows search
  - `gog --client prod gmail search` - allows for prod client
  - `gog --json gmail search` - allows with JSON output
  - `gog --client prod --json gmail search` - all combinations

## Workflow: Setting Up Claude Code for Your Environment

### Step 1: Choose Base Settings

Start with one of the templates:

```bash
cd docs/claude-settings

# Safest: read-only
cp allow-readonly-all.claude.settings.json template.json

# Balanced (recommended):
cp default-all-tiers.claude.settings.json template.json

# Most permissive (least safe):
cp ask-modify-all.claude.settings.json template.json
```

### Step 2: Customize for Your Clients

If you use multiple client names in gogcli:

```bash
./scripts/generate-claude-settings.py \
  --template template.json \
  --clients default,prod,staging \
  --add-variants with-client \
  --output custom-settings.json
```

### Step 3: Review Generated Rules

Inspect the generated file:

```bash
# Count rules
jq '.permissions | map(length)' custom-settings.json

# See all allow rules
jq '.permissions.allow | sort' custom-settings.json

# Find rules for a specific service
jq '.permissions.allow[] | select(contains("calendar"))' custom-settings.json
```

### Step 4: Install Where Claude Code Looks For It

```bash
# Option A: Project-level (team shared)
cp custom-settings.json .claude/settings.json

# Option B: Personal overrides (local only)
cp custom-settings.json .claude/settings.local.json

# Option C: Global (everywhere)
cp custom-settings.json ~/.claude/settings.json
```

See [Claude Code settings docs](https://docs.anthropic.com/en/docs/claude-code/settings) for location precedence.

## Advanced: Regenerate From Scratch

Instead of using templates, generate fresh from canonical definitions:

```bash
cd docs/claude-settings

# All services, all tiers, all variants
./scripts/generate-claude-settings.py \
  --regenerate \
  --tier all-tiers \
  --services gmail,calendar,drive \
  --clients default,prod \
  --variants base,with-client,with-json,with-both \
  --output full-settings.json
```

**When to use regeneration**:
- You want complete control over what's included
- You want to start completely fresh (not modify template)
- You want clean, minimal rule sets
- You want to audit all permissions explicitly

**Regeneration options**:

```bash
# Read-only Gmail and Calendar only
./scripts/generate-claude-settings.py \
  --regenerate \
  --tier readonly \
  --services gmail,calendar

# Modifications allowed for specific services
./scripts/generate-claude-settings.py \
  --regenerate \
  --tier all-tiers \
  --services gmail,drive

# Base variant only (no --client flags)
./scripts/generate-claude-settings.py \
  --regenerate \
  --clients default \
  --variants base
```

## Typical Configurations

### Config A: Single Development Client (Most Permissive)

```bash
./scripts/generate-claude-settings.py \
  --template default-all-tiers.claude.settings.json
  # → All 14 services, all tiers, base variant only
```

**Use for**: Local development, personal projects, no multi-client complexity

**Safety**: Auto-approve reads, prompt on writes, block deletes

### Config B: Multi-Environment (Production-Safe)

```bash
./scripts/generate-claude-settings.py \
  --template allow-readonly-all.claude.settings.json \
  --clients default,staging,prod \
  --add-variants with-client \
  --output ~/.claude/settings.json
```

**Use for**: Working with multiple environments

**Safety**: Read-only for all clients, no write access

### Config C: Service-Specific Restricted Access

```bash
# Gmail only, balanced permissions
./scripts/generate-claude-settings.py \
  --regenerate \
  --services gmail \
  --tier all-tiers

# Calendar and Tasks, modifications allowed
./scripts/generate-claude-settings.py \
  --regenerate \
  --services calendar,tasks \
  --tier all-tiers
```

**Use for**: When you only need specific services

**Safety**: Completely blocks other services

### Config D: Exploration Mode (Most Restrictive)

```bash
./scripts/generate-claude-settings.py \
  --regenerate \
  --tier readonly \
  --services gmail,calendar,drive
```

**Use for**: First-time exploration, safety-critical work

**Safety**: Read-only for selected services, nothing else permitted

## Troubleshooting

### "Settings don't match my gogcli client names"

Check what client names you actually use:

```bash
gog --version
gog config list  # if available
grep -r "client" ~/.config/gog*  # find config files
```

Then regenerate with those exact names:

```bash
./scripts/generate-claude-settings.py \
  --template default-all-tiers.claude.settings.json \
  --clients prod,staging,dev \
  --add-variants with-client
```

### "I copied a template but Claude Code still restricts me"

Claude Code loads settings in this order (first match wins):

1. `.claude/settings.json` (project-local)
2. `.claude/settings.local.json` (project personal)
3. `~/.claude/settings.json` (global)

Check which one is being used:

```bash
# From your project directory
ls -la .claude/settings*
ls -la ~/.claude/settings*
```

If multiple exist, the first one applies. Remove or rename others if unintended.

### "I want stricter/looser permissions"

Start from appropriate template:

- **Stricter**: Start with `allow-readonly-*` template
- **Looser**: Start with `ask-modify-*` template
- **Most control**: Use `--regenerate` mode to build exactly what you want

## Command Reference

For complete command reference, see [scripts/generate-claude-settings.README.md](scripts/generate-claude-settings.README.md).

Quick reference:

```
generate-claude-settings.py [--template FILE | --regenerate] [OPTIONS]

Template Mode:
  --template FILE              Input template to expand
  --clients NAMES              Comma-separated client names
  --add-variants NAMES         Add variants (with-client, with-json, with-both)

Regeneration Mode:
  --regenerate                 Generate from canonical definitions
  --services NAMES             Which services (gmail, calendar, drive, etc)
  --tier TIER                  Permission level (readonly, all-tiers)
  --variants NAMES             Which variants to include

Output:
  --output FILE                Write to file (default: stdout)
  --log-level LEVEL            DEBUG, INFO (default), WARNING, ERROR
```

## Next Steps

1. **Start**: Copy recommended template and adjust for your setup
2. **Test**: Use generated settings with Claude Code and gogcli
3. **Refine**: Adjust if needed and regenerate
4. **Share**: Commit approved settings to your project's `.claude/` directory

## See Also

* [scripts/generate-claude-settings.README.md](scripts/generate-claude-settings.README.md) - Full script documentation
* [scripts/generate-claude-settings.DEV_NOTES.md](scripts/generate-claude-settings.DEV_NOTES.md) - Implementation details
* [README.md](README.md) - Overview of settings examples
* [Claude Code Settings Docs](https://docs.anthropic.com/en/docs/claude-code/settings) - Official documentation
