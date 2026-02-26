---
description: Commit changes and create/update PR
---

# Ship Command

Commit code and create/update PR. Run `/check` first — this command does not run quality gates.

Execute all steps automatically without asking for permission between steps.

## Step 1: Ensure feature branch

If on `main`/`master`: ask user for a branch name, create and switch to it.

## Step 2: Sync with main

Run `/sync` to rebase on latest main.

## Step 3: Commit

1. Review changes (`git status`, `git diff`)
2. Extract issue key from branch name if present (e.g. `PROJ-1234` from `PROJ-1234-fix-bug`)
3. Stage and commit per the commit message format in CLAUDE.md

## Step 4: Squash if needed

If more than 1 commit on the branch, squash using merge-base:
```bash
MERGE_BASE=$(git merge-base origin/main HEAD)
git reset --soft $MERGE_BASE
git commit -m "[message]"
```
**Never use `git reset --soft origin/main`** — it may include unrelated commits.

## Step 5: Push and manage PR

- If PR exists: `git push --force-with-lease`
- If no PR: `git push -u origin HEAD` then `gh pr create --draft` with summary and test plan
- Add labels per CLAUDE.md conventions (`bug`/`enhancement`/`upgrade`)
