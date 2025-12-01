# ~/.gdbinit - GDB configuration for security research & debugging
# Author: Adam Fasulo

# ===========================================
# General Settings
# ===========================================
set confirm off
set verbose off
set history save on
set history filename ~/.gdb_history
set history size 10000
set history remove-duplicates 1

# Output settings
set print pretty on
set print array on
set print array-indexes on
set print elements 100
set print null-stop on
set print union on
set print object on
set print static-members on
set print demangle on
set print asm-demangle on
set print sevenbit-strings off

# Pagination
set pagination off

# ===========================================
# Assembly Settings
# ===========================================
# Intel syntax (more readable than AT&T)
set disassembly-flavor intel

# Show disassembly around current instruction
set disassemble-next-line on

# ===========================================
# Safety Settings
# ===========================================
# Follow child on fork (useful for analyzing child processes)
set follow-fork-mode child
set detach-on-fork off

# Handle signals
handle SIGALRM nostop print nopass
handle SIGPIPE nostop print nopass

# ===========================================
# Convenience Variables
# ===========================================
# Useful addresses (update per target)
# set $libc_base = 0x0
# set $stack_base = 0x0

# ===========================================
# Custom Commands
# ===========================================

# Print stack with better formatting
define stack
    if $argc == 0
        x/32xw $rsp
    else
        x/$arg0xw $rsp
    end
end
document stack
Print stack contents (default 32 words)
Usage: stack [count]
end

# Print registers in a clean format
define regs
    printf "RAX: 0x%016lx  RBX: 0x%016lx\n", $rax, $rbx
    printf "RCX: 0x%016lx  RDX: 0x%016lx\n", $rcx, $rdx
    printf "RSI: 0x%016lx  RDI: 0x%016lx\n", $rsi, $rdi
    printf "RBP: 0x%016lx  RSP: 0x%016lx\n", $rbp, $rsp
    printf "R8:  0x%016lx  R9:  0x%016lx\n", $r8, $r9
    printf "R10: 0x%016lx  R11: 0x%016lx\n", $r10, $r11
    printf "R12: 0x%016lx  R13: 0x%016lx\n", $r12, $r13
    printf "R14: 0x%016lx  R15: 0x%016lx\n", $r14, $r15
    printf "RIP: 0x%016lx  EFLAGS: 0x%08lx\n", $rip, $eflags
end
document regs
Print all general-purpose registers (x86_64)
end

# Disassemble current function
define dis
    if $argc == 0
        disassemble
    else
        disassemble $arg0
    end
end
document dis
Disassemble current or specified function
Usage: dis [function/address]
end

# Hexdump memory region
define hexdump
    if $argc < 2
        printf "Usage: hexdump <address> <length>\n"
    else
        dump binary memory /tmp/gdb_hexdump.bin $arg0 $arg0+$arg1
        shell xxd /tmp/gdb_hexdump.bin
        shell rm /tmp/gdb_hexdump.bin
    end
end
document hexdump
Hexdump memory region
Usage: hexdump <address> <length>
end

# Find pattern in memory
define findpattern
    if $argc < 2
        printf "Usage: findpattern <start> <end> <pattern>\n"
    else
        find $arg0, $arg1, $arg2
    end
end
document findpattern
Find pattern in memory range
Usage: findpattern <start> <end> <pattern>
end

# Print string at address
define pstr
    if $argc == 0
        printf "Usage: pstr <address>\n"
    else
        x/s $arg0
    end
end
document pstr
Print null-terminated string at address
Usage: pstr <address>
end

# ===========================================
# Exploit Development Helpers
# ===========================================

# Show GOT entries
define got
    info functions @plt
end
document got
Show PLT/GOT entries
end

# Show loaded libraries
define libs
    info sharedlibrary
end
document libs
Show loaded shared libraries
end

# Check memory protections
define vmmap
    info proc mappings
end
document vmmap
Show process memory mappings
end

# Check security features of binary
define checksec
    shell checksec --file=$_
end
document checksec
Check security features of current binary (requires checksec)
end

# ===========================================
# Breakpoint Helpers
# ===========================================

# Break on main
define bmain
    break main
end
document bmain
Set breakpoint on main()
end

# Break on malloc/free (heap debugging)
define bheap
    break malloc
    break free
    break realloc
end
document bheap
Set breakpoints on heap functions
end

# Clear all breakpoints
define bclr
    delete breakpoints
end
document bclr
Delete all breakpoints
end

# ===========================================
# Context Display (mini version)
# ===========================================
define ctx
    printf "\n"
    printf "═══════════════════════════════════════════════════════════════\n"
    printf "                         REGISTERS\n"
    printf "═══════════════════════════════════════════════════════════════\n"
    regs
    printf "\n"
    printf "═══════════════════════════════════════════════════════════════\n"
    printf "                         DISASSEMBLY\n"
    printf "═══════════════════════════════════════════════════════════════\n"
    x/10i $rip
    printf "\n"
    printf "═══════════════════════════════════════════════════════════════\n"
    printf "                           STACK\n"
    printf "═══════════════════════════════════════════════════════════════\n"
    stack 16
    printf "\n"
end
document ctx
Show context: registers, disassembly, stack
end

# ===========================================
# Hooks
# ===========================================
# Uncomment to show context on every stop
# define hook-stop
#     ctx
# end

# ===========================================
# Load pwndbg or GEF if available
# ===========================================
# Uncomment ONE of the following:
# source ~/.pwndbg/gdbinit.py
# source ~/.gef.py

# ===========================================
# Startup message
# ===========================================
printf "\n"
printf "GDB initialized with custom security research configuration\n"
printf "Commands: regs, stack, dis, ctx, vmmap, got, libs, hexdump\n"
printf "\n"

