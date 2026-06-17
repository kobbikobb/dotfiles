---
name: my-pr-review
description: "Self-review a branch or PR in my voice, console output only. Fans out across correctness, repo-consistency, broader-impact, and tests, then prints one humble, severity-prefixed note per concern (Risky/Major/Minor/Nit) plus the verdict it would get. Posts nothing to GitHub."
disable-model-invocation: true
---

# My PR Review — review for me, console only

Review the target (my current branch, or any PR) and print the feedback to the console so
I can act on it myself. Notes read as my own: humble, question-led, no agent tells. This
skill posts nothing to GitHub. To post comments and a verdict on a PR, use `my-pr-approver`.

**Argument:** $ARGUMENTS (optional PR number or URL; otherwise review the current branch)

## Workflow

1. Read `~/.claude/skills/_pr-shared/review-engine.md` and run it (Steps A-E) to produce the
   findings, off-diff notes, severity counts, and the recommended verdict. With no PR, it
   reviews `git diff main...HEAD`. Run this skill in the main session, not as a sub-agent, so
   the engine's `code-review` pre-pass (Step B) stays top-level.
2. Print the review to the console, grouped by severity (Risky, Major, Minor, Nit), each note
   in my voice. Reference the file and line so I can find it. End with the severity counts and
   the verdict it would get (the gate is informational here, nothing is submitted).
3. Stop. Do not call `gh` to post anything.

## Rules

- **Console only.** Never post comments, approve, or request changes. That is `my-pr-approver`.
- **My voice** for every note (engine's voice rules), even though it stays local.
- **Review only what changed**, unless the change makes pre-existing code actively risky.
