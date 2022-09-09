let g:obsidian_path = "~/obsidian"
let g:obsidian_notes_path = "~/obsidian/notes"

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
    let cmd  = "ls " . g:obsidian_notes_path
    for m in split(system(cmd), '\n')
      if m =~ '^' . a:base
        call add(res, m)
      endif
    endfor
    return res
  endif
endfunction

autocmd BufNewFile,BufReadPost ~/obsidian/*.md setlocal completefunc=CompleteObsidianNotes

function! s:ObsidianRgFilesWithMatches(word) abort
  let cmd = 'cd ' . g:obsidian_path . "; rg -n %s --files-with-matches  . " . "| awk '" . '{ print $0 ":1: " }' . "'"
  let res = system(printf(cmd, a:word))
  if empty (res)
    echo "Not Found '" .a:word . "'"
  else
    cexpr res | copen
  endif
endfunction

command! -nargs=1 ObsidianRgFilesWithMatches call <SID>ObsidianRgFilesWithMatches(<q-args>)
autocmd BufNewFile,BufReadPost ~/obsidian/*.md nnoremap <silent> sr :ObsidianRgFilesWithMatches 

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
    echo "Not Found internal links'"
    return
  else
   let fdGrepOption = ''
    for m in split(grepRes, '\n')
      let fdGrepOption .= " -e '/" . m . "'" " grep -e 'file' -e 'file2'
    endfor
  endif

  let fdCmd = 'cd ' . g:obsidian_path . '; fd | grep ' . fdGrepOption . "| awk '" . '{ print $0 ":1: " }' . "'"
  let fdRes = system(fdCmd)
  cexpr fdRes | copen
endfunction

command! ObsidianFdLinkedNotes call <SID>ObsidianFdLinkedNotes()
autocmd BufNewFile,BufReadPost ~/obsidian/*.md nnoremap <silent> sl :ObsidianFdLinkedNotes<CR>
