---
name: my-pr-sweep
description: "Sweep the open PR queue and review each one. Default scope is the current repo (full engine per PR in-session). With --org <name>, fans out across every repo in the org (one deep sub-agent per PR, via a workflow). Posts both verdicts, then reports each PR's impact, anything to know, and a look-into-these list."
disable-model-invocation: true
---

# My PR Sweep — review the open queue

Find every open PR waiting on a first review and review each. Clean ones get approved, the rest
get request-changes — both posted. I get back, per PR: its verdict, a one-line impact, anything
I should know even on the approved ones, and a **Look into these** list for blockers/errors.

Scope is the current repo by default. `--org <name>` sweeps the whole org.

**Argument:** $ARGUMENTS — `[--org <name>] [max] [--dry-run]`. `max` caps PRs scanned (default 50); `--dry-run` reviews and reports but posts nothing.

## Workflow

### Current repo (no `--org`)

1. List: `~/.claude/skills/_pr-shared/list-reviewable-prs.sh <max>`. Lines are
   `<number>\t<url>\t<title>`. Empty → say the queue is clear, stop.
2. For EACH PR, in order, run the `my-pr-approver` workflow (read
   `~/.claude/skills/_pr-shared/review-engine.md`, Steps A-E, post the verdict). Run it in THIS
   session, not a sub-agent, so the engine's `code-review` pre-pass stays top-level. One PR fully
   before the next. Record verdict, review URL, a one-line impact, and any heads-up.
3. Report (step below).

### Org-wide (`--org <name>`)

1. List: `~/.claude/skills/_pr-shared/list-reviewable-prs.sh --org <name> <max>`. Lines are
   `<repo>\t<number>\t<headSha>\t<url>\t<title>`. Empty → say the queue is clear, stop.
2. **Say the count first.** This is ~100 PRs and a real token/time spend; state how many before
   launching. If `--dry-run` was passed, note that nothing will be posted.
3. **Launch a Workflow** to fan out (this skill opts into the Workflow call): a `pipeline()` over
   the PR list, one stage = one deep-review agent per PR following
   `~/.claude/skills/_pr-shared/sweep-one-pr.md`, with a StructuredOutput schema matching that
   doc's Return block. Pass each agent its `repo / number / headSha / url` and the `dryRun` flag.
   Let the workflow's own concurrency cap apply (clones make each agent heavier; don't override
   it upward). Collect every returned object.
4. Report (step below).

### Report (both scopes — chat only, nothing extra on the PRs)

- **One line per PR:** verdict, number/repo, the one-line **impact**, and `⚠ <headsUp>` when set.
  Group by repo for the org sweep.
- **Heads-up roll-up:** a short list of every PR whose `headsUp` is set (even approved ones) —
  migrations, auth/security surfaces, breaking changes, broad blast radius.
- **Look into these:** bare URLs for every `changes-requested` or `error` PR.
- If everything was clean with no heads-up, say the queue is clear.

## Rules

- **Post both verdicts.** Approve the clean, request-changes the rest. Both land on the PR.
- **Impact on every PR.** Always summarize what each PR does in one line, approved or not.
- **Flag what I'd want to know even on approvals.** `headsUp` is for the things a clean approve
  still shouldn't bury: a DB migration, an auth/PII path, a breaking change, a big surface.
- **Deep per PR.** Org agents review against a real checkout (clone at head), not just the diff.
  They run the owned lenses + a hand-done correctness pass, NOT the `code-review` skill (its
  finders orphan when nested in a sub-agent).
- **Skip and report, don't guess.** A PR that errors mid-review (fetch fails, diff too big) is
  `verdict:error`, goes on the look-into-these list. Never half-post a review.
- **Never approve a draft.** The script filters drafts; hold the line anyway.
- The script excludes PRs I authored or already reviewed, so reruns resume cleanly. Don't re-add them.
- **`--dry-run`** reviews and reports but posts nothing. Recommend it for the first org run
  (e.g. `--org lucinity 10 --dry-run`), eyeball the verdicts, then go live.
- **Cleanup:** remove `/tmp/pr-sweep` when the org sweep finishes.
