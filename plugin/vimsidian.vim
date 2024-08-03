" flags
let s:save_cpo = &cpo
set cpo&vim

" check pre required
if exists('g:loaded_vimsidian_plugin') && g:loaded_vimsidian_plugin
  finish
endif

if !empty($VIMSIDIAN_TEST_PATH)
  let g:vimsidian_path = $VIMSIDIAN_TEST_PATH
endif

if !exists('g:vimsidian_path')
  echoerr '[VIMSIDIAN] Required g:vimsidian_path variable'
  finish
endif

if empty(glob(g:vimsidian_path)) || !isdirectory(glob(g:vimsidian_path))
  echoerr "[VIMSIDIAN] No such directory g:vimsidian_path '" . g:vimsidian_path . "'"
  finish
else
  let g:vimsidian_path = glob(g:vimsidian_path)
endif

" set global options
if empty($VIMSIDIAN_PATH_PATTERN)
  let $VIMSIDIAN_PATH_PATTERN = g:vimsidian_path . '/*.md'
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

if !exists('g:vimsidian_enable_link_stack')
  let g:vimsidian_enable_link_stack = 1
endif

if !exists('g:vimsidian_use_fzf')
  let g:vimsidian_use_fzf = 0
endif

if !exists('g:max_number_of_links_to_check_for_broken')
  let g:max_number_of_links_to_check_for_broken = 80
else
  if g:max_number_of_links_to_check_for_broken < 1
    let g:max_number_of_links_to_check_for_broken = 80
  endif
endif

if !exists('g:vimsidian_link_open_mode')
  let g:vimsidian_link_open_mode = 'e!'
endif

if !exists('g:vimsidian_required_commands')
  let g:vimsidian_required_commands = ['rg', 'fd', 'grep']
endif

if !exists('g:vimsidian_check_required_commands_executable')
  let g:vimsidian_check_required_commands_executable = 1
endif

if !exists('g:vimsidian_media_extensions')
  let g:vimsidian_media_extensions = ['png', 'jpg', 'jpeg', 'gif', 'bmp', 'svg', 'mp3', 'webm', 'wav', 'm4a', 'ogg', '3gp', 'flac', 'mp4', 'webm', 'ogv', 'mov', 'mkv', 'pdf']
endif

if !exists('g:vimsidian_unsuitable_link_chars')
  let g:vimsidian_unsuitable_link_chars = ['^', '|', '#', '[', ']']
endif

if !exists('g:vimsidian_internal_link_chars')
  let g:vimsidian_internal_link_chars = ['^', '|', '#']
endif

" check required commands
if g:vimsidian_check_required_commands_executable
  for g:cmd in g:vimsidian_required_commands
    if !executable(g:cmd)
      echoerr '[VIMSIDIAN] Command not found: ' . g:cmd
      finish
    endif
  endfor
endif

" commands
command! -nargs=1 VimsidianRgNotesWithMatches call vimsidian#RgNotesWithMatchesCmd(<q-args>)
command! -nargs=1 VimsidianRgLinesWithMatches call vimsidian#RgLinesWithMatchesCmd(<q-args>)
command! VimsidianRgNotesWithMatchesInteractive call vimsidian#RgNotesWithMatchesInteractive()
command! VimsidianRgLinesWithMatchesInteractive call vimsidian#RgLinesWithMatchesInteractive()
command! VimsidianRgNotesLinkingThisNote call vimsidian#RgNotesLinkingThisNote()
command! VimsidianFdLinkedNotesByThisNote call vimsidian#FdLinkedNotesByThisNote()
command! VimsidianRgTagMatches call vimsidian#RgTagMatches()
command! VimsidianMoveToLink call vimsidian#MoveToLink()
command! VimsidianMoveToCursorLink call vimsidian#MoveToCursorLink()
command! VimsidianMoveToNextLink call vimsidian#MoveToNextLink()
command! VimsidianMoveToPreviousLink call vimsidian#MoveToPreviousLink()
command! VimsidianLinkStack call vimsidian#LinkStack()
command! VimsidianMoveToNextEntryInLinkStack call vimsidian#MoveToNextEntryInLinkStack()
command! VimsidianMoveToPreviousEntryInLinkStack call vimsidian#MoveToPreviousEntryInLinkStack()
command! -nargs=1 VimsidianNewNote call vimsidian#NewNote(<q-args>)
command! VimsidianNewNoteInteractive call vimsidian#NewNoteInteractive()
command! VimsidianMatchCursorLink call vimsidian#MatchCursorLink()
command! VimsidianMatchBrokenLinks call vimsidian#MatchBrokenLinks()

