---
name: pr-status-all
description: "Dashboard of ALL my open PRs across every repo (org-wide), ranked by what needs my action — CI fail/conflicts first, then ready-to-merge, waiting-on-review, drafts last. Each row shows CI, merge, review state, idle age, comments, and a direct URL. A script does all the work; just print its output."
disable-model-invocation: true
---

# My PRs — org-wide status dashboard

All my open PRs in one ranked table. The script does every `gh`/`jq` call and renders
the Markdown itself, so this is near-zero model work — run it and print the result.

For a single repo's PRs use the repo-local `pr-status` skill. For stale *human* PRs across
the org (to chase/close) use `my-pr-stale-list`.

**Arguments:** `$ARGUMENTS` — optional `[--org <name>] [max]` (scope to one org; max default 100).

## Workflow

1. Run:
   ```bash
   ~/.claude/skills/_pr-shared/list-my-open-prs.sh $ARGUMENTS
   ```
2. Print its output verbatim (it's already a ranked Markdown table grouped by action tier).
   Don't re-fetch, re-sort, or re-summarize.
3. Optionally add one short line flagging the top action (e.g. red-CI or conflict PRs).

## Rules

- **Read-only.** Lists only; never comments, approves, or merges.
- **Trust the script.** Tiers and ranking are computed in `list-my-open-prs.sh` — print what it returns.
- **Always show the direct URL** for every PR (the table's URL column).
