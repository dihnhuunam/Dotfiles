#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$ROOT_DIR/lib/log.sh"

apt_install() {
  sudo apt install -y "$@"
}

install_glab() {
  info "Installing GitLab CLI..."

  if [[ ! -f /etc/os-release ]]; then
    warn "Cannot detect OS version: skip glab auto-install."
    return
  fi

  # shellcheck disable=SC1091
  . /etc/os-release

  if [[ "${ID:-}" != "ubuntu" ]]; then
    warn "Non-Ubuntu distro detected: skip glab auto-install."
    return
  fi

  if dpkg --compare-versions "${VERSION_ID:-0}" ge "24.04"; then
    info "Ubuntu $VERSION_ID detected: installing glab via apt..."
    apt_install glab
  else
    info "Ubuntu $VERSION_ID detected: installing glab via snap..."
    apt_install snapd
    sudo snap install glab
  fi
}

install_python_tools() {
  info "Installing Python tools via pipx..."

  if ! command -v pipx >/dev/null 2>&1; then
    # apt_install pipx
    python3 -m pipx ensurepath
  fi

  pipx install cmakelang

  success "Python tools installed."
}

basic_packages=(
  git
  gh
  curl
  wget
  unzip
  zip
  tar
  ca-certificates
  gpg
  fontconfig
  stow
  zsh
)

cpp_packages=(
  build-essential
  cmake
  ninja-build
  pkg-config
  ccache
  gdb
  valgrind
  clang
  clangd
  clang-format
  clang-tidy
  lldb
  cppcheck
)

python_packages=(
  python3
  python3-full
  python3-pip
  python3-dev
  python3-venv
  python3-pylsp
  pipx
)

qt_runtime_packages=(
  libxcb-cursor0
  libxcb-cursor-dev
)

opengl_packages=(
  libgl1-mesa-dev
  libglu1-mesa-dev
  mesa-common-dev
  mesa-utils
  freeglut3-dev
  libglfw3-dev
  libglew-dev
  libftgl-dev
)

boost_packages=(
  libboost-all-dev
)

useful_packages=(
  ripgrep
  fd-find
  fzf
  tree
  htop
  neovim
  tree-sitter-cli
  fastfetch
  ibus-unikey
  cloud-guest-utils
  gparted
  open-vm-tools
  open-vm-tools-desktop
  openssh-server
)

info "Updating apt..."
sudo apt update
success "Apt package index updated."

info "Installing basic tools..."
apt_install "${basic_packages[@]}"
install_glab
success "Basic tools installed."

info "Installing C/C++ development packages..."
apt_install "${cpp_packages[@]}"
success "C/C++ development packages installed."

info "Installing Python development packages..."
apt_install "${python_packages[@]}"
install_python_tools
success "Python development packages installed."

info "Installing Qt runtime/helper packages..."
apt_install "${qt_runtime_packages[@]}"
success "Qt runtime/helper packages installed."

info "Installing OpenGL/GLU/GLUT/GLFW/GLEW packages..."
apt_install "${opengl_packages[@]}"
success "OpenGL/GLU/GLUT/GLFW/GLEW packages installed."

info "Installing Boost library packages..."
apt_install "${boost_packages[@]}"
success "Boost library packages installed."

info "Installing useful tools..."
apt_install "${useful_packages[@]}"
success "Useful tools installed."

success "All packages installed successfully."
