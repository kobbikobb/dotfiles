---
name: daily
description: "My daily driver: run recurring PR chores across my org, record what happened, summarize to Slack, and let me review + talk it through with `log`. Dumb orchestrator — every chore delegates to the existing -all skills' worktree sub-agents. Org-agnostic; the org lives in ~/.claude/work.local.json."
disable-model-invocation: true
---

# Daily — my recurring chores, recorded, summarized, reviewable

Run my recurring chores across my org, **write a record of every run**, and surface them two ways: a
scheduled `summary` posts to Slack, and a manual `log` lets me review and talk it through. This skill
holds nothing of its own — each chore delegates to an existing orchestrator that fans out to worktree
sub-agents.

`<ORG>` = `--org` if given, else `.org` from `~/.claude/work.local.json`, else ask.

**Argument:** $ARGUMENTS — `[approve|fix|summary|all|log] [--live] [--org <name>]`. Selector defaults to `all`.
**Safe by default: posts NOTHING to PRs unless `--live` is passed** (dry-run otherwise).

**Run store:** `~/.claude/daily-logs/runs.jsonl` — one JSON line per chore run (real local file, not
in dotfiles). This is the memory that ties scheduled runs, the Slack summary, and `log` together.

## Work chores (run this order)

1. **approve** — `my-pr-approver-all --org <ORG>`. Verdict every open first-review PR so I don't
   block teammates. Read `~/.claude/skills/my-pr-approver-all/SKILL.md`, run its org workflow.
2. **fix** — `my-pr-fixer-all --org <ORG>`. Fix my own PRs (CI + owed review replies). Read
   `~/.claude/skills/my-pr-fixer-all/SKILL.md`, run its workflow.

`all` runs approve then fix. Add new chores here as one numbered section each (e.g. a future
**alerts** chore: triage Grafana alerts via the grafana MCP + sub-agents).

### After each work chore — record it
Append one line to `~/.claude/daily-logs/runs.jsonl`:
```
{"ts":"<date -u +%FT%TZ>","chore":"fix","dryRun":true,"org":"<ORG>","results":[<the per-PR objects the workflow returned>],"tally":"<the one-line tally>"}
```
`results` is the raw structured array from the orchestrator — keep it, it's what `summary`/`log`
read. Then print the normal digest to stdout (below).

## summary — post today's activity to Slack

Not a worktree chore; a reporting pass. Read `runs.jsonl`, take every record since the last
`summary` marker (or since 00:00 if none), and post one Slack message to me with:
- per chore: how many PRs reviewed/fixed, verdicts/fixes, and the **needs-me** + **deferred** items
  (these are what I act on), with PR URLs;
- whether runs were dry-run or live.
Use the Slack MCP (`slack_send_message` to my own DM). Then append a marker line
`{"ts":"...","chore":"summary"}` so the next summary doesn't repeat. Keep it skimmable on a phone.

## log — review and talk it through (interactive only)

I run this myself in an open session. Read recent `runs.jsonl` records and present, conversational:
what ran and when, what was fixed/approved, what's **still on me** (deferred + needs-me, with URLs),
and anything that errored. Then stay in the loop — answer follow-ups, and if I say so, act: go live
on a PR, address a deferred item, rerun a chore. This is where the back-and-forth the scheduled runs
can't have actually happens.

## How work chores run (headless-safe)

Scheduled runs are `claude -p "/daily ..."` — a one-shot process. **Don't fire-and-forget.** Launch
each chore's workflow, then **wait for it to finish** (poll its task output) before the next chore,
the record, and the digest — if the turn ends while a workflow is still backgrounded, the process
exits and the work dies. Run chores sequentially; let each one's fan-out be the parallelism. Pass
`dryRun` = (`--live` absent) through to the sub-agents.

## Digest (stdout)

One consolidated block, grouped by chore, reusing each orchestrator's own report format, ending with
`TALLY: <approved> approved · <changes> request-changes · <fixed> fixed · <needs-me> need me · <errors> errors`
and `DRY-RUN — nothing posted.` when `--live` is absent. Empty queues → say it's clean.

## Rules

- **Dry-run is the default.** Only `--live` posts to PRs. launchd jobs add `--live` only once I trust
  the dry-run summaries.
- **Org from config.** Every work chore runs `--org <ORG>`; never silently narrow. The org value is
  the only environment-specific bit and it lives in `~/.claude/work.local.json`, not here.
- **Always record.** A work chore that doesn't append to `runs.jsonl` is broken — `summary` and
  `log` go blind. The record is the product as much as the PR change.
- **Delegate, never reimplement.** A chore is a thin call into an existing -all orchestrator. New
  logic goes there or in a shared script, not here. This skill stays dumb.
