#!/usr/bin/env bash
set -euo pipefail

REPO_URL="${1:-git@github.com:KofTwentyTwo/dotfiles.git}"
DOTFILES_DIR="$HOME/.dotfiles"
BACKUP_DIR="$HOME/.dotfiles-backup"

echo "Setting up dotfiles from $REPO_URL"

# 1. Clone or verify existing bare repo
if [ -d "$DOTFILES_DIR" ]; then
  echo "Dotfiles repo already exists at $DOTFILES_DIR"
else
  git clone --bare "$REPO_URL" "$DOTFILES_DIR"
fi

# 2. Define local helper function
dot() {
  git --git-dir="$DOTFILES_DIR/" --work-tree="$HOME" "$@"
}

# 3. Backup any conflicting files before checkout
echo "Backing up any pre-existing dotfiles..."
mkdir -p "$BACKUP_DIR"
if ! dot checkout 2>/dev/null; then
  echo "Backing up conflicting files to $BACKUP_DIR"
  dot checkout 2>&1 | grep -E "^\s" | awk '{print $1}' | while read -r file; do
    mkdir -p "$(dirname "$BACKUP_DIR/$file")"
    mv "$HOME/$file" "$BACKUP_DIR/$file" 2>/dev/null || true
  done
  dot checkout
fi

# 4. Hide untracked files from git status
dot config status.showUntrackedFiles no

# 5. Persist function definition in user shells
persist_function() {
  local rc_file="$1"
  if ! grep -q "dot()" "$rc_file" 2>/dev/null; then
    cat <<'EOF' >> "$rc_file"

# Dotfiles management helper
dot() {
  git --git-dir="$HOME/.dotfiles/" --work-tree="$HOME" "$@"
}
EOF
  fi
}

persist_function "$HOME/.zshrc"
persist_function "$HOME/.bashrc"

echo "Dotfiles setup complete."
echo "Use 'dot status' and 'dot pull' to manage your configs."

