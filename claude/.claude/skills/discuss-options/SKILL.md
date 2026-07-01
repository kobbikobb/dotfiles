---
name: discuss-options
description: >-
  Discuss options and weigh trade-offs to reach an architecture/design decision.
  ALWAYS use this the moment the user wants to talk through choices — triggers:
  "discuss options", "discuss the options", "let's discuss pros and cons",
  "pros and cons", "weigh / compare / walk me through / talk through the options",
  "give me options", "what are my options", "help me decide between X and Y",
  "an HTML doc with options", and the legacy aliases "let's spar" / "sparring
  session". If you are about to hand-write an options-and-trade-offs comparison in
  chat, stop and use this skill instead. Renders options as a self-contained HTML
  doc the user annotates in-browser, iterates on their feedback, and records the
  final decision as an ADR.
---

# discuss-options — weigh trade-offs via an options doc + annotation loop

The intelligence (weighing trade-offs) is yours. This skill owns the **loop**:
render options → user annotates → harden → record decision.

## Flow

1. **Explore first.** Gather the facts the decision rests on (read the repos,
   find the unknowns). Don't propose options blind.
2. **Render** the options into a self-contained HTML doc from `template.html`.
   Every option gets: approach, effort, risk badge (low/med/high), and one
   open question. End with a single recommendation (not a survey) + a gaps list.
   Match the user's lean/no-fluff style: concise cards, no filler.
3. **Open** the doc for annotation via the safe launcher (below). Post **only** the
   URL + one line telling the user to annotate or name a choice — do **not** restate
   the options, table, or recommendation in chat. The doc is the single copy;
   repeating it there shows everything twice and defeats the annotate-in-browser point.
4. **Poll** for feedback, apply it to the HTML, reply, loop until the user is done.
5. **Record** the hardened decision as an ADR (below).

## Front-end: Lavish (annotate-in-browser), gated

Lavish opens the HTML locally and lets the user click/highlight elements to give
targeted feedback. It is **third-party and phones home by default** (Umami
telemetry → `a.kunchenguid.com`), and its README falsely claims "no external
calls". So it is only ever launched through the gated wrapper:

```
skills/discuss-options/lavish-safe.sh start <file>            # pinned ver, telemetry off, egress-gated
skills/discuss-options/lavish-safe.sh poll  <file>            # long-poll feedback (run backgrounded)
skills/discuss-options/lavish-safe.sh poll  <file> --agent-reply "<msg>"   # reply + keep polling
skills/discuss-options/lavish-safe.sh stop  <file>
```

Hard rules:
- **Pinned** to the vetted version (`0.1.31`) inside the wrapper. On any bump,
  re-run the egress gate before trusting it.
- **`start` aborts and kills** the server if it opens any non-loopback connection.
  Never poll a doc through a server that failed the gate.
- **Never** global-install or run `npx skills add … lavish` — that wires
  SessionStart hooks into every session. Transient `npx` cache only.
- `poll` long-polls silently — that's normal, don't kill it; re-run if interrupted.

## Fallback: built-in Artifact tool

If the egress gate fails, Lavish won't start, or the content is too sensitive to
risk any local third-party process, **drop Lavish and use the Artifact tool** —
publish the same HTML to claude.ai (private, already-trusted host); the user
comments in chat. The loop is identical; only the feedback channel changes.

## Record the decision (ADR)

When the user lands on a choice, write a short ADR:
- Repo has a decisions dir (`docs/decisions/`, `docs/adr/`, `adr/`) → write there
  as `NNNN-<slug>.md`.
- Else → write to the session scratchpad and tell the user where, ask if they
  want it committed somewhere.

ADR = context · options considered · decision · why · open questions. Lean.

## Notes
- Works in any repo (user-level skill). Only repo-specific bit is the ADR path.
- The HTML must be self-contained (inline CSS); don't rely on CDNs — they may be
  blocked and it breaks the offline-local guarantee.
