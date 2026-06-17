# PR Review Engine (shared)

Shared analysis used by `my-pr-review` and `my-pr-approver`. It fetches a PR, reviews
it across several dimensions, and produces a deduped set of comments plus a recommended
verdict. The calling skill decides how to post (plain comment vs approve/request-changes).

## Step A: Fetch the target (lean)

Run the helper once and work from its output. Don't re-fetch with `gh` in context.
```bash
~/.claude/skills/_pr-shared/fetch-pr.sh $ARGUMENTS
```
It prints `=== META ===` (number, owner, repo, url, base, head, author, draft),
`=== FILES ===` (changed paths), and `=== DIFF ===`. If there is no PR for the branch,
review `git diff main...HEAD` and produce the findings locally.

## Step B: Correctness pre-pass — borrow `code-review` (top level, best-effort)

Use Anthropic's built-in `code-review` as the correctness + simplicity/efficiency lane
instead of hand-rolling one. **Invoke it directly in this (main) session, never from inside
a sub-agent** — nested, its own background finders get orphaned and the output is lost.
Read-only:
```
/code-review high
```
Do not pass `--comment` or `--fix`. Its findings land in context as RAW INPUT only: neutral
tone, `path:line`, no severity of mine. They are re-voiced and re-graded in Step D, never
posted as-is. If it returns nothing usable, proceed without it — the owned lenses below are
the floor, not a fallback to a hand-rolled bug hunter.

## Step C: Owned lenses (parallel sub-agents, one message)

Launch these together so they run concurrently. Give each the diff, PR title, severity
rubric, and voice rules, and ask for findings as `{path, line, severity, area, comment}`
already in my voice. These cover what `code-review` structurally cannot:

- **Repo consistency** (`Explore`) — match existing idioms, naming, structure? Read sibling
  code instead of guessing.
- **Broader impact & risk** (`Explore`) — callers/contracts, DB migrations, emitted events,
  breaking changes, security boundaries. The look-beyond-the-diff pass.
- **Tests** (`general-purpose`) — coverage of new behaviour, test quality, `should`-naming.

No hand-rolled correctness lane — that is `code-review`'s job in Step B.

## Step D: Normalize + synthesize

Merge `code-review`'s raw findings (Step B) with the lens findings (Step C), then:
- **Drop anything you can't stand behind.** If a `code-review` finding doesn't reproduce on
  a read of the actual code, cut it. You are the verify gate for its output.
- **Dedupe and merge per area** into one comment, never two on the same concern.
- **Re-voice every comment as mine** (voice rules below). This step is the sole writer of
  comment text — no `code-review` wording, `path:line`, or footer reaches the PR.
- **Tag each a final severity** (Risky/Major/Minor/Nit). Anchor to the most relevant changed
  line; off-diff findings go in the top-level body (GitHub can't anchor them).

## Step E: Recommended verdict

- Any **Risky** → request changes; note it likely needs a discussion.
- Any **Major** (no Risky) → request changes.
- Only **Minor/Nit**, or nothing → approve.

## Output of the engine

Hand back to the calling skill:
- the inline comments: `[{path, line, side, body}]` (body prefixed with severity),
- any off-diff notes for the top-level body,
- the severity counts and the recommended verdict.

---

## Severity rubric

- **Risky:** correctness, security, or architecture concern that likely needs a discussion. Blocks approval.
- **Major:** should be improved before merge. Blocks approval.
- **Minor:** worth fixing, non-blocking. Does not block approval.
- **Nit:** trivial or preference. Does not block approval.

## Voice — every comment must read as my own

- **Lead with a question.** "Is this meant to be awaited?" not "This is missing await."
- **Stay humble.** Assume the author has thought about it more than I have. Hedge: "maybe
  I'm missing something", "was that intentional?", "happy to hear if that's handled elsewhere".
- **No em-dashes.** Use commas and periods. (The clearest agent tell.)
- **No `path:line` in the comment body** — the inline anchor already shows location. Naming
  a symbol (`persist()`, `formatDate`) is natural and fine.
- **One comment per concern.** Lean. A code sample only when one sentence can't carry it.
- **Don't open with a verdict word** ("wrong", "bug", "must"). Open with curiosity.

Good:
- **Risky:** Should the scope check happen before the decrypt here? As it reads now an unauthorized request still triggers a decrypt, so I wanted to check whether that ordering was intentional.
- **Major:** Is `persist()` meant to be awaited here? Looks like its errors might get swallowed and the function could return before the write lands, but maybe I'm missing something.
- **Minor:** Would it be worth pulling this through the GraphQL hook like the other components do? Just for consistency, not blocking.
- **Nit:** Should this test name start with `should` to match the convention?

Code sample only when prose alone is awkward:
> **Major:** Was backoff considered for this reconnect loop? Without it a flapping upstream would spin hot. Something like this might work:
> ```ts
> await sleep(Math.min(1000 * 2 ** attempt, 30_000))
> ```

Don't: "this is wrong, fix error handling" / "Missing await, will swallow errors."

## Posting mechanics

Build a single review payload and submit it. `event` is set by the calling skill
(`COMMENT`, `APPROVE`, or `REQUEST_CHANGES`). No footer, no AI attribution.
```bash
cat > /tmp/my-pr-review.json <<'JSON'
{
  "event": "<EVENT>",
  "body": "<one-sentence summary>. Risky: N, Major: N, Minor: N, Nit: N.",
  "comments": [
    {"path": "services/foo.ts", "line": 42, "side": "RIGHT", "body": "**Major:** <comment>"}
  ]
}
JSON
gh api repos/{owner}/{repo}/pulls/{number}/reviews --method POST --input /tmp/my-pr-review.json
```
`line` is the line in the file's new version; `side` is `RIGHT` for added/context lines,
`LEFT` for removed ones.
