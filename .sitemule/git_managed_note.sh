#!/usr/bin/env bash
# git_managed_note.sh - leave GIT-MANAGED.md in the IBM i folder this repo was just synced to:
# the folder is a copy of the git repo, and edits made there are overwritten by the next sync.
#
#   .sitemule/git_managed_note.sh <ssh host> <remote folder>     (right after the rsync)
#
# The remote folder may start with ~/ (the remote user's home). Never fails the caller.
# Master copy: .sitemule/git_managed_note.sh in the sitemule-factory repo - copy it into each
# project that syncs to the IBM i (see the sitemule-factory CLAUDE.md).
host=$1; dir=$2
[ -n "$host" ] && [ -n "$dir" ] || exit 0
cd "$(dirname "$0")/.." || exit 0

url=$(git remote get-url origin 2>/dev/null | sed -E 's#^git@([^:]+):#https://\1/#; s#^(https?://)[^@/]+@#\1#; s#\.git$##')
branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
commit=$(git log -1 --format='%h %s' 2>/dev/null)
dirty=$([ -n "$(git status --porcelain --untracked-files=no 2>/dev/null)" ] && echo yes || echo no)
rdir=${dir/#\~\//\$HOME/}   # ~/x -> $HOME/x, expanded on the IBM i

ssh -o BatchMode=yes "$host" "cat > \"$rdir/GIT-MANAGED.md\"" 2>/dev/null <<EOF || echo ">>> could not write GIT-MANAGED.md on $host (continuing)"
# Managed by git - do not edit here

This folder is a copy of the git repo **${url:-(no remote)}**, written by the
project's sync script on every build. Changes made here are overwritten.

Edit in a clone of the repo and build from there:

    git clone ${url:-<repo>}

| | |
|---|---|
| Branch | \`$branch\` |
| Commit | \`$commit\` |
| Uncommitted local changes | $dirty |
| Synced | $(date '+%Y-%m-%d %H:%M') by $(whoami) |
EOF
exit 0
