#!/usr/bin/env bash
# List open PRs ready for a first review: human-authored (no bots), not draft,
# not yet approved, no unresolved review threads, not mine, not already reviewed by me.
#
# Default (repo from cwd):  output "<number>\t<url>\t<title>" per line.
# --org <name>:             output "<repo>\t<number>\t<headSha>\t<url>\t<title>" per line,
#                           across every repo in the org.
# No lines = nothing to review.
#
# Usage: list-reviewable-prs.sh [--org <name>] [max]   (max default 50)
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

# Shared filter: not archived, not draft, not approved, no unresolved threads, not me,
# not a bot or mannequin (deactivated/imported accounts), not already reviewed by me.
# Copilot-only unresolved threads don't count — no human is mid-conversation there.
PRED='select(.repository.isArchived | not)
  | select(.isDraft|not)
  | select(.reviewDecision != "APPROVED")
  | select([.reviewThreads.nodes[] | select(.isResolved|not)
            | select(any(.comments.nodes[]; .author.login != "copilot-pull-request-reviewer"))] | length == 0)
  | select(.author.login != $ME)
  | select(.author.__typename != "Bot")
  | select(.author.__typename != "Mannequin")
  | select(.author.login | endswith("[bot]") | not)
  | select(([.reviews.nodes[]? | select(.author.login == $ME)] | length) == 0)'

PR_FIELDS='number url title isDraft reviewDecision headRefOid
  repository{ nameWithOwner isArchived }
  author{ __typename login }
  reviews(last:20){ nodes{ author{ login } } }
  reviewThreads(first:50){ nodes{ isResolved comments(first:20){ nodes{ author{ login } } } } }'

# Retry transient GraphQL 502s/timeouts (heavy search pages flake).
gql(){ local i; for i in 1 2 3; do gh api graphql "$@" && return 0; sleep 2; done; return 1; }

if [ -z "$org" ]; then
  read -r owner repo < <(gh repo view --json owner,name --jq '"\(.owner.login) \(.name)"')
  gql -f query="
    query(\$owner:String!,\$repo:String!,\$limit:Int!){
      repository(owner:\$owner,name:\$repo){
        pullRequests(states:OPEN,first:\$limit,orderBy:{field:UPDATED_AT,direction:DESC}){
          nodes{ $PR_FIELDS }
        }
      }
    }" -F owner="$owner" -F repo="$repo" -F limit="$limit" \
    | jq -r --arg ME "$me" ".data.repository.pullRequests.nodes[] | $PRED
        | [(.number|tostring), .url, .title] | @tsv"
  exit 0
fi

# --org: paginate a cross-repo search, filter, cap output at <max>.
out=""
cursor=""
while :; do
  if ! page=$(gql -f query="
    query(\$q:String!,\$after:String){
      search(query:\$q,type:ISSUE,first:25,after:\$after){
        pageInfo{ hasNextPage endCursor }
        nodes{ ... on PullRequest { $PR_FIELDS } }
      }
    }" -F q="org:$org is:pr is:open draft:false archived:false" ${cursor:+-F after="$cursor"}); then
    echo "warning: a search page failed after retries; list may be incomplete" >&2
    break
  fi
  out+=$(jq -r --arg ME "$me" ".data.search.nodes[] | $PRED
    | [.repository.nameWithOwner, (.number|tostring), .headRefOid, .url, .title] | @tsv" <<<"$page")
  out+=$'\n'
  [ "$(jq -r '.data.search.pageInfo.hasNextPage' <<<"$page")" = "true" ] || break
  cursor=$(jq -r '.data.search.pageInfo.endCursor' <<<"$page")
done
printf '%s' "$out" | grep -v '^[[:space:]]*$' | head -n "$limit"
