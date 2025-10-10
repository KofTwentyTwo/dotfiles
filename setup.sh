#!/usr/bin/env bash
set -e

REPO_URL="${1:-git@github.com:YOURUSER/dotfiles.git}"
DOTFILES_DIR="$HOME/.dotfiles"
ALIAS_CMD="alias dot='git --git-dir=$DOTFILES_DIR/ --work-tree=$HOME'"

echo "Setting up dotfiles from $REPO_URL"

# 1. Clone the bare repository
if [ -d "$DOTFILES_DIR" ]; then
  echo "Dotfiles repo already exists at $DOTFILES_DIR"
else
  git clone --bare "$REPO_URL" "$DOTFILES_DIR"
fi

# 2. Define temporary alias for this session
eval "$ALIAS_CMD"

# 3. Backup any existing conflicting files
echo "Backing up any pre-existing dotfiles..."
mkdir -p ~/.dotfiles-backup
dot checkout 2>&1 | grep -E "^\s" | awk '{print $1}' | while read -r file; do
  mkdir -p "$(dirname ~/.dotfiles-backup/$file)"
  mv "$HOME/$file" ~/.dotfiles-backup/$file || true
done

# 4. Check out the tracked files
dot checkout

# 5. Configure Git to hide untracked files in status
dot config status.showUntrackedFiles no

# 6. Persist the alias for future shells
if ! grep -q "alias dot=" ~/.zshrc 2>/dev/null && ! grep -q "alias dot=" ~/.bashrc 2>/dev/null; then
  echo "$ALIAS_CMD" >> ~/.zshrc
  echo "$ALIAS_CMD" >> ~/.bashrc
fi

echo "Dotfiles setup complete."
echo "Use 'dot status' and 'dot pull' to manage your configs."
