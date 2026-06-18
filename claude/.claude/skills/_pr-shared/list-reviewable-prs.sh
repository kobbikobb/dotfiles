#!/usr/bin/env bash
# List open PRs ready for a first review: human-authored (no bots), not draft,
# not yet approved, no unresolved review threads, not mine, not already reviewed by me.
# Output: one "<number>\t<url>\t<title>" per line. No lines = nothing to review.
# Usage: list-reviewable-prs.sh [max-to-scan]   (default 50; repo inferred from cwd)
set -euo pipefail

limit="${1:-50}"
me=$(gh api user --jq .login)
read -r owner repo < <(gh repo view --json owner,name --jq '"\(.owner.login) \(.name)"')

ME="$me" gh api graphql \
  -f query='
    query($owner:String!,$repo:String!,$limit:Int!){
      repository(owner:$owner,name:$repo){
        pullRequests(states:OPEN,first:$limit,orderBy:{field:UPDATED_AT,direction:DESC}){
          nodes{
            number url title isDraft reviewDecision
            author{__typename login}
            reviews(last:30){nodes{author{login}}}
            reviewThreads(first:100){nodes{isResolved}}
          }
        }
      }
    }' \
  -F owner="$owner" -F repo="$repo" -F limit="$limit" \
  --jq '
    .data.repository.pullRequests.nodes[]
    | select(.isDraft | not)
    | select(.reviewDecision != "APPROVED")
    | select((.reviewThreads.nodes | map(select(.isResolved | not)) | length) == 0)
    | select(.author.login != env.ME)
    | select(.author.__typename != "Bot")
    | select(.author.login | endswith("[bot]") | not)
    | select(([.reviews.nodes[]? | select(.author.login == env.ME)] | length) == 0)
    | "\(.number)\t\(.url)\t\(.title)"
  '
