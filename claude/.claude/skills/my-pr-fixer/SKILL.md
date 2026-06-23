---
name: my-pr-fixer
description: "End-to-end fix my own PR: address CI/pipeline failures, then evaluate, address, answer, and resolve all review comments. Pushes fixes and replies on every thread."
disable-model-invocation: true
---

# My PR Fixer — pipeline failures + review comments

For my PR on the current branch, do everything you can to make it ready: fix what's red in CI, then
work through every review comment — for each, decide if it makes sense to address. Fix and resolve
the ones that do; reply with a reason on the ones that don't. Push the fixes and reply on every
thread. Replies read as mine: plain, humble, no agent tells.

**Argument:** $ARGUMENTS (optional PR number; otherwise detect from branch)

## Workflow

1. **Identify the PR.** If `$ARGUMENTS` is a number, use it; else `gh pr view --json number,title,headRefName,url`.
2. **Run the fixer engine** — `~/.claude/skills/_pr-shared/fixer-engine.md`, Steps 0 then A–G,
   against this PR on the current branch. Push with `git push origin <branch>`, or
   `rebase-onto-base.sh push <worktree> <branch>` after a Step 0 rebase. Interactive points specific
   to this skill:
   - **Rebase (engine 0):** a clean rebase is automatic; if it hits conflicts, show me the
     conflicting files and **wait for my confirmation** before resolving and force-pushing.
   - **CI fixes (engine A):** fix low-risk automatically; for high-risk (test failures, coverage,
     security, non-trivial build/logic) show what failed, the root cause, and the proposed fix, then
     **wait for my confirmation** before touching it.
   - Before fixing CI, print a one-line summary per failing check so I see the categories up front.
3. **Report.** Summarize: CI fixed, comments addressed with code (resolved), comments declined with a
   reason (left unresolved), and anything that still needs my decision.

## Important rules

Engine rules apply (no CI edits, no weakened tests, reply only after push, force-push only with
`--force-with-lease` after a rebase, group fixes, answer every actionable thread, loop until a clean
pass). On top of those:

- **Decline, don't block.** Address every comment that makes sense; for the rest, reply with the
  reason. Only leave a thread for me when it genuinely needs my decision — say so in the reply.
- The engine's re-poll loop (G) is mandatory: my push triggers a fresh bot review, so one pass is
  never done — loop until a clean pass finds nothing new.
