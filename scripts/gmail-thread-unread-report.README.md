# gmail-thread-unread-report.sh

Produce a formatted terminal report of Gmail thread unread ratios from CSV data or by automatically invoking `gmail-thread-unread-stats.sh`.

## Purpose

Companion to `gmail-thread-unread-stats.sh`. Takes the CSV output and produces a human-readable report showing threads with partial unread ratios — empirical evidence that Gmail's UNREAD label is per-message, not per-thread.

## Requirements

* `awk`, `wc` — standard Unix tools
* `gmail-thread-unread-stats.sh` — only if using auto-invoke mode (no `--stdin` or `--input`)

## Usage

```bash
./gmail-thread-unread-report.sh [OPTIONS]
```

### Input Modes (checked in order)

| Mode | Flag | Description |
|------|------|-------------|
| Stdin | `--stdin` | Read CSV from stdin (piping) |
| File | `-i FILE` / `--input FILE` | Read CSV from file |
| Auto | (default) | Run `gmail-thread-unread-stats.sh` automatically |

### Options

| Flag | Default | Description |
|------|---------|-------------|
| `--top N` | 10 | Number of entries in top/bottom lists |

### Passthrough Flags (for auto-invoke mode)

| Flag | Description |
|------|-------------|
| `--account EMAIL` | Gmail account (required in auto mode) |
| `--client NAME` | OAuth client name |
| `--max N` | Max threads to fetch |
| `--query QUERY` | Gmail search query |

## Examples

```bash
# Standalone — fetches data and reports
./gmail-thread-unread-report.sh --account me@gmail.com --max 100

# From file
./gmail-thread-unread-report.sh -i /tmp/claude/gogcli/stats.csv

# From pipe
./gmail-thread-unread-stats.sh --account me@gmail.com --max 50 \
    | ./gmail-thread-unread-report.sh --stdin

# Show top 20 instead of 10
./gmail-thread-unread-report.sh -i stats.csv --top 20
```

## Report Contents

The report includes:

* **Summary statistics**: total threads, multi-message threads, partially read threads, mid-range ratio (0.5-0.9) count
* **Top N by highest unread ratio**: threads with the most unread-but-not-all-unread messages (partial reads)
* **Top N by lowest unread ratio**: threads that are mostly read but have some unread messages

Threads with ratio exactly 0.0 (fully read) or 1.0 (fully unread) are excluded from the ranked lists since they don't demonstrate partial-read behavior.

## See Also

* `gmail-thread-unread-stats.sh` — data collection script
* `../ramblings/2026-02-14--gmail-unread-label-per-message-observation.md` — background observation
