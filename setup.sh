#!/usr/bin/env bash
#
# SnapShield setup
#
# Prepares a server for SnapShield:
#   1. adds the public 45Drives package repository (Community by default),
#   2. installs Cockpit and the SnapShield Cockpit plugin (cockpit-snapshield),
#   3. turns Cockpit on.
#
# Everything else -- the SnapShield service, the Control Panel and their
# configuration -- is installed by the guided setup wizard in Cockpit
# afterwards. Open https://<this-server>:9090, then SnapShield.
#
# Usage:
#   curl -sSL https://raw.githubusercontent.com/45Drives/SnapShield-public/main/setup.sh | sudo bash
#   curl -sSL https://raw.githubusercontent.com/45Drives/SnapShield-public/main/setup.sh | sudo bash -s -- --enterprise
#
# Options:
#   --community      use the 45Drives Community repository (default)
#   --enterprise     use the 45Drives Enterprise repository
#   --testing        also enable the testing stream, for pre-release builds
#   --repo-only      set up the repository but do not install anything
#   --dry-run        print what would be done without changing anything
#   -h, --help       show this help
#
# Supported: Rocky Linux / RHEL / AlmaLinux 8 and 9, Ubuntu 20.04 and 22.04.
# Safe to run more than once.

# The whole script is wrapped in main() and only called on the last line, so a
# partially downloaded script (curl | bash) never runs half its steps.

set -euo pipefail

REPO_HOST="https://repo.45drives.com"
GPG_KEY_URL="$REPO_HOST/key/gpg.asc"
APT_KEYRING="/usr/share/keyrings/45drives-archive-keyring.gpg"
ARCHIVE_DIR="/opt/45drives/archives/repos"

CHANNEL="community"
# "testing" enables the testing stream alongside stable; the package manager
# then picks the newest build from either.
STREAM="stable"
REPO_ONLY=0
DRY_RUN=0

if [[ -t 1 ]]; then
  BOLD=$'\e[1m'; GREEN=$'\e[32m'; YELLOW=$'\e[33m'; RED=$'\e[31m'; RESET=$'\e[0m'
else
  BOLD=""; GREEN=""; YELLOW=""; RED=""; RESET=""
fi

step() { echo "${BOLD}==> $*${RESET}"; }
info() { echo "    $*"; }
warn() { echo "${YELLOW}warning:${RESET} $*" >&2; }
die()  { echo "${RED}error:${RESET} $*" >&2; exit 1; }

# Run a command, or only print it with --dry-run.
run() {
  if [[ $DRY_RUN -eq 1 ]]; then
    echo "    [dry-run] $*"
  else
    "$@"
  fi
}

# Write stdin to a file, or only print it with --dry-run.
write_file() {
  local path="$1"
  if [[ $DRY_RUN -eq 1 ]]; then
    echo "    [dry-run] would write $path:"
    sed 's/^/      /'
  else
    cat > "$path"
    info "wrote $path"
  fi
}

usage() {
  cat <<'USAGE'
Usage: setup.sh [options]

Adds the 45Drives package repository, installs Cockpit and the SnapShield
Cockpit plugin, and turns Cockpit on. The SnapShield setup wizard in Cockpit
does the rest.

Options:
  --community      use the 45Drives Community repository (default)
  --enterprise     use the 45Drives Enterprise repository
  --testing        also enable the testing stream, for pre-release builds
  --repo-only      set up the repository but do not install anything
  --dry-run        print what would be done without changing anything
  -h, --help       show this help

Supported: Rocky Linux / RHEL / AlmaLinux 8 and 9, Ubuntu 20.04 and 22.04.
USAGE
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --community)  CHANNEL="community" ;;
      --enterprise) CHANNEL="enterprise" ;;
      --testing)    STREAM="testing" ;;
      --repo-only)  REPO_ONLY=1 ;;
      --dry-run)    DRY_RUN=1 ;;
      -h|--help)    usage; exit 0 ;;
      *)            die "unknown option: $1 (see --help)" ;;
    esac
    shift
  done
}

