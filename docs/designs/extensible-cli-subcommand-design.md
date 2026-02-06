# Extensible CLI Subcommand Architecture

**Design Pattern:** External Subcommand Discovery
**Inspiration:** cargo, git, kubectl, docker CLI plugins
**Status:** Proposal
**Applicable To:** Any CLI tool requiring extensibility

---

## Executive Summary

This document describes a design pattern for CLI tools that allows third-party extensions to be discovered and invoked as native subcommands, without requiring changes to the core binary. This enables ecosystem growth while keeping the core tool focused.

---

## Problem Statement

As CLI tools mature, they face a tension:

| Approach | Pros | Cons |
|----------|------|------|
| **Monolithic** | Single binary, unified experience | Binary bloat, slow releases, contributor friction |
| **Plugin system** | Extensible, decoupled | Discovery complexity, UX fragmentation |

The external subcommand pattern offers a middle ground: **plugins that feel native**.

---

## Design Overview

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           User Experience                                │
│                                                                          │
│  $ gog docs headings --docid ABC123                                     │
│                                                                          │
│  ┌─────────────┐      ┌─────────────────┐      ┌─────────────────────┐  │
│  │  gog (core) │ ───► │ Discovery Layer │ ───► │ gog-docs-headings   │  │
│  │             │      │                 │      │ (external binary)   │  │
│  └─────────────┘      └─────────────────┘      └─────────────────────┘  │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

### Core Mechanics

1. **Naming Convention**: External commands follow `{tool}-{subcommand}[-{subsubcommand}]` pattern
2. **PATH Discovery**: Core tool searches PATH for matching binaries
3. **Help Integration**: External commands provide `--help-oneliner` for aggregated help
4. **Transparent Invocation**: User calls `tool sub sub` → core execs `tool-sub-sub`

---

## Detailed Specification

### 1. Naming Convention

```
{core}-{level1}[-{level2}][-{level3}]...

Examples:
  gog-docs              → gog docs
  gog-docs-headings     → gog docs headings
  gog-docs-named-ranges → gog docs named-ranges
  cargo-fmt             → cargo fmt
  git-lfs               → git lfs
  kubectl-krew          → kubectl krew
```

**Rules:**

* Binary name starts with `{core}-` prefix
* Hyphens separate subcommand levels
* Multi-word subcommands use hyphens: `named-ranges` (not `namedranges`)
* Case-insensitive matching on case-insensitive filesystems

### 2. Discovery Mechanism

```go
func discoverExternalCommands(prefix string) []ExternalCommand {
    var commands []ExternalCommand

    // Search PATH
    pathDirs := strings.Split(os.Getenv("PATH"), string(os.PathListSeparator))

    for _, dir := range pathDirs {
        entries, _ := os.ReadDir(dir)
        for _, entry := range entries {
            name := entry.Name()
            if strings.HasPrefix(name, prefix+"-") && isExecutable(entry) {
                cmd := parseExternalCommand(name, filepath.Join(dir, name))
                commands = append(commands, cmd)
            }
        }
    }

    return deduplicateByName(commands) // First in PATH wins
}

type ExternalCommand struct {
    BinaryPath   string   // /usr/local/bin/gog-docs-headings
    BinaryName   string   // gog-docs-headings
    Subcommands  []string // ["docs", "headings"]
    OneLiner     string   // "List document headings with hierarchy"
    Version      string   // "1.2.0" (optional)
}
```

**Performance Optimization:**

* Cache discovery results with TTL (e.g., 5 minutes)
* Store cache in `~/.{tool}/plugin-cache.json`
* Invalidate on `--refresh-plugins` flag

### 3. Help Integration (`--help-oneliner`)

Every external command MUST implement:

```bash
$ gog-docs-headings --help-oneliner
List document headings with hierarchy and URLs
```

**Requirements:**

* Exit code 0 on success
* Single line output (≤80 chars recommended)
* No trailing newline required (tool trims)
* Timeout: 100ms (skip if slower)

**Aggregated Help Display:**

```
$ gog --help
gog - Google Workspace CLI

CORE COMMANDS:
  gmail        Gmail operations
  calendar     Calendar operations
  drive        Drive operations
  docs         Google Docs operations

EXTERNAL COMMANDS:
  docs headings       List document headings with hierarchy
  docs bookmarks      List and manage document bookmarks
  docs named-ranges   List named ranges for template automation
  docs comments       List and read document comments

Use "gog <command> --help" for more information.
```