" will be removed
command! VimsidianDailyNote call s:dailyNote()

function! s:dailyNote() abort
  if exists('*vimsidian#daily_notes#open')
    call vimsidian#daily_notes#open()
  else
    echo 'The daily notes function has been moved to https://github.com/kis9a/vimsidian-daily-notes'
  endif
endfunction

" augroup
augroup vimsidian_plugin
  au!
  if g:vimsidian_enable_complete_functions
    au BufNewFile,BufReadPost $VIMSIDIAN_PATH_PATTERN setlocal completefunc=vimsidian#CompleteNotes
  endif

  if g:vimsidian_enable_link_stack
    au VimEnter,WinNew $VIMSIDIAN_PATH_PATTERN call vimsidian#linkStack#WinNew()
  endif

  if g:vimsidian_color_definition_use_default
    hi def VimsidianLinkColor term=NONE ctermfg=42 guifg=#00df87
    hi def VimsidianLinkMediaColor term=NONE ctermfg=208 guifg=#ff8700
    hi def VimsidianLinkHeaderColor term=NONE ctermfg=142 guifg=#b8bb26
    hi def VimsidianLinkBlockColor term=NONE ctermfg=142 guifg=#b8bb26
    hi def VimsidianLinkBlockFlagColor term=NONE ctermfg=142 guifg=#b8bb26
    hi def VimsidianTagColor term=NONE ctermfg=214 guifg=#ffaf00
    hi def VimsidianCalloutColor term=NONE ctermfg=117 guifg=#87dfff
    hi def VimsidianPromptColor term=NONE ctermfg=109 guifg=#076678
    hi def VimsidianCursorLinkColor term=NONE ctermfg=47 guifg=#00ff5f
    hi def VimsidianBrokenLinkColor term=NONE ctermfg=29 guifg=#00875f
  endif

  if g:vimsidian_enable_syntax_highlight
    hi link VimsidianLink VimsidianLinkColor
    hi link VimsidianLinkMedia VimsidianLinkMediaColor
    hi link VimsidianLinkHeader VimsidianLinkHeaderColor
    hi link VimsidianLinkBlock VimsidianLinkBlockColor
    hi link VimsidianLinkBlockFlag VimsidianLinkBlockFlagColor
    hi link VimsidianTag VimsidianTagColor
    hi link VimsidianCallout VimsidianCalloutColor

    au BufNewFile,BufReadPost $VIMSIDIAN_PATH_PATTERN syn match VimsidianLink /\v\[\[.{-}\]\]/
    au BufNewFile,BufReadPost $VIMSIDIAN_PATH_PATTERN syn match VimsidianLinkMedia containedin=VimsidianLink /\v\!\[\[.{-}\]\]/
    au BufNewFile,BufReadPost $VIMSIDIAN_PATH_PATTERN syn match VimsidianLinkHeader containedin=VimsidianLink /\v\[\[#.{-}\]\]/
    au BufNewFile,BufReadPost $VIMSIDIAN_PATH_PATTERN syn match VimsidianLinkBlock containedin=VimsidianLink /\v\[\[#\^.{-}\]\]/
    au BufNewFile,BufReadPost $VIMSIDIAN_PATH_PATTERN syn match VimsidianLinkBlockFlag /\v\^(\w)+$/
    au BufNewFile,BufReadPost $VIMSIDIAN_PATH_PATTERN syn match VimsidianTag /\v\#(\w+)/
    au BufNewFile,BufReadPost $VIMSIDIAN_PATH_PATTERN syn match VimsidianCallout /\v^\>(\s)+\[!(\w)+\]$/
  endif
augroup END

" end flags
let &cpo = s:save_cpo
let g:loaded_vimsidian_plugin = 1