# Sets OS_FAMILY (rhel|ubuntu), OS_VERSION (8|9 or focal|jammy) and OS_NAME.
detect_os() {
  [[ -r /etc/os-release ]] || die "cannot read /etc/os-release; unsupported operating system."
  # shellcheck disable=SC1091
  . /etc/os-release
  OS_NAME="${PRETTY_NAME:-$ID}"
  local id="${ID:-}" like="${ID_LIKE:-}"

  if [[ "$id" == "ubuntu" ]]; then
    OS_FAMILY="ubuntu"
    OS_VERSION="${VERSION_CODENAME:-}"
    case "$OS_VERSION" in
      focal|jammy) ;;
      *) die "$OS_NAME is not supported. SnapShield supports Ubuntu 20.04 (focal) and 22.04 (jammy)." ;;
    esac
  elif [[ "$id" =~ ^(rocky|rhel|almalinux|centos)$ || " $like " == *" rhel "* ]]; then
    OS_FAMILY="rhel"
    OS_VERSION="${VERSION_ID%%.*}"
    case "$OS_VERSION" in
      8|9) ;;
      *) die "$OS_NAME is not supported. SnapShield supports Rocky Linux / RHEL 8 and 9." ;;
    esac
  else
    die "$OS_NAME is not supported. SnapShield supports Rocky Linux / RHEL 8 and 9, and Ubuntu 20.04 and 22.04."
  fi
}

