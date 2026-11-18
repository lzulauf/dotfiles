#!/usr/bin/env bash
# Claude Code status line.
# Reads session context as JSON on stdin and prints a single status line.
# Shows: repo, worktree (only when in a linked worktree), git branch, model.
# Configure via ~/.claude/settings.json:
#   { "statusLine": { "type": "command", "command": "~/.claude/statusline.sh" } }

input=$(cat)

# Glyph shown before the branch name (Nerd Font octicon git-branch).
BRANCH_ICON=""

# Extract a top-level-ish string field. Uses jq when available, otherwise a
# grep/sed fallback keyed on the (unique) field name so no dependency is required.
field() {
    if command -v jq >/dev/null 2>&1; then
        echo "$input" | jq -r "$1 // empty"
    else
        echo "$input" | grep -o "\"$2\"[[:space:]]*:[[:space:]]*\"[^\"]*\"" | head -1 | sed 's/.*:[[:space:]]*"\(.*\)"/\1/'
    fi
}

cwd=$(field '.workspace.current_dir' 'current_dir'); [ -z "$cwd" ] && cwd=$(field '.cwd' 'cwd')
model=$(field '.model.display_name' 'display_name'); [ -z "$model" ] && model="?"

cd "$cwd" 2>/dev/null

branch=$(git branch --show-current 2>/dev/null)

repo=""
wt=""
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    top=$(basename "$(git rev-parse --show-toplevel 2>/dev/null)")
    # Repo name = the parent dir of the shared (common) git dir.
    common=$(git rev-parse --git-common-dir 2>/dev/null)
    common=$(readlink -f "$common" 2>/dev/null || echo "$common")
    repo=$(basename "$(dirname "$common")")
    # A linked worktree has git-dir != git-common-dir; the main checkout has them
    # equal. Only surface the worktree name when it differs from the repo.
    if [ "$(git rev-parse --git-dir 2>/dev/null)" != "$(git rev-parse --git-common-dir 2>/dev/null)" ]; then
        wt="🌳 $top"
    fi
else
    repo=$(basename "$cwd")
fi

out="📦 $repo"
[ -n "$wt" ] && out="$out | $wt"
out="$out | ${BRANCH_ICON:+$BRANCH_ICON }${branch:-no-branch}"
out="$out | 🤖 $model"
printf "%s" "$out"
