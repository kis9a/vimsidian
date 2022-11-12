function! vimsidian#CompleteNotes(findstart, base)
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
      let cmd = ['fd', '.']
    else
      let cmd = ['ls']
    endif

    for f in g:vimsidian_complete_paths
      call add(cmd, "'" . f . "'")
      let rs = vimsidian#action#System(cmd)

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

function! vimsidian#RgLinesWithMatches(word)
  let cmd = ['rg', '-F', '-n', "'" . a:word ."'", g:vimsidian_path]
  let matches = vimsidian#action#System(cmd)
  if empty (matches)
    call vimsidian#logger#Info("Not found '" .a:word . "'")
  else
    call vimsidian#action#OpenQuickFix(matches)
  endif
endfunction

function! vimsidian#RgNotesWithMatches(word)
  let cmd = ['rg', '-F', '-n', "'" . a:word ."'", '--files-with-matches', g:vimsidian_path]
  let matches = vimsidian#action#System(cmd)
  if empty (matches)
    call vimsidian#logger#Info("Not found '" .a:word . "'")
  else
    let matches = substitute(matches, '\v\n', ':1: \n', 'g')
    call vimsidian#action#OpenQuickFix(matches)
  endif
endfunction

function! vimsidian#RgNotesWithMatchesInteractive()
  let i = vimsidian#action#GetUserInput("VimsidianRgNotesWithMatchesInteractive")
  call vimsidian#RgNotesWithMatches(i)
endfunction

function! vimsidian#RgLinesWithMatchesInteractive()
  let i = vimsidian#action#GetUserInput("VimsidianRgLinesWithMatchesInteractive")
  call vimsidian#RgLinesWithMatches(i)
endfunction

function! vimsidian#RgTagMatches()
  let tag = vimsidian#unit#CursorTag()
  if tag ==# 1
    call vimsidian#logger#Info("Word under the cursor is not a tag")
    return
  endif
  call vimsidian#RgLinesWithMatches(tag)
endfunction

function! vimsidian#FdLinkedNotesByThisNote()
  let links = vimsidian#unit#LinksInThisNote()
  if len(links) > 0
    let grepArg = ''
    for m in links
      let grepArg .= " -e '/" . m . ".md'" " grep -e 'file' -e 'file2'
    endfor
  else
    call vimsidian#logger#Info("No link found in this note")
    return
  endif

  let cmd = ['fd', '.', g:vimsidian_path, '|', 'grep', grepArg]
  let matches = vimsidian#action#System(cmd)
  if empty(matches)
    call vimsidian#logger#Info("Linked notes not found")
    return
  else
    let matches = substitute(matches, '\v\n', ':1: \n', 'g')
    call vimsidian#action#OpenQuickFix(matches)
  endif
endfunction

function! vimsidian#RgNotesLinkingThisNote()
  let fname = fnamemodify(expand("%:t"), ":r")
  let ext = expand("%:e")
  if ext == "md"
    call vimsidian#RgNotesWithMatches("\[\[" . fname . "\]]")
  else
    call vimsidian#RgNotesWithMatches("\[\[" . expand("%t") . "\]]")
  endif
endfunction

function! vimsidian#MoveToPreviousLink()
  let [line, col] = vimsidian#unit#PreviousLinkPosition()
  call cursor(line, col)
endfunction

function! vimsidian#MoveToNextLink()
  let [line, col] = vimsidian#unit#NextLinkPosition()
  call cursor(line, col)
endfunction

function! vimsidian#MoveToLink()
  let f = vimsidian#unit#CursorLink()
  if f ==# 1
    return
  endif

  if empty(f)
    call vimsidian#logger#Info('Link name is empty')
    return
  endif

  let fn = ""
  if stridx(f, "#") !=# "-1"
    if f[0] ==# "#"
      let sf = split(f, "#")
      if len(sf) > 0
        let fn = sf[0]
      endif
      let f = fnamemodify(expand("%:r"), ":t")
    else
      let sf = split(f, "#")
      if len(sf) > 0
        let f = sf[0]
      endif

      if len(sf) > 1
        let fn = sf[1]
      endif
    endif
  endif

  if stridx(f, "|") !=# "-1"
    let sf = split(f, "|")
    if len(sf) > 0
      let f = sf[0]
    endif
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

  let cmd = ['fd', '.', g:vimsidian_path, '|', 'grep', "'" . '/' . f . lex . "'"]
  let note = vimsidian#action#System(cmd)
  let snote = split(note, "\n")
  if len(snote) > 0
    let note = snote[0]
  endif

  if empty(note)
    call vimsidian#logger#Info("Linked note not found '" . f . ".md'")
    return
  else
    execute 'e ' . note
  endif

  if !empty(fn)
    let lnums = []
    if fn[0] ==# "^"
      silent! execute "g/" . escape(fn, '^') . "$/call add(lnums, line('.'))"
      if len(lnums) > 0
        call cursor(lnums[0], 1)
      else
        call vimsidian#logger#Debug("g/" . escape(fn, '^') . "$/call add(lnums, line('.'))")
      endif
    else
      silent! execute "g/\\v^(\#)+.*" . fn . "$/call add(lnums, line('.'))"
      if len(lnums) > 0
        call cursor(lnums[0], 1)
      else
        call vimsidian#logger#Debug("g/\\v^(\#)+.*" . fn . "$/call add(lnums, line('.'))")
      endif
    endif
  endif
endfunction

function! vimsidian#NewNote(dir)
  let f = vimsidian#unit#CursorLink()
  if f ==# 1
    call vimsidian#logger#Info("Word under the cursor is not a link")
    return
  endif

  if empty(f)
    call vimsidian#logger#Info('Link name is empty')
    return
  endif

  let fn = ""
  if stridx(f, "#") !=# "-1"
    if f[0] ==# "#"
      let sf = split(f, "#")
      if len(sf) > 0
        let fn = sf[0]
      endif
      let f = fnamemodify(expand("%:r"), ":t")
    else
      let sf = split(f, "#")
      if len(sf) > 0
        let f = sf[0]
      endif

      if len(sf) > 1
        let fn = sf[1]
      endif
    endif
  endif

  if stridx(f, "|") !=# "-1"
    let sf = split(f, "|")
    if len(sf) > 0
      let f = sf[0]
    endif
  endif

  if empty(glob(a:dir))
    call vimsidian#logger#Info('No such directory ' . a:dir)
    return
  endif

  let note = fnamemodify(a:dir, ":p") . f . '.md'
  if !empty(glob(note))
    call vimsidian#logger#Info('Already exists ' . note)
    execute 'e ' . note
  else
    execute 'e ' . note
  endif

  if !empty(fn)
    let lnums = []
    if fn[0] ==# "^"
      silent! execute "g/" . escape(fn, '^') . "$/call add(lnums, line('.'))"
      if len(lnums) > 0
        call cursor(lnums[0], 1)
      endif
    else
      silent! execute "g/\\v^(\#)+.*" . fn . "$/call add(lnums, line('.'))"
      if len(lnums) > 0
        call cursor(lnums[0], 1)
      else
        echo "g/\\v^(\#)+.*" . fn . "$/call add(lnums, line('.'))"
      endif
    endif
  endif
endfunction

function! vimsidian#FormatLink()
  let file = expand("%:p")
  let s = join(readfile(file), "\n")
  let s = vimsidian#unit#FormatLinkString(s)
  call vimsidian#action#WriteFile(split(s, '\n'), file, "b")
  execute 'e!'
endfunction
