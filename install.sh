#!/bin/bash
# install.sh - Bootstrap script for dot-files & environment setup
# Author: Adam Fasulo
#
# Usage:
#   ./install.sh              # Interactive mode
#   ./install.sh --dotfiles   # Dotfiles only (no Ansible)
#   ./install.sh --full       # Full setup with Ansible
#   ./install.sh --help       # Show help

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ===========================================
# Helper Functions
# ===========================================

print_banner() {
    echo -e "${BLUE}"
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║     Security Research & HPC Development Environment Setup     ║"
    echo "║                        by Adam Fasulo                         ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_step() {
    echo -e "${GREEN}[+]${NC} $1"
}

print_warn() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --dotfiles    Install dotfiles only (symlinks)"
    echo "  --full        Full setup with Ansible (requires sudo)"
    echo "  --ansible     Run Ansible playbook only"
    echo "  --help        Show this help message"
    echo ""
    echo "Tags for Ansible (use with --ansible):"
    echo "  --tags base       Core system utilities"
    echo "  --tags security   Security & threat hunting tools"
    echo "  --tags hpc        HPC development environment"
    echo "  --tags dotfiles   Deploy configuration files"
    echo ""
    echo "Examples:"
    echo "  $0 --dotfiles              # Just symlink config files"
    echo "  $0 --full                  # Full automated setup"
    echo "  $0 --ansible --tags security  # Install only security tools"
}

check_os() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        OS=$ID
        VERSION=$VERSION_ID
    else
        print_error "Cannot detect OS"
        exit 1
    fi
    print_step "Detected OS: $OS $VERSION"
}

install_ansible() {
    if command -v ansible &> /dev/null; then
        print_step "Ansible already installed: $(ansible --version | head -1)"
        return 0
    fi

    print_step "Installing Ansible..."
    
    case $OS in
        ubuntu|debian)
            sudo apt-get update
            sudo apt-get install -y software-properties-common
            sudo apt-add-repository -y --update ppa:ansible/ansible 2>/dev/null || true
            sudo apt-get install -y ansible
            ;;
        fedora|rhel|centos|rocky)
            sudo dnf install -y ansible
            ;;
        *)
            print_warn "Unknown OS, trying pip install"
            pip3 install --user ansible
            ;;
    esac
    
    print_success "Ansible installed"
}

backup_existing() {
    local file="$1"
    if [[ -f "$file" && ! -L "$file" ]]; then
        local backup="${file}.backup.$(date +%Y%m%d_%H%M%S)"
        print_warn "Backing up existing $file to $backup"
        mv "$file" "$backup"
    fi
}

symlink_dotfile() {
    local src="$1"
    local dst="$2"
    
    if [[ -L "$dst" ]]; then
        rm "$dst"
    fi
    
    backup_existing "$dst"
    ln -sf "$src" "$dst"
    print_step "Linked $dst -> $src"
}

install_dotfiles_only() {
    print_step "Installing dotfiles (symlinks only)..."
    
    # Shell
    symlink_dotfile "$DOTFILES_DIR/shell/.bashrc" "$HOME/.bashrc"
    symlink_dotfile "$DOTFILES_DIR/shell/.aliases" "$HOME/.aliases"
    
    # Editor
    symlink_dotfile "$DOTFILES_DIR/editor/.vimrc" "$HOME/.vimrc"
    symlink_dotfile "$DOTFILES_DIR/editor/.gdbinit" "$HOME/.gdbinit"
    
    # Tmux
    symlink_dotfile "$DOTFILES_DIR/tmux/.tmux.conf" "$HOME/.tmux.conf"
    
    # Create local bin directory
    mkdir -p "$HOME/.local/bin"
    
    print_success "Dotfiles installed!"
    print_step "Run 'source ~/.bashrc' to apply changes"
}

run_ansible() {
    local tags="${1:-all}"
    
    print_step "Running Ansible playbook with tags: $tags"
    
    cd "$DOTFILES_DIR/ansible"
    
    if [[ "$tags" == "all" ]]; then
        ansible-playbook -i inventory.yml playbook.yml --ask-become-pass
    else
        ansible-playbook -i inventory.yml playbook.yml --tags "$tags" --ask-become-pass
    fi
    
    print_success "Ansible playbook completed!"
}

interactive_menu() {
    echo ""
    echo "Select installation type:"
    echo ""
    echo "  1) Dotfiles only (symlinks, no root required)"
    echo "  2) Full setup (Ansible - requires sudo)"
    echo "  3) Security tools only (Ansible)"
    echo "  4) HPC development only (Ansible)"
    echo "  5) Exit"
    echo ""
    read -p "Enter choice [1-5]: " choice
    
    case $choice in
        1)
            install_dotfiles_only
            ;;
        2)
            check_os
            install_ansible
            run_ansible "all"
            ;;
        3)
            check_os
            install_ansible
            run_ansible "security"
            ;;
        4)
            check_os
            install_ansible
            run_ansible "hpc"
            ;;
        5)
            echo "Exiting."
            exit 0
            ;;
        *)
            print_error "Invalid choice"
            exit 1
            ;;
    esac
}

# ===========================================
# Main
# ===========================================

print_banner

case "${1:-}" in
    --help|-h)
        show_help
        exit 0
        ;;
    --dotfiles)
        install_dotfiles_only
        ;;
    --full)
        check_os
        install_ansible
        run_ansible "all"
        ;;
    --ansible)
        check_os
        install_ansible
        shift
        tags="all"
        if [[ "${1:-}" == "--tags" && -n "${2:-}" ]]; then
            tags="$2"
        fi
        run_ansible "$tags"
        ;;
    "")
        interactive_menu
        ;;
    *)
        print_error "Unknown option: $1"
        show_help
        exit 1
        ;;
esac

echo ""
print_success "Setup complete!"
echo ""
echo "Next steps:"
echo "  1. Source your shell config: source ~/.bashrc"
echo "  2. Verify security tools: sec-check"
echo "  3. Install manual tools (Ghidra, IDA) if needed"
echo ""

