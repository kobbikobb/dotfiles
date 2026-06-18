---
name: my-pr-sweep
description: "Sweep the open PR queue (not draft, not approved, no unresolved threads, not mine, not already reviewed by me) and run my-pr-approver on each. Auto-approves the clean ones; reports the PRs that need my eyes (request-changes or errored) as URLs."
disable-model-invocation: true
---

# My PR Sweep — review the whole open queue

Find every open PR waiting on a first review and run the approver on each. Clean ones get
approved. I get back a short list of the ones that need me: the PRs that got request-changes,
plus anything that errored.

**Argument:** $ARGUMENTS (optional max number of PRs to scan; default 50)

## Workflow

1. List the queue:
   ```bash
   ~/.claude/skills/_pr-shared/list-reviewable-prs.sh $ARGUMENTS
   ```
   Each line is `<number>\t<url>\t<title>`. No lines means nothing to review: say the queue
   is clear and stop.

2. For EACH PR in the list, in order, run the `my-pr-approver` workflow against that PR
   number: read `~/.claude/skills/_pr-shared/review-engine.md`, run Steps A-E, post the
   verdict (empty body, inline comments only). Run it in THIS session, not a sub-agent, so the
   engine's `code-review` pre-pass stays top-level. Finish one PR fully before the next.
   Record per PR: verdict (approved / changes-requested / error) and the review URL.

3. Report back in chat only (nothing extra posted on the PRs):
   - One line per PR: number, verdict, url.
   - Then a **Look into these** list of bare URLs: every PR that got request-changes or errored.
   - If every PR was clean-approved, say the queue is clear.

## Rules

- **Approve only the clean ones.** Any Risky/Major is request-changes, and that PR goes on the manual list.
- **One PR at a time, fully.** Don't batch the engine across PRs. Each PR gets its own pass and one review submission.
- **Skip and report, don't guess.** If a PR errors mid-review (diff too big, fetch fails), put it on the manual list and move on. Never half-post a review.
- **Never approve a draft.** The script filters drafts; hold the line anyway.
- The script already excludes PRs I authored or have reviewed. Don't add them back.
- This burns a full review per PR, so a big queue is a lot of work. If the list is long, say so before starting.
