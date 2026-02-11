# generate-claude-settings.py

Generate customized Claude Code settings files for gogcli with flexible client names, flags, and variants.

## Purpose

Instead of copying static settings files and manually editing them for different environments, this script transforms or regenerates settings to match your exact gogcli setup - supporting multiple client names, optional flags, and variant combinations.

## Quick Start

### Transform existing template with new clients

```bash
./generate-claude-settings.py \
  --template allow-readonly-gmail.claude.settings.json \
  --clients default,prod,staging \
  --add-variants with-client
```

Output: Settings expanded with all client variations (base + per-client)

### Regenerate from canonical definitions

```bash
./generate-claude-settings.py \
  --regenerate \
  --tier all-tiers \
  --services gmail,calendar,drive \
  --clients default,prod \
  --variants base,with-client,with-json,with-both
```

Output: Fresh settings built from hardcoded definitions

### Save to file

```bash
./generate-claude-settings.py \
  --template allow-readonly-gmail.claude.settings.json \
  --clients prod > .claude/settings.json

# With debug logging to stderr
./generate-claude-settings.py \
  --template allow-readonly-gmail.claude.settings.json \
  --log-level DEBUG 2>debug.log 1>.claude/settings.json
```

## Modes

### Mode 1: Template Transform (--template)

**Use when**: You have a settings file you want to expand with new client names or variants.

```bash
./generate-claude-settings.py \
  --template default-all-tiers.claude.settings.json \
  --clients default,prod,staging \
  --add-variants with-client,with-json
```

**What happens**:
1. Reads the template file
2. Extracts base commands (strips any existing `--client` or `--json` flags)
3. Regenerates rules with new clients and variants
4. Outputs expanded settings to stdout

**Advantages**:
- Reuses human-written templates as base
- Only requires specifying new clients, not entire rule set
- Preserves permission tiers (allow/ask/deny) from template

### Mode 2: Regeneration (--regenerate)

**Use when**: You want to generate settings from canonical command definitions.

```bash
./generate-claude-settings.py \
  --regenerate \
  --tier all-tiers \
  --services gmail,calendar
```

**What happens**:
1. Uses hardcoded command lists defined in the script
2. Generates rules for specified services and tiers
3. Applies all requested variants and clients
4. Outputs fresh settings to stdout

**Advantages**:
- Single source of truth (definitions in script)
- No manual editing of templates needed
- Can generate any combination of services/tiers/clients

## Options

### Common Options

`--clients NAMES`
: Comma-separated client names (e.g., `default,prod,staging`)
: Example: `--clients default,prod`

`--output FILE`
: Write to file instead of stdout
: If not specified, outputs to stdout

`--log-level LEVEL`
: Set logging verbosity: `DEBUG`, `INFO`, `WARNING`, `ERROR`
: Default: `INFO`
: Logs always go to stderr, never stdout

### Template Mode Options

`--template FILE`
: Path to input settings template (JSON format)
: Extracts commands and expands with new variants/clients

`--add-variants NAMES`
: Comma-separated variants to add
: Options: `base` (always included), `with-client`, `with-json`, `with-both`
: If not specified, detection tries to infer from template

### Regeneration Mode Options

`--regenerate`
: Use canonical definitions instead of transforming a template

`--tier TIER`
: Permission tier to generate
: Options: `readonly` (allow only), `all-tiers` (allow/ask/deny)
: Default: `all-tiers`

`--services NAMES`
: Comma-separated services to include
: Available: `gmail`, `calendar`, `drive`, `people`, `tasks`
: Default: all services

`--variants NAMES`
: Comma-separated variants to generate
: Options: `base`, `with-client`, `with-json`, `with-both`
: Default: `base,with-client`

## Variant Types

A **variant** is a pattern for how to invoke gog commands:

| Variant | Pattern | Use Case |
|---------|---------|----------|
| `base` | `gog gmail search` | Default, always included |
| `with-client` | `gog --client prod gmail search` | Multiple clients/environments |
| `with-json` | `gog --json gmail search` | Programmatic output parsing |
| `with-both` | `gog --client prod --json gmail search` | Multi-client + programmatic |

When you generate with `--clients default,prod --variants base,with-client`:
- For each command, you get 3 rules:
  - Base variant (no flags)
  - With-client variant for "default" client
  - With-client variant for "prod" client

## Examples

### Scenario 1: Multi-environment setup