# The enterprise-premium repository is retired and no longer receives
# packages. Move any repository file that still points at it out of the way,
# the same way the 45Drives repository setup script archives obsolete files.
archive_retired_repos() {
  local dir=/etc/apt/sources.list.d files
  [[ $OS_FAMILY == rhel ]] && dir=/etc/yum.repos.d
  files=$(grep -l -s "repo.45drives.com/enterprise-premium" "$dir"/* 2>/dev/null || true)
  [[ -n "$files" ]] || return 0
  step "Archiving the retired 45Drives enterprise-premium repository"
  run mkdir -p "$ARCHIVE_DIR"
  local f
  for f in $files; do
    info "$f -> $ARCHIVE_DIR/$(basename "$f").$(date +%Y-%m-%d)"
    run mv "$f" "$ARCHIVE_DIR/$(basename "$f").$(date +%Y-%m-%d)"
  done
}

setup_repo_rhel() {
  local repo_file="/etc/yum.repos.d/45drives-$CHANNEL.repo"
  local testing_id="45drives_${CHANNEL}_testing"
  step "Adding the 45Drives ${CHANNEL^} repository ($STREAM)"

  local content
  content=$(curl -fsSL "$REPO_HOST/repofiles/rocky/45drives-$CHANNEL.repo") ||
    die "could not download $REPO_HOST/repofiles/rocky/45drives-$CHANNEL.repo"
  # The published repo file ships testing disabled; enable or disable that
  # one section to match the chosen stream.
  local want=0
  [[ $STREAM == testing ]] && want=1
  content=$(awk -v id="[$testing_id]" -v want="$want" '
    /^\[/ { in_section = ($0 == id) }
    in_section && /^[ \t]*enabled[ \t]*=/ { print "enabled = " want; next }
    { print }' <<<"$content")
  write_file "$repo_file" <<<"$content"

  run dnf -y -q makecache
}

setup_repo_ubuntu() {
  local list_file="/etc/apt/sources.list.d/45drives-$CHANNEL-$OS_VERSION.list"
  local components="main"
  [[ $STREAM == testing ]] && components="main testing"
  step "Adding the 45Drives ${CHANNEL^} repository ($STREAM)"

  export DEBIAN_FRONTEND=noninteractive
  run apt-get update -q
  run apt-get install -y -q ca-certificates curl gnupg

  info "installing the 45Drives signing key to $APT_KEYRING"
  if [[ $DRY_RUN -eq 0 ]]; then
    curl -fsSL "$GPG_KEY_URL" | gpg --batch --yes --dearmor -o "$APT_KEYRING" ||
      die "could not install the 45Drives signing key from $GPG_KEY_URL"
  else
    echo "    [dry-run] curl -fsSL $GPG_KEY_URL | gpg --dearmor -o $APT_KEYRING"
  fi

  write_file "$list_file" <<EOF
deb [arch=amd64 signed-by=$APT_KEYRING] $REPO_HOST/$CHANNEL/ubuntu $OS_VERSION $components
EOF
  run apt-get update -q
}

# Warn when the other channel is configured too, so it's clear which one
# packages may come from.
warn_other_channel() {
  local other=community dir=/etc/apt/sources.list.d
  [[ $CHANNEL == community ]] && other=enterprise
  [[ $OS_FAMILY == rhel ]] && dir=/etc/yum.repos.d
  if grep -q -s -r "repo.45drives.com/$other/" "$dir"; then
    warn "this server also has the 45Drives ${other^} repository configured; packages may come from either."
  fi
}

install_packages() {
  step "Installing Cockpit and the SnapShield Cockpit plugin"
  # The 45Drives repository carries a current Cockpit build for every
  # supported release. The plugin recommends the SnapShield service itself;
  # skip that here -- the setup wizard installs it after the operator reviews
  # the plan.
  if [[ $OS_FAMILY == rhel ]]; then
    run dnf -y install cockpit
    run dnf -y --setopt=install_weak_deps=False install cockpit-snapshield
  else
    run apt-get install -y -q cockpit
    run apt-get install -y -q --no-install-recommends cockpit-snapshield
  fi
}

enable_cockpit() {
  step "Turning on Cockpit"
  if [[ ! -d /run/systemd/system ]]; then
    warn "systemd is not running here, so Cockpit was not started. Start it with: systemctl enable --now cockpit.socket"
    return 0
  fi
  run systemctl enable --now cockpit.socket
  if command -v firewall-cmd >/dev/null 2>&1 && firewall-cmd --state >/dev/null 2>&1; then
    info "opening the Cockpit port (9090) in firewalld"
    run firewall-cmd --permanent --add-service=cockpit >/dev/null
    run firewall-cmd --reload >/dev/null
  elif command -v ufw >/dev/null 2>&1 && ufw status 2>/dev/null | grep -q "Status: active"; then
    info "opening the Cockpit port (9090) in ufw"
    run ufw allow 9090/tcp >/dev/null
  fi
}

finish() {
  local address
  address=$(hostname -I 2>/dev/null | awk '{print $1}')
  address=${address:-$(hostname)}
  echo
  if [[ $DRY_RUN -eq 1 ]]; then
    echo "${BOLD}Dry run complete -- nothing was changed.${RESET}"
    return
  fi
  echo "${GREEN}${BOLD}SnapShield setup is ready.${RESET}"
  if [[ $REPO_ONLY -eq 1 ]]; then
    echo "The 45Drives ${CHANNEL^} repository is set up. Install Cockpit and cockpit-snapshield when ready."
    return
  fi
  cat <<EOF

Next:
  1. Open https://$address:9090 and sign in with an administrator account.
  2. Turn on Administrative access (top of the page) if Cockpit shows Limited access.
  3. Choose Snapshield Dashboard in the menu and follow the setup wizard.

Guides: https://github.com/45Drives/SnapShield-public/tree/main/docs
EOF
}

main() {
  parse_args "$@"
  [[ $DRY_RUN -eq 1 || $EUID -eq 0 ]] || die "run this as root, for example: curl -sSL <url> | sudo bash"
  detect_os
  command -v curl >/dev/null 2>&1 || [[ $OS_FAMILY == ubuntu ]] ||
    die "curl is required. Install it with: dnf install -y curl"

  echo "${BOLD}SnapShield setup${RESET} -- $OS_NAME, 45Drives ${CHANNEL^} repository, $STREAM packages"
  [[ $DRY_RUN -eq 1 ]] && echo "(dry run: nothing will be changed)"

  archive_retired_repos
  if [[ $OS_FAMILY == rhel ]]; then setup_repo_rhel; else setup_repo_ubuntu; fi
  warn_other_channel
  if [[ $REPO_ONLY -eq 0 ]]; then
    install_packages
    enable_cockpit
  fi
  finish
}

main "$@"
