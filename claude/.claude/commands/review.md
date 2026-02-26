---
description: Review branch or PR against style guidelines
---

# Review Command

Review code as a colleague — professional but humble. Lead with strengths, frame issues as observations.

**Argument:** $ARGUMENTS

- If `$ARGUMENTS` is a PR number → review that PR and post a comment (`gh pr review N --comment`)
- If empty → review current branch locally (output only, no comment posted)

## Gather changes

- PR mode: `gh pr diff $ARGUMENTS`
- Branch mode: `git diff origin/main...HEAD` + `git diff HEAD` (uncommitted)

## Review checklist

Review against CLAUDE.md conventions and project-specific rules:

1. **Testing** (CRITICAL): test names start with "should", AAA pattern, lean and focused
2. **Simplicity**: simplest solution? unnecessary abstractions?
3. **Safety**: incremental changes? unintended side effects? edge cases?
4. **Clean code**: self-documenting? clear names? established patterns?
5. **Language-specific**: check project CLAUDE.md for language rules

## Output format

```
## Style Review

**Summary**: [1-2 sentences — lead with what's working]
**Strengths**: [specific and genuine]
**Observations**:
- [Critical]: ...
- [Suggestion]: ...
- [Minor]: ...
**Safety Assessment**: [incremental and safe?]
```

Do NOT approve or request changes on PRs — only comment. Be specific with file paths and line numbers.
