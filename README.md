# A repository for managing my dotfiles

- Setup simlinks with [Stow](https://www.gnu.org/software/stow/manual/stow.html)
- brew install stow
- Clone the repo and navigate into it
    - stow .
    - or ...
    - stow -t ~ nvim
    - stow -t ~ tmux
    - stow -t ~ zshrc
    - stow -t ~ ghostty
    - stow -t ~ claude  *(see cleanup below)*

## Claude Code setup

Before stowing `claude`, remove the files that will be replaced by symlinks:

```bash
# Remove commands being replaced (generalized versions now in dotfiles)
rm ~/.claude/commands/{check,ship,review,sync,ralph,rebase-main}.md

# Remove commands consolidated into review.md
rm ~/.claude/commands/{review-pr,review-branch}.md

# Remove commands that don't belong globally
rm ~/.claude/commands/{fix-build,add-issue}.md

# Remove stray directory
rm -rf ~/.claude/commands/.claude/

# Remove CLAUDE.md (replaced by symlink)
rm ~/.claude/CLAUDE.md

# Remove old dotfiles location
rm ~/dotfiles/.claude/settings.local.json && rmdir ~/dotfiles/.claude

# Stow
cd ~/dotfiles && stow -t ~ claude
```

Files kept as-is in `~/.claude/commands/`: `ship-with-issue.md`, `gsd/`
