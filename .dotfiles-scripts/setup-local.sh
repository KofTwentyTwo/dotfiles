#!/usr/bin/env bash
set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Detect operating system
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ -f /etc/os-release ]]; then
        . /etc/os-release
        case $ID in
            ubuntu|debian)
                echo "ubuntu"
                ;;
            arch|manjaro|endeavouros)
                echo "arch"
                ;;
            *)
                echo "unknown"
                ;;
        esac
    else
        echo "unknown"
    fi
}

# Install packages based on OS
install_packages() {
    local os="$1"
    local packages=("$2")
    
    log_info "Installing packages for $os..."
    
    case $os in
        "macos")
            # Check if Homebrew is installed
            if ! command -v brew &> /dev/null; then
                log_info "Installing Homebrew..."
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            fi
            
            # Install packages
            for package in "${packages[@]}"; do
                log_info "Installing $package via Homebrew..."
                brew install "$package" || log_warning "Failed to install $package"
            done
            ;;
        "ubuntu")
            log_info "Updating package lists..."
            sudo apt update
            
            for package in "${packages[@]}"; do
                log_info "Installing $package via apt..."
                sudo apt install -y "$package" || log_warning "Failed to install $package"
            done
            ;;
        "arch")
            log_info "Updating package database..."
            sudo pacman -Sy
            
            for package in "${packages[@]}"; do
                log_info "Installing $package via pacman..."
                sudo pacman -S --noconfirm "$package" || log_warning "Failed to install $package"
            done
            ;;
        *)
            log_error "Unsupported operating system: $os"
            exit 1
            ;;
    esac
}

# Install zsh and set as default shell
setup_zsh() {
    local os="$1"
    
    log_info "Setting up zsh..."
    
    # Install zsh if not present
    if ! command -v zsh &> /dev/null; then
        log_info "Installing zsh..."
        case $os in
            "macos")
                brew install zsh
                ;;
            "ubuntu")
                sudo apt update && sudo apt install -y zsh
                ;;
            "arch")
                sudo pacman -S --noconfirm zsh
                ;;
        esac
    else
        log_success "zsh is already installed"
    fi
    
    # Set zsh as default shell
    local zsh_path=$(which zsh)
    if [[ "$SHELL" != "$zsh_path" ]]; then
        log_info "Setting zsh as default shell..."
        if [[ $os == "macos" ]]; then
            # On macOS, we need to add zsh to /etc/shells first
            if ! grep -q "$zsh_path" /etc/shells; then
                echo "$zsh_path" | sudo tee -a /etc/shells
            fi
        fi
        chsh -s "$zsh_path"
        log_success "zsh set as default shell. Please restart your terminal."
    else
        log_success "zsh is already the default shell"
    fi
}

# Install Oh My Zsh
install_ohmyzsh() {
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        log_info "Installing Oh My Zsh..."
        sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        log_success "Oh My Zsh installed successfully"
    else
        log_success "Oh My Zsh is already installed"
    fi
}

# Install useful packages
install_dev_packages() {
    local os="$1"
    
    log_info "Installing development packages..."
    
    case $os in
        "macos")
            local packages=(
                "git"
                "curl"
                "wget"
                "vim"
                "tmux"
                "tree"
                "jq"
                "fzf"
                "ripgrep"
                "fd"
                "bat"
                "exa"
                "zoxide"
            )
            ;;
        "ubuntu")
            local packages=(
                "git"
                "curl"
                "wget"
                "vim"
                "tmux"
                "tree"
                "jq"
                "fzf"
                "ripgrep"
                "fd-find"
                "bat"
                "exa"
                "zoxide"
                "build-essential"
                "software-properties-common"
            )
            ;;
        "arch")
            local packages=(
                "git"
                "curl"
                "wget"
                "vim"
                "tmux"
                "tree"
                "jq"
                "fzf"
                "ripgrep"
                "fd"
                "bat"
                "exa"
                "zoxide"
                "base-devel"
            )
            ;;
    esac
    
    install_packages "$os" "${packages[@]}"
}

# Main setup function
main() {
    log_info "Starting local development environment setup..."
    
    # Detect OS
    local os=$(detect_os)
    log_info "Detected OS: $os"
    
    if [[ "$os" == "unknown" ]]; then
        log_error "Unsupported operating system. Please run this script on macOS, Ubuntu, or Arch-based distributions."
        exit 1
    fi
    
    # Setup zsh
    setup_zsh "$os"
    
    # Install Oh My Zsh
    install_ohmyzsh
    
    # Install development packages
    install_dev_packages "$os"
    
    log_success "Local development environment setup complete!"
    log_info "Please restart your terminal or run 'exec zsh' to start using zsh with Oh My Zsh"
    
    # Show next steps
    echo
    log_info "Next steps:"
    echo "1. Restart your terminal or run: exec zsh"
    echo "2. Configure your dotfiles: dot status"
    echo "3. Install additional tools as needed"
}

# Run main function
main "$@"