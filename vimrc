set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" " alternatively, pass a path where Vundle should install plugins
" "call vundle#begin('~/some/path/here')
"
" " let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'
"

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" VIM COLOR
"

Plugin 'altercation/vim-colors-solarized'
" https://github.com/morhetz/gruvbox/wiki/Installation
Plugin 'morhetz/gruvbox'
Plugin 'sjl/badwolf'
Plugin 'tomasr/molokai'
Plugin 'nanotech/jellybeans.vim'
Plugin 'endel/vim-github-colorscheme'
Plugin 'danilo-augusto/vim-afterglow'
Plugin 'dracula/vim'

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" VIM TEXT EDITOR
"
Plugin 'chrisbra/csv.vim'
Plugin 'scrooloose/nerdtree'
Plugin 'scrooloose/nerdcommenter'
Plugin 'jistr/vim-nerdtree-tabs'
Plugin 'scrooloose/syntastic'
Plugin 'xolox/vim-misc'
Plugin 'xolox/vim-easytags'
Plugin 'majutsushi/tagbar'
Plugin 'kien/ctrlp.vim'
Plugin 'vim-scripts/a.vim'
Plugin 'tpope/vim-surround'
Plugin 'nathanaelkane/vim-indent-guides'
Plugin 'Valloric/YouCompleteMe', { 'do': './install.py --tern-completer' }
Plugin 'mattn/emmet-vim'
Plugin 'elzr/vim-json'
Plugin 'honza/vim-snippets'
Plugin 'Yggdroot/indentLine'
Plugin 'ervandew/supertab'
Plugin 'MarcWeber/vim-addon-mw-utils'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'Lokaltog/powerline', {'rtp': 'powerline/bindings/vim/'}
Plugin 'Shougo/unite.vim'
Plugin 'mhartington/vim-typings'
Plugin 'Quramy/vim-dtsm'
" Plugin 'prettier/prettier'
Plugin 'perl-support.vim'
Plugin 'ambv/black'

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" VIM PYTHON
"
Plugin 'davidhalter/jedi-vim'
Plugin 'fs111/pydoc.vim'
Plugin 'cburroughs/pep8.py'
Plugin 'alfredodeza/pytest.vim'
Plugin 'vim-scripts/indentpython.vim'
Plugin 'nvie/vim-flake8'
" Plugin 'python-mode/python-mode', {'for': 'python', 'branch': 'develop'}
Plugin 'klen/python-mode'
Plugin 'Vimjas/vim-python-pep8-indent'

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" VIM XML
"

Plugin 'tpope/vim-ragtag'

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" VIM GIT
"

Plugin 'airblade/vim-gitgutter'
Plugin 'tpope/vim-fugitive'

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" VIM JAVSCRIPT | JSON | TYPESCRIPT 
"

Plugin 'jelera/vim-javascript-syntax'
Plugin 'leafgarland/typescript-vim'
Plugin 'jason0x43/vim-js-indent'
Plugin 'Quramy/vim-js-pretty-template'
Plugin 'pangloss/vim-javascript'
Plugin 'mxw/vim-jsx'
Plugin 'w0rp/ale'
Plugin 'prettier/vim-prettier', {'do': 'npm install'}

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" VIM MAN PAGES, TMUX 
"

Plugin 'Raimondi/delimitMate'
Plugin 'easymotion/vim-easymotion'


" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Maintainer: 
"       Amir Salihefendic
"		http://amix.dk/vim/vimrc.html
"       http://amix.dk - amix@amix.dk
"
" Updated:
"       Christfried BALIZOU (Custom usage only)
"
" Version: 
"       5.0 - 29/05/12 15:43:36
"
" Blog_post: 
"       http://amix.dk/blog/post/19691#The-ultimate-Vim-configuration-on-Github
"
" Awesome_version:
"       Get this config, nice color schemes and lots of plugins!
"
"       Install the awesome version from:
"
"           https://github.com/amix/vimrc
"
" Syntax_highlighted:
"       http://amix.dk/vim/vimrc.html
"
" Raw_version: 
"       http://amix.dk/vim/vimrc.txt
"
" Sections:
"    -> General
"    -> VIM user interface
"    -> Colors and Fonts
"    -> Files and backups
"    -> Text, tab and indent related
"    -> Visual mode related
"    -> Moving around, tabs and buffers
"    -> Status line
"    -> Editing mappings
"    -> vimgrep searching and cope displaying
"    -> Spell checking
"    -> Misc
"    -> Helper functions
"	 -> Plugins config
"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => General
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" mapleader Non-English keyboard
" http://stackoverflow.com/questions/14226390/how-to-use-nerd-commenter-for-vim-how-to-use-leader-key
let mapleader=","
set timeout timeoutlen=1500

