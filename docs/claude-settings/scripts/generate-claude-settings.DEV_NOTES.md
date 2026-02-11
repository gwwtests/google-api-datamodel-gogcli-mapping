# Development Notes: generate-claude-settings.py

Implementation details, architecture decisions, and how to extend the script.

## Architecture Overview

```
Input (either)
    │
    ├─→ [Template Mode] Read JSON template + extract commands
    │       │
    │       └─→ Extract (service, command) tuples from rules
    │           Strip any existing --client/--json flags
    │           Map commands to permission tiers
    │
    └─→ [Regenerate Mode] Use hardcoded command definitions
            │
            └─→ Load SERVICES dict with tier → command mappings

                    ↓

    Apply transformations:
    - Normalize variant names (with-client → with_client)
    - Filter services/tiers as requested
    - Build cartesian product: (commands) × (variants) × (clients)

                    ↓

    Generate Bash permission rules:
    - For each command: create rules for each variant/client combination
    - Format: Bash(gog [--client X] [--json] service command *)

                    ↓

    Output JSON
    └─→ {"permissions": {"allow": [...], "ask": [...], "deny": [...]}}
```

## Key Design Decisions

### 1. Hardcoded Command Definitions

Commands are defined as Python lists grouped by service and tier:

```python
GMAIL_READONLY = ["search", "get", "list", ...]
SERVICES = {"gmail": {"allow": GMAIL_READONLY, "ask": [...], "deny": [...]}}
```

**Why**:
- Single source of truth for what commands are safe
- Easy to audit (all defined in one place)
- No separate config files to sync with script
- Simple to extend (just add to list)

**Maintenance**:
- When gogcli adds new commands, update the lists
- When tiers change, reorganize between `allow`/`ask`/`deny`
- Lists should be sorted within categories for readability

### 2. Template Extraction vs. Regeneration

Script supports two modes rather than one unified approach:

**Template Mode** (`--template`):
- Extracts commands FROM existing settings files
- Doesn't require knowing all commands upfront
- Good for incrementally expanding existing configs

**Regeneration Mode** (`--regenerate`):
- Builds fresh from canonical definitions
- Single source of truth
- Good for clean slate or large changes

**Why both?**
- Users might have manually created settings files
- Legacy templates need to be extended without rewriting
- Canonical regeneration ensures consistency
- Template extraction allows conservative approach

### 3. Cartesian Product Expansion

Variants and clients are combined via cartesian product:

```python
variants = ["base", "with_client"]
clients = ["default", "prod"]

# Result: 3 rules per command
# - Bash(gog gmail search *)           # base
# - Bash(gog --client default ...)     # with_client + default
# - Bash(gog --client prod ...)        # with_client + prod
```

**Why**:
- User specifies intent once, all combinations generated
- No duplication in user config
- Automatic expansion to any number of clients

### 4. Logging to stderr, Output to stdout

```
stderr: [INFO] / [DEBUG] messages  ← Progress, diagnostics
stdout: Valid JSON                 ← Actual output
```

**Why**:
- Follows Unix convention (stdout = data, stderr = control)
- Allows piping: `./script.py ... | jq .`
- Debug logs don't pollute output
- Can redirect separately: `./script.py ... 2>debug.log 1>settings.json`

### 5. Hyphen vs. Underscore Normalization

CLI uses hyphens, internal code uses underscores:

```bash
# CLI argument
--add-variants with-client

# Internal
normalize_variant_names(["with-client"]) → ["with_client"]
```

**Why**:
- Hyphens are standard CLI convention
- Underscores are Python naming convention
- Normalization layer keeps both happy

## Code Structure

### Constants (lines 1-100)

**Command definitions**:
- `GMAIL_READONLY`, `GMAIL_WRITE`, `GMAIL_DENY` - Gmail commands
- `CALENDAR_READONLY`, etc. - Calendar commands
- ... other services ...

**Service registry**:
- `SERVICES` dict: `{service: {tier: [commands]}}`

**Variant templates**:
- `COMMAND_VARIANTS` dict: mapping variant names to command patterns

### Logging Setup (lines ~120)

`setup_logging(level)` - Initialize stderr logger with level

### Template Transformation (lines ~160-250)

**`extract_commands_from_template(template)`**
- Parses Bash rules: `"Bash(gog [--flags] service command *)"`
- Returns set of `(service, command)` tuples
- Strips flags and wildcards

**`generate_bash_rules(service, command, clients, variants, wildcard)`**
- Creates permission rules for a single command
- Applies all variant/client combinations
- Returns list of `"Bash(gog ...)"` strings

**`transform_template(template, clients, add_variants)`**
- Orchestrates template transformation
- Extracts commands, applies variants, regenerates rules
- Returns new template dict

**`normalize_variant_names(variants)`**
- Converts hyphenated names to underscored
- Small helper for CLI ↔ code translation

### Regeneration (lines ~250-310)

**`regenerate_from_definitions(tier, clients, variants, services)`**
- Builds settings from `SERVICES` constants
- Filters by tier/services/variants
- Returns new template dict

### I/O (lines ~310-330)

**`read_template(path)`**
- Loads and parses JSON template
- Raises `FileNotFoundError` or `JSONDecodeError`

**`output_settings(settings, indent)`**
- Dumps settings to stdout as formatted JSON

