#!/usr/bin/env python3
"""
Generate Claude Code settings files for gogcli with customizable client names and variants.

Transforms existing settings templates by expanding commands with different client names
and flag combinations, or regenerates from canonical command definitions.
"""

import json
import sys
import argparse
import logging
from pathlib import Path
from typing import Dict, List, Set, Tuple
from itertools import product

# ============================================================================
# COMMAND DEFINITIONS (Canonical source of truth)
# ============================================================================

GMAIL_READONLY = [
    "search", "get", "list",
    "threads list", "threads get",
    "labels list",
]

GMAIL_WRITE = [
    "send",
    "modify", "update",
    "labels create", "labels delete",
]

GMAIL_DENY = [
    "delete", "trash",
]

CALENDAR_READONLY = [
    "calendarList list",
    "events list", "events get",
    "settings list",
]

CALENDAR_WRITE = [
    "events create", "events update",
    "calendarList insert",
]

CALENDAR_DENY = [
    "events delete",
    "calendarList delete",
]

DRIVE_READONLY = [
    "files list", "files get",
    "about get",
]

DRIVE_WRITE = [
    "files create", "files update",
    "files copy",
]

DRIVE_DENY = [
    "files delete",
]

PEOPLE_READONLY = [
    "people get",
    "contactGroups list",
]

PEOPLE_WRITE = [
    "people createContact", "people updateContact",
]

PEOPLE_DENY = [
    "people deleteContact",
]

TASKS_READONLY = [
    "tasklists list",
    "tasks list", "tasks get",
]

TASKS_WRITE = [
    "tasks insert", "tasks update",
    "tasklists insert",
]

TASKS_DENY = [
    "tasks delete",
    "tasklists delete",
]

# Service definitions grouped by permission tier
SERVICES: Dict[str, Dict[str, List[str]]] = {
    "gmail": {
        "allow": GMAIL_READONLY,
        "ask": GMAIL_WRITE,
        "deny": GMAIL_DENY,
    },
    "calendar": {
        "allow": CALENDAR_READONLY,
        "ask": CALENDAR_WRITE,
        "deny": CALENDAR_DENY,
    },
    "drive": {
        "allow": DRIVE_READONLY,
        "ask": DRIVE_WRITE,
        "deny": DRIVE_DENY,
    },
    "people": {
        "allow": PEOPLE_READONLY,
        "ask": PEOPLE_WRITE,
        "deny": PEOPLE_DENY,
    },
    "tasks": {
        "allow": TASKS_READONLY,
        "ask": TASKS_WRITE,
        "deny": TASKS_DENY,
    },
}

# Template for generating command patterns
COMMAND_VARIANTS = {
    "base": "gog {service} {command}",
    "with_client": "gog --client {client} {service} {command}",
    "with_json": "gog --json {service} {command}",
    "with_both": "gog --client {client} --json {service} {command}",
}

# ============================================================================
# LOGGING SETUP
# ============================================================================

def setup_logging(level: str = "INFO") -> logging.Logger:
    """Setup logging to stderr with specified level."""
    logger = logging.getLogger("generate-claude-settings")
    logger.setLevel(level.upper())

    handler = logging.StreamHandler(sys.stderr)
    handler.setLevel(level.upper())

    formatter = logging.Formatter("[%(levelname)s] %(message)s")
    handler.setFormatter(formatter)

    logger.addHandler(handler)
    return logger


logger = logging.getLogger("generate-claude-settings")

# ============================================================================
# TEMPLATE TRANSFORMATION
# ============================================================================

def read_template(template_path: str) -> Dict:
    """Read and parse a settings template file."""
    path = Path(template_path)
    if not path.exists():
        raise FileNotFoundError(f"Template not found: {template_path}")

    try:
        with open(path) as f:
            return json.load(f)
    except json.JSONDecodeError as e:
        raise ValueError(f"Invalid JSON in template: {e}")


def extract_commands_from_template(template: Dict) -> Set[Tuple[str, str]]:
    """
    Extract base commands from template.
    Returns set of (service, command) tuples.
    """
    commands = set()

    if "permissions" not in template:
        return commands

    for tier in ["allow", "ask", "deny"]:
        if tier not in template["permissions"]:
            continue

        for rule in template["permissions"][tier]:
            # Parse "Bash(gog [--client X] [--json] service command ...)"
            if not rule.startswith("Bash(gog"):
                continue

            # Extract the gog command part
            gog_part = rule[5:-1]  # Remove "Bash(" and ")"

            # Split into tokens
            tokens = gog_part.split()

            # Skip "gog", and any flag tokens (--client, --json, etc.)
            idx = 1
            while idx < len(tokens) and (tokens[idx].startswith("--") or (idx > 1 and tokens[idx-1].startswith("--"))):
                idx += 1

            # Next token should be service
            if idx < len(tokens):
                service = tokens[idx]
                idx += 1

                # Rest is command (may be multiple words)
                if idx < len(tokens):
                    # Join remaining tokens and clean up wildcards
                    command = " ".join(tokens[idx:])
                    # Remove trailing wildcard if present
                    command = command.rstrip(" *").strip()

                    if command:  # Only add if we have a command
                        commands.add((service, command))

    return commands


