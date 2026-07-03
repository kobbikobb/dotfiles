# Fix one prod alert — per-problem agent contract

Used by `my-alert-fixer-all` (one agent per prod problem, run inside a Workflow). Each agent owns ONE
firing-alert cluster end to end in an isolated git worktree: find the **root cause**, decide whether
the right move is a code/config fix or **tuning the alert itself**, and — only when confident — open a
**draft spike PR**. Otherwise it hands me a sharp investigation lead. Inputs: `alertname`, `severity`,
`count`, `evidence` (firing labels + sample Loki lines + dashboard/query links the triage gathered),
`candidateRepos` (repos from `<ORG>` that the triage guessed might own the alert — code, config, or infra),
`dryRun` (bool).

## Grafana (read-only, via grafana MCP)

- Firing alerts / metrics: `query_prometheus`, datasource uid `mimir`. Drill the alert's own labels,
  e.g. `ALERTS{alertname="<name>",alertstate="firing"}` for instance/namespace/job.
- Logs: `query_loki_logs` / `find_error_pattern_logs`, datasource uid `d4ad6a97-3c28-4773-b63c-92fc1e37f119` (Loki-HA).
- Alert rule definition (threshold / `for` / inhibition): it lives in **gitops** as Prometheus rules
  (e.g. `azure-postgres-alerts.yaml`) — grep the gitops checkout, don't guess.

## Steps

1. **Isolated worktree** for the repo you'll change (parallel-safe — never the user's checkout or main):
   ```bash
   root=$(git -C <local-repo> rev-parse --show-toplevel)        # clone the repo if absent
    wt="$root/../worktrees/alert-<alertname-as-dash>"
   git -C "$root" fetch -q origin main
    git -C "$root" worktree add -q "$wt" origin/main -B <PROJECT_KEY>-<n>-reduce-<alertname-as-dash>
   ```
   Only create the branch/worktree once you've decided to draft a PR (high confidence + not dryRun).
   Pure investigation needs no worktree.

2. **Root-cause, outside the box.** Don't pattern-match the alert name to a quick patch. Establish
   *why* it fires: read the firing labels, pull the component's Loki logs, read the alert rule, read
   the owning code/config across `candidateRepos`. Classify the real fix:
    - **code** — a genuine bug/leak/missing-guard in the app's own repo.
    - **infra** — resource limits, probes, HPA, job spec (e.g. a cronjob that OOMs / never completes).
    - **tenant-config** — per-tenant config. **Higher blast radius** (many tenants) — prefer to
      *investigate* not auto-PR here unless the fix is unmistakable and tenant-scoped.
    - **alert-tune** — the alert is noise: wrong threshold, missing `for:`, no inhibition, fires on a
      known-benign state. Tweaking the rule is a valid, often best, outcome — that's the point.

3. **Score confidence** that your change actually removes/reduces the alert without breaking anything:
   `high` only when the root cause is proven and the change is low-risk and self-contained;
   `medium`/`low` otherwise.

4. **Confidence gate:**
    - **high & not dryRun** → open a **draft** PR. Create a Jira tracking issue first
      (`jira-axi`), branch `<PROJECT_KEY>-<n>-reduce-<alertname>`, commit with the key. Keep the diff minimal
     (lean spike, 1–2 files). `gh-axi pr create --draft`, labels `spike` + `prod-health`, title
     `[spike] reduce <alertname> alerts (confidence: high)`. Body: root cause, the Grafana evidence
     links, what the change does, and the confidence line — plain language, short.
   - **high & dryRun** → do everything except create Jira/branch/PR; report exactly what you *would*
     open (`action:"would-draft-pr"`, `pushed:false`).
   - **medium / low** (any run) → **no PR**. Return `action:"investigate"` with `needsMe` = one sharp
     line: the alert, your leading hypothesis, and the file/dashboard to look at next.

5. **Teardown** — `git -C "$root" worktree remove --force "$wt"` if you created one (always, even on error).

## Rules

- **Draft only, never merge, never auto-fix `--live` blindly.** A spike PR is a proposal for me.
- **Never weaken a real alert to silence it.** Tuning means correcting a *mis*-tuned rule (benign
  state, missing `for:`), not raising a threshold past a genuine problem. If unsure → `investigate`.
- **tenant-config:** default to `investigate` unless the fix is unmistakable and single-tenant.
- **One alert per agent.** Don't fan into multiple PRs.

## Return (StructuredOutput schema)

```
{
  "alertname": "SomeAlert",
  "severity": "critical",
  "repo": "<org>/<repo>" | null,        // repo touched, null when investigate-only
  "rootCause": "one line: the proven why",
  "fixClass": "code" | "infra" | "tenant-config" | "alert-tune",
  "confidence": "high" | "medium" | "low",
  "action": "drafted-pr" | "would-draft-pr" | "investigate" | "error",
  "prUrl": "https://github.com/... or null",
  "changes": ["one line per change, with location"],   // [] when investigate-only
  "evidence": ["grafana/loki links or queries backing the root cause"],
  "needsMe": "investigate lead (hypothesis + where to look), or null",
  "pushed": false
}
```

- `action:"drafted-pr"` only on a high-confidence live run that actually opened the draft PR.
- `action:"investigate"` is the medium/low path — `needsMe` is the product; `summary` turns it into a `todo.md` item.
- On failure set `action:"error"`, reason in `needsMe`, push nothing.
