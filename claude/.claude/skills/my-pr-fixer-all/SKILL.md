---
name: my-pr-fixer-all
description: "Run my-pr-fixer across all my open PRs that have something to fix — a red check rollup or an unanswered review thread. Fans out one sub-agent per PR, each in its own git worktree, so PRs are fixed in parallel without colliding. Reports per PR what was fixed, declined, and what's left for me. Always fans out (even single repo); current repo by default, --org sweeps the whole org."
disable-model-invocation: true
---

# My PR Fixer All — fix my whole fixable queue

Find every open PR I authored that has a problem worth a pass — a failing/errored CI rollup, or an
unresolved review thread whose last comment isn't mine — and hand each to its own fixer agent in an
isolated worktree. I get back, per PR: what CI it fixed, which comments it addressed vs declined,
anything high-risk it **deferred** to me, and anything that needs my call.

Scope is the **whole org** by default (auto-detected from the current repo). Use `--repo` to limit to the current repo only.

**Argument:** $ARGUMENTS — `[--org <name>] [--repo] [max] [--dry-run]`. `max` caps PRs (default 50);
`--dry-run` evaluates and reports but pushes/posts nothing.

## Workflow

1. **List the work.** Auto-detect the org: `org=$(gh repo view --json owner --jq '.owner.login')`.
   Unless `--repo` was passed, always use `--org $org`. Run:
   `~/.claude/skills/_pr-shared/list-my-fixable-prs.sh --org <org> <max>` (or without `--org` if `--repo`).
   Org → `<repo>\t<number>\t<headSha>\t<branch>\t<url>\t<title>`. Current repo → `<number>\t<branch>\t<url>\t<title>`.
   Empty → say the queue is clean, stop.
2. **Say the count first**, then launch. This pushes commits and replies on real PRs — state how
   many PRs and whether `--dry-run` is on before doing anything.
3. **Launch a Workflow** (this skill opts into the Workflow call): a `pipeline()` over the PR list,
   one stage = one fixer agent per PR, with a StructuredOutput schema matching the `fix-one-pr.md`
   Return block. Each agent follows `~/.claude/skills/_pr-shared/fix-one-pr.md`: own worktree, run
   the `my-pr-fixer` flow non-interactively (auto-fix low-risk, **defer** high-risk), push, reply,
   resolve, then tear the worktree down. Pass each agent its `repo / number / branch / url` (org
   adds `headSha`) and the `dryRun` flag. Let the workflow's concurrency cap apply — worktrees +
   pushes + bot-reweview loops make each agent heavy; don't raise it. Collect every returned object.
4. **Report** (below).

## Report (chat only)

One compact block per PR, in this exact shape — no tables, no per-file rundown, no praise:

```
<full url>  <status>
  did:  <one line per actual fix from `changes`, with location; "nothing" if none>
  you:  <one line per action I must take — deferred items + needsMe; omit the line entirely if none>
```

- **`did`** lists the real changes from `changes` — one line each, keeping the location, so I see
  *what* was fixed, not just a count. Add a trailing `(N comments resolved, M declined)` from the
  counts. `nothing` when the agent changed nothing.
- **`you`** only appears when there's a real action: each `deferred` item (one line, keep its
  location) and the `needsMe` line. A PR that came back `fixed`/`nothing-to-do` with empty
  `deferred` and null `needsMe` prints just the url + status line — no `you:`.
- End with a one-line tally: `N fixed · M need me · K errors`. If anything was pushed, add: bot
  re-review is pending on those PRs — rerun to mop up the new threads. If nothing needs me anywhere,
  say the queue is clean and stop.

## Rules

- **Always fan out**, even for a single repo — each fix is independent heavy work and the worktree
  isolates it. One agent per PR; never fix two PRs in one agent.
- **Sub-agents don't ask.** Auto-fix low-risk only; high-risk goes to `deferred`, never blocks. The
  whole point of fan-out is an unattended pass — an agent that stalls waiting for input is a bug.
- **Isolated worktrees only.** Never let an agent fix a PR in my working checkout or on main; each
  gets its own worktree under `platform.worktrees/`, removed when done (see [[worktree-per-task]]).
- **Skip and report, don't guess.** A PR whose worktree/fetch/push fails is `status:"error"` and
  goes on the needs-me list. Never half-push.
- **Never weaken tests, never edit CI to go green** — these carry through from `my-pr-fixer`; the
  agents inherit them. **Force-push only with `--force-with-lease`, only after a Step 0 rebase** —
  clean rebase auto-pushes; a conflict that fails the worktree build/test gate is deferred, not pushed.
- The list script only surfaces PRs with a real problem, so reruns resume cleanly — a PR that's
  mergeable with no failing check and no actionable thread won't reappear.
- **`--dry-run`** evaluates and reports but changes nothing. Recommend it for the first org run.
