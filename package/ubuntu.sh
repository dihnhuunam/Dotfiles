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

package_available() {
  apt-cache policy "$1" | awk '
    /Candidate:/ { available = ($2 != "(none)") }
    END { exit !available }
  '
}

install_glab() {
  info "Installing GitLab CLI..."

  if package_available glab; then
    apt_install glab
  else
    info "GitLab CLI is unavailable via apt; installing via snap..."
    apt_install snapd
    sudo snap install glab
  fi
}

install_python_tools() {
  info "Installing Python tools via pipx..."

  python3 -m pipx ensurepath
  python3 -m pipx install cmakelang

  success "Python tools installed."
}

install_ibus_bamboo() {
  info "Installing IBus Bamboo..."
  # Official Ubuntu instructions: https://github.com/BambooEngine/ibus-bamboo
  if ! package_available ibus-bamboo; then
    apt_install software-properties-common
    sudo add-apt-repository -y --no-update ppa:bamboo-engine/ibus-bamboo
    sudo apt update
    if ! package_available ibus-bamboo; then
      error "IBus Bamboo has no apt candidate for this Ubuntu release or architecture."
      return 1
    fi
  fi
  apt_install --install-recommends ibus ibus-bamboo
  success "IBus Bamboo installed. Log out and back in, then add Vietnamese (Bamboo) in your input source settings."
}

configure_docker_group() {
  local account_name account_groups
  account_name="$(id -un)"
  if ! getent group docker >/dev/null; then
    sudo groupadd docker
  fi
  account_groups="$(id -nG "$account_name")"
  case " $account_groups " in
    *' docker '*) info "$account_name is already in the docker group." ;;
    *)
      info "Adding $account_name to the docker group..."
      sudo usermod -aG docker "$account_name"
      ;;
  esac
  info "Log out and back in to refresh group membership, then run: docker run --rm hello-world"
}

install_docker() (
  local ID="" VERSION_CODENAME="" UBUNTU_CODENAME="" codename arch tmp_dir
  # shellcheck disable=SC1091
  . /etc/os-release
  codename="${UBUNTU_CODENAME:-$VERSION_CODENAME}"
  if [[ "$ID" != ubuntu || -z "$codename" ]]; then
    error "Docker installation requires Ubuntu with a release codename."
    return 1
  fi
  arch="$(dpkg --print-architecture)"

  local package status
  local -a conflicts=()
  for package in docker.io docker-compose docker-compose-v2 docker-doc docker-buildx podman-docker containerd runc; do
    status="$(dpkg-query -W -f='${Status}' "$package" 2>/dev/null || true)"
    if [[ "$status" == 'install ok installed' ]]; then
      conflicts+=("$package")
    fi
  done
  if (( ${#conflicts[@]} )); then
    error "Resolve conflicting packages before installing Docker CE: ${conflicts[*]}"
    return 1
  fi

  info "Configuring Docker's official Ubuntu repository..."
  apt_install ca-certificates curl gpg
  tmp_dir="$(mktemp -d)"
  trap 'rm -rf "$tmp_dir"' EXIT
  curl -fsSL --retry 3 https://download.docker.com/linux/ubuntu/gpg -o "$tmp_dir/docker.asc"
  gpg --batch --show-keys "$tmp_dir/docker.asc" >/dev/null
  printf '%s\n' \
    'Types: deb' \
    'URIs: https://download.docker.com/linux/ubuntu' \
    "Suites: $codename" \
    'Components: stable' \
    "Architectures: $arch" \
    'Signed-By: /etc/apt/keyrings/docker.asc' > "$tmp_dir/docker.sources"
  sudo install -d -m 0755 /etc/apt/keyrings /etc/apt/sources.list.d
  sudo install -m 0644 "$tmp_dir/docker.asc" /etc/apt/keyrings/docker.asc
  sudo install -m 0644 "$tmp_dir/docker.sources" /etc/apt/sources.list.d/docker.sources
  sudo apt update
  install_group "Docker Engine, Compose, and Buildx" \
    docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  if [[ -d /run/systemd/system ]]; then
    sudo systemctl enable --now docker.service
  fi
  docker --version
  docker compose version
  docker buildx version
  configure_docker_group
  success "Docker installed. Verify the daemon with: sudo docker run --rm hello-world"
)

install_system_info() {
  local package
  for package in fastfetch neofetch; do
    if package_available "$package"; then
      install_group "system information tool" "$package"
      return
    fi
  done
  warn "Neither fastfetch nor neofetch is available; skipping system information tool."
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
  jq
  rsync
  shellcheck
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

python_packages=(
  python3
  python3-pip
  python3-dev
  python3-venv
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

pcl_packages=(
  libpcl-dev
)

vmware_packages=(
  open-vm-tools
  open-vm-tools-desktop
)

ssh_packages=(
  openssh-server
  openssh-sftp-server
)

useful_packages=(
  fzf
  tree
  htop
  ibus-unikey
  cloud-guest-utils
  gparted
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

  install_group "basic tools" "${basic_packages[@]}"
  install_glab
  install_docker
  install_group "C/C++ development packages" "${cpp_packages[@]}"
  install_group "Python development packages" "${python_packages[@]}"
  install_python_tools
  install_group "Qt runtime/helper packages" "${qt_runtime_packages[@]}"
  install_group "OpenGL development packages" "${opengl_packages[@]}"
  install_group "Boost library packages" "${boost_packages[@]}"
  install_group "Point Cloud Library development packages" "${pcl_packages[@]}"
  install_group "useful tools" "${useful_packages[@]}"
  install_ibus_bamboo
  install_system_info
  install_group "VMware guest tools" "${vmware_packages[@]}"
  install_group "SSH and SFTP servers" "${ssh_packages[@]}"
  success "All packages installed successfully."
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  main "$@"
fi
