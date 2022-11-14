function! vimsidian#CompleteNotes(findstart, base) abort
  if a:findstart
    let line = getline('.')
    let start = col('.') - 1
    let exc = escape(join(g:vimsidian_unsuitable_link_chars, ''), '\\/.*$^~[]')
    while start > 0 && line[start - 1] =~ '\v[^' . exc . ']'
      let start -= 1
    endwhile
    return start
  else
    let res = []
    let notes = []

    for f in g:vimsidian_complete_paths
      if g:vimsidian_complete_paths_search_use_fd
        let rs = vimsidian#unit#Fd(vimsidian#util#WrapWithSingleQuote(f), [])
      else
        let rs = vimsidian#unit#Ls(vimsidian#util#WrapWithSingleQuote(f), [])
      endif

      for n in split(rs, '\n')
        call add(notes, substitute(fnamemodify(n, ':t'),  '\v.md$', '', 'g'))
      endfor

      for m in notes
        if m =~ '^' . a:base
          call add(res, m)
        endif
      endfor
    endfor
    return res
  endif
endfunction

function! vimsidian#MatchesOpen(m) abort
  if empty (a:m)
    call vimsidian#logger#Debug('Matches empty' . vimsidian#util#WrapWithSingleQuote(a:m))
    return
  else
    call vimsidian#action#OpenQuickFix(a:m)
  endif
endfunction

function! vimsidian#RgNotesWithMatchesOpenCmd(word) abort
  let m = vimsidian#unit#RgNotes(a:word)
  if m ==# 1
    call vimsidian#logger#Info('Not found ' . vimsidian#util#WrapWithSingleQuote(a:word))
    return
  endif
  call vimsidian#MatchesOpen(vimsidian#unit#AppendNumberToLineForList(m))
endfunction

function! vimsidian#RgLinesWithMatchesOpenCmd(word) abort
  let m = vimsidian#unit#RgLines(a:word)
  if m ==# 1
    call vimsidian#logger#Info('Not found ' . vimsidian#util#WrapWithSingleQuote(a:word))
    return
  endif
  call vimsidian#MatchesOpen(m)
endfunction

function! vimsidian#RgNotesWithMatchesInteractive() abort
  let i = vimsidian#action#GetUserInput('VimsidianRgNotesWithMatchesInteractive')
  if empty(i)
    call vimsidian#logger#Debug('Empty input')
    return
  endif
  let m = vimsidian#unit#RgNotes(i)
  if m ==# 1
    call vimsidian#logger#Info('Not found ' . vimsidian#util#WrapWithSingleQuote(i))
    return
  endif

  call vimsidian#MatchesOpen(vimsidian#unit#AppendNumberToLineForList(m))
endfunction

function! vimsidian#RgLinesWithMatchesInteractive() abort
  let i = vimsidian#action#GetUserInput('VimsidianRgLinesWithMatchesInteractive')
  if empty(i)
    call vimsidian#logger#Debug('Empty input')
    return
  endif
  let m = vimsidian#unit#RgLines(i)
  if m ==# 1
    call vimsidian#logger#Info('Not found ' . vimsidian#util#WrapWithSingleQuote(i))
    return
  endif

  call vimsidian#MatchesOpen(m)
endfunction

function! vimsidian#RgTagMatches() abort
  let tag = vimsidian#unit#CursorTag()
  if tag ==# 1
    call vimsidian#logger#Info('Word under the cursor is not a tag')
    return
  endif
  let m = vimsidian#unit#RgLines(tag)
  if m ==# 1
    call vimsidian#logger#Info('Not found ' . vimsidian#util#WrapWithSingleQuote(tag))
    return
  endif

  call vimsidian#MatchesOpen(m)
endfunction

function! vimsidian#FdLinkedNotesByThisNote() abort
  let links = vimsidian#unit#LinksInThisNote()
  if len(links) > 0
    let m = vimsidian#unit#FdNotes(links)
  else
    call vimsidian#logger#Info('No link found in this note')
    return
  endif

  if empty(m)
    call vimsidian#logger#Info('Linked notes not found')
    return
  else
  call vimsidian#MatchesOpen(vimsidian#unit#AppendNumberToLineForList(m))
  endif
endfunction

function! vimsidian#RgNotesLinkingThisNote() abort
  let fname = fnamemodify(expand('%:t'), ':r')
  let ext = expand('%:e')
  if ext ==# 'md'
    let m = vimsidian#unit#RgNotes('[[' . fname . ']]')
    if m ==# 1
      call vimsidian#logger#Info('Not found ' . vimsidian#util#WrapWithSingleQuote('[[' . fname . ']]'))
      return
    endif
  else
    let m = vimsidian#unit#RgNotes('[[' . expand('%:t') . ']]')
    if m ==# 1
      call vimsidian#logger#Info('Not found ' . vimsidian#util#WrapWithSingleQuote('[[' . expand('%:t') . ']]'))
      return
    endif
  endif

  call vimsidian#MatchesOpen(vimsidian#unit#AppendNumberToLineForList(m))
endfunction

function! vimsidian#MoveToPreviousLink() abort
  let [line, col] = vimsidian#unit#PreviousLinkPosition()
  call cursor(line, col)
endfunction

function! vimsidian#MoveToNextLink() abort
  let [line, col] = vimsidian#unit#NextLinkPosition()
  call cursor(line, col)
endfunction

function! vimsidian#MoveToLink() abort
  let f = vimsidian#unit#CursorLink()
  if f ==# 1
    return
  endif

  if empty(f)
    call vimsidian#logger#Info('Link name is empty')
    return
  endif

  let [f, fn] = vimsidian#unit#LinkSetToMove(f)
  let lex = vimsidian#unit#LinkExtension(f)

  if lex ==# ''
    let i = vimsidian#action#GetUserInput('open ' . vimsidian#util#WrapWithSingleQuote(f) . ' [y/n]')
    if i !=# 'y'
      return
    endif
  endif

  let note = vimsidian#unit#FdNote(f . lex)
  let m = split(note, '\n')
  if len(m) > 0
    let note = m[0]
  endif

  if empty(note)
    call vimsidian#logger#Info('Linked note not found' . vimsidian#util#WrapWithSingleQuote(f . lex))
    return
  else
    execute 'e! ' . note
  endif

  let [line, col] = vimsidian#unit#InternalLinkPosition(fn)
  call cursor(line, col)
endfunction

function! vimsidian#NewNote(dir) abort
  let f = vimsidian#unit#CursorLink()
  if f ==# 1
    call vimsidian#logger#Info('Word under the cursor is not a link')
    return
  endif

  if empty(f)
    call vimsidian#logger#Info('Link name is empty')
    return
  endif

  let [f, fn] = vimsidian#unit#LinkSetToMove(f)

  if empty(glob(a:dir))
    call vimsidian#logger#Info('No such directory ' . a:dir)
    return
  endif

  let note = fnamemodify(a:dir, ':p') . f . '.md'
  if !empty(glob(note))
    call vimsidian#logger#Info('Already exists ' . note)
    execute 'e! ' . note
  else
    execute 'e! ' . note
  endif

  let [line, col] = vimsidian#unit#InternalLinkPosition(fn)
  call cursor(line, col)
endfunction

function! vimsidian#FormatLink() abort
  let file = expand('%:p')
  let s = join(readfile(file), "\n")
  let s = vimsidian#unit#FormatLinkString(s)
  call vimsidian#action#WriteFile(split(s, '\n'), file, 'b')
  execute 'e!'
endfunction
