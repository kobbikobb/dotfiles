---
name: my-build
description: "After building something, tack my two PR skills onto the end: run my-pr-review and address its notes, wait for CI, then run my-pr-fixer. Use whenever a build/implementation just finished (by me or a sub-agent) and a branch/PR is pushed — so review and fixes always follow without being asked. Argument: optional PR number/URL; otherwise the current branch."
---

# My Build — build, then review and fix

Run this right after finishing a build so the review→fix tail always happens. It chains my two
existing PR skills; it posts nothing on its own beyond what those skills do.

**Argument:** $ARGUMENTS (optional PR number or URL; otherwise use the current branch).

## Workflow

1. **Land the build.** If the work isn't pushed yet: verify it (typecheck, tests, repo gates),
   commit per `LP-NNN`, push, open a draft PR. If it's already pushed, skip to step 2.

2. **Review.** Run `my-pr-review` on the target branch/PR. It's user-invocable-only
   (`disable-model-invocation`), so follow `~/.claude/skills/my-pr-review/SKILL.md` directly.
   Address every note I'd agree with by editing code; commit and push the fixes.

3. **Wait for CI.** Call `ScheduleWakeup` for +300s (reason: "my-build: pr-fixer pass after CI").
   Ends turn, re-wakes after 5m.

4. **Fix.** On wake, run `my-pr-fixer` on the same PR — follow
   `~/.claude/skills/my-pr-fixer/SKILL.md`: clear red CI, work through every review comment
   (fix+resolve the ones that make sense, reply with a reason on the rest), push, reply on each thread.

## Notes

- One pass, not a loop. After step 4 the build is done — don't re-run the tail on the fixer's push.
- If there's no PR for the branch yet (step 1 skipped but none exists), stop and say so — the
  review/fix skills need a pushed branch.
