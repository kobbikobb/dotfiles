#!/usr/bin/env bash
# Deterministic rebase plumbing for the PR fixers. Owns every force-push so no
# caller ever types a raw `git push --force` — it's always `--force-with-lease`.
# Conflict resolution and the build/test gate are the caller's job, NOT this script's.
#
#   rebase-onto-base.sh rebase <worktree> <branch> [base]
#     0  clean rebase applied (NOT pushed — caller runs `push` after its gate)
#     1  nothing to do (branch already contains base tip)
#     3  conflicts — left in the working tree for the caller to resolve or abort
#
#   rebase-onto-base.sh push <worktree> <branch>
#     force-pushes with lease (the ONLY force-push in the fixer flow)
set -euo pipefail

cmd="${1:-}"; wt="${2:-}"; branch="${3:-}"
[ -n "$cmd" ] && [ -n "$wt" ] && [ -n "$branch" ] || { echo "usage: rebase-onto-base.sh rebase|push <worktree> <branch> [base]" >&2; exit 2; }
g(){ git -C "$wt" "$@"; }

case "$cmd" in
  push)
    g push --force-with-lease origin "$branch"
    ;;

  rebase)
    base="${4:-}"
    [ -n "$base" ] || base=$(g symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null | sed 's#^origin/##')
    [ -n "$base" ] || { echo "cannot determine base branch; pass it explicitly" >&2; exit 2; }

    g fetch -q origin "$base"
    [ "$(g rev-list --count "HEAD..origin/$base")" -eq 0 ] && exit 1

    if g rebase "origin/$base"; then
      exit 0
    fi
    exit 3   # conflicts left in tree on purpose — caller resolves + gates, or `git rebase --abort`
    ;;

  *)
    echo "unknown command: $cmd" >&2; exit 2 ;;
esac
