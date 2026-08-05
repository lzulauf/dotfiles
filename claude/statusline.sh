#!/usr/bin/env bash
# Claude Code status line.
# Reads session context as JSON on stdin and prints a single status line.
# Shows: worktree (with a marker for linked vs. main checkout), git branch, model.
# Configure via ~/.claude/settings.json:
#   { "statusLine": { "type": "command", "command": "~/.claude/statusline.sh" } }

input=$(cat)

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

wt=""
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    top=$(basename "$(git rev-parse --show-toplevel 2>/dev/null)")
    # A linked worktree has git-dir != git-common-dir; the main checkout has them equal.
    if [ "$(git rev-parse --git-dir 2>/dev/null)" != "$(git rev-parse --git-common-dir 2>/dev/null)" ]; then
        wt="🌳 $top"   # linked worktree
    else
        wt="📁 $top"   # main checkout
    fi
else
    wt="📁 $(basename "$cwd")"
fi

printf "%s | %s | 🤖 %s" "$wt" "${branch:-no-branch}" "$model"
