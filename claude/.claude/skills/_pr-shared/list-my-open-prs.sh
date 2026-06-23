#!/usr/bin/env bash
# List ALL my open PRs across every repo, ranked by what needs my action.
# Emits a ready-to-print Markdown table; the caller prints it verbatim.
# Output tiers: needs-action (CI fail / conflict) -> ready -> waiting -> draft,
# oldest-first within each tier.
# Usage: list-my-open-prs.sh [--org <name>] [max]   (max default 100)
set -euo pipefail
org=""; limit=100
while [ $# -gt 0 ]; do
  case "$1" in
    --org) org="${2:-}"; shift 2 ;;
    *) limit="$1"; shift ;;
  esac
done

prs=$(gh search prs --author "@me" --state open ${org:+--owner "$org"} \
  --json repository,number --limit "$limit" \
  | jq -r '.[] | "\(.repository.nameWithOwner)\t\(.number)"')
[ -z "$prs" ] && { echo "_No open PRs._"; exit 0; }

row(){
  gh pr view "$2" -R "$1" --json title,url,isDraft,reviewDecision,latestReviews,mergeable,statusCheckRollup,updatedAt,comments 2>/dev/null \
  | jq -r --arg repo "${1#*/}" --arg num "$2" '
    def ci:
      ([.statusCheckRollup[]?|(.conclusion//.state//"")]|map(select(.!=""))) as $s
      | if ($s|length)==0 then "—"
        elif ($s|any(.=="FAILURE" or .=="ERROR" or .=="TIMED_OUT" or .=="ACTION_REQUIRED")) then "❌"
        elif ($s|any(.=="PENDING" or .=="IN_PROGRESS" or .=="QUEUED" or .=="EXPECTED")) then "🟡"
        else "✅" end;
    # reviewDecision is empty when the repo does not *require* review, so also honor a
    # standing approval in latestReviews (and a standing changes-request).
    (any(.latestReviews[]?; .state=="APPROVED")) as $approved |
    (any(.latestReviews[]?; .state=="CHANGES_REQUESTED")) as $changes |
    def merge:
      if .mergeable=="CONFLICTING" then "❌ conflict"
      elif .mergeable=="MERGEABLE" then "clean"
      else "⚠️ unknown" end;
    def rev:
      if .isDraft then "—"
      elif .reviewDecision=="CHANGES_REQUESTED" or $changes then "🔴 changes"
      elif .reviewDecision=="APPROVED" or $approved then "✅ approved"
      elif .reviewDecision=="REVIEW_REQUIRED" then "🔶 review"
      else "—" end;
    (ci) as $ci | (.mergeable) as $m |
    (if .isDraft then 3
     elif $ci=="❌" or $m=="CONFLICTING" then 0
     elif (.reviewDecision=="APPROVED" or $approved) and ($changes|not) and $ci=="✅" and $m=="MERGEABLE" then 1
     else 2 end) as $tier |
    ((now-(.updatedAt|fromdateiso8601))/86400|floor) as $idle |
    [ ($tier|tostring), ((9999-$idle)|tostring), ($idle|tostring),
      $ci, merge, rev, ($repo+"#"+$num), .url, (.comments|length|tostring), .title ]|@tsv';
}
export -f row

rows=$(echo "$prs" | xargs -P 8 -n2 bash -c 'row "$0" "$1"' | sort -t$'\t' -k1,1n -k2,2n)

echo "$rows" | awk -F'\t' '
  function flush(){ if(open){print ""}; open=0 }
  BEGIN{ split("🔴 Needs action (CI fail / conflict)|🟢 Ready to merge|🟡 Waiting on review|⚪ Drafts",H,"|"); t=-1 }
  $1!=t{ flush(); t=$1; print "## " H[t+1];
         print "| PR | Title | CI | Merge | Review | Idle | 💬 | URL |";
         print "|---|---|---|---|---|---|---|---|"; open=1 }
  { printf "| %s | %s | %s | %s | %s | %sd | %s | %s |\n", $7,$10,$4,$5,$6,$3,$9,$8 }
  END{ flush() }'
