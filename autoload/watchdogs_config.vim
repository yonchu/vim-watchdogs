let s:save_cpo = &cpo
set cpo&vim


unlet! g:watchdogs_config#default_filetype_checkers
let g:watchdogs_config#default_filetype_checkers = {
\  "c"          : [ "gcc" ],
\  "cpp"        : [ "g++" ],
\  "coffee"     : [ "coffeelint", "coffee" ],
\  "d"          : [ "dmd" ],
\  "haskel"     : [ "ghc-mod", "hlint" ],
\  "javascript" : [ "jshint", "gjslint" ],
\  "lua"        : [ "luac" ],
\  "perl"       : [ "perl" ],
\  "php"        : [ "php" ],
\  "python"     : executable("flake8") ? [ "flake8" ] : [ "pyflakes", "pep8" ],
\  "ruby"       : [ "ruby" ],
\  "sass"       : [ "sass" ],
\  "scss"       : [ "scss" ],
\  "scalac"     : [ "scalac" ],
\  "sh"         : [ "sh" ],
\  "zsh"        : [ "zsh" ],
\}
lockvar! g:watchdogs_config#default_filetype_checkers


unlet! g:watchdogs_config#default_checkers
let g:watchdogs_config#default_checkers = {
\
\  "gcc" : {
\    "command"   : "gcc",
\    "exec"      : "%c %o -fsyntax-only %s:p ",
\  },
\
\  "clang" : {
\    "command"   : "clang",
\    "exec"      : "%c %o -fsyntax-only %s:p ",
\  },
\
\
\  "g++" : {
\    "command"   : "g++",
\    "exec"      : "%c %o -std=gnu++0x -fsyntax-only %s:p ",
\  },
\
\  "g++03" : {
\    "command"   : "g++",
\    "exec"      : "%c %o -fsyntax-only %s:p ",
\  },
\
\  "clang++" : {
\    "command"   : "clang++",
\    "exec"      : "%c %o -std=gnu++0x -fsyntax-only %s:p ",
\  },
\
\  "clang++03" : {
\    "command"   : "clang++",
\    "exec"      : "%c %o -fsyntax-only %s:p ",
\  },
\
\  "msvc" : {
\    "command"   : "cl",
\    "exec"      : "%c /Zs %o %s:p ",
\  },
\
\
\  "coffee" : {
\    "command" : "coffee",
\    "exec"    : "%c -c -l -p %o %s:p",
\    "errorformat" :
\      '%E%f:%l:%c: %trror: %m,' .
\      'Syntax%trror: In %f\, %m on line %l,' .
\      '%EError: In %f\, Parse error on line %l: %m,' .
\      '%EError: In %f\, %m on line %l,' .
\      '%W%f(%l): lint warning: %m,' .
\      '%W%f(%l): warning: %m,' .
\      '%E%f(%l): SyntaxError: %m,' .
\      'Syntax%trror: %m,' .
\      '%-Z%p^,' .
\      '%-G%.%#'
\  },
\
\  "coffeelint" : {
\    "command" : "coffeelint",
\    "exec"    : "%c --csv %o %s:p",
\    "errorformat" :
\      '%f:%l:%c: %trror: %m,' .
\      'Syntax%trror: %m on line %l,' .
\      '%-G%.%#'
\  },
\
\
\  "dmd" : {
\    "command" : "dmd",
\    "exec"    : "%c %o -c %s:p",
\  },
\
\
\  "ghc-mod" : {
\    "command" : "ghc-mod",
\    "exec"    : '%c %o --hlintOpt="--language=XmlSyntax" check %s:p',
\  },
\
\  "hlint" : {
\    "command" : "hlint",
\    "exec"    : '%c %o %s:p',
\  },
\
\
\  "jshint" : {
\    "command" : "jshint",
\    "exec"    : "%c %s:p",
\    "errorformat" : '%f: line %l\, col %c\, %m,%-G%.%#error\[s\],%-G',
\  },
\
\  "gjslint" : {
\    "command" : "gjslint",
\    "exec"    : "%c --nosummary --unix_mode --nodebug_indentation --nobeep %s:p",
\    "errorformat" : "%f:%l:(New Error -%\\?\%n) %m,%f:%l:(-%\\?%n) %m,%-G1 files checked, no errors found.,%-G%.%#",
\  },
\
\
\  "luac" : {
\    "command" : "luac",
\    "exec"    : "%c %o %s:p",
\    "errorformat" : '%.%#: %#%f:%l: %m',
\  },
\
\
\  "perl" : {
\    "command" : "perl",
\    "exec"    : "%c %o -c %s:p",
\    "errorformat" : '%m\ at\ %f\ line\ %l%.%#',
\  },
\
\  "vimparse.pl" : {
\    "command" : "perl",
\    "exec"    : "%c " . substitute(expand('<sfile>:p:h:h'), '\\', '\/', "g") . "/bin/vimparse.pl" . " -c %o %s:p",
\    "errorformat" : '%f:%l:%m',
\  },
\
\
\  "php" : {
\    "command" : "php",
\    "exec"    : "%c %o -l %s:p",
\    "errorformat" : '%m\ in\ %f\ on\ line\ %l',
\  },
\
\
\  "pyflakes" : {
\    "command" : "pyflakes",
\    "exec"    : "%c %o %s:p",
\    "errorformat" : "%E%f:%l: could not compile,%-Z%p^,%E%f:%l:%c: %m,%W%f:%l: %m,%-G%.%#",
\  },
\
\  "pep8" : {
\     "command" : "pep8",
\     "cmdopt"  : '--ignore="E501"',
\     "exec"    : "%c %o %s:p",
\  },
\
\  "flake8" : {
\     "command" : "flake8",
\     "cmdopt"  : '--ignore="E501"',
\     "exec"    : "%c %o %s:p",
\     "errorformat" : '%E%f:%l: could not compile,%-Z%p^,'.
\                     '%W%f:%l:%c: F%n %m,'.
\                     '%W%f:%l:%c: C%n %m,'.
\                     '%E%f:%l:%c: %t%n %m,'.
\                     '%E%f:%l: %t%n %m,%-G%.%#'
\  },
\
\
\  "ruby" : {
\    "command" : "ruby",
\    "exec"    : "%c %o -c %s:p",
\  },
\
\
\  "sass" : {
\    "command" : "sass",
\    "exec"    : "%c %o --check ".(executable("compass") ? "--compass" : "")." %s:p",
\    "errorformat"
\      : '%ESyntax %trror:%m,%C        on line %l of %f,%Z%.%#'
\      . ',%Wwarning on line %l:,%Z%m,Syntax %trror on line %l: %m',
\  },
\
\
\  "scss" : {
\    "command" : "sass",
\    "exec"    : "%c %o --check ".(executable("compass") ? "--compass" : "")." %s:p",
\    "errorformat"
\      : '%ESyntax %trror:%m,%C        on line %l of %f,%Z%.%#'
\      .',%Wwarning on line %l:,%Z%m,Syntax %trror on line %l: %m',
\  },
\
\
\  "scalac" : {
\    "command" : "scalac",
\    "exec"    : "%c %o %s:p",
\    "errorformat"    : '%f:%l:\ error:\ %m,%-Z%p^,%-C%.%#,%-G%.%#',
\   },
\
\
\  "sh" : {
\    "command" : "sh",
\    "exec"    : "%c -n %o %s:p",
\    "errorformat"    : '%f:\ line\ %l:%m',
\   },
\
\
\  "zsh" : {
\    "command" : "zsh",
\    "exec"    : "%c -n %o %s:p",
\    "errorformat"    : '%f:%l:%m',
\   },
\
\
\}
lockvar! g:watchdogs_config#default_checkers


unlet! g:watchdogs_config#default_quickrun_config
let g:watchdogs_config#default_quickrun_config = {
\  "runner": "vimproc",
\  "runner/vimproc/updatetime": 40,
\  "outputter": "variable",
\  "commands": {},
\
\  "hook/watchdogs_multi_checker/enable": 1,
\  "hook/watchdogs_quickrun_running_checker/enable": 1,
\  "hook/shebang/enable": 0,
\}
lockvar! g:watchdogs_config#default_quickrun_config


unlet! g:watchdogs_config#default_quickrun_post_config
let g:watchdogs_config#default_quickrun_post_config = {
\  "runner": "vimscript",
\  "outputter": "null",
\  "command": ":call",
\  "cmdopt": "watchdogs_config#quickrun_post()",
\  "exec": "%c %o",
\
\  "hook/hier_update/enable_exit": 1,
\  "hook/quickfix_stateus_enable/enable_exit": 1,
\  "hook/quickfixsigns_enable/enable_exit": 1,
\
\  "hook/close_quickfix/enable_exit": 0,
\  "hook/shebang/enable": 0,
\}
lockvar! g:watchdogs_config#default_quickrun_post_config


function! watchdogs_config#quickrun_post(...)
  " post process
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
