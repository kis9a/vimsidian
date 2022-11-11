" flags
let s:save_cpo = &cpo
set cpo&vim

" check pre required
if exists('g:loaded_vimsidian_plugin') && g:loaded_vimsidian_plugin
  finish
endif

if !exists('g:vimsidian_path')
  echoerr '[VIMSIDIAN] Required g:vimsidian_path variable'
  finish
endif

if empty(glob(g:vimsidian_path))
  echoerr "[VIMSIDIAN] No such directory '" . g:vimsidian_path . "'"
  finish
endif

" set global options
if empty($VIMSIDIAN_PATH_PATTERN)
  let $VIMSIDIAN_PATH_PATTERN = g:vimsidian_path . "/*.md"
endif

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
command! -nargs=1 VimsidianRgNotesWithMatches call vimsidian#RgNotesWithMatches(<q-args>)
command! -nargs=1 VimsidianRgLinesWithMatches call vimsidian#RgLinesWithMatches(<q-args>)
command! VimsidianRgNotesWithMatchesInteractive call vimsidian#RgNotesWithMatchesInteractive()
command! VimsidianRgLinesWithMatchesInteractive call vimsidian#RgLinesWithMatchesInteractive()
command! VimsidianRgNotesLinkingThisNote call vimsidian#RgNotesLinkingThisNote()
command! VimsidianFdLinkedNotesByThisNote call vimsidian#FdLinkedNotesByThisNote()
command! VimsidianRgTagMatches call vimsidian#RgTagMatches()
command! VimsidianMoveToLink call vimsidian#MoveToLink()
command! VimsidianMoveToNextLink call vimsidian#MoveToNextLink()
command! VimsidianMoveToPreviousLink call vimsidian#MoveToPreviousLink()
command! -nargs=1 VimsidianNewNote call vimsidian#NewNote(<q-args>)
command! VimsidianFormatLink call vimsidian#FormatLink()

" augroup
augroup vimsidian_plugin
  au!
  if g:vimsidian_enable_complete_functions
    au BufNewFile,BufReadPost $VIMSIDIAN_PATH_PATTERN setlocal completefunc=vimsidian#CompleteNotes
  endif

  if g:vimsidian_color_definition_use_default
    au BufNewFile,BufReadPost $VIMSIDIAN_PATH_PATTERN hi def VimsidianLinkColor term=NONE ctermfg=47 guifg=#689d6a
    au BufNewFile,BufReadPost $VIMSIDIAN_PATH_PATTERN hi def VimsidianLinkMediaColor term=NONE ctermfg=142 guifg=#b8bb26
    au BufNewFile,BufReadPost $VIMSIDIAN_PATH_PATTERN hi def VimsidianLinkHeader term=NONE ctermfg=142 guifg=#b8bb26
    au BufNewFile,BufReadPost $VIMSIDIAN_PATH_PATTERN hi def VimsidianLinkBlock term=NONE ctermfg=142 guifg=#b8bb26
    au BufNewFile,BufReadPost $VIMSIDIAN_PATH_PATTERN hi def VimsidianTagColor term=NONE ctermfg=109 guifg=#076678
    au BufNewFile,BufReadPost $VIMSIDIAN_PATH_PATTERN hi def VimsidianPromptColor term=NONE ctermfg=109 guifg=#076678
  endif

  if g:vimsidian_enable_syntax_highlight
    au BufNewFile,BufReadPost $VIMSIDIAN_PATH_PATTERN syn match VimsidianLink containedin=markdownH1,markdownH2,markdownH3,markdownH4,markdownH5,markdownH6 /\v\[\[.{-}\]\]/
    au BufNewFile,BufReadPost $VIMSIDIAN_PATH_PATTERN syn match VimsidianLinkMedia containedin=VimsidianLink /\v\!\[\[.{-}\]\]/
    au BufNewFile,BufReadPost $VIMSIDIAN_PATH_PATTERN syn match VimsidianLinkHeader containedin=VimsidianLink /\v\[\[#.{-}\]\]/
    au BufNewFile,BufReadPost $VIMSIDIAN_PATH_PATTERN syn match VimsidianLinkBlock containedin=VimsidianLink /\v\[\[\^.{-}\]\]/
    au BufNewFile,BufReadPost $VIMSIDIAN_PATH_PATTERN syn match VimsidianTag containedin=VimsidianIdea /\v\#(\w+)/

    au BufNewFile,BufReadPost $VIMSIDIAN_PATH_PATTERN hi link VimsidianLink VimsidianLinkColor
    au BufNewFile,BufReadPost $VIMSIDIAN_PATH_PATTERN hi link VimsidianLinkMedia VimsidianLinkMediaColor
    au BufNewFile,BufReadPost $VIMSIDIAN_PATH_PATTERN hi link VimsidianLinkHeader VimsidianLinkHeaderColor
    au BufNewFile,BufReadPost $VIMSIDIAN_PATH_PATTERN hi link VimsidianLinkBlock VimsidianLinkBlockColor
    au BufNewFile,BufReadPost $VIMSIDIAN_PATH_PATTERN hi link VimsidianTag VimsidianTagColor
  endif
augroup END

" end flags
let &cpo = s:save_cpo
let g:loaded_vimsidian_plugin = 1
