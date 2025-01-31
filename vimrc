" 基本設定
set number
set wildmenu
set nocompatible
set ignorecase
set smartcase
set incsearch
set clipboard+=unnamed
set background=dark
set redrawtime=0
set regexpengine=0
set laststatus=2
set encoding=utf-8
set guifont=DroidSansMono_Nerd_Font:18
set updatetime=250
set fileformats=unix,dos,mac
set fileencodings=utf-8,sjis
set tags=.tags;$HOME
set mouse=a
set shell=zsh

" キーマッピング
inoremap <silent> jj <ESC>
inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
inoremap <expr> <cr> pumvisible() ? asyncomplete#close_popup() : "\<cr>"
nnoremap <C-J> <C-e>
nnoremap <C-K> <C-y>

map <C-n> :NERDTreeToggle<CR>
map <C-l> gt
map <C-h> gT
nmap <C-a> <Plug>(GitGutterPrevHunk)
nmap <C-e> <Plug>(GitGutterNextHunk)

autocmd FileType go nmap <silent> ;d :DlvToggleBreakpoint<CR>
nnoremap ;b :GoDebugBreakpoint<CR>

" 自動カッコ補完
"inoremap { {}<Left>
"inoremap {<Enter> {}<Left><CR><ESC><S-o>
"inoremap ( ()<ESC>i
"inoremap (<Enter> ()<Left><CR><ESC><S-o>

" GitHub Copilotのキー設定
imap <C-\> <Plug>(copilot-next)

" GoCallersのキーマッピング
nnoremap <C-c> :LspReferences<CR>

" リーダーキー(\)を使って前のバッファに戻るマッピング
nnoremap <leader>bp :bprevious<CR>
" リーダーキーを使って次のバッファに移動するマッピング
nnoremap <leader>bn :bnext<CR>

" プラグイン設定
call plug#begin()
Plug 'Shougo/neosnippet.vim'
Plug 'Shougo/neosnippet-snippets'
Plug 'tpope/vim-fugitive'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'flazz/vim-colorschemes'
Plug 'Shougo/vimshell', { 'rev' : '3787e5' }
Plug 'preservim/nerdtree'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'lervag/vimtex'
Plug 'prabirshrestha/vim-lsp'
Plug 'mattn/vim-lsp-settings'
Plug 'prabirshrestha/asyncomplete.vim'
Plug 'prabirshrestha/asyncomplete-lsp.vim'
Plug 'altercation/vim-colors-solarized'
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
Plug 'ryanoasis/vim-devicons'
Plug 'sebdah/vim-delve', { 'for': ['go'] }
Plug 'tiagofumo/vim-nerdtree-syntax-highlight'
Plug 'charlespascoe/vim-go-syntax'
Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug']}
Plug 'guns/xterm-color-table.vim'
call plug#end()

" LSP設定
if executable('pylsp')
    " pip install python-lsp-server
    au User lsp_setup call lsp#register_server({
        \ 'name': 'pylsp',
        \ 'cmd': {server_info->['pylsp']},
        \ 'allowlist': ['python'],
        \ })
endif

function! s:on_lsp_buffer_enabled() abort
    setlocal omnifunc=lsp#complete
    setlocal signcolumn=yes
    if exists('+tagfunc') | setlocal tagfunc=lsp#tagfunc | endif
    nmap <buffer> gd <plug>(lsp-definition)
    nmap <buffer> gs <plug>(lsp-document-symbol-search)
    nmap <buffer> gS <plug>(lsp-workspace-symbol-search)
    nmap <buffer> gr <plug>(lsp-references)
    nmap <buffer> gi <plug>(lsp-implementation)
    nmap <buffer> gt <plug>(lsp-type-definition)
    nmap <buffer> <leader>rn <plug>(lsp-rename)
    nmap <buffer> [g <plug>(lsp-previous-diagnostic)
    nmap <buffer> ]g <plug>(lsp-next-diagnostic)
    nmap <buffer> K <plug>(lsp-hover)
    " nnoremap <buffer> <expr><c-f> lsp#scroll(+4)
    " nnoremap <buffer> <expr><c-d> lsp#scroll(-4)

    let g:lsp_format_sync_timeout = 1000
    autocmd! BufWritePre *.rs,*.go,*.tsx,*.jsx,*.c,*.f call execute('LspDocumentFormatSync')
endfunction

augroup lsp_install
    au!
    autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
augroup END

" カラースキームとエアライン設定
syntax enable
colorscheme solarized
let g:airline#extensions#tabline#enabled = 1
let g:airline_powerline_fonts = 1
let g:airline_theme = 'wombat'

let g:airline#extensions#tabline#formatter = 'default'
let g:airline#extensions#tabline#buffer_nr_show = 1
let g:airline#extensions#tabline#tabs_label = ''
let g:airline#extensions#tabline#show_buffers = 1
let g:airline#extensions#tabline#show_tabs = 1

let g:webdevicons_enable_airline_tabline = 1
let g:webdevicons_enable_airline_statusline = 1