def generate_bash_rules(
    service: str,
    command: str,
    clients: List[str],
    variants: List[str],
    wildcard: bool = True,
) -> List[str]:
    """Generate Bash permission rules for a command with given variants."""
    rules = []

    cmd_suffix = f" {command} *" if wildcard else f" {command}"

    # Generate all combinations of (variant, client)
    for variant in variants:
        if variant == "base":
            rule = f"Bash(gog {service}{cmd_suffix})"
            rules.append(rule)
        elif variant == "with_client":
            for client in clients:
                rule = f"Bash(gog --client {client} {service}{cmd_suffix})"
                rules.append(rule)
        elif variant == "with_json":
            rule = f"Bash(gog --json {service}{cmd_suffix})"
            rules.append(rule)
        elif variant == "with_both":
            for client in clients:
                rule = f"Bash(gog --client {client} --json {service}{cmd_suffix})"
                rules.append(rule)

    return rules


def normalize_variant_names(variants: List[str]) -> List[str]:
    """Convert hyphenated variant names to underscored (for internal use)."""
    return [v.replace("-", "_") for v in variants]


def transform_template(
    template: Dict,
    clients: List[str] = None,
    add_variants: List[str] = None,
) -> Dict:
    """
    Transform a template by expanding commands with new clients and variants.
    """
    if clients is None:
        clients = []
    if add_variants is None:
        add_variants = []

    # Normalize variant names
    add_variants = normalize_variant_names(add_variants)

    # Extract commands from template
    commands = extract_commands_from_template(template)
    logger.info(f"Extracted {len(commands)} base command patterns from template")

    if not commands:
        logger.warning("No commands found in template")
        return template

    # Build mapping of (service, command) -> tier
    cmd_to_tier = {}
    for tier in ["allow", "ask", "deny"]:
        if tier in template.get("permissions", {}):
            for rule in template["permissions"][tier]:
                # Parse rule to extract service and command
                if rule.startswith("Bash(gog"):
                    gog_part = rule[5:-1]
                    tokens = gog_part.split()
                    idx = 1
                    while idx < len(tokens) and tokens[idx].startswith("--"):
                        idx += 1
                    if idx < len(tokens):
                        service = tokens[idx]
                        idx += 1
                        if idx < len(tokens):
                            command = " ".join(tokens[idx:]).rstrip(" *")
                            cmd_to_tier[(service, command)] = tier

    # Determine variants to generate
    all_variants = ["base"]
    if add_variants:
        all_variants.extend(add_variants)
    else:
        # Default: keep whatever variants are already in template
        all_variants = ["base"]
        if any("--client" in rule for tier_rules in template.get("permissions", {}).values() for rule in tier_rules):
            all_variants.append("with_client")
        if any("--json" in rule for tier_rules in template.get("permissions", {}).values() for rule in tier_rules):
            all_variants.append("with_json")
        if any("--client" in rule and "--json" in rule for tier_rules in template.get("permissions", {}).values() for rule in tier_rules):
            all_variants.append("with_both")

    logger.debug(f"Generating variants: {all_variants}")
    logger.debug(f"For clients: {clients if clients else '(none - base only)'}")

    # Generate new rules
    new_permissions = {"allow": [], "ask": [], "deny": []}

    for service, command in sorted(commands):
        tier = cmd_to_tier.get((service, command), "allow")

        rules = generate_bash_rules(
            service=service,
            command=command,
            clients=clients,
            variants=all_variants,
            wildcard=True,
        )

        new_permissions[tier].extend(rules)
        logger.debug(f"Generated {len(rules)} rules for {service} {command}")

    # Create new template
    result = template.copy()
    result["permissions"] = new_permissions

    logger.info(f"Generated {sum(len(r) for r in new_permissions.values())} total permission rules")

    return result


# ============================================================================
# REGENERATION FROM CANONICAL DEFINITIONS
# ============================================================================

