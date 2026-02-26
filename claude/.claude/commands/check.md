---
description: Run quality gates and fix issues without committing
---

# Check Command

Run all quality gates for modified files. Auto-fix issues and retry. Does NOT commit or push.

## Workflow

1. Identify modified files (`git status --porcelain` + `git diff --name-only origin/main...HEAD`)
2. Detect project tooling from config files (package.json scripts, build.gradle tasks, Makefile targets, Cargo.toml, pyproject.toml, go.mod, etc.) — read the config to find the actual commands
3. Run quality gates in order: formatting/linting → type checking → unit tests
4. If anything fails: auto-fix where possible, then re-run from step 3
5. Stop after 3 failed fix attempts and report remaining problems
6. Report: which checks ran, what was auto-fixed, final status
