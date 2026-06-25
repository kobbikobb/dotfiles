# Fixer engine — shared mechanics for fixing my own PR

The mechanics shared by `my-pr-fixer` (interactive, one PR) and `fix-one-pr.md` (fan-out, one agent
per PR). The caller identifies the PR (`number`, `owner`, `repo`) and sets how high-risk work and
pushes are handled; this engine is the how. Token-lean throughout: read only what you'll act on.

## 0. Rebase onto the base branch when the PR conflicts

A conflicting branch can't merge no matter how green CI is. The deterministic git plumbing lives in
`~/.claude/skills/_pr-shared/rebase-onto-base.sh` — it owns every force-push (always `--force-with-lease`):
```bash
rebase-onto-base.sh rebase <worktree> <branch> [base]   # 0=clean (not pushed) · 1=nothing to do · 3=conflicts left in tree
```
- **Exit 1** → branch is current, skip to Step A.
- **Exit 0** (clean rebase) → run nothing extra; force-push via `rebase-onto-base.sh push <worktree> <branch>`.
- **Exit 3** (conflicts in the tree) → resolve them, `git rebase --continue`, then run the project's
  build/tests in the worktree as a gate. **Green** → `rebase-onto-base.sh push <worktree> <branch>`.
  **Red** → `git rebase --abort`, push nothing. The caller decides who resolves: interactive asks
  first; fan-out auto-resolves and defers when the gate is red.

Never type a raw `git push --force` — the script is the only thing that force-pushes, always with lease.

## A. Fix CI / pipeline failures

Pull **failing** checks only — never dump the green list:
```bash
gh pr checks <number> --json name,state,link | jq -r '.[]|select(.state!="SUCCESS" and .state!="SKIPPED")'
gh run view <run-id> --log-failed   # only for a check that's actually failing
```
Categorize (build, tests, lint/format, coverage, security, other). Low-risk (lint/format, trivial
build — missing imports, typos, unused vars) is always fixable. The caller decides high-risk (test
failures, coverage, security, non-trivial logic/build). All green → say so, move on.

## B. Gather review comments

