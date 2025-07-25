" vimrc file useful for C/C++ programming with folders,
" automatic indentation support, trailing whitespaces removal, etc.

" Copyright (c) 2025, Jochen Issing <c.333+github@nesono.com>
" All rights reserved.
"
" Redistribution and use in source and binary forms, with or without
" modification, are permitted provided that the following conditions are met:
" * Redistributions of source code must retain the above copyright
"   notice, this list of conditions and the following disclaimer.
" * Redistributions in binary form must reproduce the above copyright
"   notice, this list of conditions and the following disclaimer in the
"   documentation and/or other materials provided with the distribution.
" * Neither the name of the <organization> nor the
"   names of its contributors may be used to endorse or promote products
"   derived from this software without specific prior written permission.
"
" THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
" ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
" WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
" DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
" DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
" (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
" LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
" ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
" (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
" SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

" We use a vim
set nocompatible    " be iMproved :)
" automatically re-read modified files (except deleted)
set autoread
set encoding=utf-8

" fix for running vim within fish
set shell=/bin/bash

filetype off        " required!
" Specify a directory for plugins
" - For Neovim: stdpath('data') . '/plugged'
" - Avoid using standard Vim directory names like 'plugin'
call plug#begin('~/.vim/plugged')

" Add maktaba and codefmt to the runtimepath.
" (The latter must be installed before it can be used.)
Plug 'google/vim-maktaba'
Plug 'google/vim-codefmt'
" Also add Glaive, which is used to configure codefmt's maktaba flags. See
" `:help :Glaive` for usage.
Plug 'google/vim-glaive'

Plug 'Valloric/YouCompleteMe'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-speeddating'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-abolish'
Plug 'tpope/vim-unimpaired'
Plug 'mileszs/ack.vim'
Plug 'scrooloose/nerdcommenter'
Plug 'scrooloose/nerdtree'
Plug 'tpope/vim-vinegar'
Plug 'vim-scripts/gtags.vim'
Plug 'flazz/vim-colorschemes'
Plug 'kien/ctrlp.vim'
"Plug 'mattn/emmet-vim'
Plug 'milkypostman/vim-togglelist'
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
"Plug 'powerline/powerline'
Plug 'neovimhaskell/haskell-vim'
Plug 'justinmk/vim-dirvish'

if has("unix")
    Plug 'vim-scripts/vim-gitgutter'
endif
" enable fzf usage in vim
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
" Initialize plugin system
call plug#end()

" Before using powerline, please install python3-pip and run
" > pip3 install powerline-statusbar
" To see the fonts then, please install fonts-powerline
" Enable powerline status bar
"python3 from powerline.vim import setup as powerline_setup
"python3 powerline_setup()
"python3 del powerline_setup

let g:ycm_autoclose_preview_window_after_insertion = 1
let g:ycm_autoclose_preview_window_after_completion = 1

if has("unix")
    let s:uname = system("uname -s")
    if s:uname == "Darwin"
        " fix leading ^G in nerdtree on macos
        let g:NERDTreeNodeDelimiter = "\u00a0"
    endif
endif

" enable ag for ack.vim
if executable('ag')
  let g:ackprg = 'ag --vimgrep'
endif

if executable('rg')
  let g:ctrlp_user_command = 'rg --files %s'
  let g:ctrlp_use_caching = 0
  let g:ctrlp_working_path_mode = 'ra'
  let g:ctrlp_switch_buffer = 'et'

  let g:ackprg = 'rg --vimgrep --no-heading'
endif

filetype plugin indent on     " required!


" change the mapleader from \ to ,
let mapleader=","

augroup autoformat_settings
  autocmd FileType bzl AutoFormatBuffer buildifier
  autocmd FileType c,cpp,proto,javascript AutoFormatBuffer clang-format
  autocmd FileType dart AutoFormatBuffer dartfmt
  autocmd FileType go AutoFormatBuffer gofmt
  autocmd FileType gn AutoFormatBuffer gn
  autocmd FileType html,css,json AutoFormatBuffer js-beautify
  autocmd FileType java AutoFormatBuffer google-java-format
  autocmd FileType python AutoFormatBuffer yapf3
  " Alternative: autocmd FileType python AutoFormatBuffer autopep8
augroup END

"let g:user_emmet_leader_key='<C-e>'
" create Emmet mappings only for normal mode
"let g:user_emmet_mode = 'n'

