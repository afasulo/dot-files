" ~/.vimrc - Vim configuration for Security Research & Systems Development
" Author: Adam Fasulo

" ===========================================
" General Settings
" ===========================================
set nocompatible              " Disable vi compatibility
filetype plugin indent on     " Enable filetype detection
syntax enable                 " Enable syntax highlighting

set encoding=utf-8            " UTF-8 encoding
set fileencoding=utf-8
set termencoding=utf-8

set history=1000              " Command history
set undolevels=1000           " Undo levels
set hidden                    " Allow hidden buffers

" ===========================================
" UI Settings
" ===========================================
set number                    " Show line numbers
set relativenumber            " Relative line numbers
set ruler                     " Show cursor position
set showcmd                   " Show command in status line
set showmode                  " Show current mode
set showmatch                 " Highlight matching brackets
set cursorline                " Highlight current line

set wildmenu                  " Command-line completion
set wildmode=list:longest,full
set laststatus=2              " Always show status line

set scrolloff=5               " Lines to keep above/below cursor
set sidescrolloff=5           " Columns to keep left/right of cursor

" Colors
set background=dark
colorscheme desert            " Built-in colorscheme

" ===========================================
" Indentation
" ===========================================
set autoindent                " Auto-indent new lines
set smartindent               " Smart auto-indent
set expandtab                 " Use spaces instead of tabs
set tabstop=4                 " Tab width
set shiftwidth=4              " Indent width
set softtabstop=4             " Soft tab width

" Filetype-specific indentation
autocmd FileType c,cpp,h setlocal tabstop=4 shiftwidth=4 noexpandtab
autocmd FileType python setlocal tabstop=4 shiftwidth=4 expandtab
autocmd FileType yaml setlocal tabstop=2 shiftwidth=2 expandtab
autocmd FileType make setlocal noexpandtab

" ===========================================
" Search
" ===========================================
set incsearch                 " Incremental search
set hlsearch                  " Highlight search results
set ignorecase                " Case-insensitive search
set smartcase                 " Case-sensitive if uppercase

" Clear search highlighting with Escape
nnoremap <Esc><Esc> :nohlsearch<CR>

" ===========================================
" Navigation
" ===========================================
set backspace=indent,eol,start  " Backspace behavior

" Easy window navigation
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Buffer navigation
nnoremap <leader>bn :bnext<CR>
nnoremap <leader>bp :bprev<CR>
nnoremap <leader>bd :bdelete<CR>

" ===========================================
" Key Mappings
" ===========================================
let mapleader = ","           " Leader key

" Quick save and quit
nnoremap <leader>w :w<CR>
nnoremap <leader>q :q<CR>
nnoremap <leader>x :x<CR>

" Toggle paste mode
set pastetoggle=<F2>

" Toggle line numbers
nnoremap <F3> :set number! relativenumber!<CR>

" Toggle hex mode
nnoremap <F4> :%!xxd<CR>
nnoremap <F5> :%!xxd -r<CR>

" Insert timestamp
nnoremap <F6> "=strftime("%Y-%m-%d %H:%M:%S")<CR>P

" ===========================================
" Code Development
" ===========================================
" Compile shortcuts
autocmd FileType c nnoremap <F9> :w<CR>:!gcc -Wall -g % -o %:r<CR>
autocmd FileType cpp nnoremap <F9> :w<CR>:!g++ -Wall -g % -o %:r<CR>
autocmd FileType python nnoremap <F9> :w<CR>:!python3 %<CR>

" Run executable
autocmd FileType c,cpp nnoremap <F10> :!./%:r<CR>

" Show trailing whitespace
set list
set listchars=tab:▸\ ,trail:·,nbsp:␣

" Remove trailing whitespace on save
autocmd BufWritePre * :%s/\s\+$//e

" ===========================================
" Security Research Helpers
" ===========================================
" Syntax highlighting for various file types
autocmd BufRead,BufNewFile *.yar,*.yara setfiletype yara
autocmd BufRead,BufNewFile *.asm setfiletype nasm
autocmd BufRead,BufNewFile *.s setfiletype gas
autocmd BufRead,BufNewFile Makefile* setfiletype make

" Hex editing mode
function! ToggleHex()
    let l:modified = &modified
    let l:oldfile = expand('%')
    if !exists('b:hex_mode') || !b:hex_mode
        let b:hex_mode = 1
        silent %!xxd
        set filetype=xxd
    else
        let b:hex_mode = 0
        silent %!xxd -r
        set filetype=
        filetype detect
    endif
    let &modified = l:modified
endfunction
nnoremap <leader>h :call ToggleHex()<CR>

" ===========================================
" Status Line
" ===========================================
set statusline=
set statusline+=%#PmenuSel#
set statusline+=\ %f                     " File name
set statusline+=\ %m                     " Modified flag
set statusline+=%#LineNr#
set statusline+=\ %y                     " File type
set statusline+=\ %{&fileencoding?&fileencoding:&encoding}
set statusline+=\ [%{&ff}]               " File format
set statusline+=%=                       " Right side
set statusline+=\ %l:%c                  " Line:Column
set statusline+=\ %p%%                   " Percentage
set statusline+=\ [%L]                   " Total lines

" ===========================================
" Backup & Swap
" ===========================================
set nobackup                  " No backup files
set nowritebackup
set noswapfile                " No swap files

" Persistent undo
if has('persistent_undo')
    set undofile
    set undodir=~/.vim/undo
    if !isdirectory(&undodir)
        call mkdir(&undodir, 'p')
    endif
endif

" ===========================================
" Misc
" ===========================================
" Auto-reload files changed outside vim
set autoread
autocmd FocusGained,BufEnter * checktime

" Mouse support (optional)
set mouse=a

" Disable error bells
set noerrorbells
set visualbell
set t_vb=

" Return to last edit position
autocmd BufReadPost *
    \ if line("'\"") > 0 && line("'\"") <= line("$") |
    \   exe "normal! g`\"" |
    \ endif

