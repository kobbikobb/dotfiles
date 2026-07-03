---
name: create-jira-story
description: Create a Jira STORY/issue/task via jira-axi — a single deliverable unit of work, optionally under a parent epic. Use when the user asks to create/draft/file a story, issue, task, or ticket (this is the default for "create an issue/ticket"). For a multi-story initiative use create-jira-epic. Defaults to the project in ~/.claude/work.local.json, links under a parent epic, uses the shared jira-create.sh script.
---

# Create a Jira story

## Project
`<PROJECT>` = `--project` if given, else `.jiraProject` from `~/.claude/work.local.json`, else ask the user.

## Defaults
- Label by type: `enhancement` (feature), `bug` (fix), `upgrade` (deps).
- A story should sit **under an epic** — ask for or find the parent epic key.

## Before creating
- Find the parent epic: `jira-axi issue list --jql 'project = <PROJECT> AND issuetype = Epic AND summary ~ "<keywords>"'`
- If the user hasn't named an epic and one clearly fits, suggest it.

## Quality checklist (the story description should have)
- **User-facing intent** — what changes and for whom, in plain language.
- **Acceptance criteria** — a short, verifiable list (what "done" looks like).
- **Scope** — concrete and bounded; link related tickets.
- Keep it lean — a story is one coherent piece of work, not an epic.

## Create it
`jira-axi issue create` only takes `--project/--summary/--type`, so creation goes through `jira-create.sh` (acli) for parent, label, and description-file support. Write the description to a file, then:
```
~/.claude/scripts/jira-create.sh --type Story \
  --summary "<short title>" \
  --desc-file <path> \
  --parent <EPIC-KEY> \
  --label "<type-label>"
```
(Pass `--project <PROJECT>` unless it equals the script's own default. Omit `--parent` only if it genuinely has no epic.)

## After creating — known limits
Creation here **cannot set start/due dates or assignee** (acli can't write custom fields via `edit`). Set dates in the Jira **Timeline/Plans UI**, assignee in the Jira UI. accountId lookup (acli — jira-axi doesn't surface accountId):
`acli jira workitem search --jql 'assignee = "<email>"' --fields assignee --json`
