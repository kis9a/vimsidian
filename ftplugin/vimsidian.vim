runtime! ftplugin/markdown.vim

if exists('b:loaded_vimsidian_ftplugin') && b:loaded_vimsidian_ftplugin 
  finish
endif

let b:loaded_vimsidian_ftplugin = 1

if exists("g:vimsidian_enable_complete_functions") && g:vimsidian_enable_complete_functions
  setlocal completefunc=vimsidian#command#CompleteNotes
endif
