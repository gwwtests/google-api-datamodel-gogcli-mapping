# Repository Maintenance Guide

Instructions for keeping this repository coherent and up-to-date.

## Quick Coherence Checklist

Before completing any work session, verify:

- [ ] CURRENT_WORK.md has today's date
- [ ] Research counts match RESEARCH_REQUESTS.md
- [ ] FUTURE_WORK.md checkboxes reflect actual completion
- [ ] All new .md files have corresponding .yaml metadata
- [ ] Cross-references point to existing files
- [ ] No empty placeholder directories remain

---

## File Update Procedures

### 1. Adding New Archived Documentation

When archiving a new web resource:

```
docs/web/{service}/{topic}/
├── {document}.md       # Content (via jina.ai reader)
├── {document}.url      # Source URL (single line)
└── {document}.yaml     # Metadata (REQUIRED)
```

**YAML metadata template:**

```yaml
source_url: "https://..."
download_timestamp: "YYYY-MM-DDTHH:MM:SSZ"
document_title: "Title"
covered_api_calls:
  - "users.method.name"
key_concepts:
  - "concept_name"
notes: |
  Important findings or caveats.
```

**After adding:**

1. Update the directory's INDEX.md
2. Add research questions to `research/RESEARCH_REQUESTS.md` if applicable
3. Update CURRENT_WORK.md progress indicators

### 2. Updating gogcli Analysis

When gogcli has new commits:

1. **Check for changes:**
   ```bash
   cd /path/to/gogcli && git log --oneline -20
   ```

2. **Update analysis files:**
   - `research/gogcli-analysis/{service}-api-usage.md` - Command tables
   - `docs/datamodel/{service}/gogcli-data-handling.md` - Data structures

3. **Update analysis date** in both files:
   ```
   **Analysis Date**: YYYY-MM-DD (updated from YYYY-MM-DD)
   ```

4. **Document new features** with version/date annotations:
   ```markdown
   **Note** (Mon YYYY): New feature description
   ```

### 3. Completing Research Questions

When a research question is answered:

1. **Update RESEARCH_REQUESTS.md:**
   - Change status: `🔴 PENDING` → `🟢 COMPLETED`
   - Add source reference: `docs/web/{service}/{file}.md`

2. **Update summary counts** at bottom of each section:
   ```markdown
   | 🟢 COMPLETED | XX |
   ```

3. **Update CURRENT_WORK.md** research tracking section

### 4. Updating Progress Tracking

**CURRENT_WORK.md** - Update when:

- Starting new service research
- Completing significant milestones
- Research counts change

**FUTURE_WORK.md** - Update when:

- Service research reaches 100%
- New services are started
- Cross-cutting concerns are documented

**Checkbox states:**

- `[ ]` - Not started
- `[~]` - In progress / partial
- `[x]` - Complete

---

## Coherence Verification

### Automated Checks

Run these to find inconsistencies:

```bash
# Find .md files without .yaml metadata
find docs/web -name "*.md" ! -name "INDEX.md" | while read f; do
  yaml="${f%.md}.yaml"
  [ ! -f "$yaml" ] && echo "Missing: $yaml"
done

# Find empty directories
find docs -type d -empty

# Find broken cross-references (basic check)
grep -r "\.\./" docs --include="*.md" | grep -v "^Binary"

# Verify research counts match
grep -c "🟢 COMPLETED" research/RESEARCH_REQUESTS.md
```

### Manual Verification

1. **Cross-reference check:**
   - Open each INDEX.md
   - Verify listed files exist
   - Verify relative paths resolve correctly

2. **Date freshness:**
   - CURRENT_WORK.md "Last Updated" should be recent
   - Analysis dates should reflect actual analysis time

3. **Consistency between files:**
   - Progress in CURRENT_WORK.md matches FUTURE_WORK.md
   - Research counts match actual RESEARCH_REQUESTS.md entries

---

## Common Maintenance Tasks

### Converting Metadata Formats

If .meta.json files exist (legacy format), convert to .yaml:

