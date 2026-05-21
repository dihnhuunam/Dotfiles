#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$ROOT_DIR/lib/log.sh"

release_arch() {
  case "$(uname -m)" in
    x86_64) printf '%s\n' x86_64 ;;
    aarch64|arm64) printf '%s\n' arm64 ;;
    *) error "Unsupported architecture: $(uname -m)" >&2; return 1 ;;
  esac
}

warn_local_path() {
  case ":$PATH:" in
    *":$HOME/.local/bin:"*) ;;
    *) warn 'Add $HOME/.local/bin to your PATH to use Neovim and LazyGit.' ;;
  esac
}

install_neovim() (
  local arch tmp_dir install_dir=""
  arch="$(release_arch)"
  tmp_dir="$(mktemp -d)"
  trap 'rm -rf "$tmp_dir"; if [[ -n "$install_dir" ]]; then rm -rf "$install_dir"; fi' EXIT

  info "Installing Neovim from the official stable release..."
  curl -fL --retry 3 \
    "https://github.com/neovim/neovim/releases/download/stable/nvim-linux-${arch}.tar.gz" \
    -o "$tmp_dir/neovim.tar.gz"
  tar -xzf "$tmp_dir/neovim.tar.gz" -C "$tmp_dir"
  "$tmp_dir/nvim-linux-$arch/bin/nvim" --headless -u NONE -i NONE \
    '+lua assert(vim.fn.has("nvim-0.12") == 1, "Neovim newer than 0.11 is required")' +qa
  mkdir -p "$HOME/.local/opt" "$HOME/.local/bin"
  install_dir="$(mktemp -d "$HOME/.local/opt/neovim-stable.XXXXXX")"
  mv "$tmp_dir/nvim-linux-$arch" "$install_dir/nvim"
  ln -sfnT "$install_dir/nvim/bin/nvim" "$HOME/.local/bin/nvim"
  install_dir="" # Keep the validated installation after publishing the symlink.
  "$HOME/.local/bin/nvim" --version
  success "Neovim stable installed."
)

install_lazygit() (
  local arch
  arch="$(release_arch)"

  local release_url tag version tmp_dir
  info "Finding the latest LazyGit release..."
  release_url="$(curl -fsSL --retry 3 -o /dev/null -w '%{url_effective}' \
    https://github.com/jesseduffield/lazygit/releases/latest)"
  tag="${release_url##*/}"
  if [[ ! "$tag" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    error "Unexpected LazyGit release tag: $tag"
    return 1
  fi
  version="${tag#v}"

  tmp_dir="$(mktemp -d)"
  trap 'rm -rf "$tmp_dir"' EXIT

  info "Installing LazyGit $version from GitHub..."
  curl -fL --retry 3 \
    "https://github.com/jesseduffield/lazygit/releases/download/${tag}/lazygit_${version}_Linux_${arch}.tar.gz" \
    -o "$tmp_dir/lazygit.tar.gz"
  tar -xzf "$tmp_dir/lazygit.tar.gz" -C "$tmp_dir" lazygit
  chmod +x "$tmp_dir/lazygit"
  "$tmp_dir/lazygit" --version
  mkdir -p "$HOME/.local/bin"
  install -m 0755 "$tmp_dir/lazygit" "$HOME/.local/bin/lazygit"

  success "LazyGit installed at $HOME/.local/bin/lazygit."
)

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
  curl -fL --retry 3 "https://github.com/ClementTsang/bottom/releases/download/${version}/bottom_${version}-1_${arch}.deb" \
    -o "$tmp_dir/bottom.deb"
  chmod 0755 "$tmp_dir"
  chmod 0644 "$tmp_dir/bottom.deb"
  sudo apt install -y "$tmp_dir/bottom.deb"
  btm --version
)

nvim_packages=(
  git
  build-essential
  ripgrep
  fd-find
  tree-sitter-cli
  clangd
  python3-pylsp
  xclip
  wl-clipboard
  gdu
  python3
  python-is-python3
  nodejs
  npm
  curl
  ca-certificates
  tar
)

main() {
  if (( EUID == 0 )); then
    error "Run this script as your normal user so Neovim and LazyGit are installed for your account."
    return 1
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
  release_arch >/dev/null

  sudo -v
  info "Updating apt..."
  sudo apt update
  info "Installing Neovim dependencies..."
  sudo apt install -y "${nvim_packages[@]}"
  install_neovim
  install_lazygit
  install_bottom
  warn_local_path
  success "Neovim and its dependencies installed."
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  main "$@"
fi