### 4. Invocation Flow

```
User types: gog docs headings --docid ABC123

┌─────────────────────────────────────────────────────────────────┐
│ 1. gog parses "docs" - not a built-in command                  │
│ 2. gog searches for "gog-docs" binary - not found              │
│ 3. gog parses "docs headings" - searches for "gog-docs-headings"│
│ 4. Found: /usr/local/bin/gog-docs-headings                     │
│ 5. gog execs: gog-docs-headings --docid ABC123                 │
│    (remaining args passed through)                              │
└─────────────────────────────────────────────────────────────────┘
```

**Argument Passing:**

```go
func invokeExternal(cmd ExternalCommand, args []string) error {
    // Pass through all remaining arguments
    execArgs := append([]string{cmd.BinaryPath}, args...)

    // Inherit environment (including auth tokens)
    return syscall.Exec(cmd.BinaryPath, execArgs, os.Environ())
}
```

### 5. Environment Variables for Plugins

Core tool sets environment variables for plugins:

```bash
# Core tool info
GOG_CORE_VERSION=2.1.0
GOG_CORE_PATH=/usr/local/bin/gog

# Authentication (shared OAuth tokens)
GOG_AUTH_TOKEN_PATH=~/.gog/oauth-token.json
GOG_CONFIG_PATH=~/.gog/config.yaml

# User preferences
GOG_OUTPUT_FORMAT=json   # or "table"
GOG_COLOR=auto           # "always", "never", "auto"

# Plugin context
GOG_PLUGIN_NAME=gog-docs-headings
GOG_PLUGIN_INVOKED_AS="gog docs headings"
```

### 6. Configuration Sharing

Plugins should read core config for consistency:

```yaml
# ~/.gog/config.yaml
output:
  format: table
  color: auto

auth:
  token_path: ~/.gog/oauth-token.json

plugins:
  # Plugin-specific config goes here
  docs-headings:
    default_limit: 50
```

### 7. Version Compatibility

Optional `--version-json` for compatibility checking:

```bash
$ gog-docs-headings --version-json
{"name":"gog-docs-headings","version":"1.2.0","min_core_version":"2.0.0"}
```

Core tool can warn on incompatibility:

```
$ gog docs headings
Warning: gog-docs-headings requires gog >= 2.0.0 (you have 1.9.0)
```

---

## Implementation Levels

### Level 1: Basic Discovery (MVP)

* Search PATH for `{tool}-*` binaries
* Pass through arguments
* No help integration

**Effort:** ~2-4 hours

### Level 2: Help Integration

* Implement `--help-oneliner` protocol
* Aggregate in `--help` output
* Cache discovery results

**Effort:** ~4-8 hours

### Level 3: Nested Subcommands

* Parse `{tool}-{sub}-{subsub}` naming
* Build command tree
* Hierarchical help display

**Effort:** ~8-16 hours

### Level 4: Full Plugin Protocol

* Environment variable contract
* Config sharing
* Version compatibility
* Plugin install/update commands

**Effort:** ~16-32 hours

---

## Prior Art Comparison

| Feature | cargo | git | kubectl | docker | Proposed |
|---------|-------|-----|---------|--------|----------|
| Naming | `cargo-{name}` | `git-{name}` | `kubectl-{name}` | `docker-{name}` | `{tool}-{sub}[-{sub}]` |
| Discovery | PATH | PATH | PATH | Plugin dir | PATH |
| Help integration | ❌ | ❌ | Via manifest | Via manifest | `--help-oneliner` |
| Nested commands | ❌ | ❌ | ❌ | ❌ | ✅ |
| Plugin manager | cargo-install | N/A | krew | N/A | Optional |
| Config sharing | Cargo.toml | .gitconfig | kubeconfig | config.json | `{tool}.yaml` |

**Key Innovation:** Nested subcommand support via naming convention.

---

## Security Considerations

1. **PATH Trust**: Only executes binaries in PATH (user-controlled)
2. **No Code Loading**: External process, not dlopen/plugin loading
3. **Credential Isolation**: Auth tokens passed via env vars or file paths
4. **Binary Verification**: Optional signature verification for installed plugins

