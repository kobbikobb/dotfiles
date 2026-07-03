---
name: create-jira-epic
description: Create a well-scoped Jira EPIC via jira-axi — a large body of work spanning multiple stories (a feature, initiative, or multi-phase project). Use when the user asks to create/draft/plan an epic, or to plan a multi-story effort/roadmap in Jira. For a single piece of work under an epic use create-jira-story. Defaults to the project in ~/.claude/work.local.json, applies an epic quality checklist, creates via the shared jira-create.sh script.
---

# Create a Jira epic

## Project
`<PROJECT>` = `--project` if given, else `.jiraProject` from `~/.claude/work.local.json`, else ask the user. Use it everywhere `<PROJECT>` appears below.

## Defaults
- Label by type: `enhancement` (feature), `bug` (fix/reliability), `upgrade` (deps). Add a quarter label (e.g. `2026-Q3`) if it's roadmap work.

## Before creating
1. **Search for an existing epic or parent first** — don't duplicate. If one exists, reparent into it instead of making a new epic:
   `jira-axi issue list --jql 'project = <PROJECT> AND issuetype = Epic AND summary ~ "<keywords>"'`
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
`jira-axi issue create` only takes `--project/--summary/--type`, so creation goes through `jira-create.sh` (acli) for label and description-file support. Write the description to a file, then:
```
~/.claude/scripts/jira-create.sh --type Epic \
  --summary "<short outcome-focused title>" \
  --desc-file <path> \
  --label "<type-label>,<quarter-label>"
```
(Pass `--project <PROJECT>` unless it equals the script's own default.)

## After creating — known limits
Creation here **cannot set start/due dates or assignee**. Set dates in Jira **Timeline/Plans UI**, assignee in Jira UI; give user exact values. AccountId lookup (acli):
`acli jira workitem search --jql 'assignee = "<email>"' --fields assignee --json`

## Optional review pass
For high-stakes epics, spawn reviewer agents (accuracy / scope / customer-framing) before finalizing, and apply their fixes.
