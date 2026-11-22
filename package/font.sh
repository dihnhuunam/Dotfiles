#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$ROOT_DIR/lib/log.sh"

FONT_NAME="JetBrainsMono"
FONT_DIR="$HOME/.local/share/fonts/JetBrainsMonoNerdFont"
FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${FONT_NAME}.zip"

install_dependencies() {
  local dependency
  local missing=false

  for dependency in curl unzip fc-cache; do
    if ! command -v "$dependency" >/dev/null 2>&1; then
      missing=true
      break
    fi
  done

  if [[ "$missing" == false ]]; then
    info "Font prerequisites already installed. Skipping."
    return 0
  fi

  info "Installing font prerequisites..."

  sudo apt update
  sudo apt install -y \
    curl \
    ca-certificates \
    unzip \
    fontconfig

  for dependency in curl unzip fc-cache; do
    if ! command -v "$dependency" >/dev/null 2>&1; then
      error "Missing dependency: $dependency"
      return 1
    fi
  done
}

font_installed() {
  [[ -d "$FONT_DIR" ]] || return 1

  local font_file

  while IFS= read -r -d '' font_file; do
    [[ -s "$font_file" ]] && return 0
  done < <(
    find "$FONT_DIR" -maxdepth 1 \
      -type f \
      \( -iname '*.ttf' -o -iname '*.otf' \) \
      -print0
  )

  return 1
}

install_font() (
  local tmp_dir
  local font_file
  local -a font_files=()

  tmp_dir="$(mktemp -d)"
  trap 'rm -rf "$tmp_dir"' EXIT

  info "Downloading $FONT_NAME Nerd Font..."

  curl -fL --retry 3 \
    "$FONT_URL" \
    -o "$tmp_dir/font.zip"

  info "Extracting font archive..."

  unzip -q "$tmp_dir/font.zip" \
    -d "$tmp_dir/extracted"

  while IFS= read -r -d '' font_file; do
    font_files+=("$font_file")
  done < <(
    find "$tmp_dir/extracted" \
      -type f \
      \( -iname '*.ttf' -o -iname '*.otf' \) \
      -print0
  )

  if (( ${#font_files[@]} == 0 )); then
    error "The downloaded archive contains no font files."
    return 1
  fi

  info "Installing ${#font_files[@]} font files..."

  mkdir -p "$FONT_DIR"

  for font_file in "${font_files[@]}"; do
    install -m 0644 \
      "$font_file" \
      "$FONT_DIR/$(basename "$font_file")"
  done

  info "Refreshing font cache..."

  fc-cache -f "$FONT_DIR"

  success "$FONT_NAME Nerd Font installed at $FONT_DIR."
)

main() {
  if (( EUID == 0 )); then
    error "Run this script as your normal user."
    return 1
  fi

  install_dependencies

  if font_installed; then
    info "$FONT_NAME Nerd Font already installed. Skipping."
    return 0
  fi

  install_font

  if ! font_installed; then
    error "$FONT_NAME Nerd Font installation verification failed."
    return 1
  fi

  success "$FONT_NAME Nerd Font setup complete."
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  main "$@"
fi
