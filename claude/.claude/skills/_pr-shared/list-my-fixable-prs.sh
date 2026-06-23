#!/usr/bin/env bash
# List MY open PRs that have something to fix: a failing/errored check rollup,
# OR an unresolved review thread whose last comment isn't mine (bots included).
# Drafts excluded. These are the PRs my-pr-fixer-all hands to a per-PR agent.
#
# Default (repo from cwd):  output "<number>\t<branch>\t<url>\t<title>" per line.
# --org <name>:             output "<repo>\t<number>\t<headSha>\t<branch>\t<url>\t<title>" per line.
# No lines = nothing to fix.
#
# Usage: list-my-fixable-prs.sh [--org <name>] [max]   (max default 50)
set -euo pipefail

org=""
limit=""
while [ $# -gt 0 ]; do
  case "$1" in
    --org) org="${2:-}"; shift 2 ;;
    *)     limit="$1"; shift ;;
  esac
done
limit="${limit:-50}"
me=$(gh api user --jq .login)

# A PR is fixable when the latest commit's check rollup is FAILURE/ERROR, OR it
# conflicts with its base (needs a rebase), OR some unresolved thread's last
# comment isn't mine (an actionable reply I still owe).
PRED='select(.isDraft | not)
  | select(
      (.commits.nodes[0].commit.statusCheckRollup.state | IN("FAILURE","ERROR"))
      or
      (.mergeable == "CONFLICTING")
      or
      ([.reviewThreads.nodes[]
        | select(.isResolved | not)
        | select((.comments.nodes | last | .author.login) != $ME)] | length > 0)
    )'

PR_FIELDS='number url title isDraft headRefName headRefOid mergeable
  repository{ nameWithOwner isArchived }
  commits(last:1){ nodes{ commit{ statusCheckRollup{ state } } } }
  reviewThreads(first:50){ nodes{ isResolved comments(first:50){ nodes{ author{ login } } } } }'

gql(){ local i; for i in 1 2 3; do gh api graphql "$@" && return 0; sleep 2; done; return 1; }

if [ -z "$org" ]; then
  read -r owner repo < <(gh repo view --json owner,name --jq '"\(.owner.login) \(.name)"')
  gql -f query="
    query(\$owner:String!,\$repo:String!,\$limit:Int!){
      repository(owner:\$owner,name:\$repo){
        pullRequests(states:OPEN,first:\$limit,orderBy:{field:UPDATED_AT,direction:DESC}){
          nodes{ author{ login } $PR_FIELDS }
        }
      }
    }" -F owner="$owner" -F repo="$repo" -F limit="$limit" \
    | jq -r --arg ME "$me" ".data.repository.pullRequests.nodes[]
        | select(.author.login == \$ME) | $PRED
        | [(.number|tostring), .headRefName, .url, .title] | @tsv"
  exit 0
fi

out=""
cursor=""
while :; do
  if ! page=$(gql -f query="
    query(\$q:String!,\$after:String){
      search(query:\$q,type:ISSUE,first:25,after:\$after){
        pageInfo{ hasNextPage endCursor }
        nodes{ ... on PullRequest { $PR_FIELDS } }
      }
    }" -F q="org:$org is:pr is:open draft:false archived:false author:@me" ${cursor:+-F after="$cursor"}); then
    echo "warning: a search page failed after retries; list may be incomplete" >&2
    break
  fi
  out+=$(jq -r --arg ME "$me" ".data.search.nodes[] | $PRED
    | [.repository.nameWithOwner, (.number|tostring), .headRefOid, .headRefName, .url, .title] | @tsv" <<<"$page")
  out+=$'\n'
  [ "$(jq -r '.data.search.pageInfo.hasNextPage' <<<"$page")" = "true" ] || break
  cursor=$(jq -r '.data.search.pageInfo.endCursor' <<<"$page")
done
printf '%s' "$out" | grep -v '^[[:space:]]*$' | head -n "$limit"
