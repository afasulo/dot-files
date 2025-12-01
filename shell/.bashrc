# ~/.bashrc - Security Research & HPC Development Environment
# 

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# ===========================================
# History Configuration
# ===========================================
HISTCONTROL=ignoreboth:erasedups
HISTSIZE=10000
HISTFILESIZE=20000
HISTTIMEFORMAT="%F %T "
shopt -s histappend

# ===========================================
# Shell Options
# ===========================================
shopt -s checkwinsize   # Update LINES/COLUMNS after each command
shopt -s globstar       # ** matches all files and directories
shopt -s cdspell        # Correct minor cd spelling errors
shopt -s dirspell       # Correct directory spelling in completion

# ===========================================
# Environment Variables
# ===========================================
export EDITOR=vim
export VISUAL=vim
export PAGER=less
export LESS='-R -F -X'

# Add local bin to PATH
export PATH="$HOME/.local/bin:$PATH"

# Development paths
export CPATH="/usr/local/include:$CPATH"
export LIBRARY_PATH="/usr/local/lib:$LIBRARY_PATH"
export LD_LIBRARY_PATH="/usr/local/lib:$LD_LIBRARY_PATH"

# GDB configuration
export DEBUGINFOD_URLS="https://debuginfod.ubuntu.com"

# ===========================================
# Prompt Configuration
# ===========================================
# Colors
RED='\[\033[0;31m\]'
GREEN='\[\033[0;32m\]'
YELLOW='\[\033[0;33m\]'
BLUE='\[\033[0;34m\]'
PURPLE='\[\033[0;35m\]'
CYAN='\[\033[0;36m\]'
WHITE='\[\033[0;37m\]'
RESET='\[\033[0m\]'

# Git branch in prompt
parse_git_branch() {
    git branch 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

# Set prompt
if [ "$EUID" -eq 0 ]; then
    PS1="${RED}\u${RESET}@${CYAN}\h${RESET}:${BLUE}\w${YELLOW}\$(parse_git_branch)${RESET}# "
else
    PS1="${GREEN}\u${RESET}@${CYAN}\h${RESET}:${BLUE}\w${YELLOW}\$(parse_git_branch)${RESET}\$ "
fi

# ===========================================
# Aliases
# ===========================================
# Load aliases from separate file
if [ -f ~/.aliases ]; then
    . ~/.aliases
fi

# ===========================================
# Completion
# ===========================================
if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
    fi
fi

# ===========================================
# Functions
# ===========================================

# Extract various archive formats
extract() {
    if [ -f "$1" ]; then
        case "$1" in
            *.tar.bz2) tar xjf "$1" ;;
            *.tar.gz)  tar xzf "$1" ;;
            *.tar.xz)  tar xJf "$1" ;;
            *.bz2)     bunzip2 "$1" ;;
            *.rar)     unrar x "$1" ;;
            *.gz)      gunzip "$1" ;;
            *.tar)     tar xf "$1" ;;
            *.tbz2)    tar xjf "$1" ;;
            *.tgz)     tar xzf "$1" ;;
            *.zip)     unzip "$1" ;;
            *.Z)       uncompress "$1" ;;
            *.7z)      7z x "$1" ;;
            *)         echo "'$1' cannot be extracted" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Create directory and cd into it
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Quick file search
ff() {
    find . -type f -name "*$1*"
}

# Process grep
psg() {
    ps aux | grep -v grep | grep -i "$1"
}

# Quick hex dump
hexview() {
    xxd "$1" | less
}

# Check listening ports
ports() {
    sudo netstat -tlnp 2>/dev/null || sudo ss -tlnp
}

# Quick system info
sysinfo() {
    echo "=== System Information ==="
    echo "Hostname: $(hostname)"
    echo "Kernel: $(uname -r)"
    echo "Uptime: $(uptime -p)"
    echo "Load: $(cat /proc/loadavg | awk '{print $1, $2, $3}')"
    echo "Memory: $(free -h | awk '/^Mem:/ {print $3 "/" $2}')"
    echo "Disk: $(df -h / | awk 'NR==2 {print $3 "/" $2 " (" $5 " used)"}')"
}

# ===========================================
# Security Research Helpers
# ===========================================

# Quick strings + grep
strgrep() {
    strings "$1" | grep -i "$2"
}

# File entropy check (high entropy = possibly encrypted/packed)
entropy() {
    if command -v ent &>/dev/null; then
        ent "$1"
    else
        echo "Install 'ent' for entropy analysis"
    fi
}

# Quick YARA scan
yarascan() {
    if [ -z "$2" ]; then
        echo "Usage: yarascan <rules.yar> <target>"
    else
        yara -r "$1" "$2"
    fi
}

# ===========================================
# Startup Messages
# ===========================================
echo " Security Research Environment loaded"
echo "   Run 'sec-check' to verify tool installation"
echo ""

