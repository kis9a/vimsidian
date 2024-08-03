function! vimsidian#unit#LinksInNote() abort
  let lnums = vimsidian#unit#LinkLineNumbers(expand('%:p'))
  let matches = []
  for l in lnums
    let ls = getline(l)
    let m = []
    call substitute(ls, '\v\[\[.{-}]]', '\=add(m, vimsidian#unit#TrimLinkToken(submatch(0)))', 'g')
    let matches = matches + m
  endfor
  return uniq(sort(matches))
endfunction

function! vimsidian#unit#CursorTag() abort
  let cword = expand('<cWORD>')
  if cword[0] ==# '#'
    let m = matchstr(cword, '\v#(\w)+')
    if m ==# ''
      return v:null
    else
      return cword
    endif
  else
    return v:null
  endif
endfunction

function! vimsidian#unit#NoteNamesInNote() abort
  let links = vimsidian#unit#LinksInNote()
  let new_notes = []
  for link in links
    let new_note = vimsidian#unit#TrimLinkToken(link)
    let valid = 1

    for ilc in g:vimsidian_internal_link_chars
      if stridx(new_note, ilc) !=# '-1'
        if new_note[0] ==# ilc
          let valid = 0
        endif

        let sl = split(new_note, ilc)
        if len(sl) > 0
          let new_note = sl[0]
        endif
      endif
    endfor

    if valid
      call add(new_notes, new_note)
    endif
  endfor

  return uniq(sort(new_notes))
endfunction

function! vimsidian#unit#CursorLink() abort
  let cc = vimsidian#util#CurrentCursorChar()
  let p = vimsidian#util#PrevCursorChar(1)
  let n = vimsidian#util#NextCursorChar(1)
  let c = vimsidian#util#CharToCol()
  let cs = split(c, '\zs')
  let csl = len(cs)
  let l = vimsidian#util#LineChar()
  let f = ''

  if cc ==# '['
    if p !=# '[' && n !=# '['
      call vimsidian#logger#Debug('1 No match link token [[')
      return v:null
    else
      let r = '\v(^.{' . csl . '})@<=.{-}]]'
      let m = matchstr(l, r)
      if m !=# ''
        let f .= vimsidian#unit#TrimLinkToken(m)
      else
        call vimsidian#logger#Debug('1 No match link token ]]')
        return v:null
      endif
    endif
  elseif cc ==# ']'
    if p !=# ']' && n !=# ']'
      call vimsidian#logger#Debug('2 No match link token [[')
      return v:null
    else
      let cr = vimsidian#util#ReverseString(c)
      let r = '\v^.{-}[['
      let m = matchstr(cr, r)
      if m !=# ''
        let f .= vimsidian#unit#TrimLinkToken(vimsidian#util#ReverseString(m))
      else
        call vimsidian#logger#Debug('2 No match link token [[')
        return v:null
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
      return v:null
    endif

    let r = '\v(^.{' . csl . '})@<=.{-}]]'
    let m = matchstr(l, r)
    if m !=# ''
      if stridx(m, '[[') !=# '-1'
        call vimsidian#logger#Debug('Maybe Between links')
        return v:null
      else
        let f .= vimsidian#unit#TrimLinkToken(m)
      endif
    else
      call vimsidian#logger#Debug('3 No match link token ]]')
      return v:null
    endif
  endif

  return f
endfunction

function! vimsidian#unit#InternalLinkMatches(path) abort
  return vimsidian#unit#InternalLinkHeaders(a:path) + vimsidian#unit#InternalLinkBlocks(a:path)
endfunction

function! vimsidian#unit#RemoveUnsuitableLinkChars(s) abort
  let exc = escape(join(g:vimsidian_unsuitable_link_chars, ''), '\\/.*$^~[]')
  return substitute(a:s, '\v[' . exc . ']', '', 'g')
endfunction

function! vimsidian#unit#LinkLineNumbers(path) abort
  let lines = vimsidian#unit#getLines(a:path)
  let lnums = []
  let lnum = 1
  for l in lines
    if l =~# '\v\[\[.{-}]]'
      call add(lnums, lnum)
    endif
    let lnum += 1
  endfor
  return lnums
endfunction

