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

## Step A.5: Check out the PR head into a worktree (do this before ANY file read)

The diff from Step A is text, but the working tree is almost always still on `main` or
some other branch — so every file a sub-agent reads, and every `git diff main...HEAD` it
runs, reflects the WRONG code. New files in the PR don't even exist on `main`. Reviewing
against the wrong tree silently grades the wrong code. So before launching any lens or
finder, materialize the PR head:
```bash
git fetch origin "$HEAD_BRANCH"                       # head from Step A's META
WT=$(mktemp -d)/pr-$NUMBER
git worktree add -d "$WT" FETCH_HEAD
```
Pass `$WT` to every sub-agent as the directory to read and diff in. Have them run
`git -C "$WT" diff main...HEAD` (three-dot = merge-base) to get the real diff, and read
files from under `$WT`. For big diffs, agents read the diff straight from the worktree
rather than receiving the fetched blob. Remove it when done: `git worktree remove --force "$WT"`.
(If the PR branch already IS the current checkout, skip the worktree and use the checkout.)

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
- **Sub-agent severities are advisory, not binding.** A confident sub-agent that grades
  something Risky or Major can flip the whole verdict, so re-read the actual source for
  EVERY Risky/Major before you let it block. Common overclaims: a "breach" on a runId /
  capability-token endpoint whose tenant model is pre-existing and uniform; a "Major" on a
  defensive `x ? … : false` branch that never triggers because the caller always supplies
  `x`. Confirm the failing path is reachable in real code, or downgrade/drop it.
- **Calibrate severity to the rubric, not to the verdict you want — in either direction.**
  Don't inflate to manufacture a blocker, and don't shave a real concern down to Minor just so
  the PR can approve. A missing test on new behavior is **Major** when that behavior is otherwise
  unverified; it's Minor only when the path is genuinely covered elsewhere. A new write/inject
  path that changes the threat model outranks a pre-existing-but-uniform scoping model. Before
  posting, read the PR's own follow-up list (body + linked tickets): flagging work the author
  already split out is noise.
- **Dedupe and merge per area** into one comment, never two on the same concern.
- **Re-voice every comment as mine** (voice rules below). This step is the sole writer of
  comment text — no `code-review` wording, `path:line`, or footer reaches the PR.
