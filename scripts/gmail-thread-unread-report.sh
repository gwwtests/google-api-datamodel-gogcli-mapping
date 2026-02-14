#!/usr/bin/env bash
#
# gmail-thread-unread-report.sh — Produce a formatted report of thread unread
# ratios from CSV data (or by invoking gmail-thread-unread-stats.sh).
#
# Read-only: no Gmail modifications.
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INPUT_FILE=""
FROM_STDIN=0
TOP_N=10

# Passthrough flags for stats script
ACCOUNT=""
CLIENT=""
MAX=""
QUERY=""

usage() {
    cat <<'EOF'
Usage: gmail-thread-unread-report.sh [OPTIONS]

Produce a formatted report of Gmail thread unread ratios.

Input modes (checked in order):
  --stdin               Read CSV from stdin
  -i FILE, --input FILE Read CSV from file
  (default)             Run gmail-thread-unread-stats.sh automatically

Options:
  --top N               Show top N entries (default: 10)
  -h, --help            Show this help

Passthrough flags (used when auto-invoking stats script):
  --account EMAIL       Gmail account (required if no --stdin or --input)
  --client NAME         OAuth client name
  --max N               Max threads to fetch
  --query QUERY         Gmail search query

Examples:
  # Standalone — fetches data automatically
  ./gmail-thread-unread-report.sh --account me@gmail.com --max 100

  # From file
  ./gmail-thread-unread-report.sh -i /tmp/claude/gogcli/stats.csv

  # From pipe
  ./gmail-thread-unread-stats.sh --account me@gmail.com | ./gmail-thread-unread-report.sh --stdin
EOF
    exit 0
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --stdin)     FROM_STDIN=1; shift ;;
        -i|--input)  INPUT_FILE="$2"; shift 2 ;;
        --top)       TOP_N="$2"; shift 2 ;;
        --account)   ACCOUNT="$2"; shift 2 ;;
        --client)    CLIENT="$2"; shift 2 ;;
        --max)       MAX="$2"; shift 2 ;;
        --query)     QUERY="$2"; shift 2 ;;
        -h|--help)   usage ;;
        *)           echo "Unknown option: $1" >&2; exit 1 ;;
    esac
done

# Determine input source
CSV_FILE=""

if [[ "$FROM_STDIN" -eq 1 ]]; then
    # Read from stdin into temp file
    CSV_FILE=$(mktemp /tmp/claude/gmail-report-XXXXXX.csv)
    trap "rm -f '$CSV_FILE'" EXIT
    cat > "$CSV_FILE"
elif [[ -n "$INPUT_FILE" ]]; then
    if [[ ! -f "$INPUT_FILE" ]]; then
        echo "Error: Input file not found: $INPUT_FILE" >&2
        exit 1
    fi
    CSV_FILE="$INPUT_FILE"
else
    # Auto-invoke stats script
    if [[ -z "$ACCOUNT" ]]; then
        echo "Error: --account is required when not using --stdin or --input" >&2
        echo "Run with --help for usage" >&2
        exit 1
    fi

    CSV_FILE=$(mktemp /tmp/claude/gmail-report-XXXXXX.csv)
    trap "rm -f '$CSV_FILE'" EXIT

    STATS_ARGS=(--account "$ACCOUNT" --verbose)
    [[ -n "$CLIENT" ]] && STATS_ARGS+=(--client "$CLIENT")
    [[ -n "$MAX" ]] && STATS_ARGS+=(--max "$MAX")
    [[ -n "$QUERY" ]] && STATS_ARGS+=(--query "$QUERY")

    echo "Fetching thread data..." >&2
    "$SCRIPT_DIR/gmail-thread-unread-stats.sh" "${STATS_ARGS[@]}" > "$CSV_FILE"
    echo "Data collected. Generating report..." >&2
fi

# Verify CSV has data
line_count=$(wc -l < "$CSV_FILE")
if [[ "$line_count" -le 1 ]]; then
    echo "No data found in CSV (only header or empty)." >&2
    exit 1
fi

data_lines=$((line_count - 1))