### Main (lines ~330+)

**`main()`**
- Argument parsing with argparse
- Mode selection (template vs. regenerate)
- Error handling and logging

## Extending the Script

### Add a new service

1. Define command lists (copy from Google API docs):

```python
NEWSERVICE_READONLY = [
    "get", "list",
]
NEWSERVICE_WRITE = [
    "create", "update",
]
NEWSERVICE_DENY = [
    "delete",
]
```

2. Register in `SERVICES` dict:

```python
SERVICES = {
    "gmail": {...},
    "newservice": {
        "allow": NEWSERVICE_READONLY,
        "ask": NEWSERVICE_WRITE,
        "deny": NEWSERVICE_DENY,
    },
}
```

3. Use it:

```bash
./generate-claude-settings.py --regenerate --services newservice
```

### Add a new variant type

Example: Add `--output-format json` variant:

1. Add to `COMMAND_VARIANTS`:

```python
COMMAND_VARIANTS = {
    "base": "gog {service} {command}",
    "with_client": "gog --client {client} {service} {command}",
    "with_json": "gog --json {service} {command}",
    "with_both": "gog --client {client} --json {service} {command}",
    "with_format": "gog --output-format {format} {service} {command}",  # NEW
}
```

2. Update `generate_bash_rules()` to handle it:

```python
def generate_bash_rules(...):
    ...
    elif variant == "with_format":
        for fmt in ["json", "csv", "table"]:  # example formats
            rule = f"Bash(gog --output-format {fmt} {service}{cmd_suffix})"
            rules.append(rule)
```

3. Document in README and support in CLI

### Improve command extraction

Current extraction works for simple patterns. If templates use more complex formats, enhance:

```python
def extract_commands_from_template(template):
    # Current: parses "Bash(gog [--flags] service command *)"
    # Could improve: handle more flag combinations, validate commands, etc.
```

## Testing

### Manual testing

```bash
# Test template mode
./generate-claude-settings.py \
  --template allow-readonly-gmail.claude.settings.json \
  --clients default,prod \
  --add-variants with-client \
  --log-level DEBUG

# Verify output
jq '.permissions | keys' output.json
jq '.permissions.allow | length' output.json
jq '.permissions.allow[0:5]' output.json

# Test regeneration
./generate-claude-settings.py \
  --regenerate \
  --services gmail,calendar \
  --variants base,with-client

# Test edge cases
./generate-claude-settings.py --regenerate --services unknown
./generate-claude-settings.py --template nonexistent.json
```

### Test scenarios

- [ ] Transform with no variants (base only)
- [ ] Transform with all variants
- [ ] Regenerate with no clients (base only)
- [ ] Regenerate with multiple clients and variants
- [ ] Output to file vs. stdout
- [ ] Error handling (missing file, invalid JSON, etc.)
- [ ] Empty services list
- [ ] All tiers vs. readonly

## Performance Considerations

### Current

- **Time complexity**: O(commands × clients × variants)
- **Space complexity**: O(rules) - stores all generated rules in memory
- **Typical**: 5-6 services × 100 commands = 500+ rules in memory

For gogcli's scale (~14 services × 5-50 commands each), this is negligible.

### If needed to optimize

- Stream output rules directly (don't store all in dict)
- Generate only requested tiers
- Parallel generation for very large rule sets

## Maintenance Checklist

When updating commands in response to gogcli changes:

- [ ] Update relevant `{SERVICE}_READONLY` / `_WRITE` / `_DENY` lists
- [ ] Keep commands sorted alphabetically within each list
- [ ] If new service added: create constants and register in `SERVICES`
- [ ] Test `--regenerate` mode with updated commands
- [ ] Generate and visually inspect sample output
- [ ] Update GENERATION.md if command categories changed
- [ ] Consider if any default templates need regeneration

## Common Issues & Solutions

### Variant name mismatches

**Problem**: User specifies `--add-variants with_client` (underscore)
**Solution**: `normalize_variant_names()` converts to `with_client` internally
**Note**: Hyphens in CLI, underscores in code

### Command extraction finding too many/few rules

**Problem**: Template has complex patterns like `Bash(gog * --help)`
**Solution**: Current extraction is best-effort. For edge cases:
- Test with `--log-level DEBUG` to see extracted commands
- Manually inspect template if extraction is wrong
- Consider regeneration mode instead

### Whitespace in output

**Problem**: JSON has extra spacing/different indentation
**Solution**: `output_settings(indent=2)` ensures consistent formatting
**Note**: Output is always 2-space indented for readability

## Future Enhancements

Ideas for extending this script:

1. **Interactive mode**: `-i` flag prompts user for choices
2. **Config files**: Store user preferences in YAML for regeneration
3. **Template validation**: Verify extracted commands against schema
4. **Diff output**: Show what changed from old to new settings
5. **Merge mode**: Combine multiple templates intelligently
6. **Service auto-detection**: Detect available gogcli versions/clients
7. **Test mode**: Verify generated rules work with Claude Code
8. **Performance profiling**: Track rule generation timing for large sets

## References

- [Claude Code Settings Schema](https://json.schemastore.org/claude-code-settings.json)
- [Claude Code Documentation](https://docs.anthropic.com/en/docs/claude-code/settings)
- [gogcli Repository](https://github.com/steipete/gogcli)
