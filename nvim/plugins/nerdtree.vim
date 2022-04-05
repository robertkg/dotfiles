Plug 'preservim/nerdtree'

let NERDTreeShowHidden=1
let NERDTreeMinimalUI=1
"let g:NERDTreeDirArrowExpandable = '->'
"let g:NERDTreeDirArrowCollapsible = ''

nnoremap <expr> <leader>n g:NERDTree.IsOpen() ? ':NERDTreeClose<CR>' : @% == '' ? ':NERDTree<CR>' : ':NERDTreeFind<CR>'
nmap <leader>N :NERDTreeFind<CR>