# User Preferences

## Code quality (applies to all changes)
- **Lean code.** Minimum lines to achieve the goal. Fewer jobs, fewer abstractions, fewer special cases. If you find yourself writing 80 lines to address a 2-line concern, stop and reconsider.
- **Easy to read > clever.** Prefer boring code. A reader should understand the intent in one pass.
- **Easy to maintain.** Less code = less to change when requirements shift.
- **Consistency with the existing repo.** Before writing new patterns, grep for how the repo already does it. Match the idiom. Match the file structure. Match the naming. Match the workflow/CI style.
- **Reuse existing patterns and approaches.** If the repo has a utility, helper, workflow template, or convention that fits, use it. Don't reinvent.
- **Call out flaws in existing patterns when you see them.** If the existing approach is wrong or outdated, say so explicitly instead of silently diverging. Propose the fix in the same PR or as a follow-up. Diverging silently creates inconsistency that future readers can't explain.
- **Over-engineering is a bug.** Defence-in-depth, extra abstraction layers, speculative flexibility — if they're not earning their keep right now, cut them.

## Comments (applies to all file types — .ts, .tsx, .tf, .yml, Dockerfile, .sh, etc.)
- **Default = no comment.** The code is the explanation. Names, structure, and tests carry the meaning.
- **One line max.** If you find yourself writing two or three, you're stacking "interesting facts" — keep the one that's actually non-obvious and cut the rest. Multi-line block comments are a code smell.
- **Only when WHY is non-obvious.** Hidden constraint, subtle invariant, surprising provider behavior, magic number, race-condition workaround. Otherwise: nothing.
- **Never restate the code.** `# Get the user` above `getUser()` is noise.
- **Never narrate future plans.** No "when staging/prod ship", "we could later add", "this allows for", "lift to X when Y". Speculation rots; delete it.
- **Never reference PRs, tickets, milestones, or current task.** "fix for #1234", "added in M3", "for the new flow" — git remembers, the codebase shouldn't.
- **No section dividers.** `# ---- Database ----`, `# === Secrets ===` — decoration, not information. Whitespace and resource names already group.
- **Test before writing:** if you removed the comment, would a future reader be confused? If no → don't write it.

## Plans
- Make the plan extremely concise. Sacrifice details for conciseness.
- At the end of each plan, list any unanswered questions.

## Bug fixes
- Avoid refactoring when doing bug fixes — keep changes lean and focused on the fix.
- Don't rename variables, restructure code, or "improve" things outside the bug fix scope.
- **Exception:** if the minimal fix would leave the code noticeably worse than the surrounding code (e.g. way deeper indentation than sibling functions, the new code sticks out as the odd one out), do the small refactor to bring it in line. Flag it clearly when you do.
- Comments should be lean — don't over-explain.
- Tests should be relevant and test behaviour, not implementation details.

## Git
- **PR descriptions: as lean as possible, plain language.** Ideally one sentence — the problem and the suggested fix — that anyone can grasp without being in the loop or reading the code. Always try to cut it shorter. No code walkthroughs, no file-by-file rundown, no internals. Add a line of detail only when the one-liner genuinely isn't enough; link the ticket/logs for the deep context instead of restating it.
- When creating PRs, add labels: `bug` (fix), `enhancement` (feature/improvement), `upgrade` (dependency)
- Use `gh pr edit <PR_NUMBER> --add-label "<label>"`
- If branch has an issue key (e.g. `PROJ-1234-fix-bug`), prefix commits: `PROJ-1234: Summary`

## Jira
- Jira CLI may be installed at `/opt/homebrew/bin/jira` on macOS
- Create issues: `jira issue create -p <PROJECT> -t <Type> -s "summary" -b "description" --no-input`
- Issue types: Bug, Task, Story
- When creating PRs for fixes, create a corresponding Jira issue and link it in the PR description
- Use Jira issue keys in branch names and commit messages

## Testing Conventions
- All test descriptions MUST start with `should`
- In Jest/Vitest suites, use `it("should ...")` — NOT `test("should ...")`. The BDD alias pairs with the `should` convention so the spec reads as "it should ...". Applies to new tests you add, even in files where existing specs use `test()`. Leave untouched specs alone (only fix the ones you are adding or already editing).
- Always use Arrange / Act / Assert with blank lines between sections
- For complex tests (>5 lines of setup), add `// Arrange`, `// Act`, `// Assert` comments