" Sets how many lines of history VIM has to remember
set history=700

" Enable filetype plugins
filetype plugin on
filetype indent on

" Set to auto read when a file is changed from the outside
set autoread

" Set line number to all opened file
set number

" With a map leader it's possible to do extra key combinations
" like <leader>w saves the current file
let mapleader = ","
let g:mapleader = ","

" Fast saving
nmap <leader>w :w!<cr>


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => VIM user interface
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Set 7 lines to the cursor - when moving vertically using j/k
set so=7

" Turn on the WiLd menu
set wildmenu

" Ignore compiled files
set wildignore=*.o,*~,*.pyc,*.class

"Always show current position
set ruler

" Height of the command bar
set cmdheight=2

" A buffer becomes hidden when it is abandoned
set hid

" Configure backspace so it acts as it should act
set backspace=eol,start,indent
set whichwrap+=<,>,h,l

" Ignore case when searching
set ignorecase

" When searching try to be smart about cases
set smartcase

" Highlight search results
set hlsearch

" Makes search act like search in modern browsers
set incsearch

" Don't redraw while executing macros (good performance config)
set lazyredraw

" For regular expressions turn magic on
set magic

" Show matching brackets when text indicator is over them
set showmatch
" How many tenths of a second to blink when matching brackets
set mat=2

" No annoying sound on errors
set noerrorbells
set novisualbell
set t_vb=
set tm=500

" Set ctags configuration
" set autochdir
" map <A-Left> :tab split<CR>:exec("tag ".expand("<cword>"))<CR>
" map <A-Right> :vsp <CR>:exec("tag ".expand("<cword>"))<CR>
" map <C-\> :tab split<CR>:exec("tag ".expand("<cword>"))<CR>
" map <A-]> :vsp <CR>:exec("tag ".expand("<cword>"))<CR>
set tags+=./tags;
nnoremap <silent> <Leader>b :TagbarToggle<CR>
nnoremap <leader>. :CtrlPTag<cr>

autocmd BufWritePost *
    \ if filereadable('tags') |
    \   call system('ctags -a '.expand('%')) |
    \ endif

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Colors and Fonts
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Enable syntax highlighting
syntax on
syntax enable

" colorscheme desert
colorscheme dracula 
set t_Co=256

if has("gui_running")
    set background=light
else
    set background=dark
endif

" if has("gui_running")
"     set guioptions-=T
"     set guioptions+=e
"     set t_Co=256
"     set guitablabel=%M\ %t
" endif

" Set utf8 as standard encoding and en_US as the standard language
set encoding=utf8

" Use Unix as the standard file type
set ffs=unix,dos,mac


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Files, backups and undo
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Turn backup off, since most stuff is in SVN, git et.c anyway...
" set nobackup
" set nowb
" set noswapfile


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

" Linebreak on 500 characters
set lbr
set tw=80

set ai "Auto indent
set si "Smart indent
set wrap "Wrap lines


""""""""""""""""""""""""""""""
" => Visual mode related
""""""""""""""""""""""""""""""
" Visual mode pressing * or # searches for the current selection
" Super useful! From an idea by Michael Naumann
vnoremap <silent> * :call VisualSelection('f')<CR>
vnoremap <silent> # :call VisualSelection('b')<CR>


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Moving around, tabs, windows and buffers
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Treat long lines as break lines (useful when moving around in them)
map j gj
map k gk

" Map <Space> to / (search) and Ctrl-<Space> to ? (backwards search)
map <space> /
map <c-space> ?

" Disable highlight when <leader><cr> is pressed
map <silent> <leader><cr> :noh<cr>

