function! vimsidian#util#PrevCursorChar(n) abort
  let chars = split(getline('.')[0 : col('.')-1], '\zs')
  let len = len(chars)
  if a:n >= len
    return ''
  else
    return chars[len(chars) - a:n - 1]
  endif
endfunction

function! vimsidian#util#NextCursorChar(n) abort
  return matchstr(getline('.'), '.', col('.')-1, a:n + 1)
endfunction

function! vimsidian#util#CharToCol() abort
  if strlen(vimsidian#util#CharCol()) ==# 3
    return getline('.')[0 : col('.')+1]
  else
    return getline('.')[0 : col('.')-1]
  endif
endfunction

function! vimsidian#util#CharCol() abort
  return matchstr(getline('.'), '.', col('.')-1)
endfunction

function! vimsidian#util#CharLen(b) abort
  return len(split(a:b, '\zs'))
endfunction

function! vimsidian#util#LineChar() abort
  return getline('.')[0 : len(getline('.'))]
endfunction

function! vimsidian#util#CurrentCursorChar() abort
  return matchstr(getline('.'), '.', col('.')-1)
endfunction

function! vimsidian#util#ReverseString(str) abort
  return join(reverse(split(a:str, '\zs')), '')
endfunction

function! vimsidian#util#WrapWithSingleQuote(str) abort
  return "'" . a:str . "'"
endfunction

function! vimsidian#util#PathJoin(...) abort
  let path = ''
  for part in a:000
    let path .= '/' . (type(part) is type([]) ? call('vimsidian#util#PathJoin', part) :part)
    unlet part
  endfor
  return substitute(path[1 :], (exists('+shellslash') ? '[\\/]' : '/') . '\+', '/', 'g')
endfunction
