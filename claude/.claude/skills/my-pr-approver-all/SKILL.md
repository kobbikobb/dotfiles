---
name: my-pr-approver-all
description: "Run my-pr-approver across the whole open PR queue, not just one PR. Default scope is the current repo (full engine per PR in-session). With --org <name>, fans out across every repo in the org (one deep sub-agent per PR, via a workflow). Approves only clean reviews it fully understood on a bounded, familiar diff; everything else is comment-only. Posts both verdicts, then reports each PR's impact, anything to know, and a look-into-these list."
disable-model-invocation: true
---

# My PR Approver All — approve/verdict the whole open queue

Find every open PR waiting on a first review and review each. Clean ones get approved, the rest
get a comment-only review (never request-changes) — both posted. I get back, per PR: its verdict, a one-line impact, anything
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
3. **Classify each PR cheaply first** (one `gh pr view <n> --repo <repo> --json additions,deletions,files`
   per PR — no checkout). A PR is **trivial** when it's small (≲40 changed lines) AND every changed
   path is docs/config/CI (`.md`, `.txt`, README, CI workflow YAML, `*.tfvars`, lockfiles) or the
   diff is purely subtractive. Everything else is **substantive**. Carry the tier with each PR.
4. **Launch a Workflow** to fan out (this skill opts into the Workflow call): a `pipeline()` over
   the PR list, one stage = one review agent per PR, with a StructuredOutput schema matching the
   `sweep-one-pr.md` Return block. Scale effort to the tier — don't flat-rate a 2-line doc tweak
   like a gateway rewrite:
   - **substantive** → full deep review per `~/.claude/skills/_pr-shared/sweep-one-pr.md` (checkout, owned lenses, hand correctness pass).
   - **trivial** → one light agent at `effort: 'low'`: read the diff (`gh pr diff`), a single careful pass, no checkout, no parallel lenses; same posting mechanics and return schema.
   Pass each agent its `repo / number / headSha / url`, tier, and the `dryRun` flag. Let the
   workflow's own concurrency cap apply (clones make substantive agents heavier; don't override it
   upward). Collect every returned object.
5. Report (step below).

### Report (both scopes — chat only, nothing extra on the PRs)

- **One line per PR:** verdict, number/repo, the one-line **impact**, and `⚠ <headsUp>` when set.
  Group by repo for the org sweep.
- **Heads-up roll-up:** a list of every PR whose `headsUp` is set (even approved ones) —
  migrations, auth/security surfaces, breaking changes, broad blast radius. Each entry leads with
  the bare PR URL so I can click straight through, then spells out three things: **what I need to
  know** (the surface or change that matters), **what action to take** (confirm a plan, merge in
  waves, watch a metric, nothing), and **the risk** (blast radius + reversibility, e.g. "13 prod
  tenants, revertible"). Don't compress this to a bare tag — give me enough to decide without
  opening the PR.
- **Look into these:** bare URLs for every `commented` (has blockers) or `error` PR.
- **Held for human:** bare URLs for every `heldForHuman` PR — clean reviews the gate wouldn't
  rubber-stamp. These feed `summary` → `todo.md`/#todo as a human-merge queue.
- **Whenever a line asks me to look at, confirm, or act on a PR, give the bare PR URL on that
  line** — never just a number/repo I have to go find. A clickable URL on every actionable item.
- If everything was clean with no heads-up, say the queue is clear.

## Rules

- **Post both verdicts.** Approve the clean, comment (never request-changes) on the rest. Both land on the PR. Approval is earned, not the default for a clean read — apply the engine's confidence gate (bounded, understood, familiar). A clean PR held for a human pass is comment-only; flag it in the report as "clean, held for human" so I know it wasn't rubber-stamped.
- **Impact on every PR.** Always summarize what each PR does in one line, approved or not.
- **Flag what I'd want to know even on approvals.** `headsUp` is for the things a clean approve
  still shouldn't bury: a DB migration, an auth/PII path, a breaking change, a big surface. When
  set, it carries what-to-know + what-action-to-take + the-risk, not just a label.
- **Scale effort to the PR.** Substantive PRs get the full deep review against a real checkout
  (owned lenses + hand-done correctness pass, NOT the `code-review` skill — its finders orphan
  nested in a sub-agent). Trivial PRs (small, docs/config/CI-only, or purely subtractive) get one
  light low-effort pass over the diff. Don't flat-rate every PR — that's the main token sink.
- **Skip and report, don't guess.** A PR that errors mid-review (fetch fails, diff too big) is
  `verdict:error`, goes on the look-into-these list. Never half-post a review.
- **Never approve a draft.** The script filters drafts; hold the line anyway.
- The script excludes PRs I authored or already reviewed, so reruns resume cleanly. Don't re-add them.
- **`--dry-run`** reviews and reports but posts nothing. Recommend it for the first org run
  (e.g. `--org <name> 10 --dry-run`), eyeball the verdicts, then go live.
- **Cleanup:** remove `/tmp/pr-sweep` when the org sweep finishes.
