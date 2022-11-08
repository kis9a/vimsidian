# vimsidian

Vim plugin to help edit [obsidian](https://obsidian.md/) notes in Vim. Highlight, Complement, Searching and open links and tags. Even if you don't use [obsidian](https://obsidian.md/), you can use it to manage your notes locally.

This plugin was made for me, but I hope it will be useful for those who want to easily edit [obsidian](https://obsidian.md/) notes with vim as I do. If you have trouble using it, please post an [issues](https://github.com/kis9a/vimsidian/issues) below. Contributions, edits and distribution are also welcome. I also shared on the obsdiain forum. [forum.obsidian.md - 46385](https://forum.obsidian.md/t/vimsidian-vim-plugin-to-help-edit-obsidian-notes-in-vim/46385)

<span style="margin: 26px 52px">![](./docs/image.gif)</span>

## LICENSE

- [WTFPL license - Do What The F\*ck You Want To Public License](./LICENSE.md)

## Description

- [Syntax highlight, Variables and Commands description](./docs/description.md)

## Setup

### Requirements

- `$VIMSIDIAN_PATH` environment variable
- [ripgrep](https://github.com/BurntSushi/ripgrep) command
- [fd](https://github.com/sharkdp/fd) command

### Installation

```vim
Plug "kis9a/vimsidian"
```

### Example configuration

#### - Minimal

```vim
let g:vimsidian_complete_paths = [$VIMSIDIAN_PATH . "/notes", $VIMSIDIAN_PATH . "/images"]

function! s:vimsidianNewNoteAtNotesDirectory()
  execute ":VimsidianNewNote " . $VIMSIDIAN_PATH . "/notes"
endfunction

function s:vimsidianMappings()
  nnoremap <silent> sl :VimsidianFdLinkedNotesByThisNote<CR>
  nnoremap <silent> sg :VimsidianRgNotesLinkingThisNote<CR>
  nnoremap <silent> st :VimsidianRgTagMatches<CR>
  nnoremap <silent> sin :VimsidianRgNotesWithMatchesInteractive<CR>
  nnoremap <silent> sil :VimsidianRgLinesWithMatchesInteractive<CR>
  nnoremap <silent> sF :VimsidianMoveToLink<CR>
  nnoremap <silent> sk :VimsidianMoveToPreviousLink<CR>
  nnoremap <silent> sj :VimsidianMoveToNextLink<CR>
  nnoremap <silent> sN :call <SID>vimsidianNewNoteAtNotesDirectory()<CR>
  nnoremap <silent> sf :VimsidianFormatLink<CR>
endfunction

autocmd BufNewFile,BufReadPost $VIMSIDIAN_PATH/*.md call s:vimsidianMappings()
```
