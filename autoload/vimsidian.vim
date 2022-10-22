" flags
let s:save_cpo = &cpo
set cpo&vim

" functions
function! vimsidian#CompleteVimsidianFiles(findstart, base)
  if a:findstart
    let line = getline('.')
    let start = col('.') - 1
    while start > 0 && line[start - 1] =~ '\a'
      let start -= 1
    endwhile
    return start
  else
    let res = []
    for f in g:vimsidian_complete_paths
      let cmd  = "ls " . f . " | sed -e 's/\.md$//'"
      for m in split(system(cmd), '\n')
        if m =~ '^' . a:base
          call add(res, m)
        endif
      endfor
    endfor
    return res
  endif
endfunction

function! vimsidian#VimsidianRgNotesWithMatches(word)
  let cmd = 'rg -F -n %s --files-with-matches $(realpath ' . g:vimsidian_path . ") | awk '" . '{ print $0 ":1: " }' . "'"
  let vimsidian_rg_notes_with_matches = system(printf(cmd, a:word))
  if empty (vimsidian_rg_notes_with_matches)
    echo "Not found '" .a:word . "'"
  else
    execute 'lcd' g:vimsidian_path
    cexpr vimsidian_rg_notes_with_matches | copen
  endif
endfunction

function! vimsidian#VimsidianRgNotesWithMatchesInteractive()
  let i = s:getUserInput("")
  call vimsidian#VimsidianRgNotesWithMatches(i)
endfunction

function! vimsidian#VimsidianRgTagMatches()
  let cword = expand('<cWORD>')
  if cword[0] == "#"
    let cmd = "rg -n '" . cword . "' $(realpath " . g:vimsidian_path . ")"
    let vimsidian_rg_tag_matches = system(cmd)
    if empty (vimsidian_rg_tag_matches)
      echo "Not found '" . cword . "'"
    else
      execute 'lcd' g:vimsidian_path
      cexpr vimsidian_rg_tag_matches | copen
    endif
  else
    echo "Word under the cursor is not a tag"
  endif
endfunction

function! vimsidian#VimsidianFdLinkedNotesByThisNote()
  let grepCmd = ''
  if stridx(system("grep --version"), "BSD") == "-1"
    let grepCmd .= 'grep -oP' " Use GNU grep option
  else
    let grepCmd .= 'grep -oE' " Use BSD grep option
  endif

  let grepCmd .= " '\\[\\[.*?\\]]' '%s' | grep -v '\\[\\[#' | tr -d '[]'"
  let absolutePath=expand('%:p')
  let grepRes = system(printf(grepCmd, absolutePath))
  if empty (grepRes)
    echo "Not found internal links'"
    return
  else
   let fdGrepArg = ''
    for m in split(grepRes, '\n')
      let fdGrepArg .= " -e '/" . m . ".md'" " grep -e 'file' -e 'file2'
    endfor
  endif

  let fdCmd = 'fd . ' . g:vimsidian_path . ' | grep ' . fdGrepArg . "| awk '" . '{ print $0 ":1: " }' . "'"
  let vimsidian_fd_linked_notes_by_this_note = system(fdCmd)
  if empty(vimsidian_fd_linked_notes_by_this_note)
    echo "Not found linking notes'"
    return
  else
    execute 'lcd' g:vimsidian_path
    cexpr vimsidian_fd_linked_notes_by_this_note | copen
  endif
endfunction

function! vimsidian#VimsidianRgNotesLinkingThisNote()
  let fname = fnamemodify(expand("%:t"), ":r")
  let ext = expand("%:e")
  if ext == "md"
    let a=vimsidian#VimsidianRgNotesWithMatches("'\[\[" . fname . "\]]'")
  else
    let a=vimsidian#VimsidianRgNotesWithMatches("'\[\[" . expand("%t") . "\]]'")
  endif
endfunction

function! vimsidian#VimsidianMoveToLink()
  let cc = s:currentCursorChar()
  let p = s:prevCursorChar(1)
  let n = s:nextCursorChar(1)
  let c = s:charToCol()
  let cs = split(c, '\zs')
  let cl = len(cs)
  let l = s:lineChar()
  let ll = s:charLen(l)
  let f = ''

  if cc ==# '['
    if p !=# '[' && n !=# '['
      return
    else
      let r = '\v(^.{' . cl . '})@<=.{-}]]'
      let m = matchstr(l, r)
      if m !=# ''
        let f .= s:removeVimsidianLinkToken(m)
      else
        echo 'No match link token ]]'
        return
      endif
    endif
  elseif cc ==# ']'
    if p !=# ']' && n !=# ']'
      return
    else
      let cr = s:reverseString(c)
      let r = '\v^.{-}[['
      let m = matchstr(cr, r)
      if m !=# ''
        let f .= s:removeVimsidianLinkToken(s:reverseString(m))
      else
        echo 'No match link token [['
        return
      endif
    endif
  else
    let cr = s:reverseString(c)
    let r = '\v^.{-}[['
    let m = matchstr(cr, r)
    if m !=# ''
      let f .= s:removeVimsidianLinkToken(s:reverseString(m))
    else
      echo 'No match link token [['
      return
    endif

    let r = '\v(^.{' . cl . '})@<=.{-}]]'
    let m = matchstr(l, r)
    if m !=# ''
      let f .= s:removeVimsidianLinkToken(m)
    else
      echo 'No match link token ]]'
      return
    endif
  endif

  let cmd = "fd . " . g:vimsidian_path . " | grep '" . f . '.md' . "' | head -n 1"
  let note = system(cmd)
  if empty(note)
    echo "Not found linking note " . f . '.md'
    return
  else
    execute 'e ' . note
  endif
endfunction

function! vimsidian#VimsidianFormatLink()
  let file = expand("%:p")
  let s = join(readfile(file), "\n")
  let s = substitute(s, '\v(\s|\n|^|\!|\(|[\u3001]|[\u3002])@<![[', ' [[', 'g')
  let s = substitute(s, '\v]](\s|\n|$|\.|\,|\)|[\u3001]|[\u3002])@!', ']] ', 'g')
  let s = substitute(s, '\v(\s|\n|^|\!|\(|[\u3001]|[\u3002])@<!\s+[[', ' [[', 'g')
  let s = substitute(s, '\v(\!|\(|[\u3001]|[\u3002])@<=\s+[[', '[[', 'g')
  let s = substitute(s, '\v]]\s+(\s|\n|$|\.|\,|\)|[\u3001]|[\u3002])@!', ']] ', 'g')
  let s = substitute(s, '\v]]\s+(\n|$|\.|\,|\)|[\u3001]|[\u3002])@=', ']]', 'g')
  call writefile(split(s, '\n'), file, "b")
  execute 'e!'
endfunction

 " helper functions
function! s:getUserInput(label)
  let curline = getline('.')
  echohl VimsidianPromptColor
  call inputsave()
  let input=input(a:label . " > ")
  echohl NONE
  call inputrestore()
  call setline('.', curline)
  return input
endfunction

function! s:prevCursorChar(n)
  let chars = split(getline('.')[0 : col('.')-1], '\zs')
  let len = len(chars)
  if a:n >= len
    return ''
  else
    return chars[len(chars) - a:n - 1]
  endif
endfunction

function! s:nextCursorChar(n)
  return matchstr(getline('.'), '.', col('.')-1, a:n + 1)
endfunction

function! s:charToCol()
  if strlen(s:charCol()) ==# 3
    return getline('.')[0 : col('.')+1]
  else
    return getline('.')[0 : col('.')-1]
  endif
endfunction

function! s:charCol()
  return matchstr(getline('.'), '.', col('.')-1)
endfunction

function! s:charLen(b)
  return len(split(a:b, '\zs'))
endfunction

function! s:lineChar()
  return getline('.')[0 : len(getline('.'))]
endfunction

function! s:currentCursorChar()
  return matchstr(getline('.'), '.', col('.')-1)
endfunction

function! s:reverseString(str)
  return join(reverse(split(a:str, '\zs')), '')
endfunction

function! s:removeVimsidianLinkToken(str)
  return substitute(a:str, '\v([|\])', '', 'g')
endfunction

" end flags
let &cpo = s:save_cpo
let loaded_vimsidian_plugin = 1
