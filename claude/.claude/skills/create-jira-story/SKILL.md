---
name: create-jira-story
description: Create a Jira story via acli. Use when the user asks to create/draft a story. Defaults to the project in ~/.claude/work.local.json, links it under a parent epic, and uses the shared jira-create.sh script.
---

# Create a Jira story

## Project
`<PROJECT>` = `--project` if given, else `.jiraProject` from `~/.claude/work.local.json`, else ask the user.

## Defaults
- Label by type: `enhancement` (feature), `bug` (fix), `upgrade` (deps).
- A story should sit **under an epic** — ask for or find the parent epic key.

## Before creating
- Find the parent epic: `acli jira workitem search --jql 'project = <PROJECT> AND issuetype = Epic AND summary ~ "<keywords>"' --fields key,summary --csv`
- If the user hasn't named an epic and one clearly fits, suggest it.

## Quality checklist (the story description should have)
- **User-facing intent** — what changes and for whom, in plain language.
- **Acceptance criteria** — a short, verifiable list (what "done" looks like).
- **Scope** — concrete and bounded; link related tickets.
- Keep it lean — a story is one coherent piece of work, not an epic.

## Create it
Write the description to a file, then:
```
~/.claude/scripts/jira-create.sh --type Story \
  --summary "<short title>" \
  --desc-file <path> \
  --parent <EPIC-KEY> \
  --label "<type-label>"
```
(Pass `--project <PROJECT>` unless it equals the script's own default. Omit `--parent` only if it genuinely has no epic.)

## After creating — acli limits
acli here **cannot set start/due dates or assignee** — set those in the Jira UI. Give the user the exact owner/dates. accountId lookup:
`acli jira workitem search --jql 'assignee = "<email>"' --fields assignee --json`
