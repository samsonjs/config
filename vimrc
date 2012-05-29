" sjs's .vimrc
"
" created: 2004.02.08
" updated: Tue 10 Nov 2009 22:18:25 PST

" {{{ * Global Settings
set nocompatible		" we should set this first since it resets things
autocmd!

filetype plugin on		" detect the type of file
filetype indent on
filetype on
"set autowrite				" write changed files when :make is executed
set cf						" enable error files and error jumping
set clipboard+=unnamed		" put yanks/etc on the clipboard
set history=1000			" How many lines of history to remember
set path=~/,.,,
set cdpath=~/,.,
set nobackup					" don't create backup files
"set backupcopy=yes          " copy the file, then overwrite the original
set backupskip=/tmp/*,/private/tmp/*" " don't mess with cron, visudo, etc

" }}}


" {{{ * Plugin Settings
"let spell_auto_type="tex,mail,text,html,cvs,human,none"
"let spell_markup_ft=",html,php,xhtml,tex,mail,human,none,"
"let spell_executable="aspell"
" }}}

" {{{ * Colours and Fonts
set background=dark		" we are using a dark background
colorscheme murphy		" bright, maybe too red though
set guifont=Bitstream\ Vera\ Sans\ Mono\ 12

" for some reason fg and bg are inverted!
"autocmd FileType mail highlight Search ctermbg=yellow ctermfg=black term=reverse term=underline
"autocmd FileType mail highlight statusline ctermbg=0 ctermfg=2*

" }}}

" {{{ * User Interface
syntax on						" syntax highlighting is a Good Thing(tm)
set backspace=2					" make backspace work normal (=eol,indent,start)
set gdefault					" assume the /g flag on :s substitutions
set hidden						" you can change buffer without saving
set smartcase					" ignore case unless uppercase letters in search
set iskeyword=@,48-57,_,-		" chars which are parts of words
								" @ = a-z,A-Z (really means isalpha() is true)
set lz							" do not redraw while running macros (much faster) (LazyRedraw)
set mouse=						" don't use the mouse
"set number						" turn on line numbers
set report=0					" tell us when anything is changed via :...
set shortmess=aItr				" shortens messages to avoid 'press a key' prompt 
set sidescroll=10				" show a context of 10 cols when scrolling horiz
set whichwrap+=<,>,h,l,~,[,]	" backspace and cursor keys wrap to
set wildmenu					" turn on wild menu
set wildmode=list:longest,full	" complete longest match, then in full

set comments+=b:\"      " treat lines starting with a quote mark as comments (for `Vim' files) 
set incsearch           " BUT do highlight as you type your search phrase
set nohlsearch          " do not highlight searched for phrases
set laststatus=2        " always show the status line

" this is from ciaranm's webpage,
" http://dev.gentoo.org/~ciaranm/docs/vim-guide
if (&termencoding == "utf-8") || has("gui_running")
	if v:version >= 700
		set listchars=eol:$,tab:>-,trail:.,extends:>,nbsp:\u2017
	else
		set listchars=eol:$,tab:>-,trail:.,extends:>
	endif
else
	if v:version >= 700
		set listchars=eol:$,tab:>-,trail:.,extends:>,nbsp:_
	else
		set listchars=eol:$,tab:>-,trail:.,extends:>
	endif
endif
set nolist

set matchpairs+=<:>     " have % bounce between angled brackets, as well as other kinds:
set showmatch           " show matching brackets
set showmode            " show mode in status line
set so=10               " Keep 10 lines (top/bottom) for scope
set statusline=%F%m%r%h%w\ (%L\l)\ --\ Buf:%-3.3n\ Fmt:%{&ff}\ %=\ [ASCII=\%03.3b,\ 0x\%02.2B]\ %04l,%03v(%p%%)
"set statusline=\ (%n)\ %F\ [%{&ff}%M%R%H%W\ %L\ lines]%=%l,%c\ --%p%%--\ 
" }}}

" {{{ * Text Formatting
"---------------------------------
set autoindent
set formatoptions+=ln	" see :h formatoptions
set expandtab			" spaces, not tabs
set nowrap				" don't wrap lines
set tabstop=4			" tab spacing
set shiftwidth=4
set smarttab			" use tabs at the start of a line, spaces elsewhere
" }}}


" {{{ * Folding
set foldenable        " Turn on folding
set foldlevel=100     " Don't autofold anything (but I can still fold manually)
set foldmethod=marker " Make folding marker sensitive
set foldminlines=3	  " don't fold less than 3 lines on me
"set foldopen-=search  " don't open folds when you search into them
set foldopen-=undo    " don't open folds when you undo stuff

" }}}

" {{{ * File Explorer
let g:explVertical=0 " should I split verticially
let g:explWinSize=35 " width of 35 pixels
" }}}

" {{{ * Win Manager
let g:winManagerWidth=35 " How wide should it be( pixels)
let g:winManagerWindowLayout = 'FileExplorer,TagsExplorer|BufExplorer' " What windows should it
" }}}

" {{{ * CTags
let Tlist_Ctags_Cmd = '/usr/bin/ctags' " Location of ctags
let Tlist_Sort_Type = "name"           " order by 
let Tlist_Use_Right_Window = 1         " split to the right side of the screen
set tags=./tags,../tags,../../tags
" }}}

" {{{ * Minibuf
let g:miniBufExplTabWrap = 1 " make tabs show complete (no broken on two lines)
" }}}

" {{{ * Mappings
" right arrow (normal mode) switches buffers  (excluding minibuf)
"map <right> <ESC>:MBEbn<RETURN>
" left arrow (normal mode) switches buffers (excluding minibuf)
"map <left> <ESC>:MBEbp<RETURN>
" up arrow (normal mode) brings up a file list
"map <up> <ESC>:Sexplore<RETURN><ESC><C-W><C-W> 
" down arrow  (normal mode) brings up the tag list
"map <down> <ESC>:Tlist<RETURN>

" [<-> by default is like k]
noremap - <PageUp>

" make enter insert a blank line
nnoremap <RETURN> O<ESC>j

" ctrl-n to cycle forwrd through files
"nnoremap <C-N> :next<CR>
nnoremap <C-N> :bnext<CR>

" ctrl-p to cycle backwards
"nnoremap <C-P> :prev<CR>
nnoremap <C-P> :bprev<CR>

" control-c comments block
vmap <C-C> :s/^/#/g<enter>

" control-x uncomments block
vmap <C-X> :s/^#//g<enter>

" have the usual indentation keystrokes still work in visual mode:
vnoremap <C-D> <LT>
vnoremap <C-T> >
vmap <Tab> <C-T>
vmap <S-Tab> <C-D>

" have <F1> prompt for a help topic, rather than displaying the introduction
" page, and have it do this from any mode:
nnoremap <F1> :help<Space>
vmap <F1> <C-C><F1>
omap <F1> <C-C><F1>
map! <F1> <C-C><F1>

" run current file through python
map <F8> :w<CR>:!python %<CR>
map <F9> :w<CR>:!xterm -e python -i % &<CR><CR>

" miniBufExplorer settings for good key mappings!
let g:miniBufExplMapWindowNavVim = 1
"let g:miniBufExplMapWindowNavArrows = 1
let g:miniBufExplMapCTabSwitchBuffs = 1

" Tip: 108 Toggle a fold with a single keystroke {{{
" Toggle fold state between closed and opened.
" Based on Vim tip:
" http://www.vim.org/tips/tip.php?tip_id=108
" Explanation:
" - 'normal! za' toggles folds.
" - 'silent!' allows to avoid error message when current line doesn't delong
" "   to fold.
" - (foldlevel('.')?'':'l') adds forward moving only if current line doesn't
" "   belong to fold.
"nnoremap  <silent>  <space> :exe 'silent! normal! za'.(foldlevel('.')?'':'l')<cr>
"nnoremap  <silent>  <C-space> :exe 'silent! normal! zM'.(foldlevel('.')?'':'l')<cr>

" changed to just toggle with 'za'
nnoremap  <silent>  <space> :exe 'silent! normal! za'<cr>
nnoremap  <silent>  <C-space> :exe 'silent! normal! zM'.(foldlevel('.')?'':'l')<cr>
" }}}

" }}}

"  * Autocommands {{{
"-----------------------

" cd to directory containg current buffer (awesome!)
"autocmd BufEnter * execute ":lcd '" . expand("%:p:h") . "'"

"autocmd BufEnter * :syntax sync fromstart " ensure every file does syntax highlighting (full)

"let g:detectindent_preferred_expandtab = 1
"let g:detectindent_preferred_indent = 4
"autocmd BufReadPost * :DetectIndent

"autocmd FileType c setlocal formatoptions+=ro
autocmd FileType c setlocal si foldmethod=indent foldminlines=1 foldlevel=100 foldnestmax=1
"autocmd FileType c,cpp,slang setlocal cindent 
autocmd FileType css,php setlocal foldmethod=indent
autocmd FileType css,perl,php setlocal smartindent
autocmd FileType css,html,php,xml setlocal formatoptions+=tl
autocmd FileType css,html,php,xml setlocal noexpandtab tabstop=4
autocmd FileType asm,make setlocal noexpandtab tabstop=8 shiftwidth=8

autocmd FileType eclectic setlocal syntax=sh
autocmd FileType sh setlocal si fdm=marker fdl=5
"autocmd FileType python source ~/.vim/scripts/python.vim
autocmd FileType python setlocal sw=4 ts=4 si fdm=indent
autocmd FileType python set complete+=k/home/sjs/hack/pydiction/pydiction

autocmd FileType mail :nmap <F8> :w<CR>:!aspell -e -c %<CR>:e<CR>
autocmd FileType mail setlocal nonu noai nosi et tw=72 comments=b:#,:%,fb:-,n:>,n:) sm! fo+=a
autocmd FileType mail highlight SpellErrors ctermfg=red ctermbg=black cterm=underline term=reverse

" }}}


"  * Informational abbrevs {{{
"--------------------------------
iab xdate <c-r>=strftime("%d/%m/%y %H:%M:%S")<cr>
iab xname Sami Samhuri
iab xschool University of Victoria

" }}}

" vim: set fdm=marker fdl=3 foldminlines=3 :
