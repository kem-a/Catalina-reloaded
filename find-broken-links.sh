#!/usr/bin/env bash
#
# find-broken-links.sh — Recursively find broken symbolic links
#
# Usage: ./find-broken-links.sh [directory...]
#   If no directory is given, defaults to the current directory.
#
# Options (set via env):
#   VERBOSE=1      Print each link checked (including valid ones)
#   ABSOLUTE=1     Show target paths as absolute (resolved from link location)
#   DELETE=1       Remove broken links automatically (prompts by default)
#   DELETE_FORCE=1 Remove broken links without prompting

set -euo pipefail

# --- helpers ---------------------------------------------------------

die() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

# --- argument parsing ------------------------------------------------

dirs=()
for arg in "${@}"; do
    if [[ -d "$arg" ]]; then
        dirs+=("$arg")
    else
        printf 'WARNING: "%s" is not a directory — skipping\n' "$arg" >&2
    fi
done

# Default to current directory
[[ ${#dirs[@]} -eq 0 ]] && dirs=(".")

# --- main loop -------------------------------------------------------

broken_count=0
total_count=0

while IFS= read -r -d '' link; do
    ((total_count++))

    # Resolve the link target *relative to the link's own directory*
    target=$(readlink "$link") || true
    link_dir=$(dirname "$link")

    # Determine whether the target is resolvable
    if [[ -z "$target" ]]; then
        # Empty target is always broken
        valid=false
    elif [[ "$target" == /* ]]; then
        # Absolute target
        [[ -e "$target" ]] && valid=true || valid=false
    else
        # Relative target — resolve against the link's directory
        [[ -e "$link_dir/$target" ]] && valid=true || valid=false
    fi

    if [[ "$valid" == false ]]; then
        ((broken_count++))
        printf '%-8s %s\n' 'BROKEN' "$link"

        if [[ -n "${DELETE_FORCE:-}" ]]; then
            rm "$link"
            printf '         -> deleted (force)\n'
        elif [[ -n "${DELETE:-}" ]]; then
            rm -i "$link"
        fi
    elif [[ -n "${VERBOSE:-}" ]]; then
        if [[ -n "${ABSOLUTE:-}" ]]; then
            resolved=$(cd "$link_dir" 2>/dev/null && realpath -m "$target" 2>/dev/null || echo "$link_dir/$target")
            printf '%-8s %s -> %s\n' 'OK' "$link" "$resolved"
        else
            printf '%-8s %s -> %s\n' 'OK' "$link" "$target"
        fi
    fi
done < <(find "${dirs[@]}" -xtype l -print0 2>/dev/null || true)

# --- summary ---------------------------------------------------------

printf '\nScanned: %d symlink(s) | Broken: %d\n' "$total_count" "$broken_count"

if [[ "$broken_count" -gt 0 ]]; then
    exit 1
fi
