#!/usr/bin/env bash

GREEN="\033[0;32m"
BLUE="\033[0;34m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
NC="\033[0m"

info() {
  printf "%b[INFO]%b %s\n" "$BLUE" "$NC" "$1"
}

success() {
  printf "%b[OK]%b %s\n" "$GREEN" "$NC" "$1"
}

warn() {
  printf "%b[WARN]%b %s\n" "$YELLOW" "$NC" "$1"
}

error() {
  printf "%b[ERROR]%b %s\n" "$RED" "$NC" "$1"
}
