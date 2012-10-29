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
set cino=>2,:0,=2,g0,h2,t0,+4,c2,(0,W4,u2,N-s
" default indentation settings
set autoindent
set tabstop=2
set shiftwidth=2
set nolist
" enable this as soon, as you are away from mmt ;)
"set smarttab
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

" for dark backgrounds
"set bg=dark
" for light backgrounds
set bg=light
if has("gui_running")
	colorscheme torte
endif

if has("autocmd")
	" enable file type detection
	filetype plugin on

	" remove blank spaces at EOL at saving buffer
	au FileType cpp,c autocmd BufWritePre * :%s/\s\+$//e
	" set file text width for c files
	au FileType cpp,c set textwidth=78

	" enable highlighing of over long lines
	"au FileType cpp,c match OverLength /\%80v.*/
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

  function! SwitchCppSourceHeader()
    if (expand ("%:e") == "cpp")
      find %:t:r.h
    else
      find %:t:r.cpp
    endif
  endfunction
  function! SwitchCSourceHeader()
    if (expand ("%:e") == "cpp")
      find %:t:r.h
    else
      find %:t:r.cpp
    endif
  endfunction

  au FileType cpp nmap <F11> :call SwitchCppSourceHeader()<CR>
  au FileType c nmap <F11> :call SwitchCSourceHeader()<CR>

	" to enable cindent only for specific files
	au FileType cpp,c set cindent
	au FileType cpp,c let Tlist_Auto_Open=1
	" insert tabs only at beginning of line
	"au FileType cpp,c set smarttab
	" make blank spaces from tabs for c(pp) files
	au FileType cpp,c set expandtab

  " also don't use tabs to indent in cmake
	au FileType cmake set expandtab

	" enable some useful stuff for python
	au FileType python set smartindent
	au FileType python inoremap # X#
	au FileType python set autoindent
	" insert tabs only at beginning of line
	au FileType python set smarttab
	" set tab widths
	au FileType python set shiftwidth=4
	au FileType python set tabstop=4
	" show indentation for python
	au FileType python set lcs=tab:\|\ 
	au FileType python set list
	au FileType python hi SpecialKey term=bold ctermfg=7 gui=bold guifg=Gray30

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

" check for underlying system - needed for clipboard
let uname = substitute(system("uname"),"\n","","g")

if uname == "Darwin"
	" setup copy paste with system for darwin
	nmap <F6> :.w !pbcopy<CR><CR>
	vmap <F6> :w !pbcopy<CR><CR>
	nmap <F7> :set paste<CR>:r !pbpaste<CR>:set nopaste<CR>
	imap <F7> <Esc>:set paste<CR>:r !pbpaste<CR>:set nopaste<CR>
	" setup TexSync with Skim
	map ,r :w<CR>:silent !/Applications/Skim.app/Contents/SharedSupport/displayline <C-r>=line('.')<CR> %<.pdf %<CR>
elseif uname == "Linux"
	" setup copy paste with system for Linux
	vmap <F6> :!xclip -f -sel clip<CR>
	map <F7> :-1r !xclip -o -sel clip<CR>
endif

" to repair backspace if logged in from Mac to Linux Machine
"if exists( "$SSH_CONNECTION" )
"	:set t_kb=^V<BS>
"	:fixdel
"endif

" some useful mappings for the vimrc
map ,v :sp ~/.vimrc<cr>     " edit my .vimrc file in a split
map ,e :e ~/.vimrc<cr>      " edit my .vimrc file
map ,u :source ~/.vimrc<cr> " update the system settings from my vimrc file

" some useful mappings for vimdiff
nnoremap ,d :diffupdate<cr>
nnoremap ,g :diffget<cr>
nnoremap ,p :diffput<cr>
nnoremap ,h :vnew<cr>:q<cr>

" some useful mappings for searching, buffer edits
map <F5> :nohls<CR>         " disable search result highlighting
" remove trailing whitespaces (not necessary for c/cpp)
map <F8> :%s/\s\+$//e<CR>
map <c-n> :bn<CR>           " edit next file in buffer
map <c-p> :bp<CR>           " edit prev file in buffer
"map <c-s> :w<CR>            " Ctrl-s saves file ;)
map <c-l> :e#<CR>           " Ctrl-l edits last file
map <silent> <F9> <Esc>:call ToggleOverLengthHi()<CR>

" mapping for tags: getting back from tag
"nnoremap <c-[> :pop<CR>

" use F4 to insert current file name at cursor
nnoremap <F4> :put =expand('%:t')<CR>kJ
inoremap <F4> <Esc>:put =expand('%:t')<CR>kJ<Esc>A
" search for keyword under cursor in current dir
"nnoremap <F6> :grep <C-R><C-W> *<CR>

autocmd VimEnter,VimLeave * silent !tmux set status

if has("gui_macvim")
	" disable antialiasing in guis
	set noantialias
	" set gui font
	set gfn=Monaco:h10
endif
" ~/.vimrc ends here
