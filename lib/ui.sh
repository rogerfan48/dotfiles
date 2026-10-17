#!/bin/bash
# Output and prompt helpers shared by initialization.sh and setup_link.sh.

if [[ -t 1 ]]; then
    C_RESET=$'\e[0m'; C_BOLD=$'\e[1m'; C_DIM=$'\e[2m'; C_BLUE=$'\e[1;34m'
    C_GREEN=$'\e[32m'; C_YELLOW=$'\e[33m'; C_RED=$'\e[1;31m'; C_CYAN=$'\e[36m'
else
    C_RESET=''; C_BOLD=''; C_DIM=''; C_BLUE=''; C_GREEN=''; C_YELLOW=''; C_RED=''; C_CYAN=''
fi
LOG="${LOG:-/dev/null}"

step() { printf '%s\n' "${C_BLUE}▶ $*${C_RESET}"; }  # action in progress
ok()   { printf '%s\n' "${C_GREEN}✓ $*${C_RESET}"; }  # done / success
skip() { printf '%s\n' "${C_DIM}• $*${C_RESET}"; }    # nothing to do
warn() { printf '%s\n' "${C_YELLOW}⚠ $*${C_RESET}"; }
err()  { printf '%s\n' "${C_RED}✗ $*${C_RESET}"; }
have() { command -v "$1" >/dev/null 2>&1; }

section() { printf '\n%s── %s%s\n' "$C_BOLD" "$*" "$C_RESET"; }

# ask <question> <default y|n>: true on yes. ASSUME_YES=1 answers the default.
ask() {
    local def="${2:-n}" hint="y/N" answer
    [[ "$def" == y ]] && hint="Y/n"
    printf '%s?%s %s %s[%s]%s ' "$C_YELLOW" "$C_RESET" "$1" "$C_DIM" "$hint" "$C_RESET"
    if [[ "${ASSUME_YES:-0}" == 1 ]]; then
        echo "$def"
        answer="$def"
    else
        read -r answer || answer=""
    fi
    [[ "${answer:-$def}" == [yY]* ]]
}

# run <label> <cmd...>: run a command with its output going to $LOG, showing a
# spinner on a terminal; on failure print the end of the log.
run() {
    local label="$1" rc start=$SECONDS
    shift
    printf '\n### %s\n' "$label" >>"$LOG"
    if [[ -t 1 ]]; then
        "$@" >>"$LOG" 2>&1 &
        local pid=$! i=0 frames=(⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏)
        while kill -0 "$pid" 2>/dev/null; do
            printf '\r  %s%s%s %s %s%ds%s' "$C_BLUE" "${frames[i++ % 10]}" "$C_RESET" \
                "$label" "$C_DIM" $((SECONDS - start)) "$C_RESET"
            sleep 0.1
        done
        wait "$pid"
        rc=$?
        printf '\r\e[K'
    else
        "$@" >>"$LOG" 2>&1
        rc=$?
    fi
    if ((rc != 0)); then
        err "$label failed (exit $rc). End of $LOG:"
        tail -n 12 "$LOG" | sed "s/^/    /"
    fi
    return $rc
}
