#!/usr/bin/env bash
# Close PRs read from stdin as "<repo>\t<number>" lines (extra columns ignored,
# so the output of list-reviewable-prs.sh or any gh query pipes straight in).
# Dry-run by default — prints what it WOULD close. Pass --yes to actually close.
#
# Usage:
#   <something that emits repo<TAB>number> | close-prs.sh [--yes] [--comment "msg"]
# Example (stale deleted-account PRs):
#   gh search prs --owner lucinity --state open --limit 1000 --json author,repository,number \
#     | jq -r '.[] | select(.author.login|test("^[A-Za-z0-9]{38,40}$")) | "\(.repository.nameWithOwner)\t\(.number)"' \
#     | close-prs.sh --yes --comment "Stale, closing during cleanup. Reopen if needed."
set -euo pipefail

yes=0
comment="Closing during a PR-queue cleanup. Reopen if this is still needed."
while [ $# -gt 0 ]; do
  case "$1" in
    --yes) yes=1; shift ;;
    --comment) comment="${2:-}"; shift 2 ;;
    *) shift ;;
  esac
done

ok=0; fail=0; n=0
while IFS=$'\t' read -r repo num _; do
  [ -z "${repo:-}" ] && continue
  n=$((n + 1))
  if [ "$yes" -eq 0 ]; then
    echo "would close $repo#$num"
    continue
  fi
  if gh pr close "$num" --repo "$repo" --comment "$comment" >/dev/null 2>&1; then
    echo "closed  $repo#$num"; ok=$((ok + 1))
  else
    echo "FAILED  $repo#$num"; fail=$((fail + 1))
  fi
done

if [ "$yes" -eq 0 ]; then
  echo "dry-run: $n PR(s) would close (pass --yes to do it)"
else
  echo "closed $ok, failed $fail"
fi
