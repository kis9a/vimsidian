" flags
let s:save_cpo = &cpo
set cpo&vim

" functions
function! vimsidian#utils#getUserInput(label)
  let curline = getline('.')
  echohl VimsidianPromptColor
  call inputsave()
  let input=input(a:label . " > ")
  echohl NONE
  call inputrestore()
  call setline('.', curline)
  return input
endfunction

function! vimsidian#utils#prevCursorChar(n)
  let chars = split(getline('.')[0 : col('.')-1], '\zs')
  let len = len(chars)
  if a:n >= len
    return ''
  else
    return chars[len(chars) - a:n - 1]
  endif
endfunction

function! vimsidian#utils#nextCursorChar(n)
  return matchstr(getline('.'), '.', col('.')-1, a:n + 1)
endfunction

function! vimsidian#utils#charToCol()
  if strlen(vimsidian#utils#charCol()) ==# 3
    return getline('.')[0 : col('.')+1]
  else
    return getline('.')[0 : col('.')-1]
  endif
endfunction

function! vimsidian#utils#charCol()
  return matchstr(getline('.'), '.', col('.')-1)
endfunction

function! vimsidian#utils#charLen(b)
  return len(split(a:b, '\zs'))
endfunction

function! vimsidian#utils#lineChar()
  return getline('.')[0 : len(getline('.'))]
endfunction

function! vimsidian#utils#currentCursorChar()
  return matchstr(getline('.'), '.', col('.')-1)
endfunction

function! vimsidian#utils#reverseString(str)
  return join(reverse(split(a:str, '\zs')), '')
endfunction

function! vimsidian#utils#removeVimsidianLinkToken(str)
  return substitute(a:str, '\v([|\])', '', 'g')
endfunction

" end flags
let &cpo = s:save_cpo
