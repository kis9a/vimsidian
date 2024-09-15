function! vimsidian#utils#LinksInNote() abort
  let lnums = vimsidian#utils#LinkLineNumbers(expand('%:p'))
  let matches = []
  for l in lnums
    let ls = getline(l)
    let m = []
    call substitute(ls, '\v\[\[.{-}]]', '\=add(m, vimsidian#utils#TrimLinkToken(submatch(0)))', 'g')
    let matches = matches + m
  endfor
  return uniq(sort(matches))
endfunction

function! vimsidian#utils#CursorTag() abort
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

function! vimsidian#utils#NoteNamesInNote() abort
  let links = vimsidian#utils#LinksInNote()
  let new_notes = []
  for link in links
    let new_note = vimsidian#utils#TrimLinkToken(link)
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

function! vimsidian#utils#CursorLink() abort
  let cc = vimsidian#utils#CurrentCursorChar()
  let p = vimsidian#utils#PrevCursorChar(1)
  let n = vimsidian#utils#NextCursorChar(1)
  let c = vimsidian#utils#CharToCol()
  let cs = split(c, '\zs')
  let csl = len(cs)
  let l = vimsidian#utils#LineChar()
  let f = ''

  if cc ==# '['
    if p !=# '[' && n !=# '['
      call vimsidian#utils#LogDebug('1 No match link token [[')
      return v:null
    else
      let r = '\v(^.{' . csl . '})@<=.{-}]]'
      let m = matchstr(l, r)
      if m !=# ''
        let f .= vimsidian#utils#TrimLinkToken(m)
      else
        call vimsidian#utils#LogDebug('1 No match link token ]]')
        return v:null
      endif
    endif
  elseif cc ==# ']'
    if p !=# ']' && n !=# ']'
      call vimsidian#utils#LogDebug('2 No match link token [[')
      return v:null
    else
      let cr = vimsidian#utils#ReverseString(c)
      let r = '\v^.{-}[['
      let m = matchstr(cr, r)
      if m !=# ''
        let f .= vimsidian#utils#TrimLinkToken(vimsidian#utils#ReverseString(m))
      else
        call vimsidian#utils#LogDebug('2 No match link token [[')
        return v:null
      endif
    endif
  else
    let cr = vimsidian#utils#ReverseString(c)
    let r = '\v^.{-}[['
    let m = matchstr(cr, r)
    if m !=# ''
      let f .= vimsidian#utils#TrimLinkToken(vimsidian#utils#ReverseString(m))
    else
      call vimsidian#utils#LogDebug('3 No match link token [[')
      return v:null
    endif

    let r = '\v(^.{' . csl . '})@<=.{-}]]'
    let m = matchstr(l, r)
    if m !=# ''
      if stridx(m, '[[') !=# '-1'
        call vimsidian#utils#LogDebug('Maybe Between links')
        return v:null
      else
        let f .= vimsidian#utils#TrimLinkToken(m)
      endif
    else
      call vimsidian#utils#LogDebug('3 No match link token ]]')
      return v:null
    endif
  endif

  return f
endfunction

function! vimsidian#utils#InternalLinkMatches(path) abort
  return vimsidian#utils#InternalLinkHeaders(a:path) + vimsidian#utils#InternalLinkBlocks(a:path)
endfunction

function! vimsidian#utils#RemoveUnsuitableLinkChars(s) abort
  let exc = escape(join(g:vimsidian_unsuitable_link_chars, ''), '\\/.*$^~[]')
  return substitute(a:s, '\v[' . exc . ']', '', 'g')
endfunction

function! vimsidian#utils#LinkLineNumbers(path) abort
  let lines = vimsidian#utils#getLines(a:path)
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

function! vimsidian#utils#InternalLinkHeaderLineNumbers(path) abort
  let lines = vimsidian#utils#getLines(a:path)
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

function! vimsidian#utils#InternalLinkBlockLineNumbers(path) abort
  let lines = vimsidian#utils#getLines(a:path)
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

function! vimsidian#utils#getLines(path) abort
  if !empty(glob(a:path))
    if expand('%:p') ==# fnamemodify(a:path, ':p')
      return getline(1, '$')
    else
      return vimsidian#utils#ReadFile(a:path)
    endif
  else
    return []
  endif
endfunction

