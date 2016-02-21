" ============================================================================
" Description: Run command on current file and get result side by side
" Author: Qiming Zhao <chemzqm@gmail.com>
" Licence: Vim licence
" Version: 0.2
" Last Modified:  2016-01-19
" ============================================================================

if exists('g:did_vim_run_loaded') || v:version < 700
  finish
endif

let g:did_vim_run_loaded = 1

function! s:GetCommand(...)
  if a:0 && len(a:1)
    let cmd = a:1
    let b:vim_run_cmd = cmd
  elseif exists('b:vim_run_cmd')
    let cmd = b:vim_run_cmd
  elseif exists('g:vim_run_command_map')
    let cmd = get(g:vim_run_command_map, &ft, '')
  elseif executable(&filetype)
    let cmd = &filetype
  endif
  if empty(cmd)
    echohl Error | echon 'Command not find for current buffer' | echohl None
    return -1
  endif
  return cmd
endfunction

function! s:Run(l1, l2, command)
  let lines = getline(a:l1, a:l2)
  let stdin = join(lines, "\n") . "\n"
  call s:Execute(a:command, stdin)
endfunction

function! s:Execute(command, ...)
  let cmd = s:GetCommand(a:command)
  if cmd == -1 | return | endif
  for i in range(1, winnr('$'))
    if bufname(winbufnr(i)) =~# '^__run__'
      let wnr = i
    endif
  endfor
  if a:0
    let output = system(cmd, a:1)
  else
    let output = system(cmd . ' ' . expand('%'))
  endif
  if exists('wnr')
    execute wnr . 'wincmd w'
    silent execute 'file __run__' . matchstr(cmd, '\v^\S+')
    silent normal! ggdG
  else
    silent execute 'keepalt belowright vsplit __run__' . matchstr(cmd, '\v^\S+')
    setl filetype=runresult buftype=nofile bufhidden=wipe
  endif
  let list = split(output, '\v\n')
  if len(list)
    let list = split(output, "\n")
    call setline(1, list[0])
    call append(1, list[1:])
  endif
  silent! execute '%s///'
  execute 'wincmd p'
  if !has('gui_running')
    redraw
  endif
endfunction

let s:auto_run_dict = {}
function! s:Autorun(...)
  if a:0 && len(a:1)
    let b:vim_run_cmd = a:1
  endif
  let file = fnamemodify(bufname('%'), ':p')
  if get(s:auto_run_dict, file, 0)
    call remove(s:auto_run_dict, file)
    echohl MoreMsg | echon 'autorun disabled' | echohl None
  else
    let s:auto_run_dict[file] = 1
    echohl MoreMsg | echon 'autorun enabled' | echohl None
  endif
endfunction

function! s:onbufwrite()
  let fnames = keys(s:auto_run_dict)
  if !len(fnames) | return | endif
  let file = fnamemodify(bufname('%'), ':p')
  if get(s:auto_run_dict, file, 0)
    call s:Execute('')
  endif
endfunction

augroup autorun
  autocmd!
  autocmd BufWritePost * call s:onbufwrite()
augroup end

command! -nargs=* -complete=shellcmd AutoRun      :call s:Autorun(<q-args>)
command! -nargs=* -complete=shellcmd -range=% Run :call s:Run(<line1>, <line2>, <q-args>)
