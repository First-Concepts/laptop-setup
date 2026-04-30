#!/usr/bin/env bash

set -euo pipefail

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "This setup script is intended for macOS only." >&2
  exit 1
fi

log() {
  printf "\n==> %s\n" "$1"
}

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

ensure_homebrew() {
  if command_exists brew; then
    log "Homebrew is already installed"
  else
    log "Installing Homebrew"
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi

  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
}

brew_install_formula() {
  local formula="$1"

  if brew list --formula "$formula" >/dev/null 2>&1; then
    log "$formula is already installed"
  else
    log "Installing $formula"
    brew install "$formula"
  fi
}

brew_install_cask() {
  local cask="$1"

  if brew list --cask "$cask" >/dev/null 2>&1; then
    log "$cask is already installed"
  else
    log "Installing $cask"
    brew install --cask "$cask"
  fi
}

install_bun() {
  if command_exists bun; then
    log "Bun is already installed"
  else
    log "Installing Bun"
    brew install oven-sh/bun/bun
  fi
}

install_graphite_cli() {
  if command_exists gt; then
    log "Graphite CLI is already installed"
  else
    log "Installing Graphite CLI"
    brew install withgraphite/tap/graphite
  fi
}

install_claude_code() {
  if command_exists claude; then
    log "Claude Code is already installed"
  else
    log "Installing Claude Code"
    curl -fsSL https://claude.ai/install.sh | bash
  fi
}

main() {
  ensure_homebrew

  log "Updating Homebrew"
  brew update

  brew_install_cask "google-chrome"
  brew_install_cask "1password"
  brew_install_cask "slack"
  brew_install_formula "1password-cli"
  brew_install_formula "gh"
  install_graphite_cli
  install_bun
  brew_install_cask "cursor"
  install_claude_code

  log "Setup complete"
  echo "Open Chrome, 1Password, Slack, Cursor, and Claude Code to finish any sign-in prompts."
  echo "Run 'gh auth login' and 'gt auth login' to authenticate the GitHub and Graphite CLIs."
  echo "If this is your first Homebrew install, restart your terminal so PATH changes are available everywhere."
}

main "$@"
