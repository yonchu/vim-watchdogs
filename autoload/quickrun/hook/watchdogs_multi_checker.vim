scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

" Definition of {{{
"
" quickrun_config["commands"] = {
"   'list': [
"     { 'name': name1,
"       'config': { 'command': 'cmd1', 'exec': '%c %o %s:%p', 'errorformat': "%f:%l:%c: %m" },
"     },
"     { 'name': name2,
"       'config': { 'command': 'cmd2', 'exec': '%c %o %s:%p' },
"     },
"   ],
"   'index': 0,
"   'quickrun_config': {},
"   'quickrun_post_config': {},
"   'finish_condition': 1/2/3,
" }
" }}}


let s:hook = {
\  "config" : {
\    "enable" : 0
\  },
\}


function! quickrun#hook#watchdogs_multi_checker#new()
  return deepcopy(s:hook)
endfunction


function! s:hook.priority(...)
  return -100
endfunction


function! s:hook.init(session)
  let a:session.config["outputter/variable/name"] = "b:multi_checker_result"
endfunction


function! s:hook.on_exit(session, context)
  if exists("b:multi_checker_result")
    let result = b:multi_checker_result
    unlet b:multi_checker_result
  else
    let result = ""
  endif

  let commands = a:session.config.commands
  let list = commands["list"]
  let index = commands["index"]
  let quickrun_config = commands["quickrun_config"]
  let quickrun_post_config = commands["quickrun_post_config"]
  let finish_condition = commands["finish_condition"]

  let target = list[index]

  call s:output2quickfix(index, target, result)

  if finish_condition == 1
    call s:complete(index, list, quickrun_post_config)
    return
  endif

  if len(result) && finish_condition == 2
    call s:complete(index, list, quickrun_post_config)
    return
  endif

  let next_index = index + 1
  if next_index >= len(list)
    call s:complete(index, list, quickrun_post_config)
    return
  endif

  let commands["index"] = next_index

  let quickrun_config = deepcopy(quickrun_config)
  call extend(quickrun_config, list[next_index]["config"])
  call quickrun#run(extend(quickrun_config, {"commands": commands}))
endfunction


function! s:output2quickfix(index, target, result)
  if a:index == 0
    cgetexpr ""
  endif

  let name = a:target["name"]
  if !len(a:result)
    call s:echo_message("[Watchdogs] ".name.": No errors found")
    return
  endif

  call s:echo_message("[Watchdogs] ".name.": Some errors found")

  try
    let errorformat = &g:errorformat
    let &g:errorformat = get(a:target["config"], "errorformat", &g:errorformat)
    caddexpr a:result
  finally
      let &g:errorformat = errorformat
  endtry
endfunction


function! s:complete(index, list, quickrun_post_config)
  let save_winnr = winnr()
  cwindow
  execute save_winnr."wincmd w"

  let executed_name_list = []
  let index = 0
  for target in a:list
    call add(executed_name_list, target["name"])
    if index == a:index
      break
    endif
    let index = index + 1
  endfor

  let title = join(executed_name_list, ", ")
  for winnr in range(1, winnr("$"))
    if getwinvar(winnr, "&buftype") ==# "quickfix"
      call setwinvar(winnr, "quickfix_title", "Watchdogs: ".title)
      break
    endif
  endfor

  call quickrun#run(deepcopy(a:quickrun_post_config))
  call s:echo_message("[Watchdogs] Check complete! (".title.") : ".len(getqflist())." errors")
endfunction


function! s:echo_message(msg)
    let x=&ruler | let y=&showcmd
    set noruler noshowcmd
    redraw!
    echohl Debug | echo strpart(a:msg, 0, &columns-1) | echohl none
    let &ruler=x | let &showcmd=y
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
