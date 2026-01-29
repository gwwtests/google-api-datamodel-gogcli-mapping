# Repository Objectives

## Primary Goal

Create a comprehensive, meticulous knowledge base documenting the **data model, semantics, and syntax** of Google APIs as used by the [gogcli](https://github.com/steipete/gogcli) command-line tool.

## Why This Repository Exists

When working with the `gog` CLI tool, developers and power users need to understand:

1. **What data structures are returned** from API calls
2. **How identifiers work** - uniqueness guarantees, formats, stability
3. **How things relate** - messages vs threads, events vs calendars
4. **How to safely combine data** from multiple accounts
5. **Time and timezone handling** - critical for calendar, email timestamps
6. **Non-obvious mappings** between what users see and what's in the API

## Target Audience

**Meticulous algorithmicians, computer scientists, and programmers** who need:

* Precise understanding of data semantics
* Guarantees about identifier uniqueness
* Knowledge of edge cases and gotchas
* Ability to write robust code that handles all scenarios
* Confidence when combining data from multiple sources

## Scope

### In Scope

* All 14 Google APIs used by gogcli:
  - Gmail, Calendar, Drive, Contacts/People, Tasks
  - Chat, Classroom, Sheets, Docs, Slides
  - Cloud Identity (Groups), Keep

* For each API:
  - Official documentation (archived with metadata)
  - Data model documentation (our synthesis)
  - Identifier analysis (uniqueness, format, stability)
  - Relationship mapping (what references what)
  - Timezone/datetime handling
  - Multi-account considerations
  - UI-to-API mapping
  - Example responses (sanitized)

### Out of Scope

* How to use the `gog` CLI tool itself (see gogcli docs)
* Authentication setup (see gogcli docs)
* Building applications on Google APIs (we document, not build)
* Real user data (all examples are synthetic/sanitized)

## Success Criteria

A developer should be able to:

1. **Answer questions like:**
   - "If I have a Gmail thread ID, is it unique globally or just within my account?"
   - "When I see a message in a thread, how do I get all messages in that thread?"
   - "If two people share a calendar event, do they see the same event ID?"
   - "What timezone is the event time in?"

2. **Find authoritative sources:**
   - Each claim is backed by official Google documentation
   - YAML metadata allows searching for docs covering specific API calls
   - Source URLs and timestamps track provenance

3. **Understand the data model:**
   - Clear diagrams of entity relationships
   - Examples of actual API responses
   - Documentation of edge cases and gotchas

## Methodology

See `AGENTS.md` for the detailed research workflow:

1. Study gogcli source to understand what APIs are used
2. Research official Google documentation
3. Archive relevant docs with searchable metadata
4. Synthesize into clear data model documentation
5. Include examples, especially non-obvious cases

## Related Files

* `AGENTS.md` - How to work in this repository
* `CURRENT_WORK.md` - What's being worked on now
* `FUTURE_WORK.md` - Roadmap of services to study
