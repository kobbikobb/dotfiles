---
name: create-jira-epic
description: Create a well-scoped Jira epic via acli. Use when the user asks to create/draft/plan an epic. Defaults to the project in ~/.claude/work.local.json, applies an epic quality checklist, and creates it with the shared jira-create.sh script.
---

# Create a Jira epic

## Project
`<PROJECT>` = `--project` if given, else `.jiraProject` from `~/.claude/work.local.json`, else ask the user. Use it everywhere `<PROJECT>` appears below.

## Defaults
- Label by type: `enhancement` (feature), `bug` (fix/reliability), `upgrade` (deps). Add a quarter label (e.g. `2026-Q3`) if it's roadmap work.

## Before creating
1. **Search for an existing epic or parent first** — don't duplicate. If one exists, reparent into it instead of making a new epic:
   `acli jira workitem search --jql 'project = <PROJECT> AND issuetype = Epic AND summary ~ "<keywords>"' --fields key,summary,status --csv`
2. Confirm scope with the user if ambiguous.

## Quality checklist (the epic description must have)
- **Plain-language goal** — one or two sentences a non-engineer (CS, exec) understands.
- **Background** — why now; link evidence (RCA / incident IDs). Label data sources (UAT vs prod); never invent percentages or ticket states.
- **Scope** — concrete work items. Mark what already exists (reparent) vs new.
- **Definition of done** — verifiable, with a concrete target. Not "as it grows" — give a number/scenario and who signs off.
- **Non-goals** — what's explicitly out, so it can't balloon.
- **Owner + timebox.**
- **No liability language** — don't write "contractually obligated" / blame; that's CS/Legal's call. Use neutral wording ("the delivery we commit to").

## Create it
Write the description to a file, then:
```
~/.claude/scripts/jira-create.sh --type Epic \
  --summary "<short outcome-focused title>" \
  --desc-file <path> \
  --label "<type-label>,<quarter-label>"
```
(Pass `--project <PROJECT>` unless it equals the script's own default.)

## After creating — acli limits
acli here **cannot set start/due dates or assignee**. Tell the user to set those in the Jira UI, and give exact values (owner name, start date, due date). To fetch an accountId for reference:
`acli jira workitem search --jql 'assignee = "<email>"' --fields assignee --json`

## Optional review pass
For high-stakes epics, spawn reviewer agents (accuracy / scope / customer-framing) before finalizing, and apply their fixes.
