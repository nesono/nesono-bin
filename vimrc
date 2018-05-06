" vimrc file useful for C/C++ programming with folders,
" automatic indentation support, trailing whitespaces removal, etc.

" Copyright (c) 2012, Jochen Issing <iss@nesono.com>
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

filetype off        " required!

set rtp+=~/.vim/bundle/vundle/
call vundle#begin()

" let Vundle manage Vundle -- REQUIRED!
Plugin 'gmarik/vundle'

" to actually install those call BundleInstall!
Plugin 'rhysd/vim-clang-format'
Plugin 'lyuts/vim-rtags'
"Plugin 'Valloric/YouCompleteMe'
Plugin 'tpope/vim-fugitive'
Plugin 'tpope/vim-speeddating'
Plugin 'tpope/vim-surround'
Plugin 'tpope/vim-abolish'
Plugin 'tpope/vim-unimpaired'
Plugin 'mileszs/ack.vim'
Plugin 'scrooloose/nerdcommenter'
Plugin 'scrooloose/nerdtree'
"Plugin 'scrooloose/syntastic'
Plugin 'vim-scripts/gtags.vim'
Plugin 'derekwyatt/vim-fswitch'
Plugin 'vim-scripts/Align'
"Plugin 'ervandew/supertab'
Plugin 'mbbill/undotree'
Plugin 'flazz/vim-colorschemes'
Plugin 'kien/ctrlp.vim'
"Plugin 'mattn/emmet-vim'
Plugin 'milkypostman/vim-togglelist'
Plugin 'rizzatti/dash.vim'
Plugin 'vim-scripts/vcscommand.vim'
if has("unix")
	"Plugin 'vim-scripts/vim-gitgutter'
endif
"Plugin 'OmniSharp/omnisharp-vim'
"Plugin 'tpope/vim-sleuth'
"Plugin 'SirVer/ultisnips'
"Plugin 'klen/python-mode'

filetype plugin indent on     " required!
" All of your Plugins must be added before the following line
call vundle#end()            " required

" enable ag for ack.vim
if executable('ag')
  let g:ackprg = 'ag --vimgrep'
endif

" configure clang-format
let g:clang_format#code_style="llvm"

"autocmd FileType c,cpp,objc nnoremap <buffer><Leader>ff :<C-u>ClangFormat<CR>
"autocmd FileType c,cpp,objc vnoremap <buffer><Leader>ff :ClangFormat<CR>

" change the mapleader from \ to ,
let mapleader=","

"let g:user_emmet_leader_key='<C-e>'
" create Emmet mappings only for normal mode
"let g:user_emmet_mode = 'n'

" SuperTab option for context aware completion
let g:SuperTabDefaultCompletionType = "context"

" Use this color in command-t for the selected item
let g:CommandTHighlightColor = 'Pmenu'

let g:CommandTMaxFiles = 500000

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
	set guifont=Source_Code_Pro:h10
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
		match OverLength /\%81v.\+/
		let b:overlengthhi = 1
		echo "overlength hilight on"
	endif
endfunction

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
	"au FileType python set lcs=tab:\|\ 
	"au FileType python set list
	"au FileType python hi SpecialKey term=bold ctermfg=7 gui=bold guifg=Gray30
	au FileType python set makeprg=python\ %
endif

if has("gui_running")
	if has("gui_macvim")
		" disable antialiasing in guis
		"set noantialias
		" set gui font
		set gfn=SourceCodePro+Powerline+Awesome\ Regular:h12
	elseif has("gui_win32")
		set guifont=Consolas:h11:cANSI
	endif
endif

" set color scheme
set background=light
silent! colorscheme solarized

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

" open each buffer as it's own tabpage:
" disable because NERDTree, etc. is then also opened in separate tab
":au BufAdd,BufNewFile * nested tab sball

" to repair backspace if logged in from Mac to Linux Machine
"if exists( "$SSH_CONNECTION" )
"	:set t_kb=^V<BS>
"	:fixdel
"endif

