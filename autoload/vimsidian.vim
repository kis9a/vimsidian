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

function! vimsidian#MatchesOpen(m, n) abort
  if empty (a:m)
    call vimsidian#logger#Debug('Matches empty' . vimsidian#util#WrapWithSingleQuote(a:m))
    return
  else
    if g:vimsidian_use_fzf && a:n
      call fzf#run(fzf#wrap({ 'source': vimsidian#unit#RemoveLineFromList(a:m), 'sink': g:vimsidian_link_open_mode }))
    else
      call vimsidian#action#OpenQuickFix(a:m, g:vimsidian_path)
    endif
  endif
endfunction

function! vimsidian#RgNotesWithMatchesOpenCmd(word) abort
  let m = vimsidian#unit#RgNotes(a:word)
  if len(m) < 1
    call vimsidian#logger#Info('Not found ' . vimsidian#util#WrapWithSingleQuote(a:word))
    return
  endif
  call vimsidian#MatchesOpen(vimsidian#unit#AppendNumberToLineForList(join(m, "\n")), v:true)
endfunction

function! vimsidian#RgLinesWithMatchesOpenCmd(word) abort
  let m = vimsidian#unit#RgLines(a:word)
  if len(m) < 1
    call vimsidian#logger#Info('Not found ' . vimsidian#util#WrapWithSingleQuote(a:word))
    return
  endif
  call vimsidian#MatchesOpen(m, v:null)
endfunction

function! vimsidian#RgNotesWithMatchesInteractive() abort
  let i = vimsidian#action#GetUserInput('VimsidianRgNotesWithMatchesInteractive')
  if empty(i)
    call vimsidian#logger#Debug('Empty input')
    return
  endif
  let m = vimsidian#unit#RgNotes(i)
  if len(m) < 1
    call vimsidian#logger#Info('Not found ' . vimsidian#util#WrapWithSingleQuote(i))
    return
  endif

  call vimsidian#MatchesOpen(vimsidian#unit#AppendNumberToLineForList(join(m, "\n")), v:true)
endfunction

function! vimsidian#RgLinesWithMatchesInteractive() abort
  let i = vimsidian#action#GetUserInput('VimsidianRgLinesWithMatchesInteractive')
  if empty(i)
    call vimsidian#logger#Debug('Empty input')
    return
  endif
  let m = vimsidian#unit#RgLines(i)
  if len(m) < 1
    call vimsidian#logger#Info('Not found ' . vimsidian#util#WrapWithSingleQuote(i))
    return
  endif

  call vimsidian#MatchesOpen(m, v:null)
endfunction

function! vimsidian#RgTagMatches() abort
  let tag = vimsidian#unit#CursorTag()
  if tag ==# v:null
    call vimsidian#logger#Info('Word under the cursor is not a tag')
    return
  endif
  let m = vimsidian#unit#RgLines(tag)
  if len(m) < 1
    call vimsidian#logger#Info('Not found ' . vimsidian#util#WrapWithSingleQuote(tag))
    return
  endif

  call vimsidian#MatchesOpen(m, v:null)
endfunction

