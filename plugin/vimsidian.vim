" flags
let s:save_cpo = &cpo
set cpo&vim

" check pre required
if exists('g:loaded_vimsidian_plugin') && g:loaded_vimsidian_plugin
  finish
endif

if !exists('g:vimsidian_log_level')
  let g:vimsidian_log_level = 2 " 0: NONE, 1:ERROR, 2:INFO, 3:DEBUG
endif

if !exists('g:vimsidian_enable_syntax_highlight')
  let g:vimsidian_enable_syntax_highlight = 1
endif

if !exists('g:vimsidian_enable_complete_functions')
  let g:vimsidian_enable_complete_functions = 1
endif

if !exists('g:vimsidian_use_fzf')
  let g:vimsidian_use_fzf = 0
endif

if !exists('g:broken_link_check_max')
  let g:broken_link_check_max = 80
else
  if g:broken_link_check_max < 1
    let g:broken_link_check_max = 80
  endif
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

" main commands
command! VimsidianJump call vimsidian#command#Jump()
command! VimsidianNextLink call vimsidian#command#NextLink()
command! VimsidianPrevLink call vimsidian#command#PrevLink()
command! VimsidianFindBacklinks call vimsidian#command#FindBacklinks()
command! VimsidianFindLinks call vimsidian#command#FindLinks()
command! VimsidianFindTags call vimsidian#command#FindTags()
command! -nargs=1 VimsidianSearchNotes call vimsidian#command#SearchNotes(<q-args>)
command! -nargs=1 VimsidianSearchLinks call vimsidian#command#SearchLinks(<q-args>)
command! -nargs=1 VimsidianNewNote call vimsidian#command#NewNote(<q-args>)
command! VimsidianMatchCursorLink call vimsidian#command#MatchCursorLink()
command! VimsidianMatchBrokenLinks call vimsidian#command#MatchBrokenLinks()

" sub commands
command! VimsidianCursorLink call vimsidian#command#CursorLink()

" will be removed
command! VimsidianDailyNote call s:dailyNote()

function! s:dailyNote() abort
  if exists('*vimsidian#daily_notes#open')
    call vimsidian#daily_notes#open()
  else
    echo 'The daily notes function has been moved to https://github.com/kis9a/vimsidian-daily-notes'
  endif
endfunction

" will be removed
command! VimsidianLinkStack call s:vimsidianLinkStackShow()
command! VimsidianMoveToNextEntryInLinkStack call s:vimsidianLinkStackNext()
command! VimsidianMoveToPreviousEntryInLinkStack call s:vimsidianLinkStackPrev()

function! s:vimsidianLinkStackShow() abort
  if exists('*vimsidian#link_stack#command#show')
    call vimsidian#link_stack#command#show()
  else
    echo 'The link stack functions have been moved to https://github.com/kis9a/vimsidian-link-stack'
  endif
endfunction

function! s:vimsidianLinkStackPrev() abort
  if exists('*vimsidian#link_stack#command#move_to_previous_entry')
    call vimsidian#link_stack#command#move_to_previous_entry()
  else
    echo 'The link stack functions have been moved to https://github.com/kis9a/vimsidian-link-stack'
  endif
endfunction

function! s:vimsidianLinkStackNext() abort
  if exists('*vimsidian#link_stack#command#move_to_next_entry')
    call vimsidian#link_stack#command#move_to_next_entry()
  else
    echo 'The link stack functions have been moved to https://github.com/kis9a/vimsidian-link-stack'
  endif
endfunction

" end flags
let &cpo = s:save_cpo
let g:loaded_vimsidian_plugin = 1
