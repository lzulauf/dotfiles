# Worktree Flow

Add a `worktree` axis to the existing `client` system so switching git worktrees
is as frictionless as switching repos.

## Background

The `client` machinery today carries **one axis of state** — "which client" — at
**two scopes**:

1. **Machine-global default** — `~/.client` holds a bare name. Every new company
   shell ends with `client $(cat ~/.client)`, so a fresh terminal resumes the last
   client.
2. **Per-tmux-session** — `zshrc_tmux` overrides `client` to also
   `tmux set-environment session_client`, and new panes read `session_client` back,
   so tmux sessions can diverge from the global default.

A name resolves to a location **by convention**: `CLIENT_DIR=~/code/$NAME`
(`~/$NAME` on humble). That convention is what keeps it cheap — state stores only a
*name*, and completion is just `_path_files -W ~/code/`.

Relevant files:
- `zshrc/zshrc_general` — `client_internal` + default `client`
- `zshrc/zshrc_humble` — overrides `client_internal` (different root)
- `zshrc/zshrc_tmux` — wraps `client` to persist into the tmux session env
- `zshrc/zshrc_everlaw`, `zshrc_benchling`, `zshrc_zymergen` — startup restore via `~/.client`
- `zshrc/completion/_client` — completion

## Problem

Git worktrees break the model in exactly two ways:

1. **Location is no longer derivable from a name** — worktrees live outside the
   `~/code/$NAME` mapping.
2. **It is a second axis** — the active thing becomes a **pair**
   `(client, worktree)`, not a single string. The state file, tmux var, and
   completion all assume one token.

## Decisions (locked)

- **State model — per-repo memory (Option B).** Each client remembers its own
  active worktree. The per-repo map is the *default provider*; the session pair is
  the *active value*. `client X` restores X's last worktree; `worktree foo` updates
  both the session and the map. Two clients never share a worktree slot, and hopping
  back resumes where you left off.
- **Location — under `~/code`, visible:** `~/code/worktrees/<repo>/<wt>`. Derivable
  like clients are, and under `CLAUDE_MOUNT_DIR=~/code` so Claude Code works inside a
  worktree.
- **Switch-only** — `worktree foo` only switches to an existing worktree; creation is
  explicit via `worktree --add`.

## Open questions (decide before Phase 1)

- **Map format** — flat `~/.client_worktrees` file (`<repo>\t<wt>` per line) vs
  per-repo files under `~/.client_worktrees/` (no parsing, easier to edit/debug).
- **`main` sentinel name** — `main` vs `root` vs `-`. `main` collides conceptually
  with the git branch; `root`/`-` may read cleaner in `worktree --list`.

## Data model

| Thing | Where | Notes |
|---|---|---|
| Current client | `~/.client` | unchanged (bare name) |
| Per-repo worktree memory | `~/.client_worktrees` | `<repo>\t<wt>`; sentinel = primary checkout |
| Session-current pair | tmux `session_client` + **new** `session_worktree` | tmux scope overrides file default |
| Main checkout | `~/code/<repo>` | = `CLIENT_DIR`, unchanged |
| Worktree | `~/code/worktrees/<repo>/<wt>` | derivable, under Claude mount |

New env vars beside `CLIENT_NAME`/`CLIENT_DIR`:
- **`WORKTREE_NAME`** — sentinel or the worktree name.
- **`WORKTREE_DIR`** — actual cd target (`$CLIENT_DIR` for the sentinel, else the worktree path).

## Phase 0 — Refactor to a shared core (no behavior change)

`client_internal` lives in `zshrc_general`, is re-overridden in `zshrc_humble`, and
`client` is wrapped again in `zshrc_tmux`. Collapse to:

- **`_context_set <client> [worktree] [--nocd]`** — the single place that sets env
  vars, persists, and cd's.
- **`_context_persist`** — the single pluggable seam for "file vs tmux," replacing
  the `zshrc_tmux` `client` override.

`client` and the new `worktree` both call `_context_set`. Ship and verify this alone
first — behavior must be identical (fresh shell resumes client, tmux panes stay in
sync, humble root still `~/$NAME`).

## Phase 1 — Add the worktree axis to state

- `_context_set` resolves the worktree: if not passed, read `~/.client_worktrees` for
  this client, default to the sentinel; compute `WORKTREE_DIR`; cd there.
- On `client X`: if the remembered worktree dir is **missing** (deleted worktree),
  fall back to the sentinel and prune the stale map entry.
- `zshrc_tmux`: read/write `session_worktree` beside `session_client`.
- Startup restore (`client $(cat ~/.client) --nocd`) also restores the remembered
  worktree.

## Phase 2 — The `worktree` command

- `worktree` / `worktree -l|--list` — list `~/code/worktrees/$CLIENT/*`
  (or `git worktree list`), mark current.
- `worktree <name>` — switch; **error if missing** (switch-only), suggest `--add`.
- `worktree -|--main` — back to the primary checkout.
- `worktree --add <name> [branch]` — `git -C $CLIENT_DIR worktree add
  ~/code/worktrees/$CLIENT/<name> [branch]`, then switch.
- `worktree --rm <name>` — `git worktree remove`, clear from map if active.

## Phase 3 — Completion + guards

- New `zshrc/completion/_worktree`: dir names under `~/code/worktrees/$CLIENT_NAME/`.
- Patch `_client` to exclude `worktrees` from candidates, and guard `_context_set`
  against a literal `worktrees` client name (collision with the new sibling dir).

## Phase 4 — README note

Short section documenting the `(client, worktree)` model and the path convention.

## Notes

- Each phase is independently shippable and testable in a fresh shell.
- Changes live in `zshrc_general` / `zshrc_tmux` + new `completion/_worktree`;
  per-company files (`zshrc_humble`) only need `client_internal` swapped for the
  shared core.
