" General settings
set langmenu=en_US
let $LANG = 'en_US'
set expandtab
set shiftwidth=4
set tabstop=4
set hidden
set signcolumn=yes:2
set relativenumber
set number
set termguicolors
set undofile
set spell
set title
set ignorecase
set smartcase
set wildmode=longest:full,full
set nowrap
set list
set listchars=tab:▸\ ,trail:·
set mouse=a
set scrolloff=8
set sidescrolloff=8
set nojoinspaces
set splitright
set clipboard=unnamedplus
set confirm
set exrc
set foldcolumn=0
set signcolumn=no

" Key maps
let mapleader = "\<space>"
nmap <leader>ve :edit ~/.config/nvim/init.vim<cr>
nmap <leader>vc :edit ~/.config/nvim/coc-settings.json<cr>
nmap <leader>vr :source ~/.config/nvim/init.vim<cr>
nmap <leader>wte :edit ~/.config/windows-terminal/settings.json<cr>

call plug#begin(stdpath('data'))
source ~/.config/nvim/plugins/coc.vim
source ~/.config/nvim/plugins/nerdtree.vim
source ~/.config/nvim/plugins/polyglot.vim
source ~/.config/nvim/plugins/startify.vim
source ~/.config/nvim/plugins/onedark.vim
source ~/.config/nvim/plugins/dracula.vim
"source ~/.config/nvim/plugins/fzf.vim
call plug#end()

" Set PowerShell as default shell
let &shell = has('win32') ? 'powershell' : 'pwsh'
set shellquote= shellpipe=\| shellxquote=
set shellcmdflag=-NoLogo\ -NoProfile\ -ExecutionPolicy\ RemoteSigned\ -Command
set shellredir=\|\ Out-File\ -Encoding\ UTF8

set backspace=indent,eol,start

highlight Pmenu guibg=black