function! ToggleRelativeAbsoluteLineNumbers()
	if &number == 1
		echom "relative on"
		set relativenumber
		set nonumber
	else
		echom "absolute on"
		set number
		set norelativenumber
	endif
endfunction

noremap <silent> <F4> :call ToggleRelativeAbsoluteLineNumbers()<CR>
noremap <silent> <F5> :nohls<CR>
noremap <silent> <F6> :call ToggleQuickfixList()<CR>
noremap <silent> <F7> :GitGutterToggle<cr>
noremap <silent> <F8> :windo set wrap!<CR>
noremap <silent> <F9> <Esc>:call ToggleOverLengthHi()<CR>
noremap <silent> <F10> :set list!<CR>
noremap <silent> <F11> :call ToggleLocationList()<CR>

" toggle browse tree region
nnoremap <F2> :NERDTreeToggle<CR>
nnoremap <F3> :NERDTreeFind<CR>
" open NERDtree if vim was opened without a file specified
"autocmd vimenter * if !argc() | silent! NERDTree | endif

" toggle undotree region
"nnoremap <F3> :UndotreeToggle<CR>


" copy current file name (relative/absolute) to system clipboard
if has("mac") || has("gui_macvim") || has("gui_mac")
	nnoremap <leader>cf :let @*=expand("%")<CR>
	nnoremap <leader>cF :let @*=expand("%:p")<CR>
	nnoremap <leader>ct :let @*=expand("%:t")<CR>
	nnoremap <leader>ch :let @*=expand("%:p:h")<CR>
	nnoremap <leader>ln :let @*=line(".")<CR>
	nnoremap <leader>cfn :let @*=expand("%").":".line(".")<CR>
endif

" copy current file name (relative/absolute) to system clipboard (Linux version)
if has("gui_gtk") || has("gui_gtk2") || has("gui_gnome") || has("unix")
	nnoremap <leader>cf :let @+=expand("%")<CR>
	nnoremap <leader>cF :let @+=expand("%:p")<CR>
	nnoremap <leader>ct :let @+=expand("%:t")<CR>
	nnoremap <leader>ch :let @+=expand("%:p:h")<CR>
	nnoremap <leader>ln :let @+=line(".")<CR>
	nnoremap <leader>cfn :let @+=expand("%").":".line(".")<CR>
endif

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

" gnu/global mapping
nnoremap <leader>gtt :Gtags<cr><cr>
nnoremap <leader>gt :Gtags
nnoremap <leader>gtr :Gtags -r<cr><cr>
nnoremap <leader>gtf :Gtags -f<cr><cr>

" FSWITCH mappings
"" Switch to the file and load it into current window
"nmap <silent> <Leader>of :FSHere<cr>
"" Switch to the file and load it into the window on the right >
"nmap <silent> <Leader>ol :FSRight<cr>
"" Switch to the file and load it into a new window split on the right >
"nmap <silent> <Leader>oL :FSSplitRight<cr>
"" Switch to the file and load it into the window on the left >
"nmap <silent> <Leader>oh :FSLeft<cr>
"" Switch to the file and load it into a new window split on the left >
"nmap <silent> <Leader>oH :FSSplitLeft<cr>
"" Switch to the file and load it into the window above >
"nmap <silent> <Leader>ok :FSAbove<cr>
"" Switch to the file and load it into a new window split above >
"nmap <silent> <Leader>oK :FSSplitAbove<cr>
"" Switch to the file and load it into the window below >
"nmap <silent> <Leader>oj :FSBelow<cr>
"" Switch to the file and load it into a new window split below >
"nmap <silent> <Leader>oJ :FSSplitBelow<cr>

