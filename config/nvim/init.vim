call plug#begin(stdpath('data'))
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'junegunn/fzf',
Plug 'junegunn/fzf.vim'
Plug 'sheerun/vim-polyglot'
Plug 'tpope/vim-surround'
Plug 'Raimondi/delimitMate'
Plug 'vim-airline/vim-airline'
Plug 'vim-syntastic/syntastic'
Plug 'ryanoasis/vim-devicons'
Plug 'vim-airline/vim-airline-themes'
Plug 'rafi/awesome-vim-colorschemes'
Plug 'preservim/nerdcommenter'
Plug 'ervandew/supertab'
Plug 'pprovost/vim-ps1'
Plug 'preservim/nerdtree'
call plug#end()

" Set PowerShell as default shell
let &shell = has('win32') ? 'powershell' : 'pwsh'
set shellquote= shellpipe=\| shellxquote=
set shellcmdflag=-NoLogo\ -NoProfile\ -ExecutionPolicy\ RemoteSigned\ -Command
set shellredir=\|\ Out-File\ -Encoding\ UTF8

" Automatically indent when starting new lines in code blocks
set autoindent

" Add line numbers
set number

" shows column, & line number in bottom right 
set ruler

" Enable syntax highlighting
syntax on

" Change tabs to 2 spaces
set expandtab 
set tabstop=2
set shiftwidth=2

" Delete previous word
set backspace=indent,eol,start

" Enable theming support
if (has("termguicolors"))
 set termguicolors
endif

let g:ps1_nofold_blocks = 1
let g:ps1_nofold_sig = 1

"tnoremap <Esc> <C-\><C-n>:q!<CR>
set relativenumber

" Switch windows with ctrl + jklh
nnoremap <C-J> <C-W>j
nnoremap <C-K> <C-W>k
nnoremap <C-L> <C-W>l
nnoremap <C-H> <C-W>h

" coc-powershell stuff
tnoremap <Esc> <C-\><C-n>
nmap <silent><nowait> <F5> :<C-u>CocCommand powershell.execute<cr>
nmap <silent><nowait> <A-r> :<C-u>CocCommand powershell.evaluateLine<cr>

" System clipboard
set clipboard^=unnamed,unnamedplus

" Nerdtree
nnoremap <C-t> :NERDTreeToggle<CR>
nnoremap <C-f> :NERDTreeFind<CR>
