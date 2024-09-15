function! vimsidian#command#Jump() abort
  let f = vimsidian#utils#CursorLink()
  if f ==# v:null
    call vimsidian#utils#LogDebug('Empty cursor link')
    return
  endif

  if empty(f)
    call vimsidian#utils#LogInfo('Link name is empty')
    return
  endif

  let [f, fn] = vimsidian#utils#LinkSetToMove(f)
  let lex = vimsidian#utils#LinkExtension(f)

  if lex ==# ''
    let i = vimsidian#utils#GetUserInput('open ' . vimsidian#utils#WrapWithSingleQuote(f) . ' [y/n]')
    if i !=# 'y'
      return
    endif
  endif

  let note = vimsidian#utils#FdNote(f . lex)
  if note ==# v:null
    call vimsidian#utils#LogDebug('Empty note ' . vimsidian#utils#WrapWithSingleQuote(f))
    return
  endif

  let m = split(note, '\n')
  if len(m) > 0
    let note = m[0]
  endif

  if empty(note)
    call vimsidian#utils#LogInfo('Linked note not found' . vimsidian#utils#WrapWithSingleQuote(f . lex))
    return
  else
    if exists('g:vimsidian_enable_link_stack') && g:vimsidian_enable_link_stack
      if exists('*vimsidian#link_stack#command#move_to_link')
        let [line, col] = vimsidian#utils#CursorLinkPosition()
        call vimsidian#link_stack#command#move_to_link(note, line, col)
      else
        echo 'vimsidian#link_stack#command#move_to_link function not found, see https://github.com/kis9a/vimsidian-link-stack'
      endif
    else
      call vimsidian#utils#OpenFile('e!', note)
    endif
  endif

  let [line, col] = vimsidian#utils#InternalLinkPosition(expand('%:p'), fn)
  call cursor(line, col)
endfunction

function! vimsidian#command#PrevLink() abort
  let [line, col] = vimsidian#utils#PreviousLinkPosition()
  call cursor(line, col)
endfunction

function! vimsidian#command#NextLink() abort
  let [line, col] = vimsidian#utils#NextLinkPosition()
  call cursor(line, col)
endfunction

function! vimsidian#command#CursorLink() abort
  let [line, col] = vimsidian#utils#CursorLinkPosition()
  call cursor(line, col)
endfunction

function! vimsidian#command#FindBacklinks() abort
  let fname = fnamemodify(expand('%:t'), ':r')
  let ext = expand('%:e')
  if ext ==# 'md'
    let m = vimsidian#utils#RgNotes('[[' . fname . ']]')
    if len(m) < 1
      call vimsidian#utils#LogInfo('Not found ' . vimsidian#utils#WrapWithSingleQuote('[[' . fname . ']]'))
      return
    endif
  else
    let m = vimsidian#utils#RgNotes('[[' . expand('%:t') . ']]')
    if len(m) < 1
      call vimsidian#utils#LogInfo('Not found ' . vimsidian#utils#WrapWithSingleQuote('[[' . expand('%:t') . ']]'))
      return
    endif
  endif

  call vimsidian#utils#MatchesOpen(vimsidian#utils#AppendNumberToLineForList(join(m, "\n")), v:true)
endfunction

