#!/usr/bin/env bash
# List open, human-authored PRs across an org's ACTIVE (non-archived) repos that
# have had no activity in <days> (default 14). Bots and mannequins excluded.
# Output per line: repo<TAB>number<TAB>author<TAB>idleDays<TAB>url<TAB>title<TAB>summary
# (summary = first ~200 chars of the PR body, newlines flattened.)
#
# Usage: list-old-human-prs.sh [--org <name>] [days] [max]
# (org defaults to the current repo's owner, days 14, max 300)
set -euo pipefail

org=""
days=14
limit=300
while [ $# -gt 0 ]; do
  case "$1" in
    --org) org="${2:-}"; shift 2 ;;
    *) if [ -z "${days_set:-}" ]; then days="$1"; days_set=1; else limit="$1"; fi; shift ;;
  esac
done

[ -z "$org" ] && org=$(gh repo view --json owner --jq '.owner.login' 2>/dev/null || true)
[ -z "$org" ] && { echo "no org: pass --org <name> or run inside a repo of the target org" >&2; exit 1; }

cutoff=$(date -u -d "$days days ago" +%Y-%m-%d 2>/dev/null || date -u -v-"${days}"d +%Y-%m-%d)

gql(){ local i; for i in 1 2 3; do gh api graphql "$@" && return 0; sleep 2; done; return 1; }

# Human = not a Bot/Mannequin and login isn't a [bot]. Archived repos excluded by the
# search qualifier; isArchived guard kept as belt-and-suspenders.
PRED='select(.repository.isArchived | not)
  | select(.author.__typename != "Bot")
  | select(.author.__typename != "Mannequin")
  | select(.author.login | endswith("[bot]") | not)'

cursor=""
while :; do
  if ! page=$(gql -f query="
    query(\$q:String!,\$after:String){
      search(query:\$q,type:ISSUE,first:25,after:\$after){
        pageInfo{ hasNextPage endCursor }
        nodes{ ... on PullRequest {
          number url title body updatedAt
          repository{ nameWithOwner isArchived }
          author{ __typename login }
        } }
      }
    }" -F q="org:$org is:pr is:open archived:false updated:<$cutoff sort:updated-asc" \
       ${cursor:+-F after="$cursor"}); then
    echo "warning: a search page failed after retries; list may be incomplete" >&2
    break
  fi
  jq -r ".data.search.nodes[] | $PRED
    | [ .repository.nameWithOwner, (.number|tostring), .author.login,
        (((now - (.updatedAt|fromdateiso8601))/86400)|floor|tostring),
        .url, .title,
        ((.body // \"\") | gsub(\"[\\r\\n]+\";\" \") | .[0:200]) ] | @tsv" <<<"$page"
  [ "$(jq -r '.data.search.pageInfo.hasNextPage' <<<"$page")" = "true" ] || break
  cursor=$(jq -r '.data.search.pageInfo.endCursor' <<<"$page")
done | head -n "$limit"
