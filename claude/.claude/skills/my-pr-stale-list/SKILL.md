---
name: my-pr-stale-list
description: "List open human-authored PRs across the org's active (non-archived) repos with no activity in 14+ days, so I can nudge or close them. Pure read — runs a script, prints a lean per-PR list (repo, author, idle age, title, summary, url). Posts nothing."
disable-model-invocation: true
---

# My PR Stale List — find old human PRs to action

Surface stale human PRs org-wide so I can chase or close them. Bots, archived repos, and
anything touched in the last 14 days are excluded by the script. Read-only — never comment,
approve, or close; just list.

**Argument:** $ARGUMENTS — `[--org <name>] [days] [max]` (org defaults to the current repo's owner; days 14, max 300).

## Workflow

1. Run the finder:
   ```bash
   ~/.claude/skills/_pr-shared/list-old-human-prs.sh $ARGUMENTS
   ```
   Each line is `repo<TAB>number<TAB>author<TAB>idleDays<TAB>url<TAB>title<TAB>summary`.
   No lines → say nothing is stale, stop.
2. Render lean, grouped by repo, oldest first. Per PR:
   - **`#<number> <title>`** — `@<author>`, idle `<idleDays>`d
   - one-line summary (the script's body excerpt)
   - the url
3. Stop. Don't fetch more, don't summarize further, don't act.

## Rules

- **Read-only.** This skill lists; it never posts. To act on one, use `my-pr-approver` (review)
  or close it by hand.
- **Trust the script's filtering.** Bots, archived repos, and recently-active PRs are already
  out — don't re-query or second-guess. Print what it returns.
- **Lean output.** Five fields per PR, oldest first. No tables of metadata, no commentary.