```bash
# Template has hardcoded "default" client
# Expand it to support default, staging, prod

./generate-claude-settings.py \
  --template default-all-tiers.claude.settings.json \
  --clients default,staging,prod \
  --add-variants with-client \
  --output .claude/settings.json

# Result: ~78 rules for each service tier
# (26 base commands × 3 clients)
```

### Scenario 2: Read-only access for specific services

```bash
# Generate only Gmail and Calendar with read-only permissions

./generate-claude-settings.py \
  --regenerate \
  --tier readonly \
  --services gmail,calendar \
  --clients default \
  --variants base,with-client
```

### Scenario 3: Programmatic + multi-client

```bash
# Support both regular and JSON output for prod/staging

./generate-claude-settings.py \
  --regenerate \
  --tier all-tiers \
  --clients prod,staging \
  --variants base,with-client,with-json,with-both \
  --output multi-variant-settings.json
```

## Output

### To stdout (default)

```bash
./generate-claude-settings.py --template input.json
# → Valid JSON on stdout (can pipe to other tools)
```

### To file

```bash
./generate-claude-settings.py --template input.json --output settings.json
# → JSON written to file
# → Nothing on stdout
```

### Logging (always stderr)

```bash
./generate-claude-settings.py --template input.json --log-level DEBUG 2>debug.log
# stderr: [INFO] / [DEBUG] messages
# stdout: Settings JSON
```

## Command Definitions

The script includes hardcoded command lists for each service and permission tier.

### Structure

```python
GMAIL_READONLY = ["search", "get", "list", "threads list", ...]
GMAIL_WRITE = ["send", "modify", "update", ...]
GMAIL_DENY = ["delete", "trash", ...]

SERVICES = {
    "gmail": {
        "allow": GMAIL_READONLY,
        "ask": GMAIL_WRITE,
        "deny": GMAIL_DENY,
    },
    # ... other services
}
```

### Adding/Updating Commands

Edit the Python script directly:

1. Find the service definition (e.g., `GMAIL_READONLY`)
2. Add/modify command in the list
3. Use the `--regenerate` mode to generate new settings

Example:
```python
GMAIL_READONLY = [
    "search", "get", "list",                    # Basic read
    "threads list", "threads get",              # Threads
    "labels list",                              # My new command
]
```

Then regenerate: `./generate-claude-settings.py --regenerate --services gmail`

## Tips & Tricks

### Combine multiple templates

```bash
# Generate Gmail-only settings
./scripts/generate-claude-settings.py \
  --regenerate --services gmail --clients default > gmail.json

# Generate Calendar-only settings
./scripts/generate-claude-settings.py \
  --regenerate --services calendar --clients default > calendar.json

# Manually merge in settings.json if needed
```

### Debug: See what commands were extracted

```bash
./generate-claude-settings.py \
  --template input.json \
  --log-level DEBUG 2>&1 | grep "Extracted\|for"

# Output shows each command that was found
```

### Debug: See generated rules

```bash
./generate-claude-settings.py --template input.json | jq '.permissions | keys'
# Shows permission tiers: allow, ask, deny

./generate-claude-settings.py --template input.json | jq '.permissions.allow | length'
# Shows number of rules in each tier
```

### Generate without any clients (base only)

```bash
./generate-claude-settings.py \
  --regenerate \
  --tier readonly \
  --variants base
# Result: 1 rule per command (no client variants)
```

## Integration with Claude Code

Once generated, use the settings file with Claude Code:

```bash
# Project-level settings (shared with team)
cp generated-settings.json .claude/settings.json

# Personal overrides (local only)
cp generated-settings.json .claude/settings.local.json

# Global settings (everywhere)
cp generated-settings.json ~/.claude/settings.json
```

See [Claude Code Settings Documentation](https://docs.anthropic.com/en/docs/claude-code/settings) for details.

## Troubleshooting

### "No commands found in template"

Template file might not be in expected format. Check:
- Does it have `"permissions"` key?
- Are rules in format `"Bash(gog ...)"`?

Validate JSON: `python3 -m json.tool input.json`

### "Unknown variant"

Variant names use hyphens: `with-client`, not `with_client`.

Correct: `--add-variants with-client,with-json`
Incorrect: `--add-variants with_client,with_json`

### Script doesn't output anything

Check stderr for errors: `./generate-claude-settings.py ... 2>&1`

Make sure to specify one of:
- `--template FILE` (transformation mode), OR
- `--regenerate` (regeneration mode)

## See Also

* `generate-claude-settings.DEV_NOTES.md` - Implementation details and extending the script
* `../README.md` - Overview of all Claude Code settings
* `GENERATION.md` - Guide to choosing and using settings templates
