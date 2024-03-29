syntax on
filetype on
set tabstop=2
set shiftwidth=2
set expandtab
set magic
let g:makegreen_stay_on_file = 1
nnoremap <f3> :bn<cr>
nnoremap <f2> :bN<cr>
nnoremap <silent> <F8> :TlistToggle<cr>
nnoremap <silent> <C-h> :wincmd h<CR>
nnoremap <silent> <C-n> :wincmd l<CR>
nnoremap <silent> <C-t> :wincmd j<CR>
nnoremap <silent> <C-c> :wincmd k<CR>
nnoremap <silent> <F6> :bprevious<CR>
nnoremap <unique> <leader><leader> :FufFile<CR>
autocmd FileType python map <buffer> <F5> :w<CR>:exec '!python3' shellescape(@%, 1)<CR>
autocmd FileType python imap <buffer> <F5> <esc>:w<CR>:exec '!python3' shellescape(@%, 1)<CR>
