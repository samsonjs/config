#!/bin/bash
#
# Runs the bootstrap end to end in a throwaway macOS VM and checks the result.
# Optional and slow (five to ten minutes once the image is cached; the first
# run pulls about 33 GB), so it is not part of CI.
#
#   bootstrap/test/vm.sh                 # base role, fresh VM, deleted afterwards
#   bootstrap/test/vm.sh --keep          # leave the VM running to poke at
#   bootstrap/test/vm.sh --roles base,dev
#
# It needs tart (https://tart.run; the Homebrew tap is broken on Homebrew 7,
# so the release binary from GitHub works best — put it on PATH or in $TART)
# and the expect that ships with macOS. The image's admin account has the
# password "admin", which is what the sudo prompts get.
#
# What it tests is the mechanics, on this working copy rather than main: the
# VM gets a copy of ~/config and ~/bin, Homebrew is removed so stage one
# installs it, and stage two runs with --skip forgejo, since a Forgejo token
# is the one thing it can't be handed. The Brewfiles are swapped for tiny ones
# so the run doesn't download every app; what the real ones say is checked by
# Deriva and by `brew bundle check`, not here. My own apps do install, from
# mudge's feed, when the VM can reach the tailnet through this Mac.

set -euo pipefail

TART="${TART:-$(command -v tart || true)}"
IMAGE="${IMAGE:-ghcr.io/cirruslabs/macos-tahoe-base:latest}"
CONFIG="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
BIN="${BIN:-$HOME/bin}"
ROLES="base"
KEEP=0

while [ $# -gt 0 ]; do
    case "$1" in
        --keep) KEEP=1 ;;
        --roles) ROLES="${2:?--roles needs a value}"; shift ;;
        -h|--help) sed -n '2,20p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
        *) echo "unknown option: $1" >&2; exit 2 ;;
    esac
    shift
done

[ -n "$TART" ] || { echo "vm.sh: tart not found; see the header of this script" >&2; exit 1; }
command -v expect >/dev/null || { echo "vm.sh: expect not found" >&2; exit 1; }

NAME="bootstrap-test-$(date +%Y%m%d-%H%M%S)"
WORK="$(mktemp -d)"
SSH_KEY="$WORK/id_ed25519"
ssh-keygen -q -t ed25519 -N "" -f "$SSH_KEY"
SSH_OPTS=(-i "$SSH_KEY" -o IdentitiesOnly=yes -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR)
ip=""

cleanup() {
    if [ "$KEEP" -eq 1 ]; then
        echo "→ Keeping VM $NAME (ssh admin@$ip, password admin; tart delete $NAME when done)"
    else
        "$TART" stop "$NAME" >/dev/null 2>&1 || true
        "$TART" delete "$NAME" >/dev/null 2>&1 || true
    fi
    rm -rf "$WORK"
}
trap cleanup EXIT

vm() { ssh -n "${SSH_OPTS[@]}" "admin@$ip" "export PATH=/opt/homebrew/bin:\$PATH; $*"; }

echo "== VM $NAME from $IMAGE"
"$TART" clone "$IMAGE" "$NAME"
"$TART" run "$NAME" --no-graphics >"$WORK/run.log" 2>&1 &
for _ in $(seq 1 60); do
    ip="$("$TART" ip "$NAME" 2>/dev/null || true)"
    [ -n "$ip" ] && break
    sleep 5
done
[ -n "$ip" ] || { echo "vm.sh: the VM never got an IP" >&2; exit 1; }
# Tart images come with a known password and no key; seed ours once. The key
# goes on the command line rather than stdin, which ssh under expect never
# closes, and the connection is password-only: with enough keys in the
# agent, ssh burns through sshd's attempt limit before it asks for one.
seeded=0
for _ in $(seq 1 12); do
    if expect >"$WORK/seed.log" 2>&1 <<EXPECT
set timeout 30
spawn ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR -o PubkeyAuthentication=no admin@$ip "mkdir -p ~/.ssh && chmod 700 ~/.ssh && echo '$(cat "$SSH_KEY.pub")' >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"
expect {
  "assword:" { send "admin\r"; exp_continue }
  eof { }
  timeout { exit 1 }
}
catch wait result
exit [lindex \$result 3]
EXPECT
    then
        seeded=1
        break
    fi
    sleep 5
