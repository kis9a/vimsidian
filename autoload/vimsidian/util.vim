function! vimsidian#util#PrevCursorChar(n)
  let chars = split(getline('.')[0 : col('.')-1], '\zs')
  let len = len(chars)
  if a:n >= len
    return ''
  else
    return chars[len(chars) - a:n - 1]
  endif
endfunction

function! vimsidian#util#NextCursorChar(n)
  return matchstr(getline('.'), '.', col('.')-1, a:n + 1)
endfunction

function! vimsidian#util#CharToCol()
  if strlen(vimsidian#util#CharCol()) ==# 3
    return getline('.')[0 : col('.')+1]
  else
    return getline('.')[0 : col('.')-1]
  endif
endfunction

function! vimsidian#util#CharCol()
  return matchstr(getline('.'), '.', col('.')-1)
endfunction

function! vimsidian#util#CharLen(b)
  return len(split(a:b, '\zs'))
endfunction

function! vimsidian#util#LineChar()
  return getline('.')[0 : len(getline('.'))]
endfunction

function! vimsidian#util#CurrentCursorChar()
  return matchstr(getline('.'), '.', col('.')-1)
endfunction

function! vimsidian#util#ReverseString(str)
  return join(reverse(split(a:str, '\zs')), '')
endfunction

