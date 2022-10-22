# vimsidian

Vim plugin to help edit obsidian notes in Vim. Highlight, Complement, Searching and open links and tags.

![](./docs/image.gif)

## Required

- $OBSIDIAN_PATH environment variable
- [realpath](https://github.com/coreutils/coreutils) command
- [ripgrep](https://github.com/BurntSushi/ripgrep) command
- [fd](https://github.com/sharkdp/fd) command

## Installation

```vim
Plug 'kis9a/vimsidian'
```

## Examples mappings

```
let g:vimsidian_path=$OBSIDIAN_PATH
let g:vimsidian_complete_paths = [$OBSIDIAN_PATH . "/notes", $OBSIDIAN_PATH . "/images",  $OBSIDIAN_PATH . "/articles"]
let g:loaded_vimsidian_plugin = 0

hi def VimsidianLinkColor term=NONE ctermfg=47 guifg=#689d6a
hi def VimsidianLinkMediaColor term=NONE ctermfg=142 guifg=#b8bb26
hi def VimsidianLinkHeader term=NONE ctermfg=142 guifg=#b8bb26
hi def VimsidianLinkBlock term=NONE ctermfg=142 guifg=#b8bb26
hi def VimsidianTagColor term=NONE ctermfg=24 guifg=blue
hi def VimsidianPromptColor term=NONE ctermfg=109 guifg=#076678

autocmd BufNewFile,BufReadPost $OBSIDIAN_PATH/*.md nnoremap <silent> sr :VimsidianRgNotesWithMatchesInteractive<CR>
autocmd BufNewFile,BufReadPost $OBSIDIAN_PATH/*.md nnoremap <silent> st :VimsidianRgTagMatches<CR>
autocmd BufNewFile,BufReadPost $OBSIDIAN_PATH/*.md nnoremap <silent> sl :VimsidianFdLinkedNotesByThisNote<CR>
autocmd BufNewFile,BufReadPost $OBSIDIAN_PATH/*.md nnoremap <silent> sg :VimsidianRgNotesLinkingThisNote<CR>
autocmd BufNewFile,BufReadPost $OBSIDIAN_PATH/*.md nnoremap <silent> sF :VimsidianMoveToLink<CR>
```

## Descriptions

### Syntax Highlight

- link `\v\[\[.{-}\]\]`
- link media `\v\!\[\[.{-}\]\]`
- link heading `\v\[\[#.{-}\]\]`
- link block `\v\[\[#.{-}\]\]`
- tag `\v\#(\w+)`

### Functions

- CompleteVimsidianFiles(findstart, base)

  List of notes under `$vimsidian_complete_paths` are popped up and input is completed. press `keyword<C-X><C-U>` in insert mode.

- VimsidianRgNotesWithMatches(word)

  Search `$vimsidian_path` for a list of notes containing the argument word and display it in the quickfix list.

- VimsidianRgTagMatches()

  Search `$vimsidian_path` for list of matches containing the under cursor tag name and display it in the quickfix list.

- VimsidianFdLinkedNotesByThisNote()

  Search `$vimsidian_path` for list of notes linked to by this note and display it in the quickfix list.

- VimsidianRgNotesLinkingThisNote()

  Search `$vimsidian_path` for list of notes linking this note and display it in the quickfix list.

- VimsidianMoveToLink()

  Search `$vimsidian_path` for the link you are cursor on and move it.

- VimsidianFormatLink()

  Format vimsidian link string for the current file. See pattern [test_vimsidian_format_link](./docs/test_vimsidian_format_link).
