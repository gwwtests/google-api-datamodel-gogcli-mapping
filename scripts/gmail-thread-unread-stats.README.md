# gmail-thread-unread-stats.sh

Query Gmail threads via [gogcli](https://github.com/steipete/gogcli) and compute per-thread unread message ratios, outputting CSV.

## Purpose

Gmail's `UNREAD` label is applied **per-message**, not per-thread. Within a single thread, some messages can be read while others remain unread. This script collects empirical data about that behavior by fetching threads and counting unread messages within each.

## Requirements

* `gog` (gogcli) — in `$PATH`, with valid OAuth credentials
* `jq` — for JSON processing
* `awk` — for ratio computation (standard on all Unix systems)

## Usage

```bash
./gmail-thread-unread-stats.sh --account EMAIL [OPTIONS]
```

### Required

| Flag | Description |
|------|-------------|
| `--account EMAIL` | Gmail account email address |

### Optional

| Flag | Default | Description |
|------|---------|-------------|
| `--max N` | 200 | Maximum threads to fetch |
| `--query QUERY` | `in:inbox` | Gmail search query |
| `--client NAME` | (gogcli default) | OAuth client name |
| `--output FILE` | stdout | Write CSV to file |
| `--sleep-ms MS` | 200 | Sleep between API calls (rate limiting) |
| `--verbose` | off | Print progress to stderr |

## Output Format

CSV with these columns:

```
thread_id,subject,date,from,total_msg,unread_msg,unread_ratio
```

* `unread_ratio` = `unread_msg / total_msg` (0.0000 to 1.0000)
* Subject field is sanitized (commas/newlines stripped)
* Fields are double-quoted for CSV safety

## Examples

```bash
# Basic: fetch 50 inbox threads
./gmail-thread-unread-stats.sh --account me@gmail.com --max 50

# Save to file with verbose output
./gmail-thread-unread-stats.sh --account me@gmail.com --max 200 \
    --output /tmp/claude/gogcli/stats.csv --verbose

# Custom query: only unread threads
./gmail-thread-unread-stats.sh --account me@gmail.com --query "is:unread"

# Use specific OAuth client
./gmail-thread-unread-stats.sh --account me@gmail.com --client prod --max 100
```

## How It Works

1. Runs `gog --json gmail search '<query>' --max N` to get thread list
2. For each thread, runs `gog --json gmail thread get <THREADID>`
3. Counts messages whose `labelIds` array contains `"UNREAD"`
4. Computes `unread_ratio = unread_msg / total_msg`
5. Outputs one CSV row per thread

## Safety

* **Read-only**: uses only `gmail search` and `gmail thread get`
* No messages are modified, sent, or deleted
* Rate-limited with configurable sleep between API calls

## See Also

* `gmail-thread-unread-report.sh` — formatted report from this script's CSV output
* `../ramblings/2026-02-14--gmail-unread-label-per-message-observation.md` — background on the UNREAD-per-message observation