def regenerate_from_definitions(
    tier: str = "all-tiers",
    clients: List[str] = None,
    variants: List[str] = None,
    services: List[str] = None,
) -> Dict:
    """
    Regenerate settings from canonical command definitions.
    """
    if clients is None:
        clients = []
    if variants is None:
        variants = ["base", "with_client"]
    else:
        variants = normalize_variant_names(variants)
    if services is None:
        services = list(SERVICES.keys())

    logger.info(f"Regenerating from definitions for services: {services}")
    logger.info(f"Variants: {variants}, Clients: {clients if clients else '(base only)'}")

    permissions = {
        "allow": [],
        "ask": [],
        "deny": [],
    }

    # Determine which tiers to include
    tiers_to_include = set()
    if tier == "all-tiers":
        tiers_to_include = {"allow", "ask", "deny"}
    elif tier == "readonly":
        tiers_to_include = {"allow"}
    else:
        tiers_to_include = {tier}

    # Generate rules for each service and command
    for service in services:
        if service not in SERVICES:
            logger.warning(f"Unknown service: {service}")
            continue

        for tier_name in tiers_to_include:
            if tier_name not in SERVICES[service]:
                continue

            for command in SERVICES[service][tier_name]:
                rules = generate_bash_rules(
                    service=service,
                    command=command,
                    clients=clients,
                    variants=variants,
                    wildcard=True,
                )

                permissions[tier_name].extend(rules)

    # Build template structure
    result = {
        "$schema": "https://json.schemastore.org/claude-code-settings.json",
        "permissions": permissions,
    }

    logger.info(f"Generated {sum(len(p) for p in permissions.values())} total permission rules")

    return result


# ============================================================================
# OUTPUT
# ============================================================================

def output_settings(settings: Dict, indent: int = 2) -> None:
    """Output settings as JSON to stdout."""
    json.dump(settings, sys.stdout, indent=indent)
    sys.stdout.write("\n")


# ============================================================================
# MAIN
# ============================================================================

def main():
    parser = argparse.ArgumentParser(
        description="Generate Claude Code settings files for gogcli with customizable variants",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Transform existing template with new clients
  %(prog)s --template examples/default-all-tiers.json --clients default,prod --add-variants with-client

  # Regenerate from canonical definitions
  %(prog)s --regenerate --tier all-tiers --clients default,staging --services gmail,calendar

  # Output to file
  %(prog)s --template examples/default-all-tiers.json --clients prod > .claude/settings.json

  # With debug logging
  %(prog)s --template examples/default-all-tiers.json --log-level DEBUG 2>debug.log 1>settings.json
        """,
    )

    # Template mode options
    template_group = parser.add_argument_group("Template Transform Mode")
    template_group.add_argument(
        "--template",
        type=str,
        help="Path to input settings template (JSON)",
    )
    template_group.add_argument(
        "--clients",
        type=str,
        help="Comma-separated client names (e.g., 'default,prod,staging')",
    )
    template_group.add_argument(
        "--add-variants",
        type=str,
        help="Comma-separated variants to add (e.g., 'with-client,with-json,with-both')",
    )

    # Regeneration mode options
    regen_group = parser.add_argument_group("Regeneration Mode")
    regen_group.add_argument(
        "--regenerate",
        action="store_true",
        help="Regenerate from canonical command definitions instead of transforming a template",
    )
    regen_group.add_argument(
        "--tier",
        choices=["readonly", "all-tiers"],
        default="all-tiers",
        help="Permission tier to generate (default: all-tiers)",
    )
    regen_group.add_argument(
        "--services",
        type=str,
        help=f"Comma-separated services (default: all). Available: {','.join(SERVICES.keys())}",
    )
    regen_group.add_argument(
        "--variants",
        type=str,
        help="Comma-separated variants (default: base,with-client). Options: base,with-client,with-json,with-both",
        default="base,with-client",
    )

    # General options
    parser.add_argument(
        "--output",
        type=str,
        help="Output file path (default: stdout)",
    )
    parser.add_argument(
        "--log-level",
        choices=["DEBUG", "INFO", "WARNING", "ERROR"],
        default="INFO",
        help="Logging level (default: INFO)",
    )

    args = parser.parse_args()

    # Setup logging
    setup_logging(args.log_level)

    try:
        # Parse common arguments
        clients = [c.strip() for c in args.clients.split(",")] if args.clients else []

        if args.regenerate:
            # Regeneration mode
            services = None
            if args.services:
                services = [s.strip() for s in args.services.split(",")]

            variants = [v.strip() for v in args.variants.split(",")]

            settings = regenerate_from_definitions(
                tier=args.tier,
                clients=clients,
                variants=variants,
                services=services,
            )
        else:
            # Template transform mode
            if not args.template:
                parser.error("Either --template or --regenerate must be specified")

            template = read_template(args.template)
            logger.info(f"Read template from {args.template}")

            add_variants = None
            if args.add_variants:
                add_variants = [v.strip() for v in args.add_variants.split(",")]

            settings = transform_template(
                template=template,
                clients=clients,
                add_variants=add_variants,
            )

        # Output
        if args.output:
            with open(args.output, "w") as f:
                json.dump(settings, f, indent=2)
                f.write("\n")
            logger.info(f"Wrote settings to {args.output}")
        else:
            output_settings(settings)

    except Exception as e:
        logger.error(f"Error: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