done
[ "$seeded" -eq 1 ] || { echo "vm.sh: could not seed an ssh key into the VM; last attempt:" >&2; cat "$WORK/seed.log" >&2; exit 1; }
until vm true 2>/dev/null; do sleep 2; done
echo "✓ $ip"

echo "== Copying this working copy of ~/config and ~/bin in"
rsync -a --exclude zsh/zhistory --exclude 'zsh/.zcomp*' --exclude zsh/completions --exclude zsh/zlocal \
    --exclude gitconfig-local -e "ssh ${SSH_OPTS[*]}" "$CONFIG/" "admin@$ip:config/"
rsync -a -e "ssh ${SSH_OPTS[*]}" "$BIN/" "admin@$ip:bin/"
vm "printf \"brew 'cowsay'\ncask 'keepingyouawake'\n\" > ~/config/Brewfile; printf \"brew 'sl'\n\" > ~/config/roles/dev/Brewfile"
vm "sudo rm -rf /opt/homebrew"

echo "== Running the bootstrap (--roles $ROLES --skip forgejo)"
set +e
expect <<EXPECT
set timeout 1800
spawn ssh -t ${SSH_OPTS[*]} admin@$ip "~/config/bootstrap.sh --roles $ROLES --skip forgejo"
expect {
  -re "Enter (same )?passphrase.*:" { send "\r"; exp_continue }
  "Press enter when done." { send "\r"; exp_continue }
  -re "Roles, comma-separated:" { send "$ROLES\r"; exp_continue }
  -re "Press .*RETURN.*to continue" { send "\r"; exp_continue }
  -re "(^|\n)Password:" { send "admin\r"; exp_continue }
  timeout { puts "\n<<vm.sh: timed out>>"; exit 124 }
  eof { }
}
catch wait result
exit [lindex \$result 3]
EXPECT
status=$?
set -e
echo
echo "== Bootstrap exited $status"

failed=0
check() {
    local name="$1"; shift
    if vm "$@" >/dev/null 2>&1; then
        echo "ok   $name"
    else
        echo "FAIL $name"
        failed=1
    fi
}
[ "$status" -eq 0 ] || failed=1
check "Homebrew installed"            'test -x /opt/homebrew/bin/brew'
check "brew shellenv in ~/.zprofile"  'grep -q "brew shellenv" ~/.zprofile'
check "git, jj, rv, tea on PATH"      'command -v git jj rv tea'
check "Ruby from bootstrap/.ruby-version" 'rv ruby find "$(cat ~/config/bootstrap/.ruby-version)"'
check "dotfiles linked"               'test "$(readlink ~/.zshrc)" = "$HOME/config/zshrc" && test "$(readlink ~/.config/jj/config.toml)" = "$HOME/config/jj/config.toml"'
check "zlocal scaffolded"             'test -f ~/config/zsh/zlocal'
check "ssh config has mudge"          'grep -q "^Host mudge" ~/.ssh/config'
check "ssh key made and in allowed_signers" 'test -s ~/.ssh/id_ed25519.pub && grep -qF "$(cut -d" " -f2 ~/.ssh/id_ed25519.pub)" ~/config/allowed_signers'
check "roles recorded"                "test \"\$(paste -sd, - < ~/.config/deriva/roles)\" = \"$ROLES\""
check "brew bundle applied"           'brew list cowsay && brew list --cask keepingyouawake'
check "macOS defaults applied"        'test "$(defaults read -g AppleShowAllExtensions)" = 1'
if vm 'curl -fs --max-time 5 -o /dev/null http://mudge:8787/deriva/appcast.xml' 2>/dev/null; then
    check "Deriva installed from the feed" 'test -d /Applications/Deriva.app'
else
    echo "skip Deriva installed from the feed (mudge not reachable from the VM)"
fi
case ",$ROLES," in
    *,dev,*)
        check "dev Brewfile applied"      'brew list sl'
        check "skills cloned and linked"  'test -L ~/.claude/skills/jujutsu'
        ;;
esac

if [ "$failed" -eq 0 ]; then
    echo "PASS"
else
    echo "FAIL"
    exit 1
fi