function! vimsidian#unit#InternalLinkHeaderLineNumbers(path) abort
  let lines = vimsidian#unit#getLines(a:path)
  let lnums = []
  let lnum = 1
  for l in lines
    if l =~# '\v^(\#)+\s.*$'
      call add(lnums, lnum)
    endif
    let lnum += 1
  endfor
  return lnums
endfunction

function! vimsidian#unit#InternalLinkBlockLineNumbers(path) abort
  let lines = vimsidian#unit#getLines(a:path)
  let lnums = []
  let lnum = 1
  for l in lines
    if l =~# '\v\^(\w)+$'
      call add(lnums, lnum)
    endif
    let lnum += 1
  endfor
  return lnums
endfunction

function! vimsidian#unit#getLines(path) abort
  if !empty(glob(a:path))
    if expand('%:p') ==# fnamemodify(a:path, ':p')
      return getline(1, '$')
    else
      return vimsidian#action#ReadFile(a:path)
    endif
  else
    return []
  endif
endfunction

function! vimsidian#unit#InternalLinkHeaders(path) abort
  let lnums = vimsidian#unit#InternalLinkHeaderLineNumbers(a:path)
  let lines = vimsidian#unit#getLines(a:path)
  let matches = []

  for l in lnums
    let ls = lines[l - 1]
    call add(matches, vimsidian#unit#RemoveUnsuitableLinkChars(substitute(ls, '\v^(\#)+(\s)+', '', 'g')))
  endfor

  return matches
endfunction

function! vimsidian#unit#InternalLinkBlocks(path) abort
  let lnums = vimsidian#unit#InternalLinkBlockLineNumbers(a:path)
  let lines = vimsidian#unit#getLines(a:path)
  let matches = []

  for l in lnums
    let ls = lines[l - 1]
    let m = matchstr(ls, '\v\^(\w)+$')
    if m !=# ''
      call add(matches, m)
    endif
  endfor
  return matches
endfunction

function! vimsidian#unit#IsExistsInternalLink(path, fn) abort
  let lines = vimsidian#unit#getLines(a:path)

  if !empty(a:fn)
    let lnums = []
    if a:fn[0] ==# '^'
      let lnums = vimsidian#unit#InternalLinkBlockLineNumbers(a:path)
      for l in lnums
        let m = matchstr(lines[l - 1], '\v' . escape(a:fn, '^') . '$')
        if m !=# ''
          return v:true
        endif
      endfor
      return v:null
    else
      let lnums = vimsidian#unit#InternalLinkHeaderLineNumbers(a:path)
      for l in lnums
        let m = matchstr(vimsidian#unit#RemoveUnsuitableLinkChars(lines[l - 1]), '\v^(\s)+.*' . vimsidian#unit#RemoveUnsuitableLinkChars(a:fn) . '$')
        if m !=# ''
          return v:true
        endif
      endfor
      return v:null
    endif
  else
    return v:null
  endif
endfunction

function! vimsidian#unit#InternalLinkPosition(path, fn) abort
  let cln = line('.')
  let lines = vimsidian#unit#getLines(a:path)

  if !empty(a:fn)
    let lnums = []
    if a:fn[0] ==# '^'
      let lnums = vimsidian#unit#InternalLinkBlockLineNumbers(a:path)
      for l in lnums
        let m = matchstr(lines[l - 1], '\v' . escape(a:fn, '^') . '$')
        if m !=# ''
          return [l, 1]
        endif
      endfor
      return [cln, 1]
    else
      let lnums = vimsidian#unit#InternalLinkHeaderLineNumbers(a:path)
      for l in lnums
        let m = matchstr(vimsidian#unit#RemoveUnsuitableLinkChars(lines[l - 1]), '\v^(\s)+.*' . vimsidian#unit#RemoveUnsuitableLinkChars(a:fn) . '$')
        if m !=# ''
          return [l, 1]
        endif
      endfor
      return [cln, 1]
    endif
  else
    return [cln, 1]
  endif
endfunction

function! vimsidian#unit#LinkSetToMove(f) abort
  let note = a:f
  let block = ''

  if stridx(note, '#') !=# '-1'
    if note[0] ==# '#'
      let sf = split(note, '#')
      if len(sf) > 0
        let block = sf[0]
      endif
      let note = fnamemodify(expand('%:r'), ':t')
    else
      let sf = split(note, '#')
      if len(sf) > 0
        let note = sf[0]
      endif

      if len(sf) > 1
        let block = sf[1]
      endif
    endif
  endif

  if stridx(note, '|') !=# '-1'
    let sf = split(note, '|')
    if len(sf) > 0
      let note = sf[0]
    endif
  endif

  return [note, block]
endfunction

function! vimsidian#unit#LinkExtension(f) abort
  let lex = '.md'
  if stridx(a:f, '.') !=# '-1'
    let fe = fnamemodify(a:f, ':e')
    for me in g:vimsidian_media_extensions
      if me ==# fe
        let lex = ''
      endif
    endfor
  endif

  return lex
endfunction

function! vimsidian#unit#Find(fs, p) abort
  for f in a:fs
    if f =~# a:p
      return f
    endif
  endfor
  return v:null
endfunction

function! vimsidian#unit#BrokenLink(files, l) abort
  if a:l[0] ==# '#'
    if vimsidian#unit#IsExistsInternalLink(expand('%:p'), strpart(a:l, 1)) !=# v:true
      return a:l
    endif
    return v:true
  endif

  let nl = a:l
  let lex = vimsidian#unit#LinkExtension(nl)

  if a:l[0] !=# '#' && stridx(nl, '#') !=# '-1'
    let sl = split(nl, '#')
    if len(sl) > 0
      let nl = sl[0]
    endif

    let f = vimsidian#unit#Find(a:files, '^.*/' . nl . lex)
    if f ==# v:true
      return a:l
    endif

    if len(sl) > 1
      if vimsidian#unit#IsExistsInternalLink(f, sl[1]) !=# v:true
        return a:l
      endif
    endif

    return v:true
  endif

  if stridx(nl, '|') !=# '-1'
    let sl = split(nl, '|')
    if len(sl) > 0
      let nl = sl[0]
    endif
  endif

  if vimsidian#unit#Find(a:files, '^.*/' . nl . lex) ==# v:null
    return a:l
  endif

  return v:true
endfunction

function! vimsidian#unit#IsBrokenLink(l) abort
  let files = split(vimsidian#unit#Fd(g:vimsidian_path, []), '\n')
  if vimsidian#unit#BrokenLink(files, a:l) !=# v:true
    return v:true
  else
    return v:null
  endif
endfunction

function! vimsidian#unit#BrokenLinksInNote() abort
  let links = vimsidian#unit#LinksInNote()

  if len(links) > g:max_number_of_links_to_check_for_broken
    call vimsidian#logger#Debug('Number of links over g:max_number_of_links_to_check_for_broken:', g:max_number_of_links_to_check_for_broken)
    let links = links[0:g:max_number_of_links_to_check_for_broken]
  endif

  let files = split(vimsidian#unit#Fd(g:vimsidian_path, []), '\n')
  let blinks = []

  for l in links
    if vimsidian#unit#BrokenLink(files, l) !=# v:true
      call add(blinks, l)
    endif
  endfor

  return blinks
endfunction

function! vimsidian#unit#CursorLinkPosition() abort
  let c = vimsidian#util#CharToCol()
  let cc = vimsidian#util#CurrentCursorChar()
  let p = vimsidian#util#PrevCursorChar(1)
  let n = vimsidian#util#NextCursorChar(1)
  let cl = len(c)
  let rc = vimsidian#util#ReverseString(c)
  let cln = line('.')

  let clink = vimsidian#unit#CursorLink()
  if clink ==# v:null
    call vimsidian#logger#Info('Empty cursor link')
    return [cln, cl]
  endif

  if cc ==# '[' && p ==# '['
    return [cln, cl - 1]
  elseif cc ==# '[' && n ==# '['
    return [cln, cl]
  else
    let m = matchstr(rc, '\v^.{-}[[')
    if m !=# ''
      let ml = len(split(m, '\zs'))
      if ml !=# ''
        return [cln, (len(c) - len(m) + 1)]
      else
        return [cln, cl]
      endif
    else
      return [cln, cl]
    endif
  endif
endfunction

function! vimsidian#unit#PreviousLinkPosition() abort
  let c = vimsidian#util#CharToCol()
  let cl = len(c)
  let rc = vimsidian#util#ReverseString(c)
  let cln = line('.')

  let m = matchstr(rc, '\v^.{-}]]')
  if m !=# ''
    let ml = len(split(m, '\zs'))
    let mp = matchstr(rc, '\v^.{'. ml . '}.{-}[[')
    if ml !=# ''
      return [cln, cl - len(mp) + 1]
    else
      return [cln, cl]
    endif
  else
    let lnums = [] | silent! g/\[\[.\{-}]]/call add(lnums, line('.'))
    let lnums = reverse(sort(lnums, 'n'))
    if empty(lnums)
      call vimsidian#logger#Info('Not found previous link')
      return [cln, cl]
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
  let cl = len(c)
  let cs = split(c, '\zs')
  let csl = len(cs)
  let l = vimsidian#util#LineChar()
  let cln = line('.')

  let m = matchstr(l, '\v(^.{' . csl . '})@<=.{-}[[')
  if m !=# ''
    let ms = split(m, '\zs')
    let ml = len(ms)
    if matchstr(l, '\v(^.{' . (csl + ml) . '})@<=.{-}]]') !=# ''
      return [cln, (len(c) + len(m) - 1)]
    endif
  else
    let lnums = [] | silent! g/\[\[.\{-}]]/call add(lnums, line('.'))
    let lnums = sort(lnums, 'n')
    if empty(lnums)
      call vimsidian#logger#Info('Not found next link')
      return [cln, cl]
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

function! vimsidian#unit#ClearLinkMatchs() abort
  if !exists('w:vimsidian_link_matches')
    return
  endif

  for i in values(w:vimsidian_link_matches)
    call vimsidian#unit#MatchDelete(i)
  endfor

  unlet w:vimsidian_link_matches
endfunction

function! vimsidian#unit#ClearBrokenLinkMatchs() abort
  if !exists('w:vimsidian_broken_link_matches')
    return
  endif

  for i in values(w:vimsidian_broken_link_matches)
    call vimsidian#unit#MatchDelete(i)
  endfor

  unlet w:vimsidian_link_matches
endfunction

function! vimsidian#unit#MatchDelete(id) abort
  try
    call matchdelete(a:id)
  catch /.*/
  endtry
endfunction

function! vimsidian#unit#MatchAdd(group, pattern) abort
  return matchadd(a:group, a:pattern)
endfunction

function! vimsidian#unit#Rg(word, opts) abort
  let cmd = ['rg', '-F', '-n', vimsidian#util#WrapWithSingleQuote(a:word), g:vimsidian_path] + a:opts
  return vimsidian#action#System(cmd)
endfunction

function! vimsidian#unit#RgNotes(word) abort
  let m = vimsidian#unit#Rg(a:word, ['--files-with-matches'])
  if empty (m)
    return []
  else
    return split(m, "\n")
  endif
endfunction

function! vimsidian#unit#RgLines(word) abort
  let m = vimsidian#unit#Rg(a:word, [])
  if empty (m)
    return []
  else
    return m
  endif
endfunction

function! vimsidian#unit#Fd(path, opts) abort
  let cmd = ['fd', '.', a:path] + a:opts
  return vimsidian#action#System(cmd)
endfunction

function! vimsidian#unit#FdNote(note) abort
  let files = split(vimsidian#unit#Fd(g:vimsidian_path, []), '\n')
  return vimsidian#unit#Find(files, '^.*/' . a:note)
endfunction

function! vimsidian#unit#FdNotes(notes) abort
  let files = split(vimsidian#unit#Fd(g:vimsidian_path, []), '\n')
  let fr = []

  for n in a:notes
    let f = vimsidian#unit#Find(files, '^.*/' . n . '.md')
    if f !=# v:null
      call add(fr, f)
    endif
  endfor

  return uniq(sort(fr))
endfunction

function! vimsidian#unit#AppendNumberToLineForList(m) abort
  return substitute(substitute(a:m, '\v\n', ':1: \n', 'g'), '\v$', ':1: \n', 'g')
endfunction

function! vimsidian#unit#RemoveLineFromList(m) abort
  let r = []
  for l in split(a:m, "\n")
    let n = split(l, ':')
    if len(n) > 0
      call add(r, n[0])
    endif
  endfor
  return r
endfunction

function! vimsidian#unit#Ls(path, opts) abort
  let cmd = ['ls', a:path] + a:opts
  return vimsidian#action#System(cmd)
endfunction

function! vimsidian#unit#TrimLinkToken(str) abort
  return substitute(a:str, '\v([|\])', '', 'g')
endfunction