# Generate report using awk
awk -F',' -v top_n="$TOP_N" '
BEGIN {
    n = 0
}
NR == 1 { next }  # skip header
{
    # Parse CSV fields (handling quoted fields)
    # Fields: thread_id,subject,date,from,total_msg,unread_msg,unread_ratio
    # Remove surrounding quotes
    gsub(/^"/, "", $1); gsub(/"$/, "", $1)

    # Subject may contain escaped quotes — just take field 2
    # For robustness, reconstruct subject from middle fields
    # Fixed-position fields from the end: ratio, unread, total are last 3
    ratio = $NF
    unread = $(NF-1)
    total = $(NF-2)

    # from is field NF-3 (quoted)
    from_field = $(NF-3)
    gsub(/^"/, "", from_field); gsub(/"$/, "", from_field)

    # date is field NF-4
    date_field = $(NF-4)
    gsub(/^"/, "", date_field); gsub(/"$/, "", date_field)

    # thread_id is first field
    tid = $1
    gsub(/"/, "", tid)

    # subject is everything between field 1 and date field
    # For simplicity, use field 2
    subj = $2
    gsub(/^"/, "", subj); gsub(/"$/, "", subj)
    if (length(subj) > 50) subj = substr(subj, 1, 47) "..."

    n++
    thread_ids[n] = tid
    subjects[n] = subj
    dates[n] = date_field
    froms[n] = from_field
    totals[n] = total + 0
    unreads[n] = unread + 0
    ratios[n] = ratio + 0.0

    # Stats
    if (total > 1) multi_msg_count++
    if (ratio > 0.0 && ratio < 1.0) partial_count++
    if (ratio >= 0.5 && ratio <= 0.9) mid_range_count++
    if (ratio == 0.0) fully_read_count++
    if (ratio == 1.0) fully_unread_count++
    total_threads++
}
END {
    printf "\n"
    printf "═══════════════════════════════════════════════════════════════════\n"
    printf "  Gmail Thread Unread Ratio Report\n"
    printf "═══════════════════════════════════════════════════════════════════\n\n"

    printf "  SUMMARY\n"
    printf "  ───────────────────────────────────\n"
    printf "  Total threads analyzed:    %6d\n", total_threads
    printf "  Multi-message threads:     %6d\n", multi_msg_count
    printf "  Partially read (0<r<1):    %6d\n", partial_count
    printf "  Mid-range ratio (0.5-0.9): %6d\n", mid_range_count
    printf "  Fully read (ratio=0):      %6d\n", fully_read_count
    printf "  Fully unread (ratio=1):    %6d\n", fully_unread_count
    printf "\n"

    # Sort by ratio descending — find top N with highest ratio (partial reads)
    # Simple selection sort for top_n
    for (i = 1; i <= n; i++) used[i] = 0

    printf "  TOP %d THREADS BY HIGHEST UNREAD RATIO (partial reads)\n", top_n
    printf "  ───────────────────────────────────────────────────────────────\n"
    printf "  %-8s  %5s  %6s  %7s  %-50s\n", "Ratio", "Unrd", "Total", "Thread", "Subject"
    printf "  %-8s  %5s  %6s  %7s  %-50s\n", "────────", "─────", "──────", "───────", "──────────────────────────────────────────────────"

    shown = 0
    for (k = 1; k <= top_n && k <= n; k++) {
        best = -1; best_ratio = -1
        for (i = 1; i <= n; i++) {
            if (!used[i] && ratios[i] > best_ratio) {
                best = i; best_ratio = ratios[i]
            }
        }
        if (best == -1) break
        # Skip ratio=1.0 (fully unread, not interesting for partial analysis)
        if (ratios[best] >= 1.0) { used[best] = 1; k--; continue }
        if (ratios[best] <= 0.0) break
        used[best] = 1
        printf "  %8.4f  %5d  %6d  %7s  %-50s\n", ratios[best], unreads[best], totals[best], thread_ids[best], subjects[best]
        shown++
    }
    if (shown == 0) printf "  (no partially-read threads found)\n"

    printf "\n"

    # Reset used array
    for (i = 1; i <= n; i++) used[i] = 0

    printf "  TOP %d THREADS BY LOWEST UNREAD RATIO (mostly read, some unread)\n", top_n
    printf "  ───────────────────────────────────────────────────────────────\n"
    printf "  %-8s  %5s  %6s  %7s  %-50s\n", "Ratio", "Unrd", "Total", "Thread", "Subject"
    printf "  %-8s  %5s  %6s  %7s  %-50s\n", "────────", "─────", "──────", "───────", "──────────────────────────────────────────────────"

    shown = 0
    for (k = 1; k <= top_n && k <= n; k++) {
        best = -1; best_ratio = 999
        for (i = 1; i <= n; i++) {
            if (!used[i] && ratios[i] < best_ratio && ratios[i] > 0.0) {
                best = i; best_ratio = ratios[i]
            }
        }
        if (best == -1) break
        # Skip ratio=1.0
        if (ratios[best] >= 1.0) { used[best] = 1; k--; continue }
        used[best] = 1
        printf "  %8.4f  %5d  %6d  %7s  %-50s\n", ratios[best], unreads[best], totals[best], thread_ids[best], subjects[best]
        shown++
    }
    if (shown == 0) printf "  (no partially-read threads found)\n"

    printf "\n"
    printf "═══════════════════════════════════════════════════════════════════\n"
}
' "$CSV_FILE"