function! vimsidian#command#FindLinks() abort
  let links = vimsidian#utils#NoteNamesInNote()
  if len(links) > 0
    let m = join(vimsidian#utils#FdNotes(links), "\n")
  else
    call vimsidian#utils#LogInfo('No link found in this note')
    return
  endif

  if empty(m)
    call vimsidian#utils#LogInfo('Linked notes not found')
    return
  else
    call vimsidian#utils#MatchesOpen(vimsidian#utils#AppendNumberToLineForList(m), v:true)
  endif
endfunction

function! vimsidian#command#FindTags() abort
  let tag = vimsidian#utils#CursorTag()
  if tag ==# v:null
    call vimsidian#utils#LogInfo('Word under the cursor is not a tag')
    return
  endif
  let m = vimsidian#utils#RgLines(tag)
  if len(m) < 1
    call vimsidian#utils#LogInfo('Not found ' . vimsidian#utils#WrapWithSingleQuote(tag))
    return
  endif

  call vimsidian#utils#MatchesOpen(m, v:null)
endfunction

function! vimsidian#command#SearchNotes(word) abort
  let m = vimsidian#utils#RgNotes(a:word)
  if len(m) < 1
    call vimsidian#utils#LogInfo('Not found ' . vimsidian#utils#WrapWithSingleQuote(a:word))
    return
  endif
  call vimsidian#utils#MatchesOpen(vimsidian#utils#AppendNumberToLineForList(join(m, "\n")), v:true)
endfunction

function! vimsidian#command#SearchLinks(word) abort
  let m = vimsidian#utils#RgLines(a:word)
  if len(m) < 1
    call vimsidian#utils#LogInfo('Not found ' . vimsidian#utils#WrapWithSingleQuote(a:word))
    return
  endif
  call vimsidian#utils#MatchesOpen(m, v:null)
endfunction

function! vimsidian#command#NewNote(dir) abort
  let f = vimsidian#utils#CursorLink()
  if f ==# v:null
    call vimsidian#utils#LogInfo('Word under the cursor is not a link')
    return
  endif

  if empty(f)
    call vimsidian#utils#LogInfo('Link name is empty')
    return
  endif

  let [f, fn] = vimsidian#utils#LinkSetToMove(f)

  if empty(glob(a:dir))
    call vimsidian#utils#LogInfo('No such directory ' . a:dir)
    return
  endif

  let note = vimsidian#utils#PathJoin(fnamemodify(a:dir, ':p'), f . '.md')
  if !empty(glob(note))
    call vimsidian#utils#LogInfo('Already exists ' . note)
    call vimsidian#utils#OpenFile('e!', note)
  else
    call vimsidian#utils#OpenFile('e!', note)
  endif

  let [line, col] = vimsidian#utils#InternalLinkPosition(expand('%:p'), fn)
  call cursor(line, col)
endfunction

function! vimsidian#command#MatchCursorLink() abort
  call vimsidian#utils#ClearLinkMatchs()

  let m = vimsidian#utils#CursorLink()
  if m ==# v:null
    call vimsidian#utils#LogDebug('Empty cursor link')
    return
  endif

  let w:vimsidian_link_matches = {}

  if !exists('w:vimsidian_broken_link_matches')
    let w:vimsidian_broken_link_matches = {}
  endif

  let pattern = escape('[[' . m . ']]', '\/~ .*^[''$')

  if vimsidian#utils#IsBrokenLink(m) ==# v:true
    if !exists('w:vimsidian_broken_link_matches[m]')
      let w:vimsidian_broken_link_matches[m] = vimsidian#utils#MatchAdd('VimsidianBrokenLinkColor', pattern)
    endif
  else
    let w:vimsidian_link_matches[m] = vimsidian#utils#MatchAdd('VimsidianCursorLinkColor', pattern)
    if exists('w:vimsidian_broken_link_matches[m]')
      call vimsidian#utils#MatchDelete(w:vimsidian_broken_link_matches[m])
    endif
  endif
endfunction

function! vimsidian#command#MatchBrokenLinks() abort
  call vimsidian#utils#ClearLinkMatchs()
  call vimsidian#utils#ClearBrokenLinkMatchs()

  let ls = vimsidian#utils#BrokenLinksInNote()
  if len(ls) < 1
    call vimsidian#utils#LogDebug('No broken links')
    return
  endif

  if !exists('w:vimsidian_broken_link_matches')
    let w:vimsidian_broken_link_matches = {}
  endif

  for l in ls
    let pattern = escape('[[' . l . ']]', '\/~ .*^[''$')
    let w:vimsidian_broken_link_matches[l] = vimsidian#utils#MatchAdd('VimsidianBrokenLinkColor', pattern)
  endfor
endfunction

function! vimsidian#command#CompleteNotes(findstart, base) abort
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

    let rs = vimsidian#utils#Fd(vimsidian#utils#WrapWithSingleQuote(vimsidian#utils#Getcwd()), [])

    for n in split(rs, '\n')
      call add(notes, substitute(fnamemodify(n, ':t'),  '\v.md$', '', 'g'))
    endfor

    for m in notes
      if m =~ '^' . a:base
        call add(res, m)
      endif
    endfor
    return res
  endif
endfunction