function! vimsidian#utils#InternalLinkHeaders(path) abort
  let lnums = vimsidian#utils#InternalLinkHeaderLineNumbers(a:path)
  let lines = vimsidian#utils#getLines(a:path)
  let matches = []

  for l in lnums
    let ls = lines[l - 1]
    call add(matches, vimsidian#utils#RemoveUnsuitableLinkChars(substitute(ls, '\v^(\#)+(\s)+', '', 'g')))
  endfor

  return matches
endfunction

function! vimsidian#utils#InternalLinkBlocks(path) abort
  let lnums = vimsidian#utils#InternalLinkBlockLineNumbers(a:path)
  let lines = vimsidian#utils#getLines(a:path)
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

function! vimsidian#utils#IsExistsInternalLink(path, fn) abort
  let lines = vimsidian#utils#getLines(a:path)

  if !empty(a:fn)
    let lnums = []
    if a:fn[0] ==# '^'
      let lnums = vimsidian#utils#InternalLinkBlockLineNumbers(a:path)
      for l in lnums
        let m = matchstr(lines[l - 1], '\v' . escape(a:fn, '^') . '$')
        if m !=# ''
          return v:true
        endif
      endfor
      return v:null
    else
      let lnums = vimsidian#utils#InternalLinkHeaderLineNumbers(a:path)
      for l in lnums
        let m = matchstr(vimsidian#utils#RemoveUnsuitableLinkChars(lines[l - 1]), '\v^(\s)+.*' . vimsidian#utils#RemoveUnsuitableLinkChars(a:fn) . '$')
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

function! vimsidian#utils#InternalLinkPosition(path, fn) abort
  let cln = line('.')
  let lines = vimsidian#utils#getLines(a:path)

  if !empty(a:fn)
    let lnums = []
    if a:fn[0] ==# '^'
      let lnums = vimsidian#utils#InternalLinkBlockLineNumbers(a:path)
      for l in lnums
        let m = matchstr(lines[l - 1], '\v' . escape(a:fn, '^') . '$')
        if m !=# ''
          return [l, 1]
        endif
      endfor
      return [cln, 1]
    else
      let lnums = vimsidian#utils#InternalLinkHeaderLineNumbers(a:path)
      for l in lnums
        let m = matchstr(vimsidian#utils#RemoveUnsuitableLinkChars(lines[l - 1]), '\v^(\s)+.*' . vimsidian#utils#RemoveUnsuitableLinkChars(a:fn) . '$')
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

function! vimsidian#utils#LinkSetToMove(f) abort
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

function! vimsidian#utils#LinkExtension(f) abort
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

function! vimsidian#utils#Find(fs, p) abort
  for f in a:fs
    if f =~# a:p
      return f
    endif
  endfor
  return v:null
endfunction

function! vimsidian#utils#BrokenLink(files, l) abort
  if a:l[0] ==# '#'
    if vimsidian#utils#IsExistsInternalLink(expand('%:p'), strpart(a:l, 1)) !=# v:true
      return a:l
    endif
    return v:true
  endif

  let nl = a:l
  let lex = vimsidian#utils#LinkExtension(nl)

  if a:l[0] !=# '#' && stridx(nl, '#') !=# '-1'
    let sl = split(nl, '#')
    if len(sl) > 0
      let nl = sl[0]
    endif

    let f = vimsidian#utils#Find(a:files, '^.*/' . nl . lex)
    if f ==# v:true
      return a:l
    endif

    if len(sl) > 1
      if vimsidian#utils#IsExistsInternalLink(f, sl[1]) !=# v:true
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

  if vimsidian#utils#Find(a:files, '^.*/' . nl . lex) ==# v:null
    return a:l
  endif

  return v:true
endfunction

function! vimsidian#utils#IsBrokenLink(l) abort
  let files = split(vimsidian#utils#Fd(vimsidian#utils#Getcwd(), []), '\n')
  if vimsidian#utils#BrokenLink(files, a:l) !=# v:true
    return v:true
  else
    return v:null
  endif
endfunction

function! vimsidian#utils#BrokenLinksInNote() abort
  let links = vimsidian#utils#LinksInNote()

  if len(links) > g:broken_link_check_max
    call vimsidian#utils#LogDebug('Number of links over g:broken_link_check_max:', g:broken_link_check_max)
    let links = links[0:g:broken_link_check_max]
  endif

  let files = split(vimsidian#utils#Fd(vimsidian#utils#Getcwd(), []), '\n')
  let blinks = []

  for l in links
    if vimsidian#utils#BrokenLink(files, l) !=# v:true
      call add(blinks, l)
    endif
  endfor

  return blinks
endfunction

function! vimsidian#utils#CursorLinkPosition() abort
  let c = vimsidian#utils#CharToCol()
  let cc = vimsidian#utils#CurrentCursorChar()
  let p = vimsidian#utils#PrevCursorChar(1)
  let n = vimsidian#utils#NextCursorChar(1)
  let cl = len(c)
  let rc = vimsidian#utils#ReverseString(c)
  let cln = line('.')

  let clink = vimsidian#utils#CursorLink()
  if clink ==# v:null
    call vimsidian#utils#LogInfo('Empty cursor link')
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

function! vimsidian#utils#PreviousLinkPosition() abort
  let c = vimsidian#utils#CharToCol()
  let cl = len(c)
  let rc = vimsidian#utils#ReverseString(c)
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
      call vimsidian#utils#LogInfo('Not found previous link')
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

function! vimsidian#utils#NextLinkPosition() abort
  let c = vimsidian#utils#CharToCol()
  let cl = len(c)
  let cs = split(c, '\zs')
  let csl = len(cs)
  let l = vimsidian#utils#LineChar()
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
      call vimsidian#utils#LogInfo('Not found next link')
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

function! vimsidian#utils#ClearLinkMatchs() abort
  if !exists('w:vimsidian_link_matches')
    return
  endif

  for i in values(w:vimsidian_link_matches)
    call vimsidian#utils#MatchDelete(i)
  endfor

  unlet w:vimsidian_link_matches
endfunction

function! vimsidian#utils#ClearBrokenLinkMatchs() abort
  if !exists('w:vimsidian_broken_link_matches')
    return
  endif

  for i in values(w:vimsidian_broken_link_matches)
    call vimsidian#utils#MatchDelete(i)
  endfor

  unlet w:vimsidian_link_matches
endfunction

function! vimsidian#utils#MatchDelete(id) abort
  try
    call matchdelete(a:id)
  catch /.*/
  endtry
endfunction

function! vimsidian#utils#MatchAdd(group, pattern) abort
  return matchadd(a:group, a:pattern)
endfunction

function! vimsidian#utils#Rg(word, opts) abort
  let cmd = ['rg', '-F', '-n', vimsidian#utils#WrapWithSingleQuote(a:word), vimsidian#utils#Getcwd()] + a:opts
  return vimsidian#utils#System(cmd)
endfunction

function! vimsidian#utils#RgNotes(word) abort
  let m = vimsidian#utils#Rg(a:word, ['--files-with-matches'])
  if empty (m)
    return []
  else
    return split(m, "\n")
  endif
endfunction

function! vimsidian#utils#RgLines(word) abort
  let m = vimsidian#utils#Rg(a:word, [])
  if empty (m)
    return []
  else
    return m
  endif
endfunction

function! vimsidian#utils#Fd(path, opts) abort
  let cmd = ['fd', '.', a:path] + a:opts
  return vimsidian#utils#System(cmd)
endfunction

function! vimsidian#utils#FdNote(note) abort
  let files = split(vimsidian#utils#Fd(vimsidian#utils#Getcwd(), []), '\n')
  return vimsidian#utils#Find(files, '^.*/' . a:note)
endfunction

function! vimsidian#utils#FdNotes(notes) abort
  let files = split(vimsidian#utils#Fd(vimsidian#utils#Getcwd(), []), '\n')
  let fr = []

  for n in a:notes
    let f = vimsidian#utils#Find(files, '^.*/' . n . '.md')
    if f !=# v:null
      call add(fr, f)
    endif
  endfor

  return uniq(sort(fr))
endfunction

function! vimsidian#utils#AppendNumberToLineForList(m) abort
  return substitute(substitute(a:m, '\v\n', ':1: \n', 'g'), '\v$', ':1: \n', 'g')
endfunction

function! vimsidian#utils#RemoveLineFromList(m) abort
  let r = []
  for l in split(a:m, "\n")
    let n = split(l, ':')
    if len(n) > 0
      call add(r, n[0])
    endif
  endfor
  return r
endfunction

function! vimsidian#utils#Ls(path, opts) abort
  let cmd = ['ls', a:path] + a:opts
  return vimsidian#utils#System(cmd)
endfunction

function! vimsidian#utils#TrimLinkToken(str) abort
  return substitute(a:str, '\v([|\])', '', 'g')
endfunction

function! vimsidian#utils#PrevCursorChar(n) abort
  let chars = split(getline('.')[0 : col('.')-1], '\zs')
  let len = len(chars)
  if a:n >= len
    return ''
  else
    return chars[len(chars) - a:n - 1]
  endif
endfunction

function! vimsidian#utils#NextCursorChar(n) abort
  return matchstr(getline('.'), '.', col('.')-1, a:n + 1)
endfunction

function! vimsidian#utils#CharToCol() abort
  if strlen(vimsidian#utils#CharCol()) ==# 3
    return getline('.')[0 : col('.')+1]
  else
    return getline('.')[0 : col('.')-1]
  endif
endfunction

function! vimsidian#utils#CharCol() abort
  return matchstr(getline('.'), '.', col('.')-1)
endfunction

function! vimsidian#utils#CharLen(b) abort
  return len(split(a:b, '\zs'))
endfunction

function! vimsidian#utils#LineChar() abort
  return getline('.')[0 : len(getline('.'))]
endfunction

function! vimsidian#utils#CurrentCursorChar() abort
  return matchstr(getline('.'), '.', col('.')-1)
endfunction

function! vimsidian#utils#ReverseString(str) abort
  return join(reverse(split(a:str, '\zs')), '')
endfunction

function! vimsidian#utils#WrapWithSingleQuote(str) abort
  return "'" . a:str . "'"
endfunction

function! vimsidian#utils#PathJoin(...) abort
  let path = ''
  for part in a:000
    let path .= '/' . (type(part) is type([]) ? call('vimsidian#utils#PathJoin', part) :part)
    unlet part
  endfor
  return substitute(path[1 :], (exists('+shellslash') ? '[\\/]' : '/') . '\+', '/', 'g')
endfunction

function! vimsidian#utils#CamelCase(str) abort
  let s = substitute(a:str, '[^A-Za-z0-9]', ' ', 'g')
  let s = join(map(split(s, '\s\+'), 'toupper(v:val[0]) . v:val[1:]'), '')
  return s
endfunction

function! vimsidian#utils#OpenQuickFix(lst, base) abort
  execute 'lcd' a:base
  cexpr a:lst | copen
endfunction

function! vimsidian#utils#GetUserInput(label) abort
  let curline = getline('.')
  echohl VimsidianPromptColor
  call inputsave()
  let input=input(a:label . ' > ')
  echohl NONE
  call inputrestore()
  call setline('.', curline)
  return input
endfunction

function! vimsidian#utils#OpenFile(opener, file) abort
  execute join([a:opener,  a:file], ' ')
endfunction

function! vimsidian#utils#System(cmd) abort
  return system(join(a:cmd, ' '))
endfunction

function! vimsidian#utils#MkdirP(f) abort
  return system(join(['mkdir -p', a:f], ' '))
endfunction

function! vimsidian#utils#ReadFile(f) abort
  return readfile(a:f)
endfunction

function! vimsidian#utils#LogError(msg) abort
  if g:vimsidian_log_level > 0
    echohl ErrorMsg
    echo 'vimsidian: ' . a:msg
    echohl None
  endif
endfunction

function! vimsidian#utils#LogInfo(msg) abort
  if g:vimsidian_log_level > 1
    echo 'vimsidian: ' . a:msg
  endif
endfunction

function! vimsidian#utils#LogDebug(msg) abort
  if g:vimsidian_log_level > 2
    echo 'vimsidian: ' . a:msg
  endif
endfunction

function! vimsidian#utils#Getcwd() abort
  let l:dir = getcwd()
  while l:dir !=# '/' && l:dir !=# ''
    if isdirectory(l:dir . '/.obsidian') || filereadable(l:dir . '/.obsidian')
      return l:dir
    endif
    let l:dir = fnamemodify(l:dir, ':h')
  endwhile
  return ''
endfunction

function! vimsidian#utils#MatchesOpen(m, n) abort
  if empty (a:m)
    call vimsidian#utils#LogDebug('Matches empty' . vimsidian#utils#WrapWithSingleQuote(a:m))
    return
  else
    if g:vimsidian_use_fzf && a:n
      call fzf#run(fzf#wrap({ 'source': vimsidian#utils#RemoveLineFromList(a:m), 'sink': ':e!' }))
    else
      call vimsidian#utils#OpenQuickFix(a:m, vimsidian#utils#Getcwd())
    endif
  endif
endfunction
