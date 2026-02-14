#!/usr/bin/env bash
#
# gmail-thread-unread-stats.sh — Query Gmail via gogcli, compute per-thread
# unread statistics, output CSV.
#
# Read-only: uses only `gmail search` and `gmail thread get`.
#
set -euo pipefail

# Defaults
MAX=200
QUERY="in:inbox"
ACCOUNT=""
CLIENT=""
OUTPUT=""
SLEEP_MS=200
VERBOSE=0

usage() {
    cat <<'EOF'
Usage: gmail-thread-unread-stats.sh --account EMAIL [OPTIONS]

Query Gmail threads via gogcli and compute per-thread unread message ratios.

Required:
  --account EMAIL       Gmail account email

Options:
  --max N               Max threads to fetch (default: 200)
  --query QUERY         Gmail search query (default: "in:inbox")
  --client NAME         OAuth client name (default: "" = gogcli default)
  --output FILE         Write CSV to file instead of stdout
  --sleep-ms MS         Sleep between thread get calls (default: 200)
  --verbose             Print progress to stderr
  -h, --help            Show this help

Output CSV columns:
  thread_id,subject,date,from,total_msg,unread_msg,unread_ratio

Examples:
  ./gmail-thread-unread-stats.sh --account me@gmail.com --max 50
  ./gmail-thread-unread-stats.sh --account me@gmail.com --query "is:unread" --output /tmp/stats.csv
EOF
    exit 0
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --account)   ACCOUNT="$2"; shift 2 ;;
        --max)       MAX="$2"; shift 2 ;;
        --query)     QUERY="$2"; shift 2 ;;
        --client)    CLIENT="$2"; shift 2 ;;
        --output)    OUTPUT="$2"; shift 2 ;;
        --sleep-ms)  SLEEP_MS="$2"; shift 2 ;;
        --verbose)   VERBOSE=1; shift ;;
        -h|--help)   usage ;;
        *)           echo "Unknown option: $1" >&2; exit 1 ;;
    esac
done

if [[ -z "$ACCOUNT" ]]; then
    echo "Error: --account is required" >&2
    echo "Run with --help for usage" >&2
    exit 1
fi

# Check dependencies
for cmd in gog jq; do
    if ! command -v "$cmd" &>/dev/null; then
        echo "Error: '$cmd' not found in PATH" >&2
        exit 1
    fi
done

log() {
    if [[ "$VERBOSE" -eq 1 ]]; then
        echo "[INFO] $*" >&2
    fi
}

# Build gog base flags
GOG_FLAGS=(--json --account "$ACCOUNT")
if [[ -n "$CLIENT" ]]; then
    GOG_FLAGS+=(--client "$CLIENT")
fi

# CSV header
csv_header="thread_id,subject,date,from,total_msg,unread_msg,unread_ratio"

# Output setup
if [[ -n "$OUTPUT" ]]; then
    echo "$csv_header" > "$OUTPUT"
    out_cmd() { echo "$1" >> "$OUTPUT"; }
else
    echo "$csv_header"
    out_cmd() { echo "$1"; }
fi

# Step 1: Search for threads
log "Searching threads with query: $QUERY (max: $MAX)"
search_json=$(gog "${GOG_FLAGS[@]}" gmail search "$QUERY" --max "$MAX" 2>/dev/null)

# Extract thread IDs and message counts
# gogcli --json gmail search returns an array of thread objects
thread_count=$(echo "$search_json" | jq 'length')
log "Found $thread_count threads"

if [[ "$thread_count" -eq 0 ]]; then
    log "No threads found, exiting"
    exit 0
fi

# Step 2: For each thread, fetch details and compute unread ratio
processed=0
skipped_single=0

for i in $(seq 0 $((thread_count - 1))); do
    thread_id=$(echo "$search_json" | jq -r ".[$i].id")
    msg_count=$(echo "$search_json" | jq -r ".[$i].messageCount // 0")
    subject=$(echo "$search_json" | jq -r '.[$i].subject // "(no subject)"' --argjson i "$i")
    date_val=$(echo "$search_json" | jq -r '.[$i].date // ""' --argjson i "$i")
    from_val=$(echo "$search_json" | jq -r '.[$i].from // ""' --argjson i "$i")

    # Skip single-message threads (ratio is trivially 0 or 1)
    if [[ "$msg_count" -le 1 ]]; then
        skipped_single=$((skipped_single + 1))

        # Still output them for completeness — fetch to check UNREAD
        thread_json=$(gog "${GOG_FLAGS[@]}" gmail thread get "$thread_id" 2>/dev/null)
        total=$(echo "$thread_json" | jq '[.messages // [] | length] | add // 0')
        if [[ "$total" -eq 0 ]]; then
            total=1
        fi
        unread=$(echo "$thread_json" | jq '[.messages // [] | .[] | select(.labelIds != null) | select(.labelIds | index("UNREAD"))] | length')
        ratio=$(awk "BEGIN {printf \"%.4f\", $unread / $total}")

        # Sanitize subject: remove commas, newlines, quotes for CSV safety
        safe_subject=$(echo "$subject" | tr -d '\n\r' | sed 's/,/ /g; s/"/""/g')
        safe_from=$(echo "$from_val" | tr -d '\n\r' | sed 's/,/ /g; s/"/""/g')

        out_cmd "\"$thread_id\",\"$safe_subject\",\"$date_val\",\"$safe_from\",$total,$unread,$ratio"

        processed=$((processed + 1))
        log "[$processed/$thread_count] Thread $thread_id: $total msgs, $unread unread (single-msg)"

        # Rate limiting
        sleep "$(awk "BEGIN {print $SLEEP_MS / 1000}")"
        continue
    fi

    # Fetch full thread
    thread_json=$(gog "${GOG_FLAGS[@]}" gmail thread get "$thread_id" 2>/dev/null)

    # Count total messages and unread messages
    total=$(echo "$thread_json" | jq '[.messages // [] | length] | add // 0')
    if [[ "$total" -eq 0 ]]; then
        total="$msg_count"
    fi
    unread=$(echo "$thread_json" | jq '[.messages // [] | .[] | select(.labelIds != null) | select(.labelIds | index("UNREAD"))] | length')

    # Compute ratio
    if [[ "$total" -gt 0 ]]; then
        ratio=$(awk "BEGIN {printf \"%.4f\", $unread / $total}")
    else
        ratio="0.0000"
    fi

    # Sanitize fields for CSV
    safe_subject=$(echo "$subject" | tr -d '\n\r' | sed 's/,/ /g; s/"/""/g')
    safe_from=$(echo "$from_val" | tr -d '\n\r' | sed 's/,/ /g; s/"/""/g')

    out_cmd "\"$thread_id\",\"$safe_subject\",\"$date_val\",\"$safe_from\",$total,$unread,$ratio"

    processed=$((processed + 1))
    log "[$processed/$thread_count] Thread $thread_id: $total msgs, $unread unread, ratio=$ratio"

    # Rate limiting
    sleep "$(awk "BEGIN {print $SLEEP_MS / 1000}")"
done

log "Done. Processed: $processed, Skipped (single-msg): $skipped_single"