Threads with resolution status + GraphQL `id` (needed to resolve):
```bash
gh api graphql -f query='
  query($owner:String!,$repo:String!,$number:Int!){
    repository(owner:$owner,name:$repo){ pullRequest(number:$number){
      reviewThreads(first:100){ nodes{ id isResolved isOutdated
        comments(first:50){ nodes{ databaseId path line body author{login} createdAt } } } } } } }
' -f owner='<owner>' -f repo='<repo>' -F number=<number>
```
In scope: threads **not resolved** where the last comment is **not** mine
(`gh api user --jq .login`). Include bots (Copilot, coderabbit) — real findings, judged critically,
not applied blindly. Also pull top-level review bodies; **bots post their summary as `COMMENTED`,
never `CHANGES_REQUESTED`** — match both or you skip every bot summary:
```bash
ME=$(gh api user --jq .login)
gh pr view <number> --json reviews | jq --arg me "$ME" '.reviews[]|select((.state=="CHANGES_REQUESTED" or .state=="COMMENTED") and .body!="" and .author.login!=$me)|{author:.author.login,state:.state,body}'
```
(`gh --jq` can't take `--arg`; pipe to standalone `jq`.)

## C. Evaluate each comment

Read the referenced file + context, then decide **does it make sense to address?**
- **Yes** → fix it (Step D), reply starting with `Fixed: <what changed>`, resolve the thread (Step F).
- **No** → reply starting with `Not fixed: <reason — disagreement + why, out of scope, already handled,
  or needs the author's call>`. Don't touch code; leave the thread unresolved.

Every in-scope thread gets a reply. Skipping a thread entirely is a failure.

## D. Quality gates, commit, push

**API-surface changes need the snapshot + sanity gate — `tsc`/`vitest`/`/precheck` do NOT cover it.** If the diff touches `packages/api/src/routes/**` or otherwise changes the public API (adds, removes, or reshapes an endpoint, schema, or classification), the committed `packages/sdk/openapi.snapshot.json` goes stale and CI's `API sanity` + `CI required` fail every time — the most common false-green this engine ships. Regenerate it: `npm run --silent generate:openapi --workspace=packages/api > packages/sdk/openapi.snapshot.json` then `npm run generate:types --workspace=packages/sdk`, and commit both. This needs **no real DB** — the dump only reads route schemas via `app.ready()` and the postgres client connects lazily, so a dummy `DATABASE_URL` is enough. `test:sanity` (route-exercises-real-DB) does need Postgres; if you can't boot one, say so and let CI's `API sanity (real DB)` job verify — never claim green on a route change without at least the snapshot regenerated.

If code changed: run `/precheck`; stage and commit with the branch issue-key prefix
(`PROJ-1234: Address review comments`) — no key, stop and ask for a rename; group related fixes into
one commit. Then push per the caller's rule: `git push origin <branch>` for normal pushes, or
`rebase-onto-base.sh push <worktree> <branch>` when a Step 0 rebase rewrote history. **Never type a
raw `git push --force`.**

## E. Answer every in-scope thread (only after a successful push)

**Mandatory — every in-scope thread gets a reply. No exceptions.** Reply format is strict:
- Addressed with code: reply starts with `Fixed: <what changed>`
- Declined: reply starts with `Not fixed: <reason>`

Discard the POST response — `--jq .html_url` returns one URL, not the whole comment object:
```bash
gh api repos/<owner>/<repo>/pulls/<number>/comments/<databaseId>/replies -f body="Fixed: ..." --jq .html_url
# or:
gh api repos/<owner>/<repo>/pulls/<number>/comments/<databaseId>/replies -f body="Not fixed: ..." --jq .html_url
```
Top-level review comments: `gh pr comment <number> --body "Fixed: ..."` or `"Not fixed: ..."`.
Keep replies short, humble, plain — no footer, no agent tells (em-dashes, `path:line`). They're team-visible and read as mine.

## F. Resolve addressed threads

**Mandatory — resolve every thread you fixed with code. This is not optional.**
Leave declined threads unresolved. Run the mutation for each fixed thread and verify `isResolved` is `true`:
```bash
gh api graphql -f query='mutation($id:ID!){resolveReviewThread(input:{threadId:$id}){thread{isResolved}}}' -f id='<thread id>'
```

## G. After your push — bots re-review the new commit (caller-controlled)

Your push makes Copilot/coderabbit re-review and re-runs CI, spawning **new** threads this pass never
saw. The caller decides whether to wait for them:
- **Loop** (interactive, one PR): wait for the new run to leave `pending` (`gh pr checks <number>`),
  give bots ~30–60s, re-run A–F. Repeat until a pass finds no failing checks and no actionable
  thread (cap ~3 passes; if still churning, stop and report).
- **Single pass** (fan-out): do NOT wait or poll. Finish after one A–F pass and report that bot
  re-review is pending — a rerun re-surfaces the PR and mops up the new threads.

## Rules (both callers inherit)

- **Never modify CI config** to go green — fix the actual code.
- **Never weaken a test** — a failing test usually means the code is wrong.
- **Reply only after a successful push** — never claim "Fixed" before the push lands.
- **Force-push only with `--force-with-lease`, only after a Step 0 rebase; never plain `--force`, never dismiss reviews.**
- **Group related fixes into one commit** — not one per comment.
- **Bots review as `COMMENTED`** — don't filter top-level reviews on `CHANGES_REQUESTED` alone.
- **Answer every actionable thread before finishing** — an unresolved bot thread with no reply is a
  failure, not an acceptable end state. Replies must start with `Fixed:` or `Not fixed:`.
- **Resolve every fixed thread** (Step F) — leaving an addressed thread unresolved is a failure.
