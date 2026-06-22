---
name: my-patch-merger
description: "Find every open bot PR carrying the configured merge label across the org and approve + squash-merge it, under my own identity. Merges by default; --dry-run just lists. The on-demand counterpart to a CI bot's triage: the bot labels green low-risk PRs in CI, I merge from my machine, so no merge rights or bypass keys live in CI."
disable-model-invocation: true
---

# My Patch Merger — merge the approved-bot-PR queue

A CI bot labels green, low-risk dependency PRs with a merge label but does not merge them — merging
stays on my machine, under my identity, so no merge key or ruleset bypass lives in CI. This skill is
that merge step: find the labeled PRs and squash-merge them.

`<LABEL>` = `--label` if given, else `.patchLabel` from `~/.claude/work.local.json`, else ask.
`<OWNER>` = `--owner` if given, else `.org` from the same file, else the current repo's org.

**Argument:** $ARGUMENTS — `[--dry-run] [--owner <org>] [--label <name>] [max]`. Bare = approve + merge the queue.

## Workflow

1. Find the queue (max 200):
   ```bash
   gh search prs --owner "<OWNER>" \
     --state open --label "<LABEL>" --limit 200 \
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

- **Merges by default; `--dry-run` to preview.** Trusts the `<LABEL>` label — the bot
  already vetted these (green + low-risk bump). GitHub is still the backstop: a red or unapproved
  PR just `FAILED`s, it never force-merges.
- **My identity, my machine.** Uses my `gh` auth, not a bot token. The gate stays GitHub's:
  if a PR is red or unapproved, the merge fails — that's the point, don't force it.
- **Squash by default.** The org rulesets only allow squash; `--method` exists but rarely needed.
- **Trust the label, not a re-review.** The bot already vetted these (green + low-risk bump).
  This skill merges; it does not re-run the review engine. Use `my-pr-approver` if you want a
  real review on one.
- **A `FAILED` is a signal, not a retry.** Report it; never `--admin`-override or bypass.
