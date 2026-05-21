#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$ROOT_DIR/lib/log.sh"

install_dependencies() {
  local dependency
  for dependency in curl unzip fc-cache; do
    if ! command -v "$dependency" >/dev/null 2>&1; then
      info "Installing font prerequisites..."
      sudo apt update
      sudo apt install -y curl ca-certificates unzip fontconfig
      return
    fi
  done
}

install_font() (
  local font_name="JetBrainsMono" tmp_dir font_file
  local font_dir="$HOME/.local/share/fonts/JetBrainsMonoNerdFont"
  local -a font_files=()
  tmp_dir="$(mktemp -d)"
  trap 'rm -rf "$tmp_dir"' EXIT

  info "Downloading $font_name Nerd Font..."
  curl -fL --retry 3 \
    "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${font_name}.zip" \
    -o "$tmp_dir/font.zip"
  unzip -q "$tmp_dir/font.zip" -d "$tmp_dir/extracted"
  while IFS= read -r -d '' font_file; do
    font_files+=("$font_file")
  done < <(find "$tmp_dir/extracted" -type f \( -iname '*.ttf' -o -iname '*.otf' \) -print0)
  if (( ${#font_files[@]} == 0 )); then
    error "The downloaded archive contains no font files."
    return 1
  fi

  info "Installing ${#font_files[@]} font files..."
  mkdir -p "$font_dir"
  for font_file in "${font_files[@]}"; do
    install -m 0644 "$font_file" "$font_dir/$(basename "$font_file")"
  done
  info "Refreshing font cache..."
  fc-cache -f "$font_dir"
  success "$font_name Nerd Font installed at $font_dir."
)

main() {
  if (( EUID == 0 )); then
    error "Run this script as your normal user so fonts are installed for your account."
    return 1
  fi
  install_dependencies
  install_font
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  main "$@"
fi
