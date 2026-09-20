#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$ROOT_DIR/lib/log.sh"

install_bottom() (
  if command -v btm >/dev/null 2>&1; then
    info "bottom is already installed. Skipping."
    return
  fi

  # Official Debian packages: https://github.com/ClementTsang/bottom
  local version="0.14.9"
  local arch
  arch="$(dpkg --print-architecture)"
  case "$arch" in
    amd64|arm64|armhf) ;;
    *) error "Unsupported architecture for bottom: $arch"; return 1 ;;
  esac

  local tmp_dir
  tmp_dir="$(mktemp -d)"
  trap 'rm -rf "$tmp_dir"' EXIT

  info "Installing bottom..."
  curl -fL "https://github.com/ClementTsang/bottom/releases/download/${version}/bottom_${version}-1_${arch}.deb" \
    -o "$tmp_dir/bottom.deb"
  sudo apt install -y "$tmp_dir/bottom.deb"
)

nvim_packages=(
  neovim
  git
  build-essential
  ripgrep
  fd-find
  tree-sitter-cli
  clangd
  python3-pylsp
  xclip
  wl-clipboard
  lazygit
  gdu
  python3
  python-is-python3
  nodejs
  npm
  curl
  ca-certificates
)

info "Updating apt..."
sudo apt update

info "Installing Neovim and its dependencies..."
sudo apt install -y "${nvim_packages[@]}"
install_bottom
success "Neovim and its dependencies installed."
