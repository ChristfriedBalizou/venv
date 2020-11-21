"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Text, tab and indent related
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
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
