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
