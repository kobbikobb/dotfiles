#!/usr/bin/env bash
# Merge PRs read from stdin as "<repo>\t<number>" lines (extra columns ignored,
# so a `gh search prs ... --json repository,number` query pipes straight in).
# Dry-run by default — prints what it WOULD merge. Pass --yes to actually merge.
# --approve submits an approving review first (satisfies a code-owner review gate).
#
# Usage:
#   <something that emits repo<TAB>number> | merge-prs.sh [--yes] [--approve] [--method squash|merge|rebase]
# Example (every patches-approved bot PR in the org):
#   gh search prs --owner "$(gh repo view --json owner --jq .owner.login)" --state open --label patches-approved --limit 200 \
#     --json repository,number --jq '.[] | "\(.repository.nameWithOwner)\t\(.number)"' \
#     | merge-prs.sh --yes --approve
set -euo pipefail

yes=0
approve=0
method="squash"
while [ $# -gt 0 ]; do
  case "$1" in
    --yes) yes=1; shift ;;
    --approve) approve=1; shift ;;
    --method) method="${2:-squash}"; shift 2 ;;
    *) shift ;;
  esac
done

ok=0; fail=0; n=0
while IFS=$'\t' read -r repo num _; do
  [ -z "${repo:-}" ] && continue
  n=$((n + 1))
  if [ "$yes" -eq 0 ]; then
    echo "would merge $repo#$num"
    continue
  fi
  [ "$approve" -eq 1 ] && gh pr review "$num" --repo "$repo" --approve >/dev/null 2>&1 || true
  if gh pr merge "$num" --repo "$repo" --"$method" >/dev/null 2>&1; then
    echo "merged  $repo#$num"; ok=$((ok + 1))
  else
    echo "FAILED  $repo#$num"; fail=$((fail + 1))
  fi
done

if [ "$yes" -eq 0 ]; then
  echo "dry-run: $n PR(s) would merge (pass --yes to do it)"
else
  echo "merged $ok, failed $fail"
fi
