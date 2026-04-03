# User Preferences

## Plans
- Make the plan extremely concise. Sacrifice details for conciseness.
- At the end of each plan, list any unanswered questions.

## Bug fixes
- Avoid refactoring when doing bug fixes — keep changes lean and focused on the fix.
- Don't rename variables, restructure code, or "improve" things outside the bug fix scope.
- Comments should be lean — don't over-explain.
- Tests should be relevant and test behaviour, not implementation details.

## Git
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
- Always use Arrange / Act / Assert with blank lines between sections
- For complex tests (>5 lines of setup), add `// Arrange`, `// Act`, `// Assert` comments
