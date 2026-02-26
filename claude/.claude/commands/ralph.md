---
description: "Interactive Ralph Wiggum loop setup"
allowed-tools: ["AskUserQuestion", "Skill"]
---

# Interactive Ralph Loop Setup

You MUST follow these steps IN ORDER. Do NOT skip ahead. Do NOT call the Skill tool until step 3.

## Step 0: Check for arguments

If `$ARGUMENTS` is non-empty, the user provided args inline (e.g. `/ralph Fix the auth bug`).
In that case, use the provided text as the prompt and skip to Step 1 asking ONLY questions 2 and 3.

If `$ARGUMENTS` is empty, proceed to Step 1 asking all 3 questions.

## Step 1: Collect parameters (MANDATORY — do this FIRST)

Call AskUserQuestion with the applicable questions in a single call:

Question 1 (SKIP if `$ARGUMENTS` was provided):
- question: "What should Ralph loop on?"
- header: "Prompt"
- multiSelect: false
- options:
  - label: "Fix all failing tests", description: "Run tests, fix failures, repeat until green"
  - label: "Refactor and clean up", description: "Iteratively improve code quality"
  - label: "Build a feature end-to-end", description: "Implement, test, and wire up a feature"

Question 2:
- question: "How many iterations max?"
- header: "Iterations"
- multiSelect: false
- options:
  - label: "15 (Recommended)", description: "Good for most tasks"
  - label: "5", description: "Quick — small focused tasks"
  - label: "30", description: "Long — complex multi-step work"
  - label: "Unlimited", description: "No limit — runs until completion promise"

Question 3:
- question: "What completion message signals the task is done?"
- header: "Completion"
- multiSelect: false
- options:
  - label: "DONE (Recommended)", description: "Generic completion signal"
  - label: "ALL TESTS PASSING", description: "For test-fixing loops"
  - label: "FEATURE COMPLETE", description: "For feature implementation loops"

## Step 2: Confirm before launching

WAIT for the user's answers. Parse them:
- Prompt = `$ARGUMENTS` if provided, otherwise answer to question 1. Strip " (Recommended)" suffix if present.
- Max iterations = number from question 2. Strip " (Recommended)" suffix. If "Unlimited", will omit flag.
- Completion message = answer to question 3. Strip " (Recommended)" suffix.

Display a summary to the user (plain text, no tool call) and immediately proceed to step 3:

```
Launching Ralph loop:
- Prompt: <prompt>
- Max iterations: <N or unlimited>
- Completion: <message>
- Cancel anytime: /ralph-wiggum:cancel-ralph
```

## Step 3: Launch the loop

Call the Skill tool:
- skill: "ralph-wiggum:ralph-loop"
- args: the assembled argument string

Build the args string as follows:
- Start with the prompt text
- Append ` --max-iterations <N>` (omit entirely if Unlimited)
- Append ` --completion-promise '<message>'`

If the prompt contains special characters like quotes or dashes, wrap it in quotes in the args.

NEVER call the Skill tool before you have answers from AskUserQuestion.
