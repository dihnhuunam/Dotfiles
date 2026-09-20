#!/usr/bin/env bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/lib/log.sh"

run_script() {
  local script_path="$1"

  if [[ -x "$script_path" ]]; then
    "$script_path"
  elif [[ -f "$script_path" ]]; then
    bash "$script_path"
  else
    error "Script not found: $script_path"
    exit 1
  fi
}

stow_package() {
  local package_name="$1"

  if [[ -d "$SCRIPT_DIR/$package_name" ]]; then
    if stow --dir "$SCRIPT_DIR" --target "$HOME" "$package_name"; then
      success "$package_name config linked."
    else
      error "Failed to link $package_name config."
      return 1
    fi
  else
    warn "Stow package not found: $SCRIPT_DIR/$package_name"
  fi
}

info "Installing Ubuntu packages..."
run_script "$SCRIPT_DIR/package/ubuntu.sh"

info "Restarting IBus..."
if command -v ibus >/dev/null 2>&1; then
  ibus restart || warn "IBus restart failed. You may need to log out and log in again."
else
  warn "IBus is not installed."
fi

info "Installing Fonts..."
run_script "$SCRIPT_DIR/package/font.sh"

info "Installing Zsh..."
run_script "$SCRIPT_DIR/package/zsh.sh"

info "Installing WezTerm..."
run_script "$SCRIPT_DIR/package/wezterm.sh"

info "Setting WezTerm as default terminal..."

if command -v gsettings >/dev/null 2>&1 && command -v wezterm >/dev/null 2>&1; then
  if gsettings writable org.gnome.desktop.default-applications.terminal exec >/dev/null 2>&1; then
    gsettings set org.gnome.desktop.default-applications.terminal exec wezterm
    gsettings set org.gnome.desktop.default-applications.terminal exec-arg ''
    success "WezTerm terminal preference was updated."
  else
    warn "GNOME terminal setting is not available on this desktop environment."
  fi
else
  warn "Cannot set default terminal automatically. gsettings or wezterm not found."
fi

info "Linking config files with stow..."
mkdir -p "$HOME/.config"
info "Removing existing .zshrc..."
rm -f "$HOME/.zshrc"
stow_package "zsh"
stow_package "wezterm"
stow_package "nvim"

success "Done. Please restart the terminal."