" gitgutter設定
let g:gitgutter_max_signs = 500
let g:gitgutter_max_signs = -1
highlight GitGutterAdd    guifg=#009900 ctermfg=2
highlight GitGutterChange guifg=#bbbb00 ctermfg=3
highlight GitGutterDelete guifg=#ff2222 ctermfg=1 
let g:gitgutter_highlight_lines = 0

" 左の線をsolarizedの背景色に合わせる
highlight! link SignColumn LineNr
autocmd ColorScheme * highlight! link SignColumn LineNr

" ctagsのタグファイルをファイル保存時に自動で作る
function! s:execute_ctags() abort
  " 探すタグファイル名
  let tag_name = '.tags'
  " ディレクトリを遡り、タグファイルを探し、パス取得
  let tags_path = findfile(tag_name, '.;')
  " タグファイルパスが見つからなかった場合
  if tags_path ==# ''
    return
  endif

  " タグファイルのディレクトリパスを取得
  " `:p:h`の部分は、:h filename-modifiersで確認
  let tags_dirpath = fnamemodify(tags_path, ':p:h')
  " 見つかったタグファイルのディレクトリに移動して、ctagsをバックグラウンド実行（エラー出力破棄）
  execute 'silent !cd' tags_dirpath '&& ctags -R -f' tag_name '2> /dev/null &'
endfunction

augroup ctags
  autocmd!
  autocmd BufWritePost * call s:execute_ctags()
augroup END

" vim-goの設定
let g:go_fmt_command = "goimports"

" NerdTreeの色設定

let g:WebDevIconsDisableDefaultFolderSymbolColorFromNERDTreeDir = 1
let g:WebDevIconsDisableDefaultFileSymbolColorFromNERDTreeFile = 1

let g:WebDevIconsDisableDefaultFolderSymbolColorFromNERDTreeDir = 1
let g:WebDevIconsDisableDefaultFileSymbolColorFromNERDTreeFile = 1
" you can add these colors to your .vimrc to help customizing
let g:WebDevIconsDisableDefaultFolderSymbolColorFromNERDTreeDir = 1
let g:WebDevIconsDisableDefaultFileSymbolColorFromNERDTreeFile = 1

" 色の定義
let s:brown = "905532"
let s:aqua =  "3AFFDB"
let s:blue = "689FB6"
let s:darkBlue = "44788E"
let s:purple = "834F79"
let s:lightPurple = "834F79"
let s:red = "AE403F"
let s:beige = "F5C06F"
let s:yellow = "F09F17"
let s:orange = "D4843E"
let s:darkOrange = "F16529"
let s:pink = "CB6F6F"
let s:salmon = "EE6E73"
let s:green = "8FAA54"
let s:lightGreen = "31B53E"
let s:white = "FFFFFF"
let s:rspec_red = 'FE405F'
let s:git_orange = 'F54D27'
let s:cyan = "689FB9"
let s:violet = "692FB6"
let s:darkRed = "AE400F"
let s:darkGreen = "8FAA51"
let s:darkPurple =  "834F76"
let s:black = "000000"
let s:blackBlue = "4682B4"
let s:gray = "808080"

" デフォルト色設定をオフにするためのVAR
let g:NERDTreeExtensionHighlightColor = {}
let g:NERDTreeExactMatchHighlightColor = {}
let g:NERDTreePatternMatchHighlightColor = {}

" ファイルタイプごとの色設定
let g:NERDTreeExtensionHighlightColor['html'] = s:orange
let g:NERDTreeExtensionHighlightColor['css'] = s:blue
let g:NERDTreeExtensionHighlightColor['js'] = s:yellow
let g:NERDTreeExtensionHighlightColor['jsx'] = s:darkBlue
let g:NERDTreeExtensionHighlightColor['ts'] = s:lightGreen
let g:NERDTreeExtensionHighlightColor['tsx'] = s:lightPurple
let g:NERDTreeExtensionHighlightColor['json'] = s:brown
let g:NERDTreeExtensionHighlightColor['md'] = s:blackBlue
let g:NERDTreeExtensionHighlightColor['rb'] = s:salmon
let g:NERDTreeExtensionHighlightColor['py'] = s:salmon
let g:NERDTreeExtensionHighlightColor['go'] = s:aqua
let g:NERDTreeExtensionHighlightColor['java'] = s:red
let g:NERDTreeExtensionHighlightColor['php'] = s:violet
let g:NERDTreeExtensionHighlightColor['sh'] = s:white
let g:NERDTreeExtensionHighlightColor['vim'] = s:pink
let g:NERDTreeExtensionHighlightColor['c'] = s:white
let g:NERDTreeExtensionHighlightColor['cpp'] = s:darkGreen
let g:NERDTreeExtensionHighlightColor['h'] = s:darkRed
let g:NERDTreeExtensionHighlightColor['hpp'] = s:darkPurple
let g:NERDTreeExtensionHighlightColor['yaml'] = s:gray
let g:NERDTreeExtensionHighlightColor['yml'] = s:gray
let g:NERDTreeExtensionHighlightColor['txt'] = s:white

