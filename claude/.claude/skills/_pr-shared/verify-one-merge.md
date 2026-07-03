# Verify one merge — per-merge health-diff agent contract

Used by `my-verify-all` (one agent per PR merged yesterday, run inside a Workflow). Each agent takes
ONE merged PR, finds the prod services it touched, and diffs their Grafana health **after the merge**
against a baseline — latency, error rate, firing alerts. It attributes a regression to the merge only
when the mapping is clean, and is honest that merge-time is an approximation of deploy-time. **Read-only:
it opens no PRs and changes nothing — it produces a verdict and, on a regression, a sharp investigate
lead.** Inputs: `repo`, `number`, `url`, `mergedAt` (RFC3339), `touchedServices` (metric `job` names
the triage derived from the changed paths), and `checks` — the unticked items from a `## Verify`
checklist in the PR body (empty if the PR has none).

## Grafana (read-only, via grafana MCP)

- **Latency / saturation:** `query_prometheus`, datasource uid `mimir`. The `job` label **is** the
  service name (e.g. `job="case-service"`). Find the service's request-duration histogram via
  `list_prometheus_metric_names` matching the job, then
  `histogram_quantile(0.95, sum by (le) (rate(<duration_bucket>{job="<svc>"}[10m])))`. No histogram →
  fall back to request rate + error ratio; say so, don't invent a latency number.
- **Error rate:** Loki uid `d4ad6a97-3c28-4773-b63c-92fc1e37f119` —
  `sum(count_over_time({service_name="<svc>", level="error"}[1h]))`.
- **Alerts:** `ALERTS{alertstate="firing"}` on `mimir`, scoped to the service's namespace/job.

## Steps

1. **Two windows per service:** *after* = `mergedAt` → now; *baseline* = the 7 days before `mergedAt`,
   same service, same hour-of-day where it matters. Pull P95 latency, error count/rate, and
   firing-alert count for both.
2. **Delta + verdict per service:** `improved` / `neutral` / `regressed`, with the magnitude
   (e.g. "P95 320ms → 540ms, +69%"). Neutral unless the move clears normal variance.
3. **Attribute, honestly.** `confidence:"high"` only when this merge is the *only* one that touched
   the regressed service in the window AND the change lines up in time. `medium` when plausible but
   other merges touched the same service. `low` when timing is murky or the deploy may not have
   landed yet (merge ≠ deploy — gitops rollout lags). Never assert causation; this is correlation.
4. **Regression → lead.** Any `regressed` service sets `regressed:true` and a one-line `needsMe`:
   the service, the delta, the suspect PR url, and where to look. Clean merges return
   `regressed:false`, `needsMe:null`.
5. **Author's `## Verify` checks.** For each item in `checks`, decide if the Grafana signals you
   already pulled confirm it (e.g. "p95 on X drops", "no error spike"). Confirmed → tick that box in
   the PR body (`- [ ]` → `- [x]`) via `gh-axi pr edit <number> --body <edited>`; this is the one write
   allowed. An item needing a DB/psql/kube/`EXPLAIN`/functional check you can't run headless → leave it
   unticked and add it to `needsMe` with the exact command to run. Report each item's status.

## Rules

- **Read-only, one exception.** No worktree, no branch, no new PR. The *only* write allowed is
  ticking a `## Verify` checkbox you confirmed from Grafana (Step 5) — never edit anything else of the
  body, never untick, never tick an item you couldn't actually confirm.
- **Merge-time is approximate.** If the service shows no post-merge traffic change at all, the deploy
  likely hasn't landed — say so (`low` confidence), don't fabricate impact.
- **One merge per agent.** Report every touched service inside the one verdict.
- **No metric → no claim.** Missing histogram/label means "couldn't measure", not "no impact".

## Return (StructuredOutput schema)

```
{
  "repo": "<org>/<repo>",
  "number": 12345,
  "url": "https://github.com/...",
  "mergedAt": "2024-01-15T14:03:00Z",
  "services": ["some-service"],
  "verdicts": [
    { "service": "some-service", "latency": "P95 320ms → 540ms (+69%)",
      "errors": "12/h → 14/h", "alerts": "0 → 0",
      "verdict": "improved" | "neutral" | "regressed", "confidence": "high" | "medium" | "low" }
  ],
  "regressed": false,
  "needsMe": "regression lead (service + delta + suspect url + where to look), or null",
  "checks": [
    { "item": "p95 on /work-list/filter drops vs baseline", "status": "ticked" | "outstanding",
      "reason": "why (confirmed from Grafana → ticked; or can't run headless → outstanding + command)" }
  ]
}
```

- `regressed:true` whenever any verdict is `regressed`; `needsMe` is the product `summary` turns into a `todo.md` lead.
- Couldn't measure a service → include it with `verdict:"neutral"`, `confidence:"low"`, and note it in `needsMe` only if it's the suspect for an actual alert.
