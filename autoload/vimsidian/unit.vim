function! vimsidian#unit#TrimLinkToken(str) abort
  return substitute(a:str, '\v([|\])', '', 'g')
endfunction

function! vimsidian#unit#CursorTag() abort
  let cword = expand('<cWORD>')
  if cword[0] ==# "#"
    return cword
  else
    return 1
  endif
endfunction

function! vimsidian#unit#LinksInThisNote() abort
  let cmd = []
  if stridx(system("grep --version"), "BSD") == "-1"
    call add(cmd, 'grep -oP') " Use GNU grep option
  else
    call add(cmd, 'grep -oE') " Use BSD grep option
  endif

  let absolutePath=expand('%:p')
  call add(cmd,  " '\\[\\[.*?\\]]' '" . absolutePath . "'")
  let links = vimsidian#action#System(cmd)
  let links = split(links, '\n')

  let new_links = []
  for link in links
    let new_link = vimsidian#unit#TrimLinkToken(link)
    let valid = 1

    for ilc in g:vimsidian_internal_link_chars
      if stridx(new_link, ilc) !=# "-1"
        if new_link[0] ==# ilc
          let valid = 0
        endif

        let sl = split(new_link, ilc)
        if len(sl) > 0
          let new_link = sl[0]
        endif
      endif
    endfor

    if valid
      call add(new_links, new_link)
    endif
  endfor

  return uniq(sort(new_links))
endfunction

function! vimsidian#unit#CursorLink() abort
  let cc = vimsidian#util#CurrentCursorChar()
  let p = vimsidian#util#PrevCursorChar(1)
  let n = vimsidian#util#NextCursorChar(1)
  let c = vimsidian#util#CharToCol()
  let cs = split(c, '\zs')
  let cl = len(cs)
  let l = vimsidian#util#LineChar()
  let f = ''

  if cc ==# '['
    if p !=# '[' && n !=# '['
      call vimsidian#logger#Debug('1 No match link token [[')
      return 1
    else
      let r = '\v(^.{' . cl . '})@<=.{-}]]'
      let m = matchstr(l, r)
      if m !=# ''
        let f .= vimsidian#unit#TrimLinkToken(m)
      else
        call vimsidian#logger#Debug('1 No match link token ]]')
        return 1
      endif
    endif
  elseif cc ==# ']'
    if p !=# ']' && n !=# ']'
      call vimsidian#logger#Debug('2 No match link token [[')
      return 1
    else
      let cr = vimsidian#util#ReverseString(c)
      let r = '\v^.{-}[['
      let m = matchstr(cr, r)
      if m !=# ''
        let f .= vimsidian#unit#TrimLinkToken(vimsidian#util#ReverseString(m))
      else
        call vimsidian#logger#Debug('2 No match link token [[')
        return 1
      endif
    endif
  else
    let cr = vimsidian#util#ReverseString(c)
    let r = '\v^.{-}[['
    let m = matchstr(cr, r)
    if m !=# ''
      let f .= vimsidian#unit#TrimLinkToken(vimsidian#util#ReverseString(m))
    else
      call vimsidian#logger#Debug('3 No match link token [[')
      return 1
    endif

    let r = '\v(^.{' . cl . '})@<=.{-}]]'
    let m = matchstr(l, r)
    if m !=# ''
      let f .= vimsidian#unit#TrimLinkToken(m)
    else
      call vimsidian#logger#Debug('3 No match link token ]]')
      return 1
    endif
  endif

  return f
endfunction

function! vimsidian#unit#PreviousLinkPosition() abort
  let c = vimsidian#util#CharToCol()
  let cs = split(c, '\zs')
  let cl = len(cs)
  let l = vimsidian#util#LineChar()
  let cln = line('.')

  let m = matchstr(vimsidian#util#ReverseString(c), '\v^.{-}]]')
  if m !=# ''
    let ml = len(split(m, '\zs'))
    let mp = matchstr(vimsidian#util#ReverseString(c), '\v^.{'. ml . '}.{-}[[')
    if ml !=# ''
      return [cln, (len(c) - len(mp) + 1)]
    else
      return [l, cl]
    endif
  else
    let lnums = [] | silent! g/\[\[.\{-}]]/call add(lnums, line('.'))
    let lnums = reverse(sort(lnums, 'n'))
    if empty(lnums)
      call vimsidian#logger#Info('Not found previous link')
      return [l, cl]
    else
      for lnum in lnums
        if lnum < cln
          let nl = getline(lnum)
          let nlm = matchstr(nl, '\v^.*[[')
          if nlm !=# ''
            return [lnum, (len(nlm) - 1)]
          else
            return [lnum, 1]
          endif
        endif
      endfor

      let nln = lnums[0]
      let nl = getline(nln)
      let nlm = matchstr(nl, '\v^.*[[')
      if nlm !=# ''
        return [nln, len(nlm) - 1]
      else
        return [nln, 1]
      endif
    endif
  endif
endfunction

function! vimsidian#unit#NextLinkPosition() abort
  let c = vimsidian#util#CharToCol()
  let cs = split(c, '\zs')
  let cl = len(cs)
  let l = vimsidian#util#LineChar()
  let cln = line('.')

  let m = matchstr(l, '\v(^.{' . cl . '})@<=.{-}[[')
  if m !=# ''
    let ms = split(m, '\zs')
    let ml = len(ms)
    if matchstr(l, '\v(^.{' . (cl + ml) . '})@<=.{-}]]') !=# ''
      return [cln, (len(c) + len(m) - 1)]
    endif
  else
    let lnums = [] | silent! g/\[\[.\{-}]]/call add(lnums, line('.'))
    let lnums = sort(lnums, 'n')
    if empty(lnums)
      call vimsidian#logger#Info('Not found next link')
      return [l, cl]
    else
      for lnum in lnums
        if lnum > cln
          let nl = getline(lnum)
          if matchstr(nl, '\v^[[') !=# ''
            return [lnum, 1]
          else
            let nlm = matchstr(nl, '\v^.{-}[[')
            if nlm !=# ''
              return [lnum, len(nlm) - 1]
            else
              return [lnum, 1]
            endif
          endif
        endif
      endfor

      let nln = lnums[0]
      let nl = getline(nln)
      if matchstr(nl, '\v^[[') !=# ''
        return [nln, 1]
      else
        let nlm = matchstr(nl, '\v^.{-}[[')
        if nlm !=# ''
          return [nln, len(nlm) - 1]
        else
          return [nln, 1]
        endif
      endif
    endif
  endif
endfunction

function! vimsidian#unit#FormatLinkString(s) abort
  let s = substitute(a:s, '\v(\s|\n|^|\!|\(|[\u3001]|[\u3002])@<![[', ' [[', 'g')
  let s = substitute(s, '\v]](\s|\n|$|\.|\,|\)|[\u3001]|[\u3002])@!', ']] ', 'g')
  let s = substitute(s, '\v(\s|\n|^|\!|\(|[\u3001]|[\u3002])@<!\s+[[', ' [[', 'g')
  let s = substitute(s, '\v(\!|\(|[\u3001]|[\u3002])@<=\s+[[', '[[', 'g')
  let s = substitute(s, '\v]]\s+(\s|\n|$|\.|\,|\)|[\u3001]|[\u3002])@!', ']] ', 'g')
  let s = substitute(s, '\v]]\s+(\n|$|\.|\,|\)|[\u3001]|[\u3002])@=', ']]', 'g')
  return s
endfunction
