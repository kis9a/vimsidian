" flags
let s:save_cpo = &cpo
set cpo&vim

if exists('g:loaded_vimsidian_plugin') && g:loaded_vimsidian_plugin
  finish
endif

if empty(glob($VIMSIDIAN_PATH))
  echoerr 'Required $VIMSIDIAN_PATH environment variable, export $VIMSIDIAN_PATH on your shell'
  finish
endif

" set global options
if !exists('g:vimsidian_complete_paths')
  let g:vimsidian_complete_paths = []
endif

if !exists('g:vimsidian_enable_complete_functions')
  let g:vimsidian_enable_complete_functions = 1
endif

if !exists('g:vimsidian_enable_syntax_highlight')
  let g:vimsidian_enable_syntax_highlight = 1
endif

if !exists('g:vimsidian_media_extensions')
  let g:vimsidian_media_extensions = ["png", "jpg", "jpeg", "gif", "bmp", "svg", "mp3", "webm", "wav", "m4a", "ogg", "3gp", "flac", "mp4", "webm", "ogv", "mov", "mkv", "pdf"]
endif

" commands
command! VimsidianRgNotesLinkingThisNote call vimsidian#VimsidianRgNotesLinkingThisNote()
command! -nargs=1 VimsidianRgNotesWithMatches call vimsidian#VimsidianRgNotesWithMatches(<q-args>)
command! VimsidianRgNotesWithMatchesInteractive call vimsidian#VimsidianRgNotesWithMatchesInteractive()
command! VimsidianRgTagMatches call vimsidian#VimsidianRgTagMatches()
command! VimsidianFdLinkedNotesByThisNote call vimsidian#VimsidianFdLinkedNotesByThisNote()
command! VimsidianMoveToLink call vimsidian#VimsidianMoveToLink()
command! VimsidianMoveToNextLink call vimsidian#VimsidianMoveToNextLink()
command! VimsidianMoveToPreviousLink call vimsidian#VimsidianMoveToPreviousLink()
command! -nargs=1 VimsidianNewNote call vimsidian#VimsidianNewNote(<q-args>)
command! VimsidianFormatLink call vimsidian#VimsidianFormatLink()

" sets
augroup vimsidian_autocmd_complete_functions
  if g:vimsidian_enable_complete_functions
    autocmd BufNewFile,BufReadPost $VIMSIDIAN_PATH/*.md setlocal completefunc=vimsidian#VimsidianCompleteNotes
  endif
augroup END

" syntax hi
augroup vimsidian_syntax_highlight
  autocmd!

  if g:vimsidian_enable_syntax_highlight
    " syntax matches
    autocmd BufNewFile,BufReadPost $VIMSIDIAN_PATH/*.md syn match VimsidianLink containedin=markdownH1,markdownH2,markdownH3,markdownH4,markdownH5,markdownH6 /\v\[\[.{-}\]\]/
    autocmd BufNewFile,BufReadPost $VIMSIDIAN_PATH/*.md syn match VimsidianLinkMedia containedin=VimsidianLink /\v\!\[\[.{-}\]\]/
    autocmd BufNewFile,BufReadPost $VIMSIDIAN_PATH/*.md syn match VimsidianLinkHeader containedin=VimsidianLink /\v\[\[#.{-}\]\]/
    autocmd BufNewFile,BufReadPost $VIMSIDIAN_PATH/*.md syn match VimsidianLinkBlock containedin=VimsidianLink /\v\[\[\^.{-}\]\]/
    autocmd BufNewFile,BufReadPost $VIMSIDIAN_PATH/*.md syn match VimsidianTag containedin=VimsidianIdea /\v\#(\w+)/

    " link colors
    autocmd BufNewFile,BufReadPost $VIMSIDIAN_PATH/*.md hi! link VimsidianLink VimsidianLinkColor
    autocmd BufNewFile,BufReadPost $VIMSIDIAN_PATH/*.md hi! link VimsidianLinkMedia VimsidianLinkMediaColor
    autocmd BufNewFile,BufReadPost $VIMSIDIAN_PATH/*.md hi! link VimsidianLinkHeader VimsidianLinkHeaderColor
    autocmd BufNewFile,BufReadPost $VIMSIDIAN_PATH/*.md hi! link VimsidianLinkBlock VimsidianLinkBlockColor
    autocmd BufNewFile,BufReadPost $VIMSIDIAN_PATH/*.md hi! link VimsidianTag VimsidianTagColor
  endif
augroup END

" end flags
let &cpo = s:save_cpo
let g:loaded_vimsidian_plugin = 1
