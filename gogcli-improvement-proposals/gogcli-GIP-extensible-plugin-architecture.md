# GIP: Extensible Plugin Architecture for gogcli

**GIP ID:** extensible-plugin-architecture
**Status:** Proposed
**Type:** Architecture / Design
**Effort:** Medium-High (phased)
**Value:** Strategic

---

## Motivation: The Numbers Tell a Story

While researching Google Docs API coverage for gogcli, we discovered:

| Metric | Count | Notes |
|--------|------:|-------|
| **Google Docs UI/API Features** | 104 | Documented in [feature comparison](../docs/datamodel/docs/google-docs-feature-comparison.yaml) |
| **gogcli Currently Implements** | 9 | 8.7% coverage |
| **API-Accessible, Missing in gogcli** | ~70 | Could be implemented |
| **UI-Only (Not API-Accessible)** | ~25 | Cannot be implemented |

**This is just ONE service (Google Docs).** gogcli supports 12+ Google services:

* Gmail, Calendar, Drive, Tasks, Contacts, Chat, Classroom, Sheets, Docs, Slides, Keep, Groups

If each service has similar feature depth, we're looking at **500-1000+ potential features** across all services.

### The Challenge

How should gogcli grow to support hundreds of features without:

* Creating a monolithic binary that takes forever to compile
* Overwhelming maintainers with PR reviews
* Forcing users to download functionality they don't need
* Creating contributor friction ("my PR has been pending for months")

---

## Proposal: External Subcommand Discovery

Adopt the **cargo/git external command pattern** where:

```
gog-docs-headings binary → invoked as `gog docs headings`
```

### How It Works

1. User runs `gog docs headings --docid ABC123`
2. gogcli checks: is `docs` a built-in? Is `docs headings` a built-in?
3. gogcli searches PATH for `gog-docs-headings` binary
4. If found, gogcli execs: `gog-docs-headings --docid ABC123`
5. External command inherits auth, config, and environment

### Key Features

| Feature | Benefit |
|---------|---------|
| `--help-oneliner` protocol | External commands appear in `gog --help` |
| Nested naming (`gog-docs-headings`) | Clean command hierarchy |
| Environment variables | Share auth tokens, config paths |
| Separate binaries | Independent releases, focused PRs |

---

## Proposed Command Layout

```
CORE (gog binary - most used, battle-tested):
├── gmail        # Most critical, most used
├── calendar     # Most critical, most used
├── drive        # Most critical, most used
└── docs         # Basic: get, create, copy, export

ECOSYSTEM (external binaries - specialized features):
├── gog-docs-headings     → gog docs headings
├── gog-docs-bookmarks    → gog docs bookmarks
├── gog-docs-named-ranges → gog docs named-ranges
├── gog-docs-comments     → gog docs comments
├── gog-docs-revisions    → gog docs revisions
├── gog-docs-suggestions  → gog docs suggestions
├── gog-docs-replace      → gog docs replace
├── gog-sheets-formulas   → gog sheets formulas
└── ... community contributions
```

---

## Benefits

### For Users

* **Install only what you need**: Core stays small, add plugins as needed
* **Faster updates**: Plugin can be updated without core release
* **Native experience**: Plugins feel like built-in commands

### For Contributors

* **Lower barrier**: Contribute a plugin without touching core
* **Faster iteration**: Ship your plugin independently
* **Clear ownership**: Maintain your own plugin

### For Maintainers

* **Reduced scope**: Core stays focused on essentials
* **Smaller PRs**: Plugin PRs are self-contained
* **Community scaling**: Ecosystem can grow without bottleneck

---

## Implementation Phases

### Phase 1: Basic Discovery (MVP)

* Search PATH for `gog-*` binaries
* Pass through arguments
* Share OAuth token path via environment

**Effort:** 2-4 hours

### Phase 2: Help Integration

* Implement `--help-oneliner` protocol
* Show external commands in `gog --help`
* Cache discovery for performance

**Effort:** 4-8 hours

### Phase 3: Full Protocol

* Environment variable contract (auth, config, output format)
* Version compatibility checking
* Plugin install helper (`gog plugin install gog-docs-headings`)

**Effort:** 16-32 hours

---

## Design Document

A detailed design document is available:

**[Extensible CLI Subcommand Architecture](../docs/designs/extensible-cli-subcommand-design.md)**

Covers:

* Naming conventions
* Discovery mechanism with Go code
* `--help-oneliner` protocol
* Environment variable contract
* Comparison with cargo, git, kubectl, docker

---

## Prior Art

| Tool | Pattern | Notes |
|------|---------|-------|
| **cargo** | `cargo-fmt`, `cargo-clippy` | Ecosystem of 1000+ plugins |
| **git** | `git-lfs`, `git-flow` | Extended by community |
| **kubectl** | `kubectl-krew` | Plugin manager available |
| **docker** | Docker CLI plugins | Official plugin protocol |

All these tools faced the same challenge: feature sprawl. All adopted external command discovery.

---

## Concrete Next Steps

If this proposal is accepted:

1. **Implement Phase 1** in gogcli core (2-4 hours)
2. **Create `gog-docs-headings`** as first plugin (2-4 hours)
3. **Document plugin authoring** in gogcli wiki
4. **Announce plugin architecture** to encourage contributions

---

## Questions for Discussion

1. **Naming**: `gog-docs-headings` vs `gogcli-docs-headings`?
2. **Authentication**: Pass token via env var or file path?
3. **Distribution**: Recommend Go for plugins? Or language-agnostic?
4. **Plugin index**: Create a registry of known plugins?

---

## Appendix: Google Docs GIP Documents

These improvement proposals would become the first plugins:

* [gog-docs-overview](./gogcli-GIP-gog-docs-overview.md) - Master document
* [gog-docs-headings](./gogcli-GIP-gog-docs-headings.md) - Phase 1, Easy
* [gog-docs-bookmarks](./gogcli-GIP-gog-docs-bookmarks.md) - Phase 1, Easy
* [gog-docs-named-ranges](./gogcli-GIP-gog-docs-named-ranges.md) - Phase 1, Easy
* [gog-docs-comments](./gogcli-GIP-gog-docs-comments.md) - Phase 1, Easy
* [gog-docs-revisions](./gogcli-GIP-gog-docs-revisions.md) - Phase 1, Easy
* [gog-docs-suggestions](./gogcli-GIP-gog-docs-suggestions.md) - Phase 1, Easy
* [gog-docs-replace](./gogcli-GIP-gog-docs-replace.md) - Phase 2, Medium

---

## References

* [Feature Comparison YAML](../docs/datamodel/docs/google-docs-feature-comparison.yaml) - 104 features documented
* [Gap Analysis](../docs/datamodel/docs/google-docs-gogcli-gap-analysis.md) - 8.7% coverage analysis
* [Design Document](../docs/designs/extensible-cli-subcommand-design.md) - Technical specification
