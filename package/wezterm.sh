#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$ROOT_DIR/lib/log.sh"

configure_repository() (
  local tmp_dir
  tmp_dir="$(mktemp -d)"
  trap 'rm -rf "$tmp_dir"' EXIT

  info "Adding the WezTerm apt repository..."

  curl -fsSL --retry 3 \
    https://apt.fury.io/wez/gpg.key \
    -o "$tmp_dir/wezterm.asc"

  gpg --batch --yes --dearmor \
    -o "$tmp_dir/wezterm.gpg" \
    "$tmp_dir/wezterm.asc"

  printf '%s\n' \
    'deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' \
    > "$tmp_dir/wezterm.list"

  sudo install -d -m 0755 \
    /usr/share/keyrings \
    /etc/apt/sources.list.d

  sudo install -m 0644 \
    "$tmp_dir/wezterm.gpg" \
    /usr/share/keyrings/wezterm-fury.gpg

  sudo install -m 0644 \
    "$tmp_dir/wezterm.list" \
    /etc/apt/sources.list.d/wezterm.list
)

install_dependencies() {
  info "Installing WezTerm prerequisites..."

  sudo apt update
  sudo apt install -y \
    curl \
    ca-certificates \
    gpg
}

install_wezterm() {
  if command -v wezterm >/dev/null 2>&1; then
    info "WezTerm already installed. Skipping installation."
    return 0
  fi

  install_dependencies
  configure_repository

  info "Installing WezTerm..."

  sudo apt update
  sudo apt install -y wezterm

  wezterm --version
  success "WezTerm installed."
}

gnome_available() {
  if [[ "${XDG_CURRENT_DESKTOP:-}" != *GNOME* ]]; then
    warn "GNOME not detected. Skipping shortcut configuration."
    return 1
  fi

  if ! command -v gsettings >/dev/null 2>&1; then
    warn "gsettings not available."
    return 1
  fi

  if [[ -z "${DBUS_SESSION_BUS_ADDRESS:-}" ]]; then
    warn "No desktop D-Bus session available."
    return 1
  fi

  return 0
}

configure_shortcut() {
  local schema="org.gnome.settings-daemon.plugins.media-keys"
  local path="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/wezterm/"
  local key_schema="${schema}.custom-keybinding:${path}"
  local shortcuts
  local wezterm_path

  wezterm_path="$(command -v wezterm)"

  info "Configuring Ctrl+Alt+T for WezTerm..."

  # Disable the default GNOME terminal shortcut if available.
  if gsettings list-keys "$schema" | grep -Fxq "terminal"; then
    gsettings set "$schema" terminal "[]"
  fi

  # Configure the custom shortcut.
  gsettings set "$key_schema" name "WezTerm"
  gsettings set "$key_schema" command "$wezterm_path start"
  gsettings set "$key_schema" binding "<Primary><Alt>t"

  # Preserve existing shortcuts and avoid duplicates.
  shortcuts="$(gsettings get "$schema" custom-keybindings)"

  if [[ "$shortcuts" != *"'$path'"* ]]; then
    if [[ "$shortcuts" == "@as []" || "$shortcuts" == "[]" ]]; then
      shortcuts="['$path']"
    else
      shortcuts="${shortcuts%]}"
      shortcuts="${shortcuts}, '$path']"
    fi

    gsettings set "$schema" custom-keybindings "$shortcuts"
  fi

  success "Ctrl+Alt+T configured for WezTerm."
}

verify_shortcut() {
  local schema="org.gnome.settings-daemon.plugins.media-keys"
  local path="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/wezterm/"
  local key_schema="${schema}.custom-keybinding:${path}"

  local binding
  local command_value
  local shortcuts
  local expected_command

  expected_command="$(command -v wezterm) start"

  binding="$(gsettings get "$key_schema" binding)"
  command_value="$(gsettings get "$key_schema" command)"
  shortcuts="$(gsettings get "$schema" custom-keybindings)"

  # Verify keyboard binding.
  if [[ "$binding" != "'<Primary><Alt>t'" ]]; then
    error "Invalid WezTerm shortcut binding: $binding"
    return 1
  fi

  # Verify executable command.
  if [[ "$command_value" != "'$expected_command'" ]]; then
    error "Invalid WezTerm shortcut command: $command_value"
    return 1
  fi

  # Verify shortcut registration.
  if [[ "$shortcuts" != *"'$path'"* ]]; then
    error "WezTerm shortcut is not registered."
    return 1
  fi

  success "WezTerm shortcut verified."
}

main() {
  if (( EUID == 0 )); then
    error "Run this script as your normal user."
    return 1
  fi

  if [[ ! -r /etc/os-release ]]; then
    error "Cannot detect the operating system."
    return 1
  fi

  local ID
  # shellcheck disable=SC1091
  . /etc/os-release

  case "${ID:-}" in
    ubuntu|debian) ;;
    *)
      error "Unsupported distribution: ${ID:-unknown}"
      return 1
      ;;
  esac

  # Step 1: Install WezTerm if needed.
  install_wezterm

  # Step 2: Configure shortcut for GNOME.
  if gnome_available; then
    configure_shortcut
    verify_shortcut
  fi

  success "WezTerm setup complete."
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  main "$@"
fi
