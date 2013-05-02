if exists('g:loaded_watchdogs')
  finish
endif
let g:loaded_watchdogs = 1

let s:save_cpo = &cpo
set cpo&vim


let g:watchdogs_filetype_checkers =
\ get(g:, "watchdogs_filetype_checkers", {})
let g:watchdogs_quickrun_config =
\ get(g:, "watchdogs_quickrun_config", {})
let g:watchdogs_quickrun_post_config =
\ get(g:, "watchdogs_quickrun_post_config", {})
let g:watchdogs_checkers =
\ get(g:, "watchdogs_checkers", {})

let g:watchdogs_check_BufWritePost_enable =
\ get(g:, "watchdogs_check_BufWritePost_enable", 0)
let g:watchdogs_check_BufWritePost_enables =
\ get(g:, "watchdogs_check_BufWritePost_enables", {})

let g:watchdogs_check_CursorHold_enable =
\ get(g:, "watchdogs_check_CursorHold_enable", 0)
let g:watchdogs_check_CursorHold_enables =
\ get(g:, "watchdogs_check_CursorHold_enables", {})


command! -nargs=* -range=0 -complete=customlist,quickrun#complete
\ WatchdogsRun call watchdogs#run(&filetype, 3, 1, <f-args>)

command! -nargs=* -range=0 -complete=customlist,quickrun#complete
\ WatchdogsRunSilent call watchdogs#run(&filetype, 3, 0, <f-args>)

command! -nargs=0
\ WatchdogsRunSweep call watchdogs#run_sweep()


augroup watchdogs-plugin
  autocmd!
  autocmd BufWritePost * call watchdogs#check_bufwrite(&filetype)
  autocmd BufWritePost * let b:watchdogs_checked_cursorhold = 0
  autocmd CursorHold   * call watchdogs#check_cursorhold(&filetype)
  autocmd BufWinLeave  * call watchdogs#run_sweep()
  autocmd WinEnter     * if winnr("$") == 1 | call watchdogs#qfclose() | endif
augroup END


let &cpo = s:save_cpo
unlet s:save_cpo
