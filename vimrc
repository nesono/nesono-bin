" vimrc file useful for C/C++ programming with folders,
" automatic indentation support, trailing whitespaces removal, etc.

" We use a vim
set nocompatible
"
" Colo(u)red or not colo(u)red
" If you want color you should set this to true

let color = "true"

if has("syntax")
    if color == "true"
	" This will switch colors ON
	so ${VIMRUNTIME}/syntax/syntax.vim
    else
	" this switches colors OFF
	syntax off
	set t_Co=0
    endif
endif

" folder stuff
set foldmethod=syntax
"set foldopen=all
"set foldclose=all
set foldlevel=100
"syn region myFold start="{" end="}" transparent fold
"syn sync fromstart

" basic indentation rules
" see cinoptions-values for descr
set cino=>2,:0,=2,g0,h2,t0,+4,c2,(0,W4,u2
set autoindent
set tabstop=2
" search options
set ic
set smartcase
set incsearch
set hlsearch
" to show line numbers
set number
" show ruler at all time
set ruler
" enable line wrapping
set wrap
highlight OverLength ctermbg=darkred guibg=#191919

" Move cursor by lines on *screen* instead of lines in *file*
nnoremap j gj
nnoremap k gk
vnoremap j gj
vnoremap k gk
nnoremap <Down> gj
nnoremap <Up> gk
vnoremap <Down> gj
vnoremap <Up> gk
inoremap <Down> <C-o>gj
inoremap <Up> <C-o>gk

" make blank spaces at EOL red
let c_space_errors=1

" for dark backgrounds
set bg=dark
if has("gui_running")
  colorscheme torte
endif

" make blank spaces from tabs
set expandtab
if has("autocmd")
  " enable file type detection
  filetype plugin on

  " remove blank spaces at EOL at saving buffer
  autocmd BufWritePre * :%s/\s\+$//e
  " set file text width for c files
  au FileType cpp,c set textwidth=78
  " enable highlighing of over long lines
  au FileType cpp,c match OverLength /\%80v.*/

  " to enable cindent only for specific files
  au FileType cpp,c set cindent
  au FileType cpp,c let Tlist_Auto_Open=1

  "autocmd BufNewFile,BufRead *.c set cindent
  "autocmd BufNewFile,BufRead *.cc set cindent
  "autocmd BufNewFile,BufRead *.cpp set cindent
  "autocmd BufNewFile,BufRead *.cpp let Tlist_Auto_Open=1
  "autocmd BufNewFile,BufRead *.cxx set cindent
  "autocmd BufNewFile,BufRead *.cxx let Tlist_Auto_Open=1
  "autocmd BufNewFile,BufRead *.h set cindent
  "autocmd BufNewFile,BufRead *.hpp set cindent
  "autocmd BufNewFile,BufRead *.hpp let Tlist_Auto_Open=1
  "autocmd BufNewFile,BufRead *.tcc set cindent
endif

"if $OSTYPE == "linux-gnu"
"  vmap <F6> :!xclip -f -sel clip<CR>
"  map <F7> :-1r !xclip -o -sel clip<CR>
"endif
"if $OSTYPE == "darwin10.0"
"  nmap <F6> :set paste<CR>:r !pbpaste<CR>:set nopaste<CR>
"  imap <F7> <Esc>:set paste<CR>:r !pbpaste<CR>:set nopaste<CR>
"  nmap <F6> :.w !pbcopy<CR><CR>
"  vmap <F7> :w !pbcopy<CR><CR>
"endif

" to repair backspace if logged in from Mac to Linux Machine
"if exists( "$SSH_CONNECTION" )
"  :set t_kb=^V<BS>
"  :fixdel
"endif

" some useful mappings
map ,v :sp ~/.vimrc<cr>     " edit my .vimrc file in a split
map ,e :e ~/.vimrc<cr>      " edit my .vimrc file
map ,u :source ~/.vimrc<cr> " update the system settings from my vimrc file
map <F5> :nohls<CR>         " disable search result highlighting
map <c-n> :bn<CR>           " edit next file in buffer
map <c-p> :bp<CR>           " edit prev file in buffer
map <c-s> :w<CR>            " Ctrl-s saves file ;)
map <c-l> :e#<CR>           " Ctrl-l edits last file

" ~/.vimrc ends here
