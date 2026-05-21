#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$ROOT_DIR/lib/log.sh"

configure_repository() (
  local tmp_dir
  tmp_dir="$(mktemp -d)"
  trap 'rm -rf "$tmp_dir"' EXIT

  info "Adding the official WezTerm apt repository..."
  curl -fsSL --retry 3 https://apt.fury.io/wez/gpg.key -o "$tmp_dir/wezterm.asc"
  gpg --batch --yes --dearmor -o "$tmp_dir/wezterm.gpg" "$tmp_dir/wezterm.asc"
  printf '%s\n' 'deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' \
    > "$tmp_dir/wezterm.list"
  sudo install -d -m 0755 /usr/share/keyrings /etc/apt/sources.list.d
  sudo install -m 0644 "$tmp_dir/wezterm.gpg" /usr/share/keyrings/wezterm-fury.gpg
  sudo install -m 0644 "$tmp_dir/wezterm.list" /etc/apt/sources.list.d/wezterm.list
)

main() {
  if command -v wezterm >/dev/null 2>&1; then
    info "WezTerm already installed. Skipping."
    return
  fi

  if [[ ! -r /etc/os-release ]]; then
    error "Cannot detect the operating system; this installer requires Ubuntu or Debian."
    return 1
  fi
  local ID
  # shellcheck disable=SC1091
  . /etc/os-release
  case "${ID:-}" in
    ubuntu|debian) ;;
    *) error "Unsupported distribution: ${ID:-unknown}"; return 1 ;;
  esac

  sudo -v
  info "Installing repository prerequisites..."
  sudo apt update
  sudo apt install -y curl ca-certificates gpg
  configure_repository

  info "Installing WezTerm..."
  sudo apt update
  sudo apt install -y wezterm
  wezterm --version
  success "WezTerm installed."
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  main "$@"
fi
