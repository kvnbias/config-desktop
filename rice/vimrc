" Copy:
" ~/.vimrc  -> /root/.vimrc
" ~/.vim    -> /root/.vim
"
" git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
" :PluginInstall
"
" Theme: https://github.com/chriskempson/tomorrow-theme
" Config file for vim

set nocompatible                       " be iMproved, required
filetype off                           " required

" package manager init
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" package manager
Plugin 'VundleVim/Vundle.vim'

" themes
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'ryanoasis/vim-devicons'
Plugin 'mhinz/vim-startify'

" git
Plugin 'airblade/vim-gitgutter'        " file modification indicator
Plugin 'tpope/vim-fugitive'            " git commands on vim commands
Plugin 'Xuyuanp/nerdtree-git-plugin'   " git on nerdtree

" sidebar
Plugin 'scrooloose/nerdtree'           "side bar

" fuzzy finder
Plugin 'ctrlpvim/ctrlp.vim' 

" syntax highliters


" All of your Plugins must be added before the following line
call vundle#end()                  " required
filetype plugin indent on          " required
" To ignore plugin indent changes, instead use:
" filetype plugin on

" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line

" display line numbers
:set nu
" audo indent on linebreak
:set autoindent
" enable syntax highlighting colors
:syntax on
" display characters as
:set listchars=eol:¬,tab:>·,trail:~,extends:>,precedes:<,space:.
"  line highlighting
:highlight LineNr ctermfg=grey
" default tab space. expandtab: use space, noexpandtab: use tabs
:set tabstop=2 shiftwidth=2 expandtab
" show whitespaces declared in listchars
:set list
" show status name, file size, path, etc
:set laststatus=2
" set encoding
:set encoding=UTF-8

" color scheme. manually added to ~/.vim/colors
colorscheme Tomorrow-Night

" load vim plugins inside of tmux
set t_Co=256

" set airline tabs theme on init
let g:airline_theme='minimalist'

" display powerline symbols
let g:airline_powerline_fonts = 1

" initialize symbol customization
let g:airline_symbols = {}

" powerline fonts supplied by nerd fonts - sauce code pro
let g:airline_left_sep = ''
let g:airline_left_alt_sep = ''
let g:airline_right_sep = ''
let g:airline_right_alt_sep = ''
let g:airline_symbols.branch = ''
let g:airline_symbols.readonly = ''

" override section. fontawesome fonts supplied by nerd fonts - sauce code pro
let g:airline_section_z = '%p%%   %l/%L ln %c col'
let g:airline_section_warning = ''

" terminal transparency
hi! Normal ctermbg=NONE guibg=NONE
hi! NonText ctermbg=NONE guibg=NONE

" filetype indention settings
autocmd Filetype html setlocal ts=2 sw=2 expandtab
autocmd Filetype ruby setlocal ts=2 sw=2 expandtab
autocmd Filetype javascript setlocal ts=2 sw=2 expandtab
autocmd Filetype coffeescript setlocal ts=2 sw=2 expandtab
autocmd Filetype jade setlocal ts=2 sw=2 expandtab

autocmd Filetype php setlocal ts=4 sw=4 sts=0 expandtab

" Start NERDTree
" autocmd VimEnter * NERDTree
" Go to previous (last accessed) window.
autocmd VimEnter * wincmd p

" morhetz/gruvbox

" nerdtree
autocmd BufWinEnter * NERDTreeMirror
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

" map to ctrl + e
map <C-e> :NERDTreeToggle<CR>

let NERDTreeShowHidden=1

let g:NERDTreeIndicatorMapCustom = {
    \ "Modified"  : "M",
    \ "Staged"    : "S",
    \ "Untracked" : "U",
    \ "Renamed"   : "R",
    \ "Deleted"   : "D",
    \ "Unmerged"  : "=",
    \ "Dirty"     : "× ",
    \ "Clean"     : "ø ",
    \ 'Ignored'   : "i ",
    \ "Unknown"   : "? "
    \ }

" updates old files on-the-fly
let g:startify_update_oldfiles     = 1

" if session exist in directory, session will be loaded automatically
let g:startify_session_autoload    = 1

" will be executed before saveing session
let g:startify_session_before_save = [
        \ 'echo "Cleaning up before saving.."',
        \ 'silent! NERDTreeTabsClose'
        \ ]

" update session:
" 1. before leaving vim
" 2. before loading new session via :SLoad
" also works for sessions started with
" vim -S mysession.vim
let g:startify_session_persistence = 1

" change to file dir when opening file/bookmark
let g:startify_change_to_dir       = 1

" bookmarks list
let g:startify_bookmarks = [
        \ { 'v': '~/.vimrc' },
        \ ]

" ~/mysecret.txt
let g:startify_skiplist = [
        \ '^/tmp',
        \ '/project/.*/documentation',
        \ escape(fnamemodify($HOME, ':p'), '\') .'mysecret.txt',
        \ ] 

" show <empty buffer> and <quit>.
let g:startify_enable_special      = 0

let g:startify_files_number        = 5
let g:startify_relative_path       = 1

let g:startify_custom_header = ''

" custom header
" let g:startify_custom_header = [
"         \ '                                 ________  __ __        ',
"         \ '            __                  /\_____  \/\ \\ \       ',
"         \ '    __  __ /\_\    ___ ___      \/___//''/''\ \ \\ \    ',
"         \ '   /\ \/\ \\/\ \ /'' __` __`\        /'' /''  \ \ \\ \_ ',
"         \ '   \ \ \_/ |\ \ \/\ \/\ \/\ \      /'' /''__  \ \__ ,__\',
"         \ '    \ \___/  \ \_\ \_\ \_\ \_\    /\_/ /\_\  \/_/\_\_/  ',
"         \ '     \/__/    \/_/\/_/\/_/\/_/    \//  \/_/     \/_/    ',
"         \ ]

hi StartifyBracket ctermfg=240
hi StartifyFile    ctermfg=147
hi StartifyFooter  ctermfg=240
hi StartifyHeader  ctermfg=114
hi StartifyNumber  ctermfg=215
hi StartifyPath    ctermfg=245
hi StartifySlash   ctermfg=240
hi StartifySpecial ctermfg=240