```bash
for f in *.meta.json; do
  python3 -c "
import json
with open('$f') as f:
    d = json.load(f)
print('source_url:', repr(d.get('url', '')))
print('download_timestamp:', repr(d.get('retrieved_date', '') + 'T00:00:00Z'))
print('document_title:', repr(d.get('title', '')))
if d.get('covered_api_calls'):
    print('covered_api_calls:')
    for c in d['covered_api_calls']:
        print(f'  - \"{c}\"')
if d.get('key_concepts'):
    print('key_concepts:')
    for c in d['key_concepts']:
        print(f'  - \"{c}\"')
" > "${f%.meta.json}.yaml"
  rm "$f"
done
```

### Cleaning Up Empty Directories

```bash
# Find and remove empty directories
find docs -type d -empty -delete
```

### Fixing Broken Cross-References

Common patterns to search/replace:

| Old Pattern | New Pattern |
|-------------|-------------|
| Absolute paths (`/home/...`) | Relative paths (`../../../`) |
| Wrong repo name | Correct repo name |
| `.meta.json` | `.yaml` |

---

## Adding a New Service

When starting research on a new Google API service:

1. **Create directory structure:**
   ```
   docs/web/{service}/
   ├── INDEX.md
   └── {topics}/

   docs/datamodel/{service}/
   └── (created as findings emerge)

   research/gogcli-analysis/
   └── {service}-api-usage.md
   ```

2. **Add to RESEARCH_REQUESTS.md:**
   ```markdown
   ## {Service} API

   ### Identifiers
   | ID | Question | Status | Source |
   |----|----------|--------|--------|
   | XX-ID-001 | ... | 🔴 PENDING | |
   ```

3. **Update FUTURE_WORK.md:**
   - Mark service as started
   - Add subtasks

4. **Update CURRENT_WORK.md:**
   - Add progress bar
   - Add key files section

---

## Commit Guidelines

### Commit Message Format

```
{Type}: {Brief description}

{Detailed changes as bullet points}

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
```

### Commit Types

- `Add` - New documentation or features
- `Update` - Changes to existing docs
- `Fix` - Corrections to errors
- `Improve` - Coherence/quality improvements
- `Remove` - Deletions

### What to Commit Together

**Same commit:**

- New .md + .yaml + .url files for same document
- INDEX.md update for newly added files
- CURRENT_WORK.md progress update

**Separate commits:**

- Different services
- gogcli analysis updates vs documentation additions
- Coherence fixes vs new content

---

## YAML Tracking System

### Purpose

YAML files serve as machine-readable metadata that enables:

* Automated coherence verification
* Feature coverage statistics
* API call tracking across documents
* Cross-referencing and searchability

### YAML File Types

#### 1. Document Metadata (`.yaml` in `docs/web/`)

Tracks archived web documentation:

```yaml
# docs/web/gmail/messages/messages-reference.yaml
source_url: "https://developers.google.com/gmail/api/reference/rest/v1/users.messages"
download_timestamp: "2026-02-06T12:00:00Z"
document_title: "Gmail API - Messages Reference"
covered_api_calls:
  - "users.messages.list"
  - "users.messages.get"
  - "users.messages.send"
  - "users.messages.modify"
key_concepts:
  - "message format"
  - "MIME structure"
  - "label operations"
related_docs:
  - "../threads/threads-reference.md"
notes: |
  Important: Message IDs are unique per mailbox only.
```

#### 2. Feature Comparison (`.yaml` in `docs/datamodel/`)

Maps features across UI/API/gogcli:

```yaml
# docs/datamodel/drive/google-drive-feature-comparison.yaml
metadata:
  service: "Google Drive"
  api_version: "v3"
  analysis_date: "2026-02-06"
  total_features: 150

categories:
  file_operations:
    features:
      - id: "FO-001"
        name: "Upload file"
        ui_support: full      # full | partial | none
        api_support: full
        gogcli_support: full
        api_method: "files.create"
        gogcli_command: "gog drive upload"
        notes: "750GB daily limit"
```

### Calculating Statistics with Scripts

#### Count Features by Support Level

```bash
# Count gogcli-supported features
yq '.categories[].features[] | select(.gogcli_support == "full")' \
  docs/datamodel/drive/google-drive-feature-comparison.yaml | grep -c "^id:"

# Summarize all levels
for level in full partial none; do
  count=$(yq ".categories[].features[] | select(.gogcli_support == \"$level\")" \
    docs/datamodel/*/google-*-feature-comparison.yaml 2>/dev/null | grep -c "^id:" || echo 0)
  echo "gogcli $level: $count"
done
```

