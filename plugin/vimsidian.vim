" flags
let s:save_cpo = &cpo
set cpo&vim

" check pre required
if exists('g:loaded_vimsidian_plugin') && g:loaded_vimsidian_plugin
  finish
endif

if empty(glob($VIMSIDIAN_PATH))
  echoerr '[VIMSIDIAN] Required $VIMSIDIAN_PATH environment variable, export $VIMSIDIAN_PATH on your shell'
  finish
endif

" set global options
if !exists('g:vimsidian_log_level')
  let g:vimsidian_log_level = 2 " 0: NONE, 1:ERROR, 2:INFO, 3:DEBUG
endif

if !exists('g:vimsidian_enable_syntax_highlight')
  let g:vimsidian_enable_syntax_highlight = 1
endif

if !exists('g:vimsidian_color_definition_use_default')
  let g:vimsidian_color_definition_use_default = 1
endif

if !exists('g:vimsidian_complete_paths')
  let g:vimsidian_complete_paths = []
endif

if !exists('g:vimsidian_enable_complete_functions')
  let g:vimsidian_enable_complete_functions = 1
endif

if !exists('g:vimsidian_complete_paths_search_use_fd')
  let g:vimsidian_complete_paths_search_use_fd = 1 " 0: ls, 1: fd
endif

if !exists('g:vimsidian_required_commands')
  let g:vimsidian_required_commands = ['rg', 'fd', 'grep']
endif

if !exists('g:vimsidian_check_required_commands_executable')
  let g:vimsidian_check_required_commands_executable = 1
endif

if !exists('g:vimsidian_media_extensions')
  let g:vimsidian_media_extensions = ["png", "jpg", "jpeg", "gif", "bmp", "svg", "mp3", "webm", "wav", "m4a", "ogg", "3gp", "flac", "mp4", "webm", "ogv", "mov", "mkv", "pdf"]
endif

if !exists('g:vimsidian_unsuitable_link_chars')
  let g:vimsidian_unsuitable_link_chars = ['^', '|', '#', '[', ']']
endif

if !exists('g:vimsidian_internal_link_chars')
  let g:vimsidian_internal_link_chars = ['^', '|', '#']
endif

" check required commands
if g:vimsidian_check_required_commands_executable
  for cmd in g:vimsidian_required_commands
    if !executable(cmd)
      echoerr '[VIMSIDIAN] Command not found: ' . cmd
      finish
    endif
  endfor
endif

" commands
command! -nargs=1 VimsidianRgNotesWithMatches call vimsidian#VimsidianRgNotesWithMatches(<q-args>)
command! -nargs=1 VimsidianRgLinesWithMatches call vimsidian#VimsidianRgLinesWithMatches <q-args>)
command! VimsidianRgNotesWithMatchesInteractive call vimsidian#VimsidianRgNotesWithMatchesInteractive()
command! VimsidianRgLinesWithMatchesInteractive call vimsidian#VimsidianRgLinesWithMatchesInteractive()
command! VimsidianRgNotesLinkingThisNote call vimsidian#VimsidianRgNotesLinkingThisNote()
command! VimsidianFdLinkedNotesByThisNote call vimsidian#VimsidianFdLinkedNotesByThisNote()
command! VimsidianRgTagMatches call vimsidian#VimsidianRgTagMatches()
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

  if g:vimsidian_color_definition_use_default
    autocmd BufNewFile,BufReadPost $VIMSIDIAN_PATH/*.md hi! def VimsidianLinkColor term=NONE ctermfg=47 guifg=#689d6a
    autocmd BufNewFile,BufReadPost $VIMSIDIAN_PATH/*.md hi! def VimsidianLinkMediaColor term=NONE ctermfg=142 guifg=#b8bb26
    autocmd BufNewFile,BufReadPost $VIMSIDIAN_PATH/*.md hi! def VimsidianLinkHeader term=NONE ctermfg=142 guifg=#b8bb26
    autocmd BufNewFile,BufReadPost $VIMSIDIAN_PATH/*.md hi! def VimsidianLinkBlock term=NONE ctermfg=142 guifg=#b8bb26
    autocmd BufNewFile,BufReadPost $VIMSIDIAN_PATH/*.md hi! def VimsidianTagColor term=NONE ctermfg=109 guifg=#076678
    autocmd BufNewFile,BufReadPost $VIMSIDIAN_PATH/*.md hi! def VimsidianPromptColor term=NONE ctermfg=109 guifg=#076678
  endif

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
