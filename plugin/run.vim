" ============================================================================
" Description: Run command on current file and get result side by side
" Author: Qiming Zhao <chemzqm@gmail.com>
" Licence: Vim licence
" Version: 0.1
" Last Modified:  December 30, 2015
" ============================================================================

if exists('did_vim_run_loaded') || v:version < 700
  finish
endif

let did_vim_run_loaded = 1

function! s:run()
  if exists('b:run_cmd')
    let cmd = b:run_cmd
  elseif exists('g:vim_run_command_map')
    let cmd = get(g:vim_run_command_map, &ft, '')
  elseif executable(&ft)
    let cmd = &filetype
  else
    echohl Error | echon 'Command not find for current buffer' | echohl None
    return
  endif
  for i in range(1, winnr('$'))
    if bufname(winbufnr(i)) =~# '^__run__'
      let wnr = i
    endif
  endfor
  let output = system(cmd . ' ' . bufname('%'))
  if exists('wnr')
    execute wnr . 'wincmd w'
    silent execute 'file __run__' . matchstr(cmd, '\v^\S+')
  else
    execute 'belowright vsplit __run__' . matchstr(cmd, '\v^\S+')
  endif
  normal! ggdG
  setl filetype=runresult readonly bufhidden=wipe
  setl buftype=nofile
  silent call append(0, split(output, '\v\n'))
  silent! execute '%s///'
  execute ':$d'
  execute 'wincmd p'
endfunction

let s:auto_run_dict = {}
function! s:autorun()
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
    call s:run()
  endif
endfunction

augroup autorun
  autocmd!
  autocmd BufWritePost * call s:onbufwrite()
augroup end

command! -nargs=0 Run :call s:run()
command! -nargs=0 AutoRun :call s:autorun(<f-args>)
