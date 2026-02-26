---
description: Address PR review comments
---

# Review Comments Command

Fetch unresolved review comments on the current PR, address each one, and push fixes.

**Argument:** $ARGUMENTS

## Workflow

### Step 1: Identify PR

If `$ARGUMENTS` is a PR number, use that. Otherwise detect from current branch:
```bash
gh pr view --json number,url
```

### Step 2: Fetch review comments

```bash
gh api repos/{owner}/{repo}/pulls/{number}/comments --jq '.[] | select(.position != null) | {id, path, line: .original_line, body, in_reply_to_id}'
```

Also fetch top-level review comments:
```bash
gh pr view {number} --json reviews --jq '.reviews[] | select(.state != "APPROVED") | {author: .author.login, body}'
```

Filter to unresolved/actionable comments only.

### Step 3: Address each comment

For each comment:
1. Read the referenced file and line
2. Understand what the reviewer is asking
3. If it's a valid fix: make the change
4. If it's a question or disagreement: prepare a reply explaining the reasoning
5. If unclear: skip and flag for user

Group related comments on the same file together.

### Step 4: Commit and push

1. Stage all fixes with `git add`
2. Commit with message: `Address review comments`
3. Push with `git push`

### Step 5: Reply to comments

For each addressed comment, post a brief reply:
```bash
gh api repos/{owner}/{repo}/pulls/{number}/comments/{id}/replies -f body="Fixed."
```

For comments where you chose not to change code, reply with a short explanation.

### Step 6: Report

Summary:
- Comments addressed with code changes
- Comments replied to without code changes
- Comments skipped (if any — explain why)