- **Tag each a final severity** (Risky/Major/Minor/Nit) and anchor every finding to a changed
  line as an inline comment. **The review carries no central body — all findings live in
  context, on the line they're about.** If a finding is genuinely off-diff, anchor it to the
  nearest relevant changed line and open by naming where the real code lives ("This is about
  `requireRun` below, not this line, but..."). If it can't be tied to any changed line, drop
  it rather than open a central body for it.

## Step E: Recommended verdict

- Any **Risky** → comment (don't approve); note it likely needs a discussion.
- Any **Major** (no Risky) → comment (don't approve).
- Only **Minor/Nit**, or nothing → approve **only if the confidence gate passes**; else comment.

**Sensitive surfaces never auto-approve.** If the diff touches auth, migrations, money, PII,
event-sourcing, concurrency, or data-delete, the verdict is `COMMENT` regardless of how small or
clean it is — hold it for a human. No size or clarity earns an approve here.

**Confidence gate — approve is not the default for a clean review.** An approval is a signal
the team relies on to merge without a second look, so only spend it when you actually earned it.
Approve only when BOTH hold; otherwise post `COMMENT` (findings if any, else a single inline note
"looks fine, but too large/unfamiliar for me to rubber-stamp — worth a human pass"):
- **Bounded scope.** The diff is small enough to have reviewed in full, not skimmed.
- **Full understanding.** You followed every changed path — no "probably fine" on code you
  didn't actually trace.

When in doubt, comment. A comment-only review with no blockers still lets the author merge; a
wrong approval is the thing that erodes trust in the bot.

Never request changes — it hard-locks the branch until this exact reviewer clears it. Comment leaves the findings visible without blocking; the author decides.

## Output of the engine

Hand back to the calling skill:
- the inline comments: `[{path, line, side, body}]` (body prefixed with severity) — these are
  the entire review; there is no central body,
- the severity counts and the recommended verdict (for the calling skill to report back to
  the user, NOT to post on the PR).

---

## Severity rubric

- **Risky:** correctness, security, or architecture concern that likely needs a discussion. Blocks approval.
- **Major:** should be improved before merge. Blocks approval.
- **Minor:** worth fixing, non-blocking. Does not block approval.
- **Nit:** trivial or preference. Does not block approval.

## Voice — every comment must read as my own

- **Short. 2-3 sentences, often fewer.** This is the big one. State the problem, give the
  shortest concrete scenario that proves it, ask one thing. Cut the supporting justification,
  the "the role template says...", the menu of options. If the author needs more, they'll ask.
- **Clipped scenario beats prose.** "You capture page A, move to page B, say investigate, and
  A gets investigated, not B." Fragments are fine. Don't narrate the mechanism in full.
- **Grammar is sacrificable for simplicity.** If dropping an article, a verb, or a clause makes
  it faster to read, drop it. A clear fragment beats a correct sentence. Readability wins.
- **One direct ask to close.** "Can you look into this, or prove me wrong?" / "Was that
  intentional?" / "Am I missing something?" Humble but blunt. Not a hedge sandwich.
- **Stay humble, don't grovel.** One hedge, not three. "maybe I'm missing something" once is
  plenty; don't also add "so perhaps this is fine" and "happy to hear otherwise".
- **No em-dashes.** Use commas and periods. (The clearest agent tell.)
- **No `path:line` in the body** — the anchor shows location. Naming a symbol is fine, but
  don't pile on internal symbols to prove you read the code; the author knows their code.
- **Don't open with a verdict word** ("wrong", "bug", "must"). Open with the problem or a question.

Good (note the length — match this, not longer):
- **Risky:** Does the scope check run before the decrypt here? Looks like an unauthorized request still triggers a decrypt. Intentional?
- **Major:** This auto-approves with the page already captured, no freshness check. You capture page A, move to page B, investigate, and A gets investigated. Can you look into this, or prove me wrong?
- **Minor:** Worth pulling this through the GraphQL hook like the other components, just for consistency? Not blocking.
- **Nit:** `should`-prefix to match the convention?

Code sample only when prose alone is awkward, and keep it just as short:
> **Major:** Was backoff considered here? A flapping upstream would spin hot. Maybe:
> ```ts
> await sleep(Math.min(1000 * 2 ** attempt, 30_000))
> ```

Don't: "this is wrong, fix error handling" / a five-sentence comment that names three symbols,
explains the mechanism in full, and offers an either/or menu. That's a design doc, not a review note.

## Posting mechanics

Build a single review payload and submit it. `event` is set by the calling skill
(`COMMENT`, `APPROVE`, or `REQUEST_CHANGES`). **`body` is always empty — never post a
summary, severity counts, praise, or off-diff notes centrally. Everything lives in the
inline `comments`.** No footer, no AI attribution. The severity counts and verdict go to the
user in chat, not on the PR.
```bash
cat > /tmp/my-pr-review.json <<'JSON'
{
  "event": "<EVENT>",
  "body": "",
  "comments": [
    {"path": "services/foo.ts", "line": 42, "side": "RIGHT", "body": "**Major:** <comment>"}
  ]
}
JSON
gh api repos/{owner}/{repo}/pulls/{number}/reviews --method POST --input /tmp/my-pr-review.json
```
A clean `APPROVE` with no findings is an empty `body` and an empty `comments` array. For a
`COMMENT` event GitHub needs at least one inline comment (an empty-body comment-only review
is rejected) — if there's nothing to say in context, there's nothing to post.
`line` is the line in the file's new version; `side` is `RIGHT` for added/context lines,
`LEFT` for removed ones. GitHub rejects the whole review if any comment anchors a line
that isn't part of the diff hunks, so anchor only on added/context lines you can see in
the diff; anything off-diff goes in `body`.
