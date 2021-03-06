"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Text, tab and indent related
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Set line number
set number

" Use spaces instead of tabs
set expandtab

" Be smart when using tabs ;)
set smarttab

" 1 tab == 4 spaces
set shiftwidth=4
set tabstop=4

" Linebreak on 80 characters
set lbr
set tw=80

"" Set spell
set spell

"" Split
noremap <Leader>h :<C-u>split<CR>
noremap <Leader>v :<C-u>vsplit<CR>


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Plugins configs
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Pymode
let g:pymode=1
let g:pymode_indent=0

" Emmet
let g:user_emmet_leader_key=';'
let g:user_emmet_mode='a'
let g:user_emmet_settings={
  \  'javascript.jsx' : {
    \      'extends' : 'jsx',
    \  },
  \}

" Black configuration
let g:black_linelength=80

"" Git
noremap <Leader>ga :Gwrite<CR>
noremap <Leader>gc :Gcommit<CR>
noremap <Leader>gsh :Gpush<CR>
noremap <Leader>gll :Gpull<CR>
noremap <Leader>gs :Gstatus<CR>
noremap <Leader>gb :Gblame<CR>
noremap <Leader>gd :Gvdiff<CR>
noremap <Leader>gr :Gremove<CR>

" NeoComplete
let g:neocomplete#enable_at_startup=1

" Add spaces after comment delimiters by default
let g:NERDSpaceDelims = 1

" Use compact syntax for prettified multi-line comments
let g:NERDCompactSexyComs = 1

" Align line-wise comment delimiters flush left instead of following code indentation
let g:NERDDefaultAlign = 'left'

" Set a language to use its alternate delimiters by default
let g:NERDAltDelims_java = 1

" Add your own custom formats or override the defaults
let g:NERDCustomDelimiters = { 'c': { 'left': '/**','right': '*/' } }

" Allow commenting and inverting empty lines (useful when commenting a region)
let g:NERDCommentEmptyLines = 1

" Enable trimming of trailing whitespace when uncommenting
let g:NERDTrimTrailingWhitespace = 1

" Enable NERDCommenterToggle to check all selected lines is commented or not
let g:NERDToggleCheckAllLines = 1

" " NERDTree map key
map <F3> :NERDTreeToggle <CR>
let g:NERDTreeMouseMode = 2

" " Jedi-vim
let g:jedi#completions_enabled = 0
let g:jedi#show_call_signatures = ""
let g:jedi#completions_command = ""
" Disable documentation buffer
autocmd FileType python setlocal completeopt-=preview

"" Airline
let g:ariline#extensions#tabline#enable = 1
let g:airline_powerline_fonts = 1


" Tagbar
nmap <silent> <F4> :TagbarToggle<CR>
let g:tagbar_autofocus = 0

let g:tagbar_type_go = {
    \ 'ctagstype' : 'go',
    \ 'kinds'     : [  'p:package', 'i:imports:1', 'c:constants', 'v:variables',
        \ 't:types',  'n:interfaces', 'w:fields', 'e:embedded', 'm:methods',
        \ 'r:constructor', 'f:functions' ],
    \ 'sro' : '.',
    \ 'kind2scope' : { 't' : 'ctype', 'n' : 'ntype' },
    \ 'scope2kind' : { 'ctype' : 't', 'ntype' : 'n' },
    \ 'ctagsbin'  : 'gotags',
    \ 'ctagsargs' : '-sort -silent'
    \ }
