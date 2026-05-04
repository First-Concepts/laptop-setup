# First Concepts Laptop Setup

macOS setup script for First Concepts employees.

## What It Installs

- Homebrew
- Google Chrome
- 1Password desktop app
- 1Password CLI
- Slack desktop app
- GitHub CLI
- Graphite CLI
- nvm
- Node.js 24 through nvm
- Bun
- Cursor
- Claude Code

## Usage

Run this from Terminal on a new Mac:

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/First-Concepts/laptop-setup/main/setup-macos.sh)"
```

Or, after cloning the repo:

```sh
chmod +x setup-macos.sh
./setup-macos.sh
```

The script may prompt for your macOS password during Homebrew or app installation. It installs Node.js 24 through nvm and sets it as the default Node.js version. After it finishes, open Chrome, 1Password, Slack, Cursor, and Claude Code to complete sign-in. Run `gh auth login` and `gt auth login` to authenticate the GitHub and Graphite CLIs.
