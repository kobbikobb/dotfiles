---
description: Fetch and rebase on main (no quality gates)
---

# Sync Command

Fetch latest main, rebase current branch, push. No quality gates.

1. Stash uncommitted changes if any (`git stash push -m "sync-stash"`)
2. `git fetch origin main && git rebase origin/main`
3. If conflicts: resolve, `git add`, `git rebase --continue`. Abort if too complex.
4. `git push --force-with-lease`
5. Restore stash if created (`git stash pop`)
6. Report: commits rebased, conflicts resolved, push status
