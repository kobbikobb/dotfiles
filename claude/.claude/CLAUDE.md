# User Preferences

## Plans
- Make the plan extremely concise. Sacrifice details for conciseness.
- At the end of each plan, list any unanswered questions.

## Git
- When creating PRs, add labels: `bug` (fix), `enhancement` (feature/improvement), `upgrade` (dependency)
- Use `gh pr edit <PR_NUMBER> --add-label "<label>"`

## Commit Messages
- If branch has an issue key (e.g. `PROJ-1234-fix-bug`), prefix: `PROJ-1234: Summary`
- Otherwise just: `Summary`
- Footer:
  ```
  🤖 Generated with [Claude Code](https://claude.com/claude-code)

  Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>
  ```

## Testing Conventions
**ALL tests MUST follow these rules — no exceptions.**

### Naming
- All test descriptions MUST start with `should`
- `it('should return user when ID is valid')` ✓
- `it('returns user when ID is valid')` ✗

### Structure — AAA Pattern
- Always use Arrange / Act / Assert with blank lines between sections
- For complex tests (>5 lines of setup), add `// Arrange`, `// Act`, `// Assert` comments