function! vimsidian#FdLinkedNotesByThisNote() abort
  let links = vimsidian#unit#NoteNamesInNote()
  if len(links) > 0
    let m = join(vimsidian#unit#FdNotes(links), "\n")
  else
    call vimsidian#logger#Info('No link found in this note')
    return
  endif

  if empty(m)
    call vimsidian#logger#Info('Linked notes not found')
    return
  else
  call vimsidian#MatchesOpen(vimsidian#unit#AppendNumberToLineForList(m), v:true)
  endif
endfunction

function! vimsidian#RgNotesLinkingThisNote() abort
  let fname = fnamemodify(expand('%:t'), ':r')
  let ext = expand('%:e')
  if ext ==# 'md'
    let m = vimsidian#unit#RgNotes('[[' . fname . ']]')
    if len(m) < 1
      call vimsidian#logger#Info('Not found ' . vimsidian#util#WrapWithSingleQuote('[[' . fname . ']]'))
      return
    endif
  else
    let m = vimsidian#unit#RgNotes('[[' . expand('%:t') . ']]')
    if len(m) < 1
      call vimsidian#logger#Info('Not found ' . vimsidian#util#WrapWithSingleQuote('[[' . expand('%:t') . ']]'))
      return
    endif
  endif

  call vimsidian#MatchesOpen(vimsidian#unit#AppendNumberToLineForList(join(m, "\n")), v:true)
endfunction

function! vimsidian#MatchBrokenLinks() abort
  call vimsidian#unit#ClearLinkMatchs()
  call vimsidian#unit#ClearBrokenLinkMatchs()

  let ls = vimsidian#unit#BrokenLinksInNote()
  if len(ls) < 1
    call vimsidian#logger#Debug('No broken links')
    return
  endif

  if !exists('w:vimsidian_broken_link_matches')
    let w:vimsidian_broken_link_matches = {}
  endif

  for l in ls
    let pattern = escape('[[' . l . ']]', '\/~ .*^[''$')
    let w:vimsidian_broken_link_matches[l] = vimsidian#unit#MatchAdd('VimsidianBrokenLinkColor', pattern)
  endfor
endfunction

function! vimsidian#MatchCursorLink() abort
  call vimsidian#unit#ClearLinkMatchs()

  let m = vimsidian#unit#CursorLink()
  if m ==# v:null
    call vimsidian#logger#Debug('Empty cursor link')
    return
  endif

  let w:vimsidian_link_matches = {}

  if !exists('w:vimsidian_broken_link_matches')
    let w:vimsidian_broken_link_matches = {}
  endif

  let pattern = escape('[[' . m . ']]', '\/~ .*^[''$')

  if vimsidian#unit#IsBrokenLink(m) ==# v:true
    if !exists('w:vimsidian_broken_link_matches[m]')
      let w:vimsidian_broken_link_matches[m] = vimsidian#unit#MatchAdd('VimsidianBrokenLinkColor', pattern)
    endif
  else
    let w:vimsidian_link_matches[m] = vimsidian#unit#MatchAdd('VimsidianCursorLinkColor', pattern)
    if exists('w:vimsidian_broken_link_matches[m]')
      call vimsidian#unit#MatchDelete(w:vimsidian_broken_link_matches[m])
    endif
  endif
endfunction

function! vimsidian#MoveToCursorLink() abort
  let [line, col] = vimsidian#unit#CursorLinkPosition()
  call cursor(line, col)
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
  if f ==# v:null
    call vimsidian#logger#Debug('Empty cursor link')
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
  if note ==# v:null
    call vimsidian#logger#Debug('Empty note ' . vimsidian#util#WrapWithSingleQuote(f))
    return
  endif

  let m = split(note, '\n')
  if len(m) > 0
    let note = m[0]
  endif

  if empty(note)
    call vimsidian#logger#Info('Linked note not found' . vimsidian#util#WrapWithSingleQuote(f . lex))
    return
  else
    if g:vimsidian_enable_link_stack
      if exists('*vimsidian#link_stack#command#move_to_link')
        let [line, col] = vimsidian#unit#CursorLinkPosition()
        call vimsidian#link_stack#command#move_to_link(note, line, col)
      else
        echo 'vimsidian#link_stack#command#move_to_link funciton not found, see https://github.com/kis9a/vimsidian-link-stack'
      endif
    else
      call vimsidian#action#OpenFile(g:vimsidian_link_open_mode, note)
    endif
  endif

  let [line, col] = vimsidian#unit#InternalLinkPosition(expand('%:p'), fn)
  call cursor(line, col)
endfunction

function! vimsidian#NewNote(dir) abort
  let f = vimsidian#unit#CursorLink()
  if f ==# v:null
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

  let note = vimsidian#util#PathJoin(fnamemodify(a:dir, ':p'), f . '.md')
  if !empty(glob(note))
    call vimsidian#logger#Info('Already exists ' . note)
    call vimsidian#action#OpenFile(g:vimsidian_link_open_mode, note)
  else
    call vimsidian#action#OpenFile(g:vimsidian_link_open_mode, note)
  endif

  let [line, col] = vimsidian#unit#InternalLinkPosition(expand('%:p'), fn)
  call cursor(line, col)
endfunction

function! vimsidian#NewNoteInteractive() abort
  let f = vimsidian#action#GetUserInput('VimsidianNewNoteInterfactive: g:vimsidian_path/')
  if empty(f)
    call vimsidian#logger#Debug('Empty input')
    return
  endif

  let note = vimsidian#util#PathJoin(fnamemodify(g:vimsidian_path, ':p'), f . '.md')
  let b = fnamemodify(note, ':h')
  if empty(glob(b))
    call vimsidian#logger#Debug('Base directory not found ' . note)
    let d = vimsidian#action#GetUserInput('Create a directory ? ' . vimsidian#util#WrapWithSingleQuote(b) . ' [y/n]')
    if d !=# 'y'
      return
    else
      call vimsidian#action#MkdirP(b)
      call vimsidian#action#OpenFile(g:vimsidian_link_open_mode, note)
    endif
  else
    if !empty(glob(note))
      call vimsidian#logger#Info('Already exists ' . note)
    else
      call vimsidian#action#OpenFile(g:vimsidian_link_open_mode, note)
    endif
  endif
endfunction