if has("cscope")
	"set csprg=cscope
	set csto=0
	set cst
	set nocsverb
	" add any database in current directory
	if filereadable("cscope.out")
		cs add cscope.out
		" else add database pointed to by environment
	elseif $CSCOPE_DB != ""
		cs add $CSCOPE_DB
	endif
	set cscopequickfix=s-,c-,d-,i-,t-,e-
endif

" cscope short cuts
nnoremap <C-\>s :cs f s <C-R>=expand("<cword>")<cr><cr>
nnoremap <C-\>g :cs f g <C-R>=expand("<cword>")<cr><cr>
nnoremap <C-\>c :cs f c <C-R>=expand("<cword>")<cr><cr>
nnoremap <C-\>d :cs f d <C-R>=expand("<cfile>")<cr><cr>
nnoremap <C-\>t :cs f t <C-R>=expand("<cword>")<cr><cr>
nnoremap <C-\>e :cs f e <C-R>=expand("<cword>")<cr><cr>
nnoremap <C-\>f :cs f f <C-R>=expand("<cfile>")<cr><cr>
nnoremap <C-\>i :cs f i <C-R>=expand("<cfile>")<cr><cr>

nnoremap <C-\>vs :scs f s <C-R>=expand("<cword>")<cr><cr>
nnoremap <C-\>vg :scs f g <C-R>=expand("<cword>")<cr><cr>
nnoremap <C-\>vc :scs f c <C-R>=expand("<cword>")<cr><cr>
nnoremap <C-\>vd :scs f d <C-R>=expand("<cfile>")<cr><cr>
nnoremap <C-\>vt :scs f t <C-R>=expand("<cword>")<cr><cr>
nnoremap <C-\>ve :scs f e <C-R>=expand("<cword>")<cr><cr>
nnoremap <C-\>vf :scs f f <C-R>=expand("<cfile>")<cr><cr>
nnoremap <C-\>vi :scs f i <C-R>=expand("<cfile>")<cr><cr>

" buffer handling
nnoremap <leader>bo :only<cr>     " keep only this buffer open (in split view)
nnoremap <leader>bd :bd<cr>       " delete buffer

" fugitive handling
nnoremap <leader>gb :Gblame<cr>
nnoremap <leader>gp :Gpull --rebase<cr>
nnoremap <leader>gf :Gfetch --all --prune<cr>
nnoremap <leader>gs :Gstatus<cr>
nnoremap <leader>gr :Gread<cr>
nnoremap <leader>gw :Gwrite<cr>
nnoremap <leader>gd :Gdiff<cr>
nnoremap <leader>gll :Glog<cr>
nnoremap <leader>gl :Glog
nnoremap <leader>gg :Ggrep
nnoremap <leader>go :Gbrowse<cr>
nnoremap <leader>gm :Gmove

" VCSCommand short cuts
nnoremap <leader>vb :VCSBlame<cr>
nnoremap <leader>vs :VCSStatus<cr>
nnoremap <leader>vc :VCSCommit<cr>
nnoremap <leader>va :VCSAdd<cr>
nnoremap <leader>vd :VCSVimDiff<cr>
nnoremap <leader>vi :VCSInfo<cr>
nnoremap <leader>vl :VCSLog<cr>
nnoremap <leader>vu :VCSUpdate<cr>

" YouCompleteMe short cuts
nnoremap <leader>yg :YcmCompleter GoTo<cr>
nnoremap <leader>yr :YcmCompleter GoToReferences<cr>
nnoremap <leader>yi :YcmCompleter GoToImplementation<cr>
nnoremap <leader>yt :YcmCompleter GetType<cr>
nnoremap <leader>yp :YcmCompleter GetParent<cr>
nnoremap <leader>yd :YcmCompleter GetDoc<cr>
nnoremap <leader>yf :YcmCompleter FixIt<cr>
nnoremap <leader>yn :YcmCompleter RefactorRename<cr>

set statusline=%<%f\ %h%m%r%{fugitive#statusline()}%=%-14.(%l,%c%V%)\ %P
set laststatus=2

" ~/.vimrc ends here