---

## Example: gogcli Ecosystem

With this design, gogcli could evolve to:

```
CORE (gog binary):
├── gmail (built-in, most used)
├── calendar (built-in, most used)
├── drive (built-in, most used)
├── docs (built-in basic, e.g., get/create)
└── ... other core services

ECOSYSTEM (external binaries):
├── gog-docs-headings     → gog docs headings
├── gog-docs-bookmarks    → gog docs bookmarks
├── gog-docs-named-ranges → gog docs named-ranges
├── gog-docs-comments     → gog docs comments
├── gog-docs-revisions    → gog docs revisions
├── gog-docs-suggestions  → gog docs suggestions
├── gog-docs-replace      → gog docs replace
├── gog-sheets-formulas   → gog sheets formulas
├── gog-slides-export     → gog slides export
└── ... community contributions
```

**Benefits:**

* Core binary stays lean (~10MB vs ~50MB+)
* Users install only what they need
* Contributors can iterate independently
* Maintainers review smaller, focused PRs

---

## Appendix: Reference Implementation

### Go Implementation Skeleton

```go
package main

import (
    "fmt"
    "os"
    "os/exec"
    "path/filepath"
    "strings"
)

const toolPrefix = "gog"

func main() {
    args := os.Args[1:]

    if len(args) == 0 {
        showHelp()
        return
    }

    // Try built-in commands first
    if cmd := findBuiltinCommand(args[0]); cmd != nil {
        cmd.Run(args[1:])
        return
    }

    // Try external commands
    if ext := findExternalCommand(args); ext != nil {
        invokeExternal(ext, args[len(ext.Subcommands):])
        return
    }

    fmt.Fprintf(os.Stderr, "Unknown command: %s\n", args[0])
    os.Exit(1)
}

func findExternalCommand(args []string) *ExternalCommand {
    // Try longest match first: gog-docs-headings before gog-docs
    for i := len(args); i > 0; i-- {
        binaryName := toolPrefix + "-" + strings.Join(args[:i], "-")
        if path, err := exec.LookPath(binaryName); err == nil {
            return &ExternalCommand{
                BinaryPath:  path,
                Subcommands: args[:i],
            }
        }
    }
    return nil
}

func invokeExternal(cmd *ExternalCommand, remainingArgs []string) {
    execCmd := exec.Command(cmd.BinaryPath, remainingArgs...)
    execCmd.Stdin = os.Stdin
    execCmd.Stdout = os.Stdout
    execCmd.Stderr = os.Stderr
    execCmd.Env = buildPluginEnv()

    if err := execCmd.Run(); err != nil {
        if exitErr, ok := err.(*exec.ExitError); ok {
            os.Exit(exitErr.ExitCode())
        }
        os.Exit(1)
    }
}

func buildPluginEnv() []string {
    env := os.Environ()
    env = append(env, fmt.Sprintf("%s_CORE_VERSION=%s",
        strings.ToUpper(toolPrefix), version))
    env = append(env, fmt.Sprintf("%s_AUTH_TOKEN_PATH=%s",
        strings.ToUpper(toolPrefix), getTokenPath()))
    return env
}
```

### Plugin Skeleton (gog-docs-headings)

```go
package main

import (
    "fmt"
    "os"
)

const (
    version   = "1.0.0"
    oneLiner  = "List document headings with hierarchy and URLs"
)

func main() {
    args := os.Args[1:]

    // Handle special flags first
    for _, arg := range args {
        switch arg {
        case "--help-oneliner":
            fmt.Println(oneLiner)
            return
        case "--version":
            fmt.Printf("gog-docs-headings %s\n", version)
            return
        case "--version-json":
            fmt.Printf(`{"name":"gog-docs-headings","version":"%s","min_core_version":"2.0.0"}`, version)
            return
        }
    }

    // Normal command execution
    // Read GOG_AUTH_TOKEN_PATH from env for authentication
    tokenPath := os.Getenv("GOG_AUTH_TOKEN_PATH")
    // ... implement command logic
}
```

---

## Document History

| Date | Version | Changes |
|------|---------|---------|
| 2026-02-06 | 1.0 | Initial design document |