" Smart way to move between windows
map <C-j> <C-W>j
map <C-k> <C-W>k
map <C-h> <C-W>h
map <C-l> <C-W>l

" Close the current buffer
map <leader>bd :Bclose<cr>

" Close all the buffers
map <leader>ba :1,1000 bd!<cr>

" Useful mappings for managing tabs
map <leader>tn :tabnew<cr>
map <leader>to :tabonly<cr>
map <leader>tc :tabclose<cr>
map <leader>tm :tabmove

" Opens a new tab with the current buffer's path
" Super useful when editing files in the same directory
map <leader>te :tabedit <c-r>=expand("%:p:h")<cr>/

" Switch CWD to the directory of the open buffer
map <leader>cd :cd %:p:h<cr>:pwd<cr>

" Specify the behavior when switching between buffers 
try
  set switchbuf=useopen,usetab,newtab
  set stal=2
catch
endtry

" Return to last edit position when opening files (You want this!)
autocmd BufReadPost *
     \ if line("'\"") > 0 && line("'\"") <= line("$") |
     \   exe "normal! g`\"" |
     \ endif
" Remember info about open buffers on close
set viminfo^=%


""""""""""""""""""""""""""""""
" => Status line
""""""""""""""""""""""""""""""
" Always show the status line
set laststatus=2

" Format the status line
set statusline=\ %{HasPaste()}%F%m%r%h\ %w\ \ CWD:\ %r%{getcwd()}%h\ \ \ Line:\ %l


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Editing mappings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Remap VIM 0 to first non-blank character
map 0 ^

" Move a line of text using ALT+[jk] or Comamnd+[jk] on mac
nmap <M-j> mz:m+<cr>`z
nmap <M-k> mz:m-2<cr>`z
vmap <M-j> :m'>+<cr>`<my`>mzgv`yo`z
vmap <M-k> :m'<-2<cr>`>my`<mzgv`yo`z

if has("mac") || has("macunix")
  nmap <D-j> <M-j>
  nmap <D-k> <M-k>
  vmap <D-j> <M-j>
  vmap <D-k> <M-k>
endif

"" Split
noremap <Leader>h :<C-u>split<CR>
noremap <Leader>v :<C-u>vsplit<CR>

"" Git
noremap <Leader>ga :Gwrite<CR>
noremap <Leader>gc :Gcommit<CR>
noremap <Leader>gsh :Gpush<CR>
noremap <Leader>gll :Gpull<CR>
noremap <Leader>gs :Gstatus<CR>
noremap <Leader>gb :Gblame<CR>
noremap <Leader>gd :Gvdiff<CR>
noremap <Leader>gr :Gremove<CR>

" Delete trailing white space on save, useful for Python and CoffeeScript ;)
func! DeleteTrailingWS()
  exe "normal mz"
  %s/\s\+$//ge
  exe "normal `z"
endfunc
autocmd BufWrite *.py :call DeleteTrailingWS()
autocmd BufWrite *.coffee :call DeleteTrailingWS()


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => vimgrep searching and cope displaying
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" When you press gv you vimgrep after the selected text
vnoremap <silent> gv :call VisualSelection('gv')<CR>

" Open vimgrep and put the cursor in the right position
map <leader>g :vimgrep // **/*.<left><left><left><left><left><left><left>

" Vimgreps in the current file
map <leader><space> :vimgrep // <C-R>%<C-A><right><right><right><right><right><right><right><right><right>

" When you press <leader>r you can search and replace the selected text
vnoremap <silent> <leader>r :call VisualSelection('replace')<CR>

" Do :help cope if you are unsure what cope is. It's super useful!
"
" When you search with vimgrep, display your results in cope by doing:
"   <leader>cc
"
" To go to the next search result do:
"   <leader>n
"
" To go to the previous search results do:
"   <leader>p
"
" map <leader>cc :botright cope<cr>
map <leader>co ggVGy:tabnew<cr>:set syntax=qf<cr>pgg
map <leader>n :cn<cr>
map <leader>p :cp<cr>


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Spell checking
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Pressing ,ss will toggle and untoggle spell checking
set spell
map <leader>ss :setlocal spell!<cr>

