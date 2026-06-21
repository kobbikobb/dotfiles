# Fix one PR — per-PR fixer agent contract

Used by `my-pr-fixer-all` (one agent per PR, run inside a Workflow). Each agent owns ONE of my
PRs end to end in an isolated git worktree, runs the `my-pr-fixer` flow non-interactively, and
returns a compact result. Inputs: `repo` (owner/name), `number`, `branch`, `url`, `dryRun` (bool).

## Steps

1. **Isolated worktree** (parallel-safe — never touch the user's checkout or main):
   ```bash
   root=$(git -C <local-repo> rev-parse --show-toplevel)        # the repo for <repo>; clone if absent
   wt="$root/../platform.worktrees/fix-<repo-as-dash>-<number>"
   git -C "$root" fetch -q origin <branch>
   git -C "$root" worktree add -q "$wt" "origin/<branch>" -B <branch>
   ```
   Work entirely inside `$wt`. The branch must track `origin/<branch>` so pushes land on the PR.

2. **Run the fixer engine** against `$wt` — `~/.claude/skills/_pr-shared/fixer-engine.md`, Steps A–G,
   for PR `<number>`. Push with `git push origin <branch>`. Two binding overrides for fan-out:
   - **Non-interactive.** There is no user to ask. **Auto-fix only low-risk** (lint/format, trivial
     build errors — missing imports, typos, unused vars). **Skip high-risk** (test failures, coverage
     gaps, security findings, non-trivial logic/build) — do NOT attempt them, do NOT block; record
     each in `deferred` for the report. Still reply on those threads in plain prose saying it needs
     the author's call.
   - **`dryRun`** → do all the evaluation and produce the report, but push nothing, post no replies,
     resolve no threads.

3. **Teardown** — `git -C "$root" worktree remove --force "$wt"` (always, even on error).

## Return (StructuredOutput schema)

```
{
  "repo": "owner/name",
  "number": 123,
  "url": "https://github.com/...",
  "status": "fixed" | "partial" | "nothing-to-do" | "error",
  "checksFixed": ["lint", "build"],        // CI categories fixed, [] if none
  "commentsAddressed": 0,                   // threads fixed with code + resolved
  "commentsDeclined": 0,                    // threads replied-to but not changed
  "deferred": ["one line per high-risk item skipped, with PR-relative location"],
  "needsMe": "anything that genuinely needs the author's decision, else null",
  "pushed": true                            // false on dryRun / error / no code change
}
```

- `status:"nothing-to-do"` when a fresh pass finds no failing checks and no actionable threads.
- `status:"partial"` when something was fixed but `deferred` or `needsMe` is non-empty.
- On `error` (worktree/fetch failed, push rejected), set `status:"error"`, put the reason in
  `needsMe`, push nothing.
- `deferred` is the heart of the report — every high-risk thing left for the author lives here.
