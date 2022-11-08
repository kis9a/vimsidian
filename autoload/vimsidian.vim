function! vimsidian#VimsidianCompleteNotes(findstart, base)
  if a:findstart
    let line = getline('.')
    let start = col('.') - 1
    let exc = escape(join(g:vimsidian_unsuitable_link_chars, ""), '\\/.*$^~[]')
    while start > 0 && line[start - 1] =~ '\v[^' . exc . ']'
      let start -= 1
    endwhile
    return start
  else
    let res = []
    let notes = []

    if g:vimsidian_complete_paths_search_use_fd
      let cmd = 'fd . '
    else
      let cmd = 'ls '
    endif

    for f in g:vimsidian_complete_paths
      let cmd .= "'" . f . "'"
      let rs = system(cmd)

      for n in split(rs, '\n')
        call add(notes, substitute(fnamemodify(n, ":t"),  '\v.md$', '', 'g'))
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

function! vimsidian#VimsidianRgLinesWithMatches(word)
  let cmd = "rg -F -n '%s' " . $VIMSIDIAN_PATH
  let matches = system(printf(cmd, a:word))
  if empty (matches)
    call vimsidian#logger#LogInfo("Not found '" .a:word . "'")
  else
    call vimsidian#action#OpenQuickFix(matches)
  endif
endfunction

function! vimsidian#VimsidianRgNotesWithMatches(word)
  let cmd = "rg -F -n '%s' --files-with-matches " . $VIMSIDIAN_PATH
  let matches = system(printf(cmd, a:word))
  if empty (matches)
    call vimsidian#logger#LogInfo("Not found '" .a:word . "'")
  else
    let matches = substitute(matches, '\v\n', ':1: \n', 'g')
    call vimsidian#action#OpenQuickFix(matches)
  endif
endfunction

function! vimsidian#VimsidianRgNotesWithMatchesInteractive()
  let i = vimsidian#action#GetUserInput("VimsidianRgNotesWithMatchesInteractive")
  call vimsidian#VimsidianRgNotesWithMatches(i)
endfunction

function! vimsidian#VimsidianRgLinesWithMatchesInteractive()
  let i = vimsidian#action#GetUserInput("VimsidianRgLinesWithMatchesInteractive")
  call vimsidian#VimsidianRgLinesWithMatches(i)
endfunction

function! vimsidian#VimsidianRgTagMatches()
  let tag = vimsidian#unit#CursorTag()
  if tag ==# 1
    call vimsidian#logger#LogInfo("Word under the cursor is not a tag")
    return
  endif
  call vimsidian#VimsidianRgLinesWithMatches(tag)
endfunction

function! vimsidian#VimsidianFdLinkedNotesByThisNote()
  let links = vimsidian#unit#LinksInThisNote()
  if len(links) > 0
    let grepArg = ''
    for m in links
      let grepArg .= " -e '/" . m . ".md'" " grep -e 'file' -e 'file2'
    endfor
  else
    call vimsidian#logger#LogInfo("No link found in this note")
    return
  endif

  let cmd = 'fd . ' . $VIMSIDIAN_PATH . ' | grep ' . grepArg
  let matches = system(cmd)
  if empty(matches)
    call vimsidian#logger#LogInfo("Linked notes not found")
    return
  else
    let matches = substitute(matches, '\v\n', ':1: \n', 'g')
    call vimsidian#action#OpenQuickFix(matches)
  endif
endfunction

function! vimsidian#VimsidianRgNotesLinkingThisNote()
  let fname = fnamemodify(expand("%:t"), ":r")
  let ext = expand("%:e")
  if ext == "md"
    call vimsidian#VimsidianRgNotesWithMatches("\[\[" . fname . "\]]")
  else
    call vimsidian#VimsidianRgNotesWithMatches("\[\[" . expand("%t") . "\]]")
  endif
endfunction

function! vimsidian#VimsidianMoveToPreviousLink()
  let [line, col] = vimsidian#unit#PreviousLinkPosition()
  call cursor(line, col)
endfunction

function! vimsidian#VimsidianMoveToNextLink()
  let [line, col] = vimsidian#unit#NextLinkPosition()
  call cursor(line, col)
endfunction

function! vimsidian#VimsidianMoveToLink()
  let f = vimsidian#unit#CursorLink()
  if f ==# 1
    return
  endif

  let lex = '.md'
  if stridx(f, '.') !=# "-1"
    let fe = fnamemodify(f, ":e")
    for me in g:vimsidian_media_extensions
      if me ==# fe
        let lex = ''
      endif
    endfor
  endif

  if lex ==# ''
    let i = vimsidian#action#GetUserInput("open '" . f . "' > [y/n]")
    if i !=# "y"
      return
    endif
  endif

  let cmd = "fd . " . $VIMSIDIAN_PATH . " | grep '/" . f . lex . "'"
  let note = system(cmd)
  let snote = split(note, "\n")
  if len(snote) > 0
    let note = snote[0]
  endif

  if empty(note)
    call vimsidian#logger#LogInfo("Linked note not found '" . f . ".md'")
    return
  else
    execute 'e ' . note
  endif
endfunction

function! vimsidian#VimsidianNewNote(dir)
  let f = vimsidian#unit#CursorLink()
  if f ==# 1
    call vimsidian#logger#LogInfo("Word under the cursor is not a link")
    return
  endif

  if empty(f)
    call vimsidian#logger#LogInfo('Link name is empty')
    return
  endif

  if empty(glob(a:dir))
    call vimsidian#logger#LogInfo('No such directory ' . a:dir)
    return
  endif

  let note = fnamemodify(a:dir, ":p") . f . '.md'
  if !empty(glob(note))
    call vimsidian#logger#LogInfo('Already exists ' . note)
    execute 'e ' . note
  else
    execute 'e ' . note
  endif
endfunction

function! vimsidian#VimsidianFormatLink()
  let file = expand("%:p")
  let s = join(readfile(file), "\n")
  let s = vimsidian#unit#FormatLinkString(s)
  call vimsidian#action#WriteFile(split(s, '\n'), file, "b")
  execute 'e!'
endfunction
