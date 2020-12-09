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
