" flags
let s:save_cpo = &cpo
set cpo&vim

if exists('g:loaded_vimsidian_plugin') && g:loaded_vimsidian_plugin
  finish
endif

" commands
command! VimsidianRgNotesLinkingThisNote call vimsidian#VimsidianRgNotesLinkingThisNote()
command! -nargs=1 VimsidianRgNotesWithMatches call vimsidian#VimsidianRgNotesWithMatches(<q-args>)
command! VimsidianRgNotesWithMatchesInteractive call vimsidian#VimsidianRgNotesWithMatchesInteractive()
command! VimsidianRgTagMatches call vimsidian#VimsidianRgTagMatches()
command! VimsidianFdLinkedNotesByThisNote call vimsidian#VimsidianFdLinkedNotesByThisNote()
command! VimsidianMoveToLink call vimsidian#VimsidianMoveToLink()
command! VimsidianFormatLink call vimsidian#VimsidianFormatLink()

" sets
autocmd BufNewFile,BufReadPost $OBSIDIAN_PATH/*.md setlocal completefunc=vimsidian#CompleteVimsidianFiles

" syntax hi
"" syntax matches
autocmd BufNewFile,BufReadPost $OBSIDIAN_PATH/*.md syn match VimsidianLink containedin=markdownH1,markdownH2,markdownH3,markdownH4,markdownH5,markdownH6 /\v\[\[.{-}\]\]/
autocmd BufNewFile,BufReadPost $OBSIDIAN_PATH/*.md syn match VimsidianLinkMedia containedin=VimsidianLink /\v\!\[\[.{-}\]\]/
autocmd BufNewFile,BufReadPost $OBSIDIAN_PATH/*.md syn match VimsidianLinkHeader containedin=VimsidianLink /\v\[\[#.{-}\]\]/
autocmd BufNewFile,BufReadPost $OBSIDIAN_PATH/*.md syn match VimsidianLinkBlock containedin=VimsidianLink /\v\[\[\^.{-}\]\]/
autocmd BufNewFile,BufReadPost $OBSIDIAN_PATH/*.md syn match VimsidianTag containedin=VimsidianIdea /\v\#(\w+)/

"" link colors
autocmd BufNewFile,BufReadPost $OBSIDIAN_PATH/*.md hi! link VimsidianLink VimsidianLinkColor
autocmd BufNewFile,BufReadPost $OBSIDIAN_PATH/*.md hi! link VimsidianLinkMedia VimsidianLinkMediaColor
autocmd BufNewFile,BufReadPost $OBSIDIAN_PATH/*.md hi! link VimsidianLinkHeader VimsidianLinkHeaderColor
autocmd BufNewFile,BufReadPost $OBSIDIAN_PATH/*.md hi! link VimsidianLinkBlock VimsidianLinkBlockColor
autocmd BufNewFile,BufReadPost $OBSIDIAN_PATH/*.md hi! link VimsidianTag VimsidianTagColor

" end flags
let &cpo = s:save_cpo
let loaded_vimsidian_plugin = 1
