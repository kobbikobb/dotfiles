---
name: my-alert-fixer-all
description: "Triage my org's firing prod alerts in Grafana, pick the biggest real problems, and hand each to its own sub-agent in an isolated worktree to root-cause and — only when confident — open a draft spike PR (code/config fix or alert-tune). Lower-confidence problems come back as sharp investigation leads, never PRs. Reads Grafana via the grafana MCP. Org-agnostic; repos derived from --org."
disable-model-invocation: true
---

# My Alert Fixer All — turn firing prod alerts into spike PRs

Read what's actually on fire in prod, rank it, and fan out one sub-agent per problem in an isolated
worktree. Each agent finds the **root cause** and either opens a **draft spike PR** (high confidence)
or hands back an investigation lead (otherwise). The goal is fewer alerts and more action — a small,
reviewable diff per real problem, not a wall of dashboards.

Scope is `<ORG>`. Each problem is independent heavy work; always fan out.

**Argument:** $ARGUMENTS — `[--org <name>] [max] [--dry-run]`. `max` caps problems (default **1**);
`--dry-run` investigates and reports but creates no Jira/branch/PR. **Dry-run is the default unless
`--live` is passed by the caller** (`/daily` passes it through).

## Workflow (this skill opts into the Workflow call)

**Phase 1 — Triage (one agent).** Read Grafana, rank, dedup, emit the top `max` problems.
- Firing alerts: `query_prometheus` on datasource uid `mimir` —
  `sort_desc(count by (alertname, severity) (ALERTS{alertstate="firing"}))`.
- For each candidate, gather evidence the fixer will need: drill the alert's labels
  (`ALERTS{alertname="<n>",alertstate="firing"}` → namespace/job/instance), pull a few Loki lines
  (`find_error_pattern_logs`, uid `d4ad6a97-3c28-4773-b63c-92fc1e37f119`), and guess `candidateRepos`.
- **Rank:** customer-facing impact > `severity` (critical > warning > info) > how long it's been
  firing > recurring count. `Watchdog`/`severity:none` and pure-`info` are never problems — drop them.
- **Dedup:** read `~/.claude/daily-logs/runs.jsonl`; skip any `alertname` an `alerts` chore already
   drafted a PR for or flagged in the last 7 days, unless it re-fired after a resolve.
- Emit `max` problems (default 1), best first. None worth acting on → report the queue is quiet, stop.

**Phase 2 — Fix (one agent per problem).** Fan out; each follows
`~/.claude/skills/_pr-shared/fix-one-alert.md`: own worktree, root-cause across the candidate repos,
score confidence, gate (high → draft spike PR; else → investigate lead), tear the worktree down.
Pass each agent its `alertname / severity / count / evidence / candidateRepos` and the `dryRun` flag.
Use a StructuredOutput schema matching the contract's Return block. Let the workflow's concurrency
cap apply — worktrees + clones make each agent heavy; don't raise it. Collect every returned object.

## Report (chat only)

One compact block per problem, no tables, no praise:

```
<alertname> (<severity>)  <confidence> · <action>
  cause: <rootCause>
  did:   <one line per change with location, or the draft PR url>   # omit if investigate-only
  you:   <needsMe — the investigate lead, or null>                  # omit if none
```

End with a tally: `N drafted · M to investigate · K errors`. When `--dry-run`, append
`DRY-RUN — nothing opened.` Every PR line carries its full `https://github.com/...` url.

## Rules

- **Always fan out**, one agent per problem, each in its own worktree under `worktrees/`
  (see [[worktree-per-task]]). Never investigate two problems in one agent.
- **Sub-agents don't ask** — high-confidence drafts, everything else becomes an investigate lead.
  An unattended pass must never stall.
- **Draft PRs only, never merge.** Confidence gate is the whole point: a wrong auto-PR wastes the
  scarce reviewer time this is meant to save. When unsure → investigate, not PR.
- **Default top 1.** Start small; raise `max` only once the dry-run leads prove trustworthy.
- **Read-only on Grafana.** This skill triages and proposes; it never silences a real alert.
