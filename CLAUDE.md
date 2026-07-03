# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/manual/stow.html). Each top-level directory is a stow *package* whose internal layout mirrors `$HOME`. Stowing a package symlinks its contents into the home directory.

Packages: `claude` (Claude Code config — the substantial one), `nvim`, `tmux`, `zshrc`, `ghostty`.

## Working with stow packages

A file lives at `<package>/<path-relative-to-home>`. Example: `~/.zshrc` is edited at `zshrc/.zshrc`; the nvim config at `~/.config/nvim/...` lives under `nvim/.config/nvim/...`.

```bash
stow -t ~ <package>   # link one package into $HOME
stow .                # link all
stow -R -t ~ <package> # restock after adding/removing files
```

When adding a new config file, place it at the path it should occupy under `$HOME`, inside the right package — do not edit `~` directly, edit the package and (re)stow. `claude` needs the pre-stow cleanup in `README.md` before first stow (it replaces files Claude Code ships by default).

## The `claude` package

Holds the global Claude Code setup symlinked to `~/.claude/`:
- `CLAUDE.md` — global user preferences applied to **all** projects (code quality, comments, git/Jira workflow, testing conventions). This is the authoritative style guide; honor it when editing anything here.
- `commands/` — slash commands (`check`, `ship`, `sync`, `ralph`).
- `skills/` — the bulk of the logic. Each skill is a directory with a `SKILL.md` (YAML frontmatter `name` + `description`, then a prose workflow).

### Skill architecture

Skills are markdown instructions, not executable code — the "build" is whether the prose is unambiguous and the embedded shell snippets are correct.

The PR-automation skills (`my-pr-fixer`, `my-pr-fixer-all`, `my-pr-review`, `my-pr-approver`, `my-pr-approver-all`, `my-patch-merger`, `pr-status-all`, `my-pr-stale-list`) share their mechanics through `skills/_pr-shared/`:
- `*-engine.md` / `*.md` — the reusable "how" (e.g. `fixer-engine.md`, `review-engine.md`, `fix-one-pr.md`). Each `SKILL.md` is a thin wrapper that points at an engine and sets only the caller-specific policy (interactive vs. fan-out, how high-risk work and pushes are handled).
- `*.sh` — deterministic git/`gh` plumbing (listing PRs, rebasing, merging). Anything that force-pushes is isolated in a script and always uses `--force-with-lease`.

Conventions to match when editing or adding skills:
- An `-all` skill fans out one sub-agent per PR (each in its own git worktree under `worktrees/`) via a `Workflow` `pipeline()`; the non-`-all` variant handles a single PR interactively. Keep that split.
- Engines are token-lean by design ("read only what you'll act on") and never dump green CI checks — preserve that when extending.
- Shared logic goes in `_pr-shared/`; don't duplicate it into individual `SKILL.md` files.
- `disable-model-invocation: true` in frontmatter means the skill only runs when explicitly invoked.
- The `claude` package's `CLAUDE.md` lists scoped skill variants (`claude:create-jira-story`, etc.) — these apply when editing files under `claude/`.

## Git note

Per the global `CLAUDE.md`, this environment uses `gh-axi` (not `gh`) and `jira-axi` (not `acli jira`) for GitHub/Jira operations. The Jira skills use `jira-axi` for reads/searches; creation falls back to `acli` (via `~/.claude/scripts/jira-create.sh`) because `jira-axi issue create` lacks parent/label/description flags. See `README.md` for install/setup.
