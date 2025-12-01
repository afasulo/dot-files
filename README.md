# dot-files 
Repo of all of my most(ly) current dot files such as .vimrc, .gdbinit, .zshrc, etc.

Automated development environment setup for **security research**, **threat hunting**, and **HPC development**. Uses Ansible for reproducible provisioning across workstations and VMs.

## Quick Start

```bash
# Clone and bootstrap
git clone https://github.com/afasulo/dot-files.git ~/.dotfiles
cd ~/.dotfiles
./install.sh

# Or run specific Ansible roles
cd ansible
ansible-playbook -i inventory.yml playbook.yml --tags "security"
```

## What's Here

### Development Environment
- Shell configs (`.bashrc`, `.zshrc`) 
- Vim configuration optimized for C/Python development
- GDB init with exploit development helpers (install gef at some point)
- Tmux config for session management

###  Security & Threat Hunting Tools
- **Network Analysis**: Wireshark, tcpdump, nmap, netcat
- **Forensics**: Volatility, binwalk, foremost, sleuthkit
- **Malware Analysis**: YARA, radare2, Ghidra (manual)
- **Reverse Engineering**: GDB + pwndbg/GEF, strace, ltrace
- **OSINT**: whois, dig, theHarvester

###  HPC Development
- Compilers: GCC, Clang, build-essential
- Debugging: GDB, Valgrind, strace
- Build systems: CMake, Make
- Profiling: perf, linux-tools

## Directory Structure

```
dot-files/
├── ansible/
│   ├── playbook.yml          # Main playbook
│   ├── inventory.yml         # Target hosts
│   └── roles/
│       ├── base/             # Core packages
│       ├── security-tools/   # Threat hunting & forensics
│       ├── hpc-dev/          # HPC development environment
│       └── dotfiles/         # Deploy config files
├── shell/
│   ├── .bashrc               # Bash configuration
│   ├── .zshrc                # Zsh configuration
│   └── .aliases              # Shared aliases
├── editor/
│   ├── .vimrc                # Vim configuration
│   └── .gdbinit              # GDB initialization
├── tmux/
│   └── .tmux.conf            # Tmux configuration
└── install.sh                # Bootstrap script
```

## Ansible Roles

### Base (`--tags base`)
Core system utilities, updates, and essential packages.

### Security Tools (`--tags security`)
Full threat hunting and forensics toolkit:
```bash
ansible-playbook -i inventory.yml playbook.yml --tags "security"
```

### HPC Development (`--tags hpc`)
Development environment for systems programming:
```bash
ansible-playbook -i inventory.yml playbook.yml --tags "hpc"
```

### Dotfiles (`--tags dotfiles`)
Deploy shell, editor, and tmux configurations:
```bash
ansible-playbook -i inventory.yml playbook.yml --tags "dotfiles"
```

## Manual Steps

Some tools require manual installation due to licensing or complexity:
- **Ghidra**: Download from [ghidra-sre.org](https://ghidra-sre.org/)
- **IDA Free**: Download from [hex-rays.com](https://hex-rays.com/ida-free/)
- **Burp Suite**: Download from [portswigger.net](https://portswigger.net/burp)

## Compatibility

| OS | Status |
|----|--------|
| Ubuntu 22.04+ | Fully tested on homelab|
| Debian 12+ |  Supported |
| RHEL/Rocky 9 |  Partial (adjust package names) |
| macOS | Dotfiles only (brew for packages) |



---


