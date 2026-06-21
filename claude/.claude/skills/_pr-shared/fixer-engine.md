# Fixer engine — shared mechanics for fixing my own PR

The mechanics shared by `my-pr-fixer` (interactive, one PR) and `fix-one-pr.md` (fan-out, one agent
per PR). The caller identifies the PR (`number`, `owner`, `repo`) and sets how high-risk work and
pushes are handled; this engine is the how. Token-lean throughout: read only what you'll act on.

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
- **Yes** → fix it (Step D), reply `Fixed: <what changed>`, resolve the thread.
- **No** → reply in plain prose with the reason (disagreement + why, out of scope, already handled,
  or needs the author's call). Don't touch code; leave the thread unresolved.

## D. Quality gates, commit, push

If code changed: run `/precheck`; stage and commit with the branch issue-key prefix
(`PLAT-1234: Address review comments`) — no key, stop and ask for a rename; group related fixes into
one commit. Then push per the caller's rule. **Never force-push.**

## E. Answer every in-scope thread (only after a successful push)

Discard the POST response — `--jq .html_url` returns one URL, not the whole comment object:
```bash
gh api repos/<owner>/<repo>/pulls/<number>/comments/<databaseId>/replies -f body="<reply>" --jq .html_url
```
- **Fixed:** `Fixed: <what changed>`  · **Not fixed:** `<why, plain prose>`
Top-level review comments: `gh pr comment <number> --body "<reply>"`. Keep replies short, humble,
plain — no footer, no agent tells (em-dashes, `path:line`). They're team-visible and read as mine.

## F. Resolve addressed threads

Resolve every thread you fixed with code (leave declined ones unresolved):
```bash
gh api graphql -f query='mutation($id:ID!){resolveReviewThread(input:{threadId:$id}){thread{isResolved}}}' -f id='<thread id>'
```

## G. Re-poll after your push (bots re-review the new commit)

Your push makes Copilot/coderabbit re-review and re-runs CI, spawning **new** threads this pass never
saw. So loop: wait for the new run to leave `pending` (`gh pr checks <number>`), give bots ~30–60s,
then re-run A–F against the current state. Repeat until a pass finds no failing checks and no
actionable thread (cap ~3 passes; if still churning, stop and report what's left).

## Rules (both callers inherit)

- **Never modify CI config** to go green — fix the actual code.
- **Never weaken a test** — a failing test usually means the code is wrong.
- **Reply only after a successful push** — never claim "Fixed" before the push lands.
- **Never force-push; never dismiss reviews.**
- **Group related fixes into one commit** — not one per comment.
- **Bots review as `COMMENTED`** — don't filter top-level reviews on `CHANGES_REQUESTED` alone.
- **Answer every actionable thread before finishing** — an unresolved bot thread with no reply is a
  failure, not an acceptable end state.