" 正確な一致のファイルの色設定
let g:NERDTreeExactMatchHighlightColor['.gitignore'] = s:git_orange
let g:NERDTreeExactMatchHighlightColor['README.md'] = s:blackBlue
let g:NERDTreeExactMatchHighlightColor['LICENSE'] = s:white
let g:NERDTreeExactMatchHighlightColor['docker-compose.yaml'] = s:blackBlue
let g:NERDTreeExactMatchHighlightColor['docker-compose.yml'] = s:blackBlue
let g:NERDTreeExactMatchHighlightColor['Dockerfile'] = s:blackBlue
let g:NERDTreeExactMatchHighlightColor['Dockerfile.dev'] = s:blackBlue


" パターンマッチによる色設定
let g:NERDTreePatternMatchHighlightColor['.*_spec\.rb$'] = s:rspec_red
let g:NERDTreePatternMatchHighlightColor['.*_test\.py$'] = s:rspec_red
let g:NERDTreePatternMatchHighlightColor['.*_test\.js$'] = s:rspec_red

" デフォルトの色設定（フォルダとファイル）
let g:WebDevIconsDefaultFolderSymbolColor = s:blue
let g:WebDevIconsDefaultFileSymbolColor = s:blue

" Copilot commit message設定
let g:copilot_filetypes = #{
  \   gitcommit: v:true,
  \   markdown: v:true,
  \   text: v:true,
  \   ddu-ff-filter: v:false,
  \ }

function s:append_diff() abort
  " Get the Git repository root directory
  let git_dir = FugitiveGitDir()
  let git_root = fnamemodify(git_dir, ':h')

  " Get the diff of the staged changes relative to the Git repository root
  let diff = system('git -C ' . git_root . ' diff --cached')

  " Add a comment character to each line of the diff
  let comment_diff = join(map(split(diff, '\n'), {idx, line -> '# ' . line}), "\n")

  " Append the diff to the commit message
  call append(line('$'), split(comment_diff, '\n'))
endfunction

autocmd BufReadPost COMMIT_EDITMSG call s:append_diff()

" Goのシンタックスハイライト設定
augroup go_highlight
    autocmd!
    autocmd FileType go highlight goVar guifg=#dcdcdc ctermfg=252
    autocmd FileType go highlight goVarIdentifier guifg=#dcdcdc ctermfg=252
    autocmd FileType go highlight goDeclaration guifg=#dcdcdc ctermfg=252
    autocmd FileType go highlight goDeclType guifg=#dcdcdc ctermfg=252
    autocmd FileType go highlight goField ctermfg=176
    " autocmd FileType go highlight goField ctermfg=252
    autocmd FileType go highlight goIdentifier guifg=#dcdcdc ctermfg=252
    autocmd FileType go highlight Identifier guifg=#dcdcdc ctermfg=252
    autocmd FileType go highlight goNonPrimitiveType ctermfg=6
    autocmd FileType go highlight Statement ctermfg=173
    autocmd FileType go highlight goStringFormat ctermfg=173
    autocmd FileType go highlight goStringEscape ctermfg=173
    autocmd FileType go highlight GoPackageName  ctermfg=222
    autocmd FileType go highlight goTypeDeclName guifg=#dcdcdc ctermfg=252
    autocmd FileType go highlight goInterfaceMethod ctermfg=39
    autocmd FileType go highlight goFuncName ctermfg=39
    autocmd FileType go highlight goFuncBlock ctermfg=252
    autocmd FileType go highlight goImportString ctermfg=65
    autocmd FileType go highlight goString ctermfg=65
    autocmd FileType go highlight Delimiter ctermfg=252
    autocmd FileType go highlight goOperator ctermfg=252
    autocmd FileType go highlight goComma ctermfg=252
    autocmd FileType go highlight goFuncCallArgs ctermfg=252
    autocmd FileType go highlight goStructTypeField ctermfg=252
    autocmd FileType go highlight goStructLiteralField ctermfg=252
    autocmd FileType go highlight goStructLiteralBlock ctermfg=252
    autocmd FileType go highlight goUnderscore ctermfg=252
    autocmd FileType go highlight Type ctermfg=130
    autocmd FileType go highlight GoFuncCall ctermfg=179
    autocmd FileType go highlight Boolean ctermfg=130
    autocmd FileType go highlight goBuiltins ctermfg=130
    autocmd FileType go highlight goNil ctermfg=130
    autocmd FileType go highlight goStructTypeTag ctermfg=65
augroup END

let g:vimtex_compiler_latexmk = {
    \ 'executable' : 'latexmk',
    \ 'options' : [
    \   '-pdf',
    \   '-pdflatex=lualatex',
    \   '-file-line-error',
    \   '-synctex=1',
    \   '-interaction=nonstopmode',
    \ ],
\}

" .texファイルを開いたときに:Copilot disableを実行する
autocmd FileType tex Copilot disable

