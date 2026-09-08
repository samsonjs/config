#!/bin/bash
# Rename descriptively named remotes (forgejo, samsonjs, github) to origin in
# every repo under the given directories, so jj and git defaults apply without
# per-remote config. Idempotent: repos that already have an origin are skipped.
#
# Rules, applied per repo in this order:
#   1. The first existing remote among forgejo, samsonjs, github becomes origin.
#   2. If samsonjs was chosen and github also exists, github becomes upstream.
#   3. Stale per-repo jj config that pinned git.push/git.fetch to forgejo or
#      github, or trunk() to a single remote bookmark, is removed.
#
# Usage: rename-remotes.sh [-n] [dir ...]   (-n = dry run; default dirs below)
set -euo pipefail

dry_run=false
if [ "${1:-}" = "-n" ]; then dry_run=true; shift; fi
if [ $# -eq 0 ]; then set -- "$HOME/bin" "$HOME/config" "$HOME"/Developer/*; fi

failed=0
run() {
    if $dry_run; then echo "    would: $*"; return; fi
    echo "    $*"
    "$@" || { echo "    FAILED (fix by hand, then rerun)" >&2; failed=1; }
}

# jj workspaces may have no .git directory, so ask jj for remotes when it can.
has_remote() {
    if [ -d "$1/.jj" ]; then
        jj -R "$1" git remote list 2>/dev/null | awk '{print $1}' | grep -qx "$2"
    else
        git -C "$1" remote | grep -qx "$2"
    fi
}

for dir in "$@"; do
    dir=${dir%/}
    [ -d "$dir/.git" ] || [ -d "$dir/.jj" ] || continue
    if [ -d "$dir/.jj" ]; then
        # jj refuses to rename a remote whose config section has extra keys, and
        # the gh CLI adds `gh-resolved` to the one it resolves the repo through.
        rename() {
            [ -d "$dir/.git" ] && git -C "$dir" config --unset "remote.$1.gh-resolved" 2>/dev/null || true
            run jj -R "$dir" git remote rename "$1" "$2"
        }
    else
        rename() { run git -C "$dir" remote rename "$1" "$2"; }
    fi

    chosen=""
    if ! has_remote "$dir" origin; then
        for name in forgejo samsonjs github; do
            if has_remote "$dir" "$name"; then chosen=$name; break; fi
        done
        if [ -n "$chosen" ]; then
            echo "$dir"
            rename "$chosen" origin
            if [ "$chosen" = samsonjs ] && has_remote "$dir" github && ! has_remote "$dir" upstream; then
                rename github upstream
            fi
        fi
    fi

    # Per-repo jj config that only made sense with the old names.
    if [ -d "$dir/.jj" ]; then
        cfg=$(jj -R "$dir" config list --repo 2>/dev/null || true)
        for key in git.push git.fetch; do
            if grep -qE "^$key = \"(forgejo|github)\"" <<<"$cfg"; then
                [ -n "$chosen" ] || echo "$dir"
                run jj -R "$dir" config unset --repo "$key"
            fi
        done
        if grep -qE '^revset-aliases\."trunk\(\)" = "(.*@(forgejo|github)|(main|master)@origin)"' <<<"$cfg"; then
            [ -n "$chosen" ] || echo "$dir"
            run jj -R "$dir" config unset --repo 'revset-aliases."trunk()"'
        fi
    fi
done

exit $failed