" Colo(u)red or not colo(u)red
" If you want color you should set this to true

let color = "true"

if has("unix")
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
set cino=>4,:0,=4,g2,h2,t0,+8,c4,(0,W8,u4,N-s

" indentation settings (should be done with vim-sleuth?)
set autoindent
set tabstop=4
set shiftwidth=4
set expandtab
"set smarttab

set nolist
" enable this as soon, as you are away from mmt ;)
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

nnoremap <Home> g<Home>
nnoremap <End> g<End>
vnoremap <Home> g<Home>
vnoremap <End> g<End>
inoremap <Home> <C-o>g<Home>
inoremap <End> <C-o>g<End>

" make blank spaces at EOL red
let c_space_errors=1

if has("gui_running")
	syntax on
	"set guifont=Source_Code_Pro:h10
endif

" Highlight rows longer than 80 characters
function! ToggleOverLengthHi()
	if exists("b:overlengthhi") && b:overlengthhi
		highlight clear OverLength
		let b:overlengthhi = 0
		echo "overlength hilight off"
	else
		" adjust colors/styles as desired
		highlight OverLength ctermbg=darkred gui=undercurl guisp=blue
		" change '81' to be 1+(number of columns)
		match OverLength /\%121v.\+/
		let b:overlengthhi = 1
		echo "overlength hilight on"
	endif
endfunction

" Some Go language stuff
let g:go_disable_autoinstall = 0
let g:go_fmt_command = "goimports"

" Highlight
let g:go_highlight_functions = 1
let g:go_highlight_methods = 1
let g:go_highlight_structs = 1
let g:go_highlight_operators = 1
let g:go_highlight_build_constraints = 1

if has("autocmd")
	autocmd BufReadPost fugitive://* set bufhidden=delete

	" enable file type detection
	filetype plugin on

    " CPP SETTINGS
	" remove blank spaces at EOL at saving buffer
	au FileType cc,cpp,c autocmd BufWritePre * :%s/\s\+$//e
	" set file text width for c files
	au FileType cc,cpp,c set textwidth=100
	" to enable cindent only for specific files
	au FileType cc,cpp,c set cindent
	au FileType cc,cpp,c let Tlist_Auto_Open=1
	" insert tabs only at beginning of line
	"au FileType cc,cpp,c set smarttab
	" make blank spaces from tabs for c(pp) files
	au FileType cc,cpp,c set expandtab
	" enable highlighing of over long lines
	au FileType cc,cpp,c match OverLength /\%100v.*/
    au FileType cc,cpp,c set autowrite

    " run :GoBuild or :GoTestCompile based on the go file
    function! s:build_go_files()
      let l:file = expand('%')
      if l:file =~# '^\f\+_test\.go$'
        call go#test#Test(0, 1)
      elseif l:file =~# '^\f\+\.go$'
        call go#cmd#Build(0)
      endif
    endfunction

    " enable autowrite when calling :make for go files
    au FileType go set autowrite
    autocmd FileType go nmap <leader>b :<C-u>call <SID>build_go_files()<CR>
    autocmd FileType go nmap <leader>r :GoRun<cr>
    autocmd FileType go nmap <leader>t :GoTest<cr>
    autocmd FileType go nmap <leader>c :GoCoverageToggle<cr>
    autocmd FileType go nmap <leader>i :GoImports<cr>

	" CMAKE SETTINGS
	" also don't use tabs to indent in cmake
	au FileType cmake set expandtab
	au FileType cmake set shiftwidth=4
	au FileType cmake set tabstop=4

  " PYTHON SETTINGS
	"" enable some useful stuff for python
	au FileType python set smartindent
	au FileType python inoremap # X#
	au FileType python set autoindent
	"" insert tabs only at beginning of line
	au FileType python set smarttab
	"" set tab widths
	au FileType python set shiftwidth=4
	au FileType python set tabstop=4
	"" show indentation for python
	"au FileType python set list
	"au FileType python hi SpecialKey term=bold ctermfg=7 gui=bold guifg=Gray30
	au FileType python set makeprg=python\ %

  " HASKELL SETTINGS
    " Tab specific option
    au FileType haskell set tabstop=8                   "A tab is 8 spaces
    au FileType haskell set expandtab                   "Always uses spaces instead of tabs
    au FileType haskell set softtabstop=4               "Insert 4 spaces when tab is pressed
    au FileType haskell set shiftwidth=4                "An indent is 4 spaces
    au FileType haskell set shiftround                  "Round indent to nearest shiftwidth multiple
endif

if has("gui_running")
	if has("gui_win32")
		set guifont=Consolas:h11:cANSI
	endif
endif

" set color scheme
set background=dark
silent! colorscheme materialtheme

command! -nargs=? Filter let @a='' | execute 'g/<args>/y A' | new | setlocal bt=nofile | put! a

if has("unix")
	highlight link GitGutterAdd DiffAdd
	highlight link GitGutterDelete DiffDelete
	highlight link GitGutterChange DiffChange
	highlight clear SignColumn
	let g:gitgutter_sign_added = '+'
	let g:gitgutter_sign_modified = '~'
	let g:gitgutter_sign_removed = '-'
	let g:gitgutter_sign_modified_removed = '+-'
endif

" fix problems with backspace
set backspace=indent,eol,start

" hide buffer instead of closing
set hidden

" do not write backup and/or swap files
set nobackup
set noswapfile

"function! ToggleRelativeAbsoluteLineNumbers()
	"if &number == 1
		"echom "relative on"
		"set relativenumber
		"set nonumber
	"else
		"echom "absolute on"
		"set number
		"set norelativenumber
	"endif
"endfunction

" toggle browse tree region
nnoremap <F2> :NERDTreeToggle<CR>
nnoremap <F3> :NERDTreeFind<CR>
" open NERDtree if vim was opened without a file specified
"autocmd vimenter * if !argc() | silent! NERDTree | endif

noremap <silent> <F4> :call ToggleRelativeAbsoluteLineNumbers()<CR>
noremap <silent> <F5> :nohls<CR>
noremap <silent> <F6> :call ToggleQuickfixList()<CR>
noremap <silent> <F7> :GitGutterToggle<cr>
noremap <silent> <F8> :windo set wrap!<CR>
noremap <silent> <F9> <Esc>:call ToggleOverLengthHi()<CR>
noremap <silent> <F10> :set list!<CR>
noremap <silent> <F11> :call ToggleLocationList()<CR>

let g:ctrlp_cmd = 'CtrlPLastMode'
"nnoremap <leader>pp <c-p><c-\>w

" some useful mappings for the vimrc
map <leader>v :sp ~/.vimrc<cr>     " edit my .vimrc file in a split
map <leader>e :e ~/.vimrc<cr>      " edit my .vimrc file
map <leader>u :source ~/.vimrc<cr> " update the system settings from my vimrc file

" some useful mappings for vimdiff
nnoremap <leader>du :diffupdate<cr>
nnoremap <leader>dg :diffget<cr>
nnoremap <leader>dp :diffput<cr>
nnoremap <leader>dt :windo diffthis<cr>
nnoremap <leader>do :windo diffo<cr>

" fugitive handling
nnoremap <leader>gb :Gblame<cr>
nnoremap <leader>gs :Gstatus<cr>
nnoremap <leader>gl :Git log --oneline -20<cr>
nnoremap <leader>gd :Gdiff<cr>
nnoremap <leader>gw :Gwrite<cr>
nnoremap <leader>ge :Gedit<cr>
nnoremap <leader>gc :Gcommit -v <cr>
nnoremap <leader>ga :Gcommit -v --amend<cr>
nnoremap <leader>gp :Gpush --force-with-lease<cr>
nnoremap <leader>gP :Gpush --force<cr>
nnoremap <leader>gr :Gpull --rebase<cr>
nnoremap <leader>gf :Gfetch --prune<cr>

nnoremap <leader>jd :YcmCompleter GoTo<cr>
nnoremap <leader>jh :YcmCompleter GoToInclude<cr>
nnoremap <leader>fix :YcmCompleter FixIt<cr>

"set statusline=%<%f\ %h%m%r%{fugitive#statusline()}%=%-14.(%l,%c%V%)\ %P
set laststatus=2
let g:lightline = {
    \ 'active': {
    \   'left': [ [ 'mode', 'paste' ],
    \             [ 'gitbranch', 'readonly', 'filename', 'modified' ] ]
    \ },
    \ 'component_function': {
    \   'gitbranch': 'fugitive#head'
    \ },
    \ }

" ~/.vimrc ends here
