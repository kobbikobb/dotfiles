---
name: my-pr-fixer
description: "End-to-end fix my own PR: address CI/pipeline failures, then evaluate, address, answer, and resolve all review comments. Pushes fixes and replies on every thread."
disable-model-invocation: true
---

# My PR Fixer — pipeline failures + review comments

For my PR on the current branch, do everything you can to make it ready: fix what's red in
CI, then work through every review comment — for each, decide if it makes sense to address.
Fix and resolve the ones that do; reply with a reason on the ones that don't. Push the
fixes and reply on every thread. Replies read as mine: plain, humble, no agent tells.

**Argument:** $ARGUMENTS (optional PR number; otherwise detect from branch)

## Workflow

### Step 1: Identify the PR

If `$ARGUMENTS` is a PR number use that, otherwise detect from the branch:
```bash
gh pr view --json number,title,headRefName,url
```

### Step 2: Fix CI / pipeline failures

```bash
gh pr checks {number}
gh run view <run-id> --log-failed   # for each failing check
```
Categorize (build, tests, lint/format, coverage, security, other) and print a summary
before fixing.

- **Low-risk, fix automatically:** lint/format, trivial build errors (missing imports,
  typos, unused vars).
- **High-risk, ask first:** test failures, coverage gaps, security vulnerabilities,
  non-trivial build/logic errors. Show what failed, the root cause, and the proposed fix,
  then wait for confirmation.

If checks are all green, say so and move on.

### Step 3: Gather review comments

Fetch threads with resolution status and the GraphQL thread `id` (needed to resolve later):
```bash
gh api graphql -f query='
  query($owner: String!, $repo: String!, $number: Int!) {
    repository(owner: $owner, name: $repo) {
      pullRequest(number: $number) {
        reviewThreads(first: 100) {
          nodes {
            id
            isResolved
            isOutdated
            comments(first: 50) {
              nodes { databaseId path line body author { login } createdAt }
            }
          }
        }
      }
    }
  }
' -f owner='{owner}' -f repo='{repo}' -F number={number}
```
Consider threads that are **not resolved** and where the last comment is **not** already
me. Include bot reviewers (Copilot, coderabbit) — they often have real findings — but
evaluate them critically, don't apply blindly. Also pull top-level `CHANGES_REQUESTED`
reviews:
```bash
gh pr view {number} --json reviews --jq '.reviews[] | select(.state=="CHANGES_REQUESTED" and .body!="") | {author:.author.login, body}'
```

### Step 4: Evaluate each comment

Read the referenced file + context, then for each comment decide: **does it make sense to
address?** Bots included (Copilot, coderabbit) — judge them critically, don't apply blindly.

- **Yes → address it.** Fix it (Step 5), then reply `Fixed: <what changed>` and resolve the
  thread. Covers bugs, missing error handling, style/naming, sound refactors — anything that
  genuinely makes the PR better.
- **No → reply with why.** Don't touch code; reply in plain prose stating the reason:
  disagreement (what and why), out of scope, already handled elsewhere, or it needs my call
  (say what decision you need). Leave these threads unresolved.

### Step 5: Quality gates, commit, push

If any code changed:
1. Run `/precheck`.
2. Stage, commit with the branch issue key prefix (`PLAT-1234: Address review comments`).
   If the branch has no issue key, stop and ask me to rename it.
3. Show the diff, then `git push origin <branch>` (never force-push).

### Step 6: Answer every thread (only after a successful push)

Reply to **all** in-scope threads, fixed or not, using `databaseId`:
```bash
gh api repos/{owner}/{repo}/pulls/{number}/comments/{databaseId}/replies -f body="<reply>"
```
- **Fixed:** `Fixed: <what changed>`
- **Not fixed:** `<why, in plain prose: disagreement, out of scope, already handled>`

Keep replies short, humble, and plain. No footer, no agent tells (em-dashes, `path:line`).
Top-level review comments: reply with `gh pr comment {number} --body "<reply>"`.

### Step 7: Resolve threads

Resolve every thread you **addressed** with code, using its GraphQL `id`:
```bash
gh api graphql -f query='mutation($id: ID!) { resolveReviewThread(input: {threadId: $id}) { thread { isResolved } } }' -f id='<thread id>'
```
Leave **declined** threads unresolved — the reply stands and the reviewer (or I) can respond.

### Step 8: Report

Summarize: CI failures fixed, comments addressed with code (and resolved), comments
declined with a reason (left unresolved), and anything that still needs my decision.

## Important rules

- **Don't modify CI config** to make checks pass — fix the actual code.
- **Never weaken a test** to make it pass — a failing test usually means the code is wrong.
- **Reply only after a successful push** — never claim "Fixed" before the push lands.
- **Never force-push; never dismiss reviews.**
- **Decline, don't block.** Address every comment that makes sense; for the rest, reply with
  the reason. Only leave a thread for me when it genuinely needs my decision — say so in the
  reply rather than stopping.
- **Group related fixes into one commit** — not one per comment.
- **No footer, no agent tells** — replies are team-visible and must read as mine.
