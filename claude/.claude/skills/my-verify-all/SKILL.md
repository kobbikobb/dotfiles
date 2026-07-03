---
name: my-verify-all
description: "Verify the prod impact of every PR merged across my org yesterday: map each merge to the services it touched and diff their Grafana health (latency, error rate, firing alerts) after the merge against a 7-day baseline. Flags regressions as confidence-scored investigate leads. Read-only — opens no PRs. Reads Grafana via the grafana MCP. Org-agnostic; repos derived from --org."
disable-model-invocation: true
---

# My Verify All — did yesterday's merges hurt prod?

Close the loop on what shipped: list everything merged yesterday, map each merge to the prod services
it touched, and diff those services' Grafana health after the merge against their recent baseline. The
output is a short verdict per merge and — for anything that regressed — a sharp, confidence-scored
investigate lead. **Read-only: it never opens or changes a PR.**

Scope: `<ORG>` repos (derived from --org). Each merge is independent work; always fan out.

**Argument:** $ARGUMENTS — `[--org <name>] [max]`. `max` caps merges examined (default 25). No
`--live` flag — this chore only reads Grafana and reports.

## Workflow (this skill opts into the Workflow call)

**Phase 1 — Triage (one agent).** Build the merge list and map services.
- **Window:** yesterday (org local time) — but **on Monday, cover since last Friday 00:00**,
  or nothing merged Friday gets verified.
- List merges in that window:
  `gh-axi search prs --merged --owner <ORG> <repo-flags> --merged-at <window> --json number,title,url,repository,mergedAt,files,body`
  (build `<repo-flags>` by listing the org's repos that host prod services — `--repo <ORG>/<app> --repo <ORG>/<gitops>` etc.).
- From each merge's `body`, parse a `## Verify` section's **unticked** checkboxes (`- [ ] …`) into a
  `checks` list of item strings (empty when absent). These are author-requested post-deploy checks.
- For each merge, derive `touchedServices` from the changed paths → Mimir `job` names using
  repo-specific path conventions (e.g. `<app-repo>: services/<svc>/...` → job `<svc>`,
  `<gitops-repo>: manifest paths name the service directly`). Confirm
  each guessed name exists with `list_prometheus_label_values` (label `job`, uid `mimir`). Drop merges
  that touch no prod service (docs, CI, tests-only) — nothing to measure.
- Emit up to `max` merges, each with its `repo/number/url/mergedAt/touchedServices/checks`. None →
  report "no service-touching merges yesterday", stop.

**Phase 2 — Verify (one agent per merge).** Fan out; each follows
`~/.claude/skills/_pr-shared/verify-one-merge.md`: diff each touched service's P95 latency (Mimir),
error rate (Loki `service_name`+`level=error`), and firing-alert count, after-merge vs 7-day baseline;
verdict + honest attribution confidence; regressions become leads. It also evaluates the PR's
`## Verify` checks — ticking the ones Grafana confirms, listing the rest as needs-me. Pass each agent
its `repo/number/url/mergedAt/touchedServices/checks`. StructuredOutput schema matches the contract's
Return block. Let the workflow's concurrency cap apply. Collect every returned object.

## Report (chat only)

One compact line per merge, regressions first, no praise:

```
<url>  <overall: regressed|neutral|improved>
  <service>: <latency> · <errors> · alerts <a> — <verdict> (<confidence>)
  checks: <t> ticked, <o> outstanding                # only when the PR had ## Verify items
  you: <needsMe>                                     # regression lead and/or outstanding checks
```

End with a tally: `N regressed · M neutral · K improved · J unmeasurable`. Every PR line carries its
full `https://github.com/...` url.

## Rules

- **Read-only, one exception.** This chore measures and reports; it opens no PRs and never touches
  code. The *only* write allowed is ticking a `## Verify` checkbox the agent confirmed from Grafana.
  Everything else it triggers is *me* investigating a lead or running an outstanding check.
- **Always fan out**, one agent per merge — independent Grafana work; never two merges in one agent.
- **Correlation, not proof.** Merge ≠ deploy (gitops rollout lags); the agents bake timing uncertainty
  into confidence and never assert causation. A `low`-confidence regression is a hint, not a verdict.
- **Skip what you can't measure** loudly — a service with no histogram or no post-merge traffic is
  "couldn't measure", reported as such, not silently dropped or fabricated.
