autocmd BufRead,BufNewFile *.md if filereadable('.obsidian') || isdirectory('.obsidian') | set filetype=vimsidian | endif
