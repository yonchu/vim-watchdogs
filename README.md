vim-watchdogs
-------------

[osyo-manga/vim-watchdogsb](https://github.com/osyo-manga/vim-watchdogs) の改良版。

オリジナルのwatchdogsとの互換性はありません。

変更点

- 複数checkerの指定
- watchdogsの設定を ``g:quickrun_config`` から分離

以下のvimプラグインを併用することで
[scrooloose/syntasticb](https://github.com/scrooloose/syntastic)
と同等の機能が使用出来ます。

- [jceb/vim-hierb](https://github.com/jceb/vim-hier)
- [yonchu/quickfixstatus](https://github.com/yonchu/quickfixstatus)
- [tomtom/quickfixsigns_vim](https://github.com/tomtom/quickfixsigns_vim)

## インストール方法

```vim
NeoBundle 'yonchu/vim-watchdogs', 'multi-checker'
NeoBundle 'osyo-manga/shabadou.vim

" or

NeoBundle 'yonchu/vim-watchdogs',  {
      \ 'depends' : [ 'osyo-manga/shabadou.vim' ],
      \ 'rev' : 'multi-checker',
      \ }

" or

NeoBundleLazy 'yonchu/vim-watchdogs',  {
      \ 'depends' : [ 'osyo-manga/shabadou.vim' ],
      \ 'rev' : 'multi-checker',
      \ 'autoload' : {
      \   'filetypes' : [
      \     'python', 'html', 'javascript', 'coffee', 'perl',
      \     'php', 'ruby', 'scss', 'sass', 'coffee',
      \ ]}}
```

## 設定例

```vim
" 使用するチェッカーを変更
let g:watchdogs_filetype_checkers = {
      \  'coffee' : [ 'coffeelint', 'coffee' ],
      \  'python' : [ 'flake8', 'pyflakes', 'pep8' ],
      \ }


" watchdogs用の quickrun_config の設定
" (各checker実行時時に使用する qucirun の設定)
let g:watchdogs_quickrun_config = {
      \  'runner/vimproc/updatetime' : 40,
      \ }


" watchdogsで全てのcheckerによる処理が終了した後に実行される処理を規定
let g:watchdogs_quickrun_post_config = {
      \  'hook/close_quickfix/enable_exit' : 1,
      \ }


" 新規checkerの設定、または既存checkerの設定変更
let g:watchdogs_checkers = {
      \ 'jshint' : {
      \   'command' : 'jshint',
      \   'exec'    : '%c --verbose %s:p',
      \   'errorformat' : '%f: line %l\, col %c\, %m,%-G%.%#error\[s\],%-G',
      \  },
      \ }


" ファイル保存時の自動実行を設定
"   0 : 実行しない
"   1 : 指定されたcheckerの中で、一番はじめに実行可能なものを1つだけ実行する
"   2 : 指定されたcheckerを順にエラーが検出されるまで実行する。
"   3 : 指定されたcheckerを順に全て実行する

" 全てのfiletypeのデフォルトの動作を規定
"let g:watchdogs_check_BufWritePost_enable = 0

" filetype毎の動作を規定
"   全体設定よりも優先される。
"   ここに指定されていないfiletypeは全体設定に従う。
let g:watchdogs_check_BufWritePost_enables = {
      \  'c'          : 0,
      \  'coffee'     : 3,
      \  'cpp'        : 0,
      \  'javascript' : 3,
      \  'perl'       : 1,
      \  'php'        : 1,
      \  'python'     : 3,
      \  'ruby'       : 1,
      \  'sass'       : 1,
      \  'scss'       : 1,
      \ }

```

デフォルトのcheckerに関する設定は、
vim-watchdogs/autoload/watchdogs_config.vim に記述されています。


## 新しいcheckerを設定したい場合

まず、以下のような設定を自身の.vimrcに記述します。

checkerの名前と使用するコマンド名の部分を埋めます。

```vim
let g:watchdogs_checkers = {
      \ '<checkerの名前>' : {
      \   'command' : 'コマンド名',
      \   'cmdopt'  : 'コマンドオプション',
      \   'exec'    : '%c %o %s:p',
      \   'errorformat' : 'エラーフォーマット',
      \  },
      \ }
```

最後にエラーフォーマットを定義します。

エラーフォーマットは、まずsyntasticに同様のコマンドがないか探してみて下さい。

以下のページに既にコマンドが存在していれば、そのファイルを開き、ファイル内の
``errorformat`` をコピーして使用すればよいでしょう。

- [syntastic/syntax_checkers](https://github.com/scrooloose/syntastic/tree/master/syntax_checkers)

ない場合は自身で作成剃る必要があります。

``:help errorformat``や既存のerrorformatを参考にして下さい。
