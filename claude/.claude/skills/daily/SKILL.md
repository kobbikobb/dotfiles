---
name: daily
description: "My daily driver: run recurring PR chores across my org, record what happened, distill what's on me into a plan file, and let me pick it up + talk it through with `log`. Dumb orchestrator — every chore delegates to the existing -all skills' worktree sub-agents. Org-agnostic; the org lives in ~/.claude/work.local.json."
disable-model-invocation: true
---

# Daily — my recurring chores, recorded, summarized, reviewable

Run my recurring chores across my org, **write a record of every run**, and surface them two ways: a
scheduled `summary` distills what's on me into a plan file (`~/.claude/daily-logs/todo.md`), and a
manual `log` lets me pick that up and talk it through. This skill holds nothing of its own — each
chore delegates to an existing orchestrator that fans out to worktree sub-agents.

`<ORG>` = `--org` if given, else `.org` from `~/.claude/work.local.json`, else ask.

**Argument:** $ARGUMENTS — `[approve|fix|alerts|verify|summary|all|log] [--live] [--org <name>]`. Selector defaults to `all`.
**Safe by default: posts NOTHING to PRs unless `--live` is passed** (dry-run otherwise).

**Run store:** `~/.claude/daily-logs/runs.jsonl` — one JSON line per chore run (real local file, not
in dotfiles). This is the memory that ties scheduled runs, the `summary` plan file, and `log` together.

## Work chores (run this order)

1. **approve** — `my-pr-approver-all --org <ORG>`. Verdict every open first-review PR so I don't
   block teammates. Read `~/.claude/skills/my-pr-approver-all/SKILL.md`, run its org workflow.
2. **fix** — `my-pr-fixer-all --org <ORG>`. Fix my own PRs (CI + owed review replies). Read
   `~/.claude/skills/my-pr-fixer-all/SKILL.md`, run its workflow.
3. **alerts** — `my-alert-fixer-all --org <ORG>`. Triage firing prod alerts in Grafana (grafana MCP),
   pick the biggest real problem, fan out a sub-agent to root-cause it and — only when confident —
   open a draft spike PR; else hand back an investigation lead. Read
   `~/.claude/skills/my-alert-fixer-all/SKILL.md`, run its workflow. `results` is its returned
   per-problem array; its `needsMe` (investigate leads) feed `summary` exactly like `deferred` does.
4. **verify** — `my-verify-all --org <ORG>`. Diff the prod health of every service-touching PR merged
   yesterday (latency, errors, alerts, after-merge vs baseline) via Grafana, flag regressions as
   confidence-scored leads. **Read-only — opens no PRs**, so `--live` is irrelevant to it. Read
   `~/.claude/skills/my-verify-all/SKILL.md`, run its workflow. `results` is its per-merge array; its
   `needsMe` (regression leads) feed `summary` like `deferred` does.

`all` runs approve then fix (not alerts/verify — different cadence/risk; run those on their own
selectors). Add new chores here as one numbered section each.

### After each work chore — record it
Append one line to `~/.claude/daily-logs/runs.jsonl`:
```
{"ts":"<date -u +%FT%TZ>","chore":"fix","dryRun":true,"org":"<ORG>","results":[<the per-PR objects the workflow returned>],"tally":"<the one-line tally>"}
```
`results` is the raw structured array from the orchestrator — keep it, it's what `summary`/`log`
read. Then print the normal digest to stdout (below).

## summary — write today's action items to a plan file

Not a worktree chore; a reporting pass. Read `runs.jsonl`, take every record since the last
`summary` marker (or since 00:00 if none), and write the open action items to the plan file
`~/.claude/daily-logs/todo.md` (overwrite each run — it's a live worklist, not a log). Headless-safe:
a plain file the cron can always write, no Slack, no token.

Items are `- [ ] <url> — <one line: what's on me>`. Sources:
- **needs-me / deferred** fields across all records
- **`heldForHuman:true`** — clean but not auto-approved; `impact` = one-liner
- **alerts/verify leads** — `<alertname-or-service>` with `needsMe` line

Rules: **confirm each PR still open** (`gh pr view`), drop merged/closed. Group into `### Deferred`
and `### Needs me`. Top: date + tally. Clear queue → "Nothing on me." Append
`{"ts":"...","chore":"summary"}` marker line.

If Slack MCP available in run context, also post to **#todo** (`C0BCHFU263Y`). Best-effort: skip
silently when absent.

## log — review and talk it through (interactive only)

I run this myself in an open session. Read `~/.claude/daily-logs/todo.md` (the plan `summary` wrote)
for what's **still on me**, and `runs.jsonl` for the fuller context — what ran when, what was
fixed/approved, anything that errored. Present it conversational, lead with the open items + URLs.
Then stay in the loop — answer follow-ups, and if I say so, act: go live on a PR, address a deferred
item, rerun a chore. If Slack MCP available, post to **#todo** (`C0BCHFU263Y`).

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
- **Every PR I name carries its URL.** Any line that points me at a PR — in `log`, the `todo.md`
  plan, the #todo post, the stdout digest — gives the clickable `https://github.com/<owner>/<repo>/pull/<n>`
  on that line, never a bare `repo#number` I have to go find.
