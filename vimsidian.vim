" obsidian paths
"" NOTE: customize for your
let g:obsidian_path = "~/obsidian"
let g:obsidian_notes_path = "~/obsidian/notes"
let g:obsidian_images_path = "~/obsidian/images"
let g:obsidian_articles_path = "~/obsidian/articles"
let g:obsidian_complete_paths = [g:obsidian_notes_path, g:obsidian_images_path, g:obsidian_articles_path]

" sets
autocmd BufNewFile,BufReadPost *.md setlocal colorcolumn=80 " Emphasize column 80 to make it a newline criterion.

" obsidian corlors
hi def obsidianGreen term=NONE ctermfg=47 guifg=#689d6a
hi def obsidianLightGreen term=NONE ctermfg=142 guifg=#b8bb26
hi def obsidianLightGreen term=NONE ctermfg=142 guifg=#b8bb26
hi def obsidianBlue term=NONE ctermfg=24 guifg=blue
hi def obsidianLightBlue term=NONE ctermfg=109 guifg=#076678

autocmd BufNewFile,BufReadPost ~/obsidian/*.md syn match obsidianLink containedin=markdownH1,markdownH2,markdownH3,markdownH4,markdownH5,markdownH6 /\v\[\[.{-}\]\]/
autocmd BufNewFile,BufReadPost ~/obsidian/*.md syn match obsidianLinkMedia containedin=obsidianLink /\v\!\[\[.{-}\]\]/
autocmd BufNewFile,BufReadPost ~/obsidian/*.md syn match obsidianLinkHeader containedin=obsidianLink /\v\[\[#.{-}\]\]/
autocmd BufNewFile,BufReadPost ~/obsidian/*.md syn match obsidianLinkBlock containedin=obsidianLink /\v\[\[\^.{-}\]\]/
autocmd BufNewFile,BufReadPost ~/obsidian/*.md syn match obsidianTag containedin=obsidianIdea /\v\#(\w+)/

autocmd BufNewFile,BufReadPost ~/obsidian/*.md hi! link obsidianLink obsidianGreen
autocmd BufNewFile,BufReadPost ~/obsidian/*.md hi! link obsidianLinkMedia obsidianGreen
autocmd BufNewFile,BufReadPost ~/obsidian/*.md hi! link obsidianLinkHeader obsidianLightGreen
autocmd BufNewFile,BufReadPost ~/obsidian/*.md hi! link obsidianLinkBlock obsidianLightGreen
autocmd BufNewFile,BufReadPost ~/obsidian/*.md hi! link obsidianTag obsidianLightBlue

" complete obsidian notes: Note names under `$obsidian_complete_paths` are popped up and input is completed. press `<C-X><C-U>` in insert mode
function! CompleteObsidianFiles(findstart, base)
  if a:findstart
    let line = getline('.')
    let start = col('.') - 1
    while start > 0 && line[start - 1] =~ '\a'
      let start -= 1
    endwhile
    return start
  else
    let res = []
    for f in g:obsidian_complete_paths
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

autocmd B

" obsidian rg notes with matches: Notes containing the argument word
function! s:ObsidianRgNotesWithMatches(word) abort
  let cmd = 'rg -F -n %s --files-with-matches $(realpath ' . g:obsidian_path . ") | awk '" . '{ print $0 ":1: " }' . "'"
  let obsidian_rg_notes_with_matches = system(printf(cmd, a:word))
  if empty (obsidian_rg_notes_with_matches)
    echo "Not found '" .a:word . "'"
  else
    execute 'lcd' g:obsidian_path
    cexpr obsidian_rg_notes_with_matches | copen
  endif
endfunction

command! -nargs=1 ObsidianRgNotesWithMatches call <SID>ObsidianRgNotesWithMatches(<q-args>)

" obsidian rg notes with matches interactive: Notes containing the word input
function! s:ObsidianRgNotesWithMatchesInteractive() abort
  let i = s:getUserInput("")
  call s:ObsidianRgNotesWithMatches(i)
endfunction

command! ObsidianRgNotesWithMatchesInteractive call <SID>ObsidianRgNotesWithMatchesInteractive()
autocmd BufNewFile,BufReadPost ~/obsidian/*.md nnoremap <silent> sr :ObsidianRgNotesWithMatchesInteractive<CR>

" obsidian rg tag matches: Search `$obsidian_path` for matches containing the under cursor tag name
function! s:ObsidianRgTagMatches() abort
  let cword = expand('<cWORD>')
  if cword[0] == "#"
    let cmd = "rg -n '" . cword . "' $(realpath " . g:obsidian_path . ")"
    let obsidian_rg_tag_matches = system(cmd)
    if empty (obsidian_rg_tag_matches)
      echo "Not found '" . cword . "'"
    else
      execute 'lcd' g:obsidian_path
      cexpr obsidian_rg_tag_matches | copen
    endif
  else
    echo "Word under the cursor is not a tag"
  endif
endfunction

command! ObsidianRgTagMatches call <SID>ObsidianRgTagMatches()
autocmd BufNewFile,BufReadPost ~/obsidian/*.md nnoremap <silent> st :ObsidianRgTagMatches<CR>

" obsidian fd linked notes by this note: Notes linked to by this note
function! s:ObsidianFdLinkedNotesByThisNote() abort
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

  let fdCmd = 'fd . ' . g:obsidian_path . ' | grep ' . fdGrepArg . "| awk '" . '{ print $0 ":1: " }' . "'"
  let obsidian_fd_linked_notes_by_this_note = system(fdCmd)
  if empty(obsidian_fd_linked_notes_by_this_note)
    echo "Not found linking notes'"
    return
  else
    execute 'lcd' g:obsidian_path
    cexpr obsidian_fd_linked_notes_by_this_note | copen
  endif
endfunction

command! ObsidianFdLinkedNotesByThisNote call <SID>ObsidianFdLinkedNotesByThisNote()
autocmd BufNewFile,BufReadPost ~/obsidian/*.md nnoremap <silent> sl :ObsidianFdLinkedNotesByThisNote<CR>

" obsidian fd linked notes: Notes linking this note
function! s:ObsidianRgNotesLinkingThisNote() abort
  let fname = fnamemodify(expand("%:t"), ":r")
  let ext = expand("%:e")
  if ext == "md"
    let a=s:ObsidianRgNotesWithMatches("'\[\[" . fname . "\]]'")
  else
    let a=s:ObsidianRgNotesWithMatches("'\[\[" . expand("%t") . "\]]'")
  endif
endfunction

command! ObsidianRgNotesLinkingThisNote call <SID>ObsidianRgNotesLinkingThisNote()
autocmd BufNewFile,BufReadPost ~/obsidian/*.md nnoremap <silent> sg :ObsidianRgNotesLinkingThisNote<CR>

 " obsidian move to link: obsidian goto link under cursor
function! s:ObsidianMoveToLink() abort
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
        let f .= s:removeObsidianLinkToken(m)
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
        let f .= s:removeObsidianLinkToken(s:reverseString(m))
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
      let f .= s:removeObsidianLinkToken(s:reverseString(m))
    else
      echo 'No match link token [['
      return
    endif

    let r = '\v(^.{' . cl . '})@<=.{-}]]'
    let m = matchstr(l, r)
    if m !=# ''
      let f .= s:removeObsidianLinkToken(m)
    else
      echo 'No match link token ]]'
      return
    endif
  endif

  let cmd = "fd . " . g:obsidian_path . " | grep '" . f . '.md' . "' | head -n 1"
  let note = system(cmd)
  if empty(note)
    echo "Not found linking note " . f . '.md'
    return
  else
    execute 'e ' . note
  endif
endfunction

command! ObsidianMoveToLink call <SID>ObsidianMoveToLink()
autocmd BufNewFile,BufReadPost ~/obsidian/*.md nnoremap <silent> sF :ObsidianMoveToLink<CR>

" obsidian format link: Format obsidian link string for the current file
function! s:ObsidianFormatLink()
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

command! ObsidianFormatLink call <SID>ObsidianFormatLink()
autocmd BufNewFile,BufReadPost ~/obsidian/*.md nnoremap <silent> si :ObsidianFormatLink<CR>

 " helper functions
function! s:getUserInput(label)
  let curline = getline('.')
  echohl Question
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

function! s:removeObsidianLinkToken(str)
  return substitute(a:str, '\v([|\])', '', 'g')
endfunction
