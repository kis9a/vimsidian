# vimsidian

Vim plugin to help edit [obsidian](https://obsidian.md/) notes in Vim. Highlight, Complement, Searching and open links and tags. Even if you don't use [obsidian](https://obsidian.md/), you can use it to manage your notes locally.

This plugin was made for me, but I hope it will be useful for those who want to easily edit [obsidian](https://obsidian.md/) notes with vim as I do. If you have trouble using it, please post an [issues](https://github.com/kis9a/vimsidian/issues) below. Contributions, edits and distribution are also welcome. I also shared on the obsdiain forum. [forum.obsidian.md - 46385](https://forum.obsidian.md/t/vimsidian-vim-plugin-to-help-edit-obsidian-notes-in-vim/46385)

<span style="margin: 20px 40px">![](./docs/image.gif)</span>

## Required

- `VIMSIDIAN_PATH` environment variable
- [ripgrep](https://github.com/BurntSushi/ripgrep) command
- [fd](https://github.com/sharkdp/fd) command

## Installation

```vim
Plug "kis9a/vimsidian"
```

## Mapping Examples

```vim
let g:loaded_vimsidian_plugin = 0
let g:vimsidian_enable_complete_functions = 1
let g:vimsidian_enable_syntax_highlight = 1
let g:vimsidian_complete_paths = [$VIMSIDIAN_PATH . "/notes", $VIMSIDIAN_PATH . "/images",  $VIMSIDIAN_PATH . "/articles"]

hi def VimsidianLinkColor term=NONE ctermfg=47 guifg=#689d6a
hi def VimsidianLinkMediaColor term=NONE ctermfg=142 guifg=#b8bb26
hi def VimsidianLinkHeader term=NONE ctermfg=142 guifg=#b8bb26
hi def VimsidianLinkBlock term=NONE ctermfg=142 guifg=#b8bb26
hi def VimsidianTagColor term=NONE ctermfg=109 guifg=#076678
hi def VimsidianPromptColor term=NONE ctermfg=109 guifg=#076678

function! s:vimsidianNewNoteSameDirectoryAsCurrentFile()
  execute ':VimsidianNewNote ' . fnamemodify(expand("%:p"), ":h")
endfunction

function! s:vimsidianNewNoteAtNotesDirectory()
  execute ':VimsidianNewNote ' . $VIMSIDIAN_PATH . '/notes'
endfunction

augroup vimsidian_mappings
  autocmd!
  autocmd BufNewFile,BufReadPost $VIMSIDIAN_PATH/*.md nnoremap <silent> sr :VimsidianRgNotesWithMatchesInteractive<CR>
  autocmd BufNewFile,BufReadPost $VIMSIDIAN_PATH/*.md nnoremap <silent> st :VimsidianRgTagMatches<CR>
  autocmd BufNewFile,BufReadPost $VIMSIDIAN_PATH/*.md nnoremap <silent> sl :VimsidianFdLinkedNotesByThisNote<CR>
  autocmd BufNewFile,BufReadPost $VIMSIDIAN_PATH/*.md nnoremap <silent> sg :VimsidianRgNotesLinkingThisNote<CR>
  autocmd BufNewFile,BufReadPost $VIMSIDIAN_PATH/*.md nnoremap <silent> <C-k> :VimsidianMoveToLink<CR>
  autocmd BufNewFile,BufReadPost $VIMSIDIAN_PATH/*.md nnoremap <silent> sk :VimsidianMoveToPreviousLink<CR>
  autocmd BufNewFile,BufReadPost $VIMSIDIAN_PATH/*.md nnoremap <silent> sj :VimsidianMoveToNextLink<CR>
  autocmd BufNewFile,BufReadPost $VIMSIDIAN_PATH/*.md nnoremap <silent> si :VimsidianFormatLink<CR>
  autocmd BufNewFile,BufReadPost $VIMSIDIAN_PATH/*.md nnoremap <silent> sC :call <SID>vimsidianNewNoteSameDirectoryAsCurrentFile()<CR>
  autocmd BufNewFile,BufReadPost $VIMSIDIAN_PATH/*.md nnoremap <silent> sN :call <SID>vimsidianNewNoteAtNotesDirectory()<CR>
augroup END
```

## Descriptions

### Variables

| Name                                  | Default                                         | Description                                                                                                                                                                  |
| ------------------------------------- | ----------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| g:loaded_vimsidian_plugin             | 0                                               | A variable that indicates if the plugin is already loaded. You can disable this plugin by setting g:loaded_vimsidian_plugin = 1                                              |
| g:vimsidian_enable_complete_functions | 1                                               | Variable that controls enable/disable of note input completion function, enabled by default                                                                                  |
| g:vimsidian_enable_syntax_highlight   | 1                                               | Variable to control whether syntax highlighting is enabled or disabled, enabled by default                                                                                   |
| g:vimsidian_complete_paths            | []                                              | A list of directories containing notes that complete the input                                                                                                               |
| g:vimsidian_media_extensions          | ["png", "jpg", "jpeg", "gif", "svg", "mp3" ...] | A list of extensions to recognize as media when interpreting the link under the cursor. [Hosting media files](https://help.obsidian.md/Obsidian+Publish/Hosting+media+files) |

### Syntax Highlight

| Name         | Pattern            |
| ------------ | ------------------ |
| link         | `\v\[\[.{-}\]\]`   |
| link media   | `\v\!\[\[.{-}\]\]` |
| link heading | `\v\[\[#.{-}\]\]`  |
| link block   | `\v\[\[#.{-}\]\]`  |
| tag          | `\v\#(\w+)`        |

### Commands, Functions

| Name                                    | Description                                                                                                                     |
| --------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------- |
| VimsidianCompleteNotes(findstart, base) | List of notes under `$vimsidian_complete_paths` are popped up and input is completed. press `keyword<C-X><C-U>` in insert mode. |
| :VimsidianRgNotesWithMatches $keyword   | Search `$vimsidian_path` for a list of notes containing the argument keyword and display it in the quickfix list.               |
| :VimsidianRgTagMatches                  | Search `$vimsidian_path` for list of matches containing the under cursor tag name and display it in the quickfix list.          |
| :VimsidianFdLinkedNotesByThisNote       | Search `$vimsidian_path` for list of notes linked to by this note and display it in the quickfix list.                          |
| :VimsidianRgNotesLinkingThisNote        | Search `$vimsidian_path` for list of notes linking this note and display it in the quickfix list.                               |
| :VimsidianMoveToLink                    | Search `$vimsidian_path` for the link you are cursor on and move it.                                                            |
| :VimsidianMoveToPreviousLink            | Go to link before current cursor.                                                                                               |
| :VimsidianMoveToNextLink                | Go to link after current cursor position.                                                                                       |
| :VimsidianNewNote $baseDir              | Creates a note with the name of the link under the cursor in a directory with the name of the argument.                         |
| :VimsidianFormatLink                    | Format vimsidian link string for the current file. See pattern [test_vimsidian_format_link](./docs/test_vimsidian_format_link). |
