# dotfiles
My configuration files

# Setup
1. git clone dotfiles
1. Symlink files into home directory
    1. `mkdir -p ~/.config/git/`
    1. `ln -s dotfiles/gitconfig .gitconfig`
    1. `ln -s dotfiles/gitignore_global ~/.config/git/gitignore_global`
    1. `ln -s dotfiles/python .python`
    1. `ln -s dotfiles/inputrc .inputrc` (readline setup)
1. Set global git excludes file
1. Create .zshrc: `echo "source ~/dotfiles/zshrc/zshrc" > .zshrc`
1. Add starship configuration: `mkdir -p ~/.config && ln -s ~/dotfiles/starship.toml ~/.config/`
1. Create .tmux.conf: `echo "source-file dotfiles/tmux/tmux_general.conf" > .tmux.conf`
1. Brew Installation
    1. Install Brew (https://brew.sh/)
    1. `ln -s dotfiles/Brewfile ~/.Brewfile`
    1. `brew bundle --global`
1. Claude Code status line
    1. `mkdir -p ~/.claude`
    1. `ln -s ~/dotfiles/claude/statusline.sh ~/.claude/statusline.sh`
    1. Reference it in `~/.claude/settings.json`:
        ```json
        {
          "statusLine": {
            "type": "command",
            "command": "~/.claude/statusline.sh"
          }
        }
        ```
    1. The script shows `<worktree> | <branch> | <model>` (e.g. `🌳 feature-x | feat/foo | 🤖 Opus 4.8`). `📁` marks the main checkout, `🌳` a linked git worktree. Uses `jq` if present, otherwise falls back to `grep`/`sed` (no dependency required).


# Clients and worktrees

The active context is a pair `(client, worktree)`. A **client** is a repo under
`~/code/<client>`; a **worktree** is a linked git worktree under
`~/code/worktrees/<client>/<name>`. The sentinel `main` means the primary
checkout.

Switch clients with `client`:

```
client servers        # cd to ~/code/servers, restore its remembered worktree
```

Switch worktrees within the current client with `worktree`:

```
worktree                     # list this client's worktrees (also -l/--list)
worktree feature-x           # switch to an existing worktree
worktree --main              # switch back to the primary checkout (also -)
worktree --add feature-x foo # create ~/code/worktrees/<client>/feature-x on branch foo, then switch
worktree --rm feature-x      # remove the worktree
```

State lives in three scopes:

- `~/.client` — global default client (a fresh shell resumes it).
- `~/.client_worktrees` — per-client remembered worktree (`<client>\t<wt>`), so
  `client servers` returns you to the worktree you last used on `servers`.
- tmux `session_client` / `session_worktree` — the current pair for a tmux
  session, so panes stay in sync and sessions can diverge.
