function! vimsidian#logger#LogError(msg)
  if g:vimsidian_log_level > 0
    echohl ErrorMsg
    echo '[VIMSIDIAN] ' . a:msg
    echohl None
  endif
endfunction

function! vimsidian#logger#Info(msg)
  if g:vimsidian_log_level > 1
    echo '[VIMSIDIAN] ' . a:msg
  endif
endfunction

function! vimsidian#logger#Debug(msg)
  if g:vimsidian_log_level > 2
    echo '[VIMSIDIAN] [DEBUG] ' . a:msg
  endif
endfunction
