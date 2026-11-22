
#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# shellcheck source=../lib/log.sh
source "$ROOT_DIR/lib/log.sh"

readonly LLVM_VERSION=22

readonly KEYRING_DIR="/usr/share/keyrings"
readonly SOURCES_DIR="/etc/apt/sources.list.d"

readonly KITWARE_KEY_FINGERPRINT="4DBEBE3EEC96E7B8C6EC5BE99E92FDC6C5B9BA75"
readonly LLVM_KEY_FINGERPRINT="6084F3CF814B57C1CF12EFD515CF4D18AF4F7421"

# ============================================================
# APT helpers
# ============================================================

apt_install() {
  sudo apt-get install -y "$@"
}

install_group() {
  local label="$1"
  shift

  info "Installing $label..."
  apt_install "$@"
  success "$label installed."
}

check_ubuntu() {
  if [[ ! -r /etc/os-release ]]; then
    error "Cannot detect the operating system."
    return 1
  fi

  # shellcheck disable=SC1091
  . /etc/os-release

  if [[ "${ID:-}" != "ubuntu" ]]; then
    error "This script requires Ubuntu; detected ${ID:-unknown}."
    return 1
  fi

  case "${VERSION_CODENAME:-}" in
    jammy|noble)
      info "Detected Ubuntu ${VERSION_ID} (${VERSION_CODENAME})."
      ;;
    *)
      error "Unsupported Ubuntu release: ${VERSION_CODENAME:-unknown}."
      return 1
      ;;
  esac

  if (( EUID == 0 )); then
    error "Run this script as your normal user with sudo available."
    return 1
  fi
}

# ============================================================
# Repository helpers
# ============================================================

install_repository_key() {
  local url="$1"
  local fingerprint="$2"
  local destination="$3"

  local tmp_dir
  local actual_fingerprint

  tmp_dir="$(mktemp -d)"

  if ! curl -fsSL "$url" -o "$tmp_dir/key.asc"; then
    rm -rf "$tmp_dir"
    error "Failed to download repository signing key."
    return 1
  fi

  actual_fingerprint="$(
    gpg --show-keys \
      --with-colons \
      --fingerprint \
      "$tmp_dir/key.asc" 2>/dev/null |
      awk -F: '$1 == "fpr" {print toupper($10); exit}'
  )"

  if [[ "$actual_fingerprint" != "$fingerprint" ]]; then
    rm -rf "$tmp_dir"
    error "Repository signing key fingerprint mismatch."
    return 1
  fi

  if ! gpg --batch --yes --dearmor \
    -o "$tmp_dir/key.gpg" "$tmp_dir/key.asc"; then
    rm -rf "$tmp_dir"
    error "Failed to convert repository signing key."
    return 1
  fi

  sudo install -m 0644 \
    "$tmp_dir/key.gpg" "$destination"

  rm -rf "$tmp_dir"
}

write_repository() {
  local destination="$1"
  local entry="$2"

  if [[ -f "$destination" ]]; then
    if [[ "$(<"$destination")" == "$entry" ]]; then
      info "Repository already configured: $destination"
      return 0
    fi

    error "Repository file already exists with different contents: $destination"
    return 1
  fi

  printf '%s\n' "$entry" |
    sudo tee "$destination" >/dev/null
}

# ============================================================
# Kitware APT Repository
# ============================================================

setup_kitware_repository() {
  local codename="$VERSION_CODENAME"

  local keyring="$KEYRING_DIR/kitware-archive-keyring.gpg"
  local source_file="$SOURCES_DIR/kitware.list"

  local repo_entry="deb [signed-by=$keyring] https://apt.kitware.com/ubuntu/ $codename main"

  info "Setting up Kitware APT repository..."

  if [[ ! -f "$keyring" ]]; then
    install_repository_key \
      "https://apt.kitware.com/keys/kitware-archive-latest.asc" \
      "$KITWARE_KEY_FINGERPRINT" \
      "$keyring"
  fi

  write_repository "$source_file" "$repo_entry"

  success "Kitware repository configured."
}

# ============================================================
# LLVM APT Repository
# ============================================================

setup_llvm_repository() {
  local codename="$VERSION_CODENAME"

  local keyring="$KEYRING_DIR/llvm-archive-keyring.gpg"
  local source_file="$SOURCES_DIR/llvm.list"

  local repo_entry="deb [signed-by=$keyring] https://apt.llvm.org/$codename/ llvm-toolchain-$codename-$LLVM_VERSION main"

  info "Setting up LLVM APT repository..."

  if [[ ! -f "$keyring" ]]; then
    install_repository_key \
      "https://apt.llvm.org/llvm-snapshot.gpg.key" \
      "$LLVM_KEY_FINGERPRINT" \
      "$keyring"
  fi

  write_repository "$source_file" "$repo_entry"

  success "LLVM repository configured."
}

# ============================================================
# Package groups
# ============================================================

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
  # Build tools
  build-essential
  cmake
  ninja-build
  pkg-config
  ccache

  # Debugging and analysis
  gdb
  valgrind
  cppcheck

  # LLVM toolchain
  "clang-${LLVM_VERSION}"
  "clang-format-${LLVM_VERSION}"
  "clang-tidy-${LLVM_VERSION}"
  "clangd-${LLVM_VERSION}"
  "lldb-${LLVM_VERSION}"
  "lld-${LLVM_VERSION}"
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

# ============================================================
# Version verification
# ============================================================

verify_tools() {
  info "Verifying installed development tools..."

  cmake --version | head -n 1
  "clang-${LLVM_VERSION}" --version | head -n 1
  "clang-format-${LLVM_VERSION}" --version
  "clang-tidy-${LLVM_VERSION}" --version | head -n 1
  "clangd-${LLVM_VERSION}" --version | head -n 1

  success "Development tools verified."
}

# ============================================================
# Main
# ============================================================

main() {
  check_ubuntu

  sudo -v

  info "Updating Ubuntu APT package index..."
  sudo apt-get update

  # Repository prerequisites
  apt_install ca-certificates gpg wget curl

  # Configure repositories
  setup_kitware_repository
  setup_llvm_repository

  # Refresh APT after adding repositories
  info "Updating APT package index..."
  sudo apt-get update

  # Install package groups
  install_group "Basic tools" "${basic_packages[@]}"
  install_group "Useful tools" "${useful_packages[@]}"
  install_group "C/C++ development packages" "${cpp_packages[@]}"
  install_group "Qt runtime/helper packages" "${qt_runtime_packages[@]}"
  install_group "OpenGL development packages" "${opengl_packages[@]}"
  install_group "Boost library packages" "${boost_packages[@]}"
  install_group "Point Cloud Library packages" "${pcl_packages[@]}"
  install_group "Python development packages" "${python_packages[@]}"

  # Verify installations
  verify_tools

  success "All packages installed successfully."
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  main "$@"
fi
