#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$ROOT_DIR/lib/log.sh"

install_dependencies() {
  local dependency
  for dependency in zsh git curl chsh getent; do
    if ! command -v "$dependency" >/dev/null 2>&1; then
      info "Installing Zsh prerequisites..."
      sudo apt update
      sudo apt install -y zsh git curl ca-certificates passwd libc-bin
      return
    fi
  done
}

install_oh_my_zsh() (
  local zsh_dir="$1" tmp_dir
  if [[ -d "$zsh_dir" ]]; then
    info "Oh My Zsh already installed. Skipping."
    return
  fi

  tmp_dir="$(mktemp -d)"
  trap 'rm -rf "$tmp_dir"' EXIT
  info "Installing Oh My Zsh..."
  curl -fsSL --retry 3 \
    https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh \
    -o "$tmp_dir/install.sh"
  ZSH="$zsh_dir" RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh "$tmp_dir/install.sh" --unattended
)

install_plugin() {
  local name="$1" destination="$2"
  if [[ -d "$destination" ]]; then
    info "$name already installed. Skipping."
    return
  fi
  info "Installing $name..."
  git clone --depth 1 "https://github.com/zsh-users/${name}.git" "$destination"
}

set_default_shell() {
  local zsh_path account_shell account_name
  zsh_path="$(command -v zsh)"
  account_name="$(id -un)"
  account_shell="$(getent passwd "$account_name" | cut -d: -f7)"
  if [[ -z "$account_shell" ]]; then
    error "Cannot determine the login shell for $account_name."
    return 1
  fi
  if [[ "$account_shell" == "$zsh_path" || "$account_shell" -ef "$zsh_path" ]]; then
    info "Default shell is already Zsh. Skipping."
    return
  fi
  if ! grep -Fxq "$zsh_path" /etc/shells; then
    error "Zsh is not listed in /etc/shells: $zsh_path"
    return 1
  fi
  info "Changing default shell to Zsh (chsh may request your password)..."
  chsh -s "$zsh_path"
}

main() {
  if (( EUID == 0 )); then
    error "Run this script as your normal user so Zsh is configured for your account."
    return 1
  fi
  install_dependencies

  local zsh_dir="${ZSH:-$HOME/.oh-my-zsh}"
  local custom_dir="${ZSH_CUSTOM:-$zsh_dir/custom}"
  install_oh_my_zsh "$zsh_dir"
  mkdir -p "$custom_dir/plugins"
  install_plugin zsh-syntax-highlighting "$custom_dir/plugins/zsh-syntax-highlighting"
  install_plugin zsh-autosuggestions "$custom_dir/plugins/zsh-autosuggestions"
  set_default_shell
  success "Zsh setup complete. Log out and back in to use your new login shell."
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  main "$@"
fi
