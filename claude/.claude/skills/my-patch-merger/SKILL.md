---
name: my-patch-merger
description: "Find every open bot PR labeled patches-approved across the org and approve + squash-merge it, under my own identity. Merges by default; --dry-run just lists. The on-demand counterpart to patches-bot's CI triage: the bot labels in CI, I merge from my machine, so no merge rights or bypass keys live in CI."
disable-model-invocation: true
---

# My Patch Merger — merge the patches-approved queue

patches-bot labels green, low-risk bot dependency PRs `patches-approved` in CI but does not
merge them — merging stays on my machine, under my identity, so no merge key or ruleset
bypass lives in CI. This skill is that merge step: find the labeled PRs and squash-merge them.

**Argument:** $ARGUMENTS — `[--dry-run] [--owner <org>] [max]`. Bare = approve + merge the queue.

## Workflow

1. Find the queue (owner defaults to the current repo's org, max 200):
   ```bash
   gh search prs --owner "$(gh repo view --json owner --jq .owner.login)" \
     --state open --label patches-approved --limit 200 \
     --json repository,number,title \
     --jq '.[] | "\(.repository.nameWithOwner)\t\(.number)\t\(.title)"'
   ```
   Empty → say the queue is clear, stop.
2. **Merge (default):** approve + squash-merge the whole queue.
   ```bash
   <finder> | cut -f1,2 | ~/.claude/skills/_pr-shared/merge-prs.sh --yes --approve
   ```
3. **`--dry-run`:** list only, merge nothing — one `repo#number — title` per line, plus the count.
   ```bash
   <finder> | cut -f1,2 | ~/.claude/skills/_pr-shared/merge-prs.sh
   ```
4. Report merged / failed counts. List any `FAILED` PRs with their URLs so I can look —
   a failure usually means a real gate is still red (checks, CodeQL, missing approval).

## Rules

- **Merges by default; `--dry-run` to preview.** Trusts the `patches-approved` label — the closer
  already vetted these (green + low-risk bump). GitHub is still the backstop: a red or unapproved
  PR just `FAILED`s, it never force-merges.
- **My identity, my machine.** Uses my `gh` auth, not a bot token. The gate stays GitHub's:
  if a PR is red or unapproved, the merge fails — that's the point, don't force it.
- **Squash by default.** The org rulesets only allow squash; `--method` exists but rarely needed.
- **Trust the label, not a re-review.** The closer already vetted these (green + low-risk bump).
  This skill merges; it does not re-run the review engine. Use `my-pr-approver` if you want a
  real review on one.
- **A `FAILED` is a signal, not a retry.** Report it; never `--admin`-override or bypass.
