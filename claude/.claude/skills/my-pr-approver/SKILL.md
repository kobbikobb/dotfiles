---
name: my-pr-approver
description: "Review a PR in my voice and submit a verdict. Runs the shared review engine, posts severity-prefixed inline comments, then approves (all Minor/Nit) or requests changes (any Risky/Major). The gate."
disable-model-invocation: true
---

# My PR Approver — review and submit a verdict

Review the target PR like `my-pr-review`, then act on it: approve when it is clean, request
changes when it is not. Comments read as my own: humble, question-led, no agent tells.

**Argument:** $ARGUMENTS (optional PR number or URL; otherwise detect from branch)

## Workflow

1. Read `~/.claude/skills/_pr-shared/review-engine.md` and run it (Steps A-E) to produce the
   inline comments, off-diff notes, severity counts, and the recommended verdict. Run this
   skill in the main session, not as a sub-agent, so the engine's `code-review` pre-pass
   (Step B) stays top-level.
2. Map the verdict to a review event:
   - Any **Risky** → `REQUEST_CHANGES`; the summary notes it likely needs a discussion first.
   - Any **Major** (no Risky) → `REQUEST_CHANGES`.
   - Only **Minor/Nit**, or nothing → `APPROVE`.
3. Post a single review with that `event` using the posting mechanics in the engine. Top-level
   `body` = one-sentence summary + severity counts. Off-diff notes go in the body.
4. Report the verdict, counts by severity, and the review URL.

## Rules

- **No AI-attribution footer, no agent tells** (em-dashes, `path:line`). It posts as mine.
- **Review only what changed**, unless the change makes pre-existing code actively risky.
- **One review submission**, not a stream of separate comments.
- Never auto-approve a draft PR; report and stop instead.
