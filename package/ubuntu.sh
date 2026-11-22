#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$ROOT_DIR/lib/log.sh"

apt_install() {
  sudo apt install -y "$@"
}

install_group() {
  local label="$1"
  shift
  info "Installing $label..."
  apt_install "$@"
  success "$label installed."
}

basic_packages=(
  git
  gh
  unzip
  zip
  tar
  stow
  zsh
  wget
  curl
  gpg
  ca-certificates
  fontconfig
  openssh-server
  open-vm-tools
  open-vm-tools-desktop
  sqlitebrowser
)

useful_packages=(
  neofetch
  fzf
  tree
  htop
  ibus-unikey
  cloud-guest-utils
  gparted
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
  clang-format
  clang-tidy
  lldb
  cppcheck
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

pcl_packages=(
  libpcl-dev
)

python_packages=(
  python3
  python3-pip
  python3-venv
  pipx
)

main() {
  if [[ ! -r /etc/os-release ]]; then
    error "Cannot detect the operating system; this script requires Ubuntu."
    return 1
  fi
  local ID
  # shellcheck disable=SC1091
  . /etc/os-release
  if [[ "${ID:-}" != "ubuntu" ]]; then
    error "This script requires Ubuntu; detected ${ID:-unknown}."
    return 1
  fi
  if (( EUID == 0 )); then
    error "Run this script as your normal user with sudo available, so pipx installs tools for you."
    return 1
  fi

  sudo -v
  info "Updating apt..."
  sudo apt update
  success "Apt package index updated."

  install_group "Basic tools" "${basic_packages[@]}"
  install_group "Useful tools" "${useful_packages[@]}"
  install_group "C/C++ development packages" "${cpp_packages[@]}"
  install_group "Qt runtime/helper packages" "${qt_runtime_packages[@]}"
  install_group "OpenGL development packages" "${opengl_packages[@]}"
  install_group "Boost library packages" "${boost_packages[@]}"
  install_group "Point Cloud Library development packages" "${pcl_packages[@]}"
  install_group "Python development packages" "${python_packages[@]}"
  success "All packages installed successfully."
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  main "$@"
fi
