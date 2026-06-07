#!/usr/bin/env bash
#
# Optimize the Nix store: prune old generations, garbage-collect dead paths,
# and hard-link identical files to reclaim disk space.
#
# Usage:
#   ./nix-optimize.sh              # GC dead paths + dedup store
#   ./nix-optimize.sh --age 14d    # also delete generations older than 14 days
#   ./nix-optimize.sh --all        # also delete ALL but the current generation
#   ./nix-optimize.sh --dry-run    # show what would happen, change nothing
#
set -euo pipefail

AGE=""
DELETE_ALL=false
DRY_RUN=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --age)     AGE="$2"; shift 2 ;;
    --all)     DELETE_ALL=true; shift ;;
    --dry-run) DRY_RUN=true; shift ;;
    -h|--help)
      grep '^#' "$0" | sed 's/^# \?//'
      exit 0 ;;
    *) echo "unknown option: $1" >&2; exit 1 ;;
  esac
done

run() {
  echo "+ $*"
  $DRY_RUN || "$@"
}

size_before=$(du -sh /nix/store 2>/dev/null | cut -f1)
echo "Nix store size before: ${size_before}"
echo

# 1. Prune profile generations. GC only reclaims space once nothing references
#    a path, and old generations are the references that pin dead paths.
if $DELETE_ALL; then
  echo "==> Deleting all old generations (keeping current)"
  run sudo nix-collect-garbage --delete-old
elif [[ -n "$AGE" ]]; then
  echo "==> Deleting generations older than ${AGE}"
  run sudo nix-collect-garbage --delete-older-than "$AGE"
  # User profile generations live outside the system profile.
  run nix-collect-garbage --delete-older-than "$AGE"
fi

# 2. Garbage-collect unreferenced store paths.
echo
echo "==> Collecting garbage"
run sudo nix store gc

# 3. Deduplicate: replace identical files with hard links.
echo
echo "==> Optimising store (hard-linking duplicates)"
run sudo nix store optimise

echo
if ! $DRY_RUN; then
  size_after=$(du -sh /nix/store 2>/dev/null | cut -f1)
  echo "Nix store size after:  ${size_after} (was ${size_before})"
fi