#### Find Documents Covering Specific API Calls

```bash
# Find all docs covering a specific API method
yq '.covered_api_calls[]' docs/web/**/*.yaml 2>/dev/null | grep "files.get"

# List all covered API calls across services
yq '.covered_api_calls[]' docs/web/**/*.yaml 2>/dev/null | sort -u
```

#### Generate Coverage Matrix

```bash
# Create CSV of feature coverage per service
echo "service,total,ui_full,api_full,gogcli_full"
for yaml in docs/datamodel/*/google-*-feature-comparison.yaml; do
  service=$(yq '.metadata.service' "$yaml")
  total=$(yq '.metadata.total_features' "$yaml")
  ui=$(yq '.categories[].features[] | select(.ui_support == "full")' "$yaml" | grep -c "^id:")
  api=$(yq '.categories[].features[] | select(.api_support == "full")' "$yaml" | grep -c "^id:")
  gogcli=$(yq '.categories[].features[] | select(.gogcli_support == "full")' "$yaml" | grep -c "^id:")
  echo "$service,$total,$ui,$api,$gogcli"
done
```

#### Find Missing Metadata

```bash
# Find .md files without corresponding .yaml
find docs/web -name "*.md" ! -name "INDEX.md" -exec sh -c '
  for f; do
    yaml="${f%.md}.yaml"
    [ ! -f "$yaml" ] && echo "Missing: $yaml"
  done
' sh {} +
```

#### Aggregate Key Concepts

```bash
# List all key concepts across documentation
yq '.key_concepts[]' docs/web/**/*.yaml 2>/dev/null | sort | uniq -c | sort -rn | head -20
```

### Validation Scripts

#### Validate YAML Syntax

```bash
# Check all YAML files parse correctly
find docs -name "*.yaml" -exec sh -c '
  for f; do
    yq "." "$f" > /dev/null 2>&1 || echo "Invalid YAML: $f"
  done
' sh {} +
```

#### Verify Feature ID Uniqueness

```bash
# Check for duplicate feature IDs within a file
for yaml in docs/datamodel/*/google-*-feature-comparison.yaml; do
  dups=$(yq '.categories[].features[].id' "$yaml" | sort | uniq -d)
  [ -n "$dups" ] && echo "Duplicates in $yaml: $dups"
done
```

#### Cross-Reference Validation

```bash
# Check that related_docs point to existing files
yq '.related_docs[]' docs/web/**/*.yaml 2>/dev/null | while read rel; do
  # Resolve relative path (simplified - full impl needs context)
  [ -n "$rel" ] && echo "Check: $rel"
done
```

### Best Practices

1. **Consistent Field Names**: Use same field names across all YAML files
2. **ISO Timestamps**: Always use `YYYY-MM-DDTHH:MM:SSZ` format
3. **Unique IDs**: Feature IDs should be unique within a file (e.g., `FO-001`, `SH-002`)
4. **Atomic Updates**: Update YAML and related .md files in same commit
5. **Notes Field**: Use for critical caveats or version-specific behavior

### Integration with INDEX.md Files

Each directory's INDEX.md should reference its YAML files:

```markdown
## Metadata Files

| File | Purpose |
|------|---------|
| `messages-reference.yaml` | API call tracking for messages endpoint |
| `threads-reference.yaml` | API call tracking for threads endpoint |

### Quick Stats

- Total API calls documented: $(yq '.covered_api_calls | length' *.yaml | awk '{s+=$1}END{print s}')
- Key concepts: $(yq '.key_concepts | length' *.yaml | awk '{s+=$1}END{print s}')
```

---

## Periodic Maintenance Schedule

### Weekly

- Check if gogcli has new commits
- Verify CURRENT_WORK.md date is recent

### Monthly

- Run coherence verification checks
- Review RESEARCH_REQUESTS.md for stale items
- Check for empty directories

### Per Service Completion

- Update all progress indicators
- Verify all cross-references
- Update summary statistics
