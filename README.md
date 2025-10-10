# Dotfiles

Personal configuration files managed with a bare git repository.

## Quick Setup

### 1. Dotfiles Setup
```bash
# Clone and setup
git clone --bare git@github.com:KofTwentyTwo/dotfiles.git ~/.dotfiles
alias dot='git --git-dir=~/.dotfiles/ --work-tree=~'
dot checkout
dot config status.showUntrackedFiles no

# Or use the setup script
curl -fsSL https://raw.githubusercontent.com/KofTwentyTwo/dotfiles/main/.dotfiles-scripts/setup.sh | bash
```

### 2. Local Development Environment
```bash
# Install zsh, oh-my-zsh, and dev packages (macOS/Ubuntu/Arch)
curl -fsSL https://raw.githubusercontent.com/KofTwentyTwo/dotfiles/main/.dotfiles-scripts/setup-local.sh | bash
```

### 3. Using the Launcher (after dotfiles setup)
```bash
# Setup dotfiles
./setup dotfiles

# Setup local environment
./setup local

# Show help
./setup help
```

## Usage

```bash
# Check status
dot status

# Add new file
dot add ~/.newconfig
dot commit -m "Add newconfig"
dot push

# Update existing
dot add ~/.bashrc
dot commit -m "Update bashrc"
dot push

# Pull changes
dot pull
```

## How It Works

- Repository: `~/.dotfiles/` (bare git repo)
- Working tree: `~` (your home directory)
- Use `dot` alias for all git operations
- No `.git` folder in home directory