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
  let i = vimsidian#utils#getUserInput("")
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
  let cc = vimsidian#utils#currentCursorChar()
  let p = vimsidian#utils#prevCursorChar(1)
  let n = vimsidian#utils#nextCursorChar(1)
  let c = vimsidian#utils#charToCol()
  let cs = split(c, '\zs')
  let cl = len(cs)
  let l = vimsidian#utils#lineChar()
  let ll = vimsidian#utils#charLen(l)
  let f = ''

  if cc ==# '['
    if p !=# '[' && n !=# '['
      return
    else
      let r = '\v(^.{' . cl . '})@<=.{-}]]'
      let m = matchstr(l, r)
      if m !=# ''
        let f .= vimsidian#utils#removeVimsidianLinkToken(m)
      else
        echo 'No match link token ]]'
        return
      endif
    endif
  elseif cc ==# ']'
    if p !=# ']' && n !=# ']'
      return
    else
      let cr = vimsidian#utils#reverseString(c)
      let r = '\v^.{-}[['
      let m = matchstr(cr, r)
      if m !=# ''
        let f .= vimsidian#utils#removeVimsidianLinkToken(vimsidian#utils#reverseString(m))
      else
        echo 'No match link token [['
        return
      endif
    endif
  else
    let cr = vimsidian#utils#reverseString(c)
    let r = '\v^.{-}[['
    let m = matchstr(cr, r)
    if m !=# ''
      let f .= vimsidian#utils#removeVimsidianLinkToken(vimsidian#utils#reverseString(m))
    else
      echo 'No match link token [['
      return
    endif

    let r = '\v(^.{' . cl . '})@<=.{-}]]'
    let m = matchstr(l, r)
    if m !=# ''
      let f .= vimsidian#utils#removeVimsidianLinkToken(m)
    else
      echo 'No match link token ]]'
      return
    endif
  endif

  let cmd = "fd . " . g:vimsidian_path . " | grep '/" . f . '.md' . "' | head -n 1"
  let note = system(cmd)
  if empty(note)
    echo "Not found linking note " . f . '.md'
    return
  else
    execute 'e ' . note
  endif
endfunction

function! vimsidian#VimsidianMoveToPreviousLink()
  let cc = vimsidian#utils#currentCursorChar()
  let c = vimsidian#utils#charToCol()
  let cs = split(c, '\zs')
  let cl = len(cs)
  let l = vimsidian#utils#lineChar()
  let ll = vimsidian#utils#charLen(l)
  let cln = line('.')

  let m = matchstr(vimsidian#utils#reverseString(c), '\v^.{-}]]')
  if m !=# ''
    let ml = len(split(m, '\zs'))
    let mp = matchstr(vimsidian#utils#reverseString(c), '\v^.{'. ml . '}.{-}[[')
    if ml !=# ''
      call cursor(cln, (len(c) - len(mp) + 1))
      return
    else
    endif
  else
    let lnums = [] | silent! g/\[\[.\{-}]]/call add(lnums, line('.'))
    let lnums = reverse(sort(lnums, 'n'))
    if empty(lnums)
      echo 'Not found previous link'
      return
    else
      for lnum in lnums
        if lnum < cln
          let nl = getline(lnum)
          let nlm = matchstr(nl, '\v^.*[[')
          if nlm !=# ''
            call cursor(lnum, (len(nlm) - 1))
            return
          else
            call cursor(lnum, 1)
            return
          endif
        endif
      endfor

      let nln = lnums[0]
      let nl = getline(nln)
      let nlm = matchstr(nl, '\v^.*[[')
      if nlm !=# ''
        call cursor(nln, len(nlm) - 1)
        return
      else
        call cursor(nln, 1)
        return
      endif
    endif
  endif
endfunction

function! vimsidian#VimsidianMoveToNextLink()
  let cc = vimsidian#utils#currentCursorChar()
  let c = vimsidian#utils#charToCol()
  let cs = split(c, '\zs')
  let cl = len(cs)
  let l = vimsidian#utils#lineChar()
  let ll = vimsidian#utils#charLen(l)
  let cln = line('.')

  let m = matchstr(l, '\v(^.{' . cl . '})@<=.{-}[[')
  if m !=# ''
    let ms = split(m, '\zs')
    let ml = len(ms)
    if matchstr(l, '\v(^.{' . (cl + ml) . '})@<=.{-}]]') !=# ''
      call cursor(cln, (len(c) + len(m) - 1))
      return
    endif
  else
    let lnums = [] | silent! g/\[\[.\{-}]]/call add(lnums, line('.'))
    let lnums = sort(lnums, 'n')
    if empty(lnums)
      echo 'Not found next link'
      return
    else
      for lnum in lnums
        if lnum > cln
          let nl = getline(lnum)
          if matchstr(nl, '\v^[[') !=# ''
            call cursor(lnum, 1)
            return
          else
            let nlm = matchstr(nl, '\v^.{-}[[')
            if nlm !=# ''
              call cursor(lnum, len(nlm) - 1)
              return
            else
              call cursor(lnum, 1)
              return
            endif
          endif
          return
        endif
      endfor

      let nln = lnums[0]
      let nl = getline(nln)
      if matchstr(nl, '\v^[[') !=# ''
        call cursor(nln, 1)
        return
      else
        let nlm = matchstr(nl, '\v^.{-}[[')
        if nlm !=# ''
          call cursor(nln, len(nlm) - 1)
          return
        else
          call cursor(nln, 1)
          return
        endif
      endif
    endif
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

" end flags
let &cpo = s:save_cpo
