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

configure_zshrc_for_nvm() {
  local zshrc="$HOME/.zshrc"
  local nvm_dir_line='export NVM_DIR="$HOME/.nvm"'
  local nvm_source_line='[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"'

  touch "$zshrc"

  if grep -Fxq "$nvm_dir_line" "$zshrc" && grep -Fxq "$nvm_source_line" "$zshrc"; then
    log "nvm is already configured in ~/.zshrc"
  else
    log "Configuring nvm in ~/.zshrc"
    {
      printf "\n"
      printf "%s\n" "$nvm_dir_line"
      printf "%s\n" "$nvm_source_line"
    } >>"$zshrc"
  fi

  log "Sourcing ~/.zshrc"
  zsh -lc "source '$zshrc'"
}

install_node_with_nvm() {
  export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"

  if [[ ! -s "$NVM_DIR/nvm.sh" ]]; then
    log "Installing nvm"
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash
  else
    log "nvm is already installed"
  fi

  if [[ ! -s "$NVM_DIR/nvm.sh" ]]; then
    echo "nvm installed, but $NVM_DIR/nvm.sh was not found." >&2
    exit 1
  fi

  # nvm is a shell function, so it needs to be sourced before use in this script.
  # shellcheck source=/dev/null
  . "$NVM_DIR/nvm.sh"

  log "Installing Node.js 24 with nvm"
  nvm install 24 --default
  nvm use 24
  configure_zshrc_for_nvm
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

start_configured_zsh() {
  if [[ -t 0 && -t 1 ]]; then
    log "Starting zsh with ~/.zshrc loaded"
    echo "Type 'exit' to return to the shell that launched this setup script."
    exec zsh -l
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
  install_node_with_nvm
  install_bun
  brew_install_cask "cursor"
  install_claude_code

  log "Setup complete"
  echo "Open Chrome, 1Password, Slack, Cursor, and Claude Code to finish any sign-in prompts."
  echo "Node.js 24 was installed through nvm and set as the default Node.js version."
  echo "Run 'gh auth login' and 'gt auth login' to authenticate the GitHub and Graphite CLIs."
  echo "The setup will start zsh in this terminal so ~/.zshrc is loaded immediately."
  start_configured_zsh
}

main "$@"
