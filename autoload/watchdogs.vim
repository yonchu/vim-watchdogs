let s:save_cpo = &cpo
set cpo&vim


let g:watchdogs#quickrun_running_check =
  \ get(g:, "watchdogs#quickrun_running_check", 0)

unlet! s:default_args
let s:default_args = { "hook/watchdogs_quickrun_running_checker/enable": 0 }
lockvar! s:default_args


" Script's functions {{{
function! s:is_running()
  if exists("*quickrun#is_running")
    if quickrun#is_running()
      return 1
    endif
  elseif g:watchdogs#quickrun_running_check
    echo "[Watchdogs] Now checking..."
    return 1
  endif
  return 0
endfunction

function! s:is_precious_enabled()
  if !exists('*precious#base_filetype')
    return 0
  endif
  let bf = precious#base_filetype()
  let cf = precious#context_filetype()
  if bf == cf
    return 0
  endif
  call s:echo_message("[Watchdogs] Cancel: filetype is changed by vim-precious.")
  return 1
endfunction


function! s:get_valid_checkers(checkers)
  let checkers = a:checkers
  if type(checkers) != type([])
    let checkers = [checkers]
  endif

  let valid_checkers = []
  for checker_name in checkers
    if has_key(g:watchdogs_checkers, checker_name)
      let config = g:watchdogs_checkers[checker_name]
    elseif has_key(g:watchdogs_config#default_checkers, checker_name)
      let config = g:watchdogs_config#default_checkers[checker_name]
    else
      echoerr "[Watchdogs] Error: Unknown checker ".checker_name
    endif
    if executable(config["command"])
      call add(valid_checkers, {"name": checker_name, "config": config})
    endif
  endfor
  return valid_checkers
endfunction


function! s:run_checkers(checkers, finish_condition, args, post_args)
  let checkers = s:get_valid_checkers(a:checkers)

  if len(checkers) == 0
    return
  endif

  let checker_name_list = []
  for checker in checkers
    call add(checker_name_list, checker["name"])
  endfor
  call s:echo_message("[Watchdogs] Start checking (".join(checker_name_list, ", ").")")

  let quickrun_config = extend(deepcopy(g:watchdogs_config#default_quickrun_config),
    \ g:watchdogs_quickrun_config)
  call extend(quickrun_config, a:args)

  let quickrun_post_config = extend(deepcopy(g:watchdogs_config#default_quickrun_post_config),
    \ g:watchdogs_quickrun_post_config)
  call extend(quickrun_post_config, a:post_args)

  let commands = {
    \ "list": checkers,
    \ "index": 0,
    \ "quickrun_config": deepcopy(quickrun_config),
    \ "quickrun_post_config": quickrun_post_config,
    \ "finish_condition": a:finish_condition,
    \ }

  call extend(quickrun_config, checkers[0]["config"])
  call quickrun#run(extend(quickrun_config, {"commands": commands}))
endfunction


function! s:get_finish_condition(checker_type, trigger)
  let finish_condition = get(g:, "watchdogs_check_".a:trigger."_enable", 0)
  let enables_dict = get(g:, "watchdogs_check_".a:trigger."_enables", {})
  if has_key(enables_dict, a:checker_type)
    let finish_condition = enables_dict[a:checker_type]
  endif
  return finish_condition
endfunction


function! s:echo_message(msg)
    let x=&ruler | let y=&showcmd
    set noruler noshowcmd
    redraw!
    echohl Debug | echo strpart(a:msg, 0, &columns-1) | echohl none
    let &ruler=x | let &showcmd=y
endfunction
" }}}


" Global functions {{{
function! watchdogs#run(checker_type, finish_condition, is_oustput_msg, ...)
  let args = a:0 >= 1 ? a:1 : {}
  let post_args = a:0 >= 2 ? a:2 : {}

  let checker_type = get(b:, "watchdogs_checker_type", a:checker_type)

  if has_key(g:watchdogs_filetype_checkers, checker_type)
    let checkers = g:watchdogs_filetype_checkers[checker_type]
  elseif has_key(g:watchdogs_config#default_filetype_checkers, checker_type)
    let checkers = g:watchdogs_config#default_filetype_checkers[checker_type]
  else
    if a:is_output_msg
      echoerr "[Watchdogs] Error: Not found filetype_checkers definition (".checker_type.")"
    endif
    return
  endif
  call s:run_checkers(checkers, a:finish_condition, args, post_args)
endfunction


function! watchdogs#check_bufwrite(filetype)
  if s:is_running()
    return
  endif

  let checker_type = get(b:, "watchdogs_checker_type", a:filetype)
  let finish_condition = s:get_finish_condition(checker_type, "BufWritePost")
  if !finish_condition
    return
  endif

  if s:is_precious_enabled()
    return
  endif

  call watchdogs#run(
    \ checker_type,
    \ finish_condition,
    \ 0,
    \ s:default_args,
    \ )
endfunction


function! watchdogs#check_cursorhold(filetype)
  if s:is_running()
    return
  endif

  if get(b:, "watchdogs_checked_cursorhold", 1)
    return
  endif

  let checker_type = get(b:, "watchdogs_checker_type", a:filetype)
  let finish_condition = s:get_finish_condition(checker_type, "CursorHold")
  if !finish_condition
    return
  endif

  if s:is_precious_enabled()
    return
  endif

  call watchdogs#run(
    \ checker_type,
    \ finish_condition,
    \ 0,
    \ s:default_args,
    \ )
  let b:watchdogs_checked_cursorhold=1
endfunction


function! watchdogs#run_sweep()
  call quickrun#sweep_sessions()
endfunction


function! watchdogs#qfclose()
  for winnr in range(1, winnr("$"))
    if getwinvar(winnr, "&buftype") ==# "quickfix"
      \ && getwinvar(winnr, "quickfix_title") =~? "watchdogs"
      execute winnr."wincmd q"
      break
    endif
  endfor
endfunction

" }}}


let &cpo = s:save_cpo
unlet s:save_cpo

" vim:fdm=marker commentstring="%s
