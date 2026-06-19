# Sweep one PR — per-PR deep-review agent contract

Used by `my-pr-approver-all --org` (one agent per PR, run inside a Workflow). Each agent reviews ONE
PR against a local checkout and returns a structured verdict. Inputs: `repo` (owner/name),
`number`, `headSha`, `url`, and `dryRun` (bool).

## Steps

1. **Checkout the head** — independent shallow tree, parallel-safe (no shared clone):
   ```bash
   d=/tmp/pr-sweep/<repo-with-slash-as-dash>-<number>
   rm -rf "$d"; git init -q "$d"
   git -C "$d" remote add origin "https://github.com/<repo>.git"
   git -C "$d" fetch -q --depth 1 origin <headSha>
   git -C "$d" checkout -q FETCH_HEAD
   ```
   `--depth 1` gives the full working tree at the head commit, so `rg`/glob cross-file tracing
   works. Get the diff with `gh pr diff <number> --repo <repo>`. Do NOT run `npm install`, build,
   or tests — read and trace only.

2. **Review deeply** against the local tree, following `~/.claude/skills/_pr-shared/review-engine.md`:
   the owned lenses (repo consistency, broader impact + security, tests), a careful line-by-line
   diff read, and verify-by-reading the real files for any claim before trusting it. Use the
   engine's severity rubric and voice rules. (Do NOT invoke the `code-review` skill — its
   background finders orphan when nested in a sub-agent. Do the correctness pass by hand here.)

3. **Decide the verdict** — any Risky or Major → `REQUEST_CHANGES`; only Minor/Nit or clean →
   `APPROVE`. Never approve a draft (shouldn't reach you; bail if so).

4. **Post** (skip entirely if `dryRun`) — one review, engine posting mechanics: **empty body,
   inline comments only**, severity-prefixed, lean voice (short, clipped scenario, one ask).
   `gh api repos/<repo>/pulls/<number>/reviews --method POST --input <json>`.

5. **Teardown** — `rm -rf "$d"`.

## Return (StructuredOutput schema)

```
{
  "repo": "owner/name",
  "number": 123,
  "url": "https://github.com/...",
  "verdict": "approved" | "changes-requested" | "error",
  "blockerCount": 0,            // Risky + Major count
  "impact": "one plain line: what this PR changes and who/what it affects",
  "headsUp": "anything I should know even if approved (migration, auth/security surface, breaking change, broad blast radius, sketchy area), else null",
  "reviewUrl": "the posted review URL, or null on dry-run/error"
}
```

`impact` is ALWAYS filled — a one-line, plain-language summary of the change, even for a clean
approve. `headsUp` flags things worth my attention regardless of verdict (set null if genuinely
nothing). On `error` (fetch failed, diff too big, repo gone), set `verdict:"error"`, put the
reason in `impact`, and post nothing.