" Shortcuts using <leader>
map <leader>sn ]s
map <leader>sp [s
map <leader>sa zg
map <leader>s? z=


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Misc
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Remove the Windows ^M - when the encodings gets messed up
noremap <Leader>m mmHmt:%s/<C-V><cr>//ge<cr>'tzt'm

" Quickly open a buffer for scripbble
map <leader>q :e ~/buffer<cr>

" Toggle paste mode on and off
map <leader>pp :setlocal paste!<cr>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Debugger 
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Enable default vim 8+ termdebug
packadd termdebug

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Helper functions
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! CmdLine(str)
    exe "menu Foo.Bar :" . a:str
    emenu Foo.Bar
    unmenu Foo
endfunction

function! VisualSelection(direction) range
    let l:saved_reg = @"
    execute "normal! vgvy"

    let l:pattern = escape(@", '\\/.*$^~[]')
    let l:pattern = substitute(l:pattern, "\n$", "", "")

    if a:direction == 'b'
        execute "normal ?" . l:pattern . "^M"
    elseif a:direction == 'gv'
        call CmdLine("vimgrep " . '/'. l:pattern . '/' . ' **/*.')
    elseif a:direction == 'replace'
        call CmdLine("%s" . '/'. l:pattern . '/')
    elseif a:direction == 'f'
        execute "normal /" . l:pattern . "^M"
    endif

    let @/ = l:pattern
    let @" = l:saved_reg
endfunction


" Returns true if paste mode is enabled
function! HasPaste()
    if &paste
        return 'PASTE MODE  '
    en
    return ''
endfunction

" Don't close window, when deleting a buffer
command! Bclose call <SID>BufcloseCloseIt()
function! <SID>BufcloseCloseIt()
   let l:currentBufNum = bufnr("%")
   let l:alternateBufNum = bufnr("#")

   if buflisted(l:alternateBufNum)
     buffer #
   else
     bnext
   endif

   if bufnr("%") == l:currentBufNum
     new
   endif

   if buflisted(l:currentBufNum)
     execute("bdelete! ".l:currentBufNum)
   endif
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Plugins configs
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" ----------------------- Nerd comments -------------------------
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

" ---------------------- Nerd tree toogle --------------------------
" " NERDTree map key
map <F3> :NERDTreeToggle <CR>
let g:NERDTreeMouseMode = 2

" ------------------------- Tagbar -------------------------------
nmap <silent> <F4> :TagbarToggle<CR>
let g:tagbar_autofocus = 1


" Tagbar
nmap <silent> <F4> :TagbarToggle<CR>
let g:tagbar_autofocus = 1

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


" Tagbar
nmap <silent> <F4> :TagbarToggle<CR>
let g:tagbar_autofocus = 1

" Vim airline
let g:airline#extensions#tabline#enabled = 1

autocmd FileType javascript set formatprg=prettier\ --stdin

" IndentLine
" set list listchars=tab:>-,trail:.,extends:>
" set listchars=space:.
let g:indentLine_leadingSpaceEnabled = 1
:nnoremap <Leader>il :IndentLinesToggle<CR>
:nnoremap <Leader>ls :LeadingSpaceToggle<CR>

" " Pymode
" " Turn on the whole plugin
" let g:pymode = 1
" " to support python3
" let g:pymode_python = 'python3'
" " Trim unused white spaces on save
" let g:pymode_trim_whitespaces = 1
" " Enable pymode indentation
" let g:pymode_indent = 1
" " Enable pymode folding
" let g:pymode_folding = 0
" " Enable automatic virtualenv detection
" let g:pymode_virtualenv = 1
" " Turn on the run code script
" let g:pymode_run = 1
" " Enable breakpoints functionality
" let g:pymode_breakpoint = 1
" let g:pymode_breakpoint_bind = '<leader>b'
" " Disable code checking
" let g:pymode_lint = 0


" Insert Emmet configuration
let g:user_emmet_leader_key=';'
let g:user_emmet_mode='a'    "enable all function in all mode.
let g:user_emmet_settings = {
  \  'javascript.jsx' : {
    \      'extends' : 'jsx',
    \  },
  \}

" Black configuration
let g:black_linelength=80
