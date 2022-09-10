" obsidian paths
let g:obsidian_path = "~/obsidian"
let g:obsidian_notes_path = "~/obsidian/notes"
let g:obsidian_images_path = "~/obsidian/images"

" obsidian corlors
hi def obsidianGreen term=NONE ctermfg=47 guifg=#689d6a
hi def obsidianLightGreen term=NONE ctermfg=142 guifg=#b8bb26
autocmd BufNewFile,BufReadPost ~/obsidian/*.md syn match obsidianLink /\v\[\[.{-}\]\]/
autocmd BufNewFile,BufReadPost ~/obsidian/*.md syn match obsidianLinkMedia containedin=obsidianLink /\v\!\[\[.{-}\]\]/
autocmd BufNewFile,BufReadPost ~/obsidian/*.md syn match obsidianLinkHeader containedin=obsidianLink /\v\[\[#.{-}\]\]/
autocmd BufNewFile,BufReadPost ~/obsidian/*.md syn match obsidianLinkBlock containedin=obsidianLink /\v\[\[\^.{-}\]\]/
autocmd BufNewFile,BufReadPost ~/obsidian/*.md hi! link obsidianLink obsidianGreen
autocmd BufNewFile,BufReadPost ~/obsidian/*.md hi! link obsidianLinkMedia obsidianGreen
autocmd BufNewFile,BufReadPost ~/obsidian/*.md hi! link obsidianLinkHeader obsidianLightGreen
autocmd BufNewFile,BufReadPost ~/obsidian/*.md hi! link obsidianLinkBlock obsidianLightGreen

" complete obsidian notes
function! CompleteObsidianNotes(findstart, base)
  if a:findstart
    let line = getline('.')
    let start = col('.') - 1
    while start > 0 && line[start - 1] =~ '\a'
      let start -= 1
    endwhile
    return start
  else
    let res = []
    let cmd  = "ls " . g:obsidian_notes_path . "; ls " . g:obsidian_images_path
    for m in split(system(cmd), '\n')
      if m =~ '^' . a:base
        call add(res, m)
      endif
    endfor
    return res
  endif
endfunction

autocmd BufNewFile,BufReadPost ~/obsidian/*.md setlocal completefunc=CompleteObsidianNotes

" obsidian rg files with matches
function! s:ObsidianRgFilesWithMatches(word) abort
  let cmd = 'cd ' . g:obsidian_path . "; rg -n %s --files-with-matches  . " . "| awk '" . '{ print $0 ":1: " }' . "'"
  let res = system(printf(cmd, a:word))
  if empty (res)
    echo "Not found '" .a:word . "'"
  else
    cexpr res | copen
  endif
endfunction

command! -nargs=1 ObsidianRgFilesWithMatches call <SID>ObsidianRgFilesWithMatches(<q-args>)
autocmd BufNewFile,BufReadPost ~/obsidian/*.md nnoremap <silent> sr :ObsidianRgFilesWithMatches 

" obsidian fd linked notes
function! s:ObsidianFdLinkedNotes() abort
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
   let fdGrepOption = ''
    for m in split(grepRes, '\n')
      let fdGrepOption .= " -e '/" . m . ".md'" " grep -e 'file' -e 'file2'
    endfor
  endif

  let fdCmd = 'cd ' . g:obsidian_path . '; fd | grep ' . fdGrepOption . "| awk '" . '{ print $0 ":1: " }' . "'"
  let fdRes = system(fdCmd)
  if empty(fdRes)
    echo "Not found linked files'"
    return
  else
    cexpr fdRes | copen
  endif
endfunction

command! ObsidianFdLinkedNotes call <SID>ObsidianFdLinkedNotes()
autocmd BufNewFile,BufReadPost ~/obsidian/*.md nnoremap <silent> sl :ObsidianFdLinkedNotes<CR>
