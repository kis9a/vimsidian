# vimsidian

![](https://img.shields.io/github/actions/workflow/status/kis9a/vimsidian/test.yml?branch=main)

Vim plugin to help edit [Obsidian](https://obsidian.md/) notes in Vim. Links, backlink resolution and jumps, search and completion and highlighting. Even if you don't use [Obsidian](https://obsidian.md/), you can use it to manage your notes locally.

This plugin was made for me, but I hope it will be useful for those who want to easily edit [Obsidian](https://obsidian.md/) notes with vim as I do. If you have trouble using it, please post an [issues](https://github.com/kis9a/vimsidian/issues) below. Contributions, edits and distribution are also welcome.

<br/>
<image width="680px" src="https://raw.githubusercontent.com/kis9a/vimsidian/main/pictures/vimsidian.gif"></image>

## Motivation

In my earlier days, I used to divide notes in directories and manage note relationships by describing relative paths. However, I had trouble categorizing notes and spent a lot of time resolving note paths. I needed to achieve the following.

- Hierarchical structure is not suitable for classification of detailed personal knowledge.
- Create atomic notes and link notes to each other.
- Eliminate stress by unifying editing tasks and management of editing plugins in Vim.
- [[Link]] format to integrate into [Obsidian](https://obsidian.md/).

For me, [vimsidian](https://github.com/kis9a/vimsidian) is the plugin that solves these issues and complements my PKM (personal knowledge managment).

## Features

- Insert mode completion of note names.
- Find and move the link under the cursor.
- Go to link before or afater current cursor.
- Create a note with the name of the link under the cursor.
- Search for notes and lines matching keywords.
- Display notes in the quickfix window containing the tag string under the cursor.
- Highlighting broken links.
- Fewer dependencies.

## Extensions

* [kis9a/vimsidian-daily-notes: Daily note extension for vimsidian](https://github.com/kis9a/vimsidian-daily-notes)
* [kis9a/vimsidian-link-stack: Keep a link stack of jumping history in each window](https://github.com/kis9a/vimsidian-link-stack) 
* [vimsidian-formatting-of-link-spacing-example.md · GitHub](https://gist.github.com/kis9a/a60add3b0043ad10f46cbedb2f4eaab6)

## Initialization

### Requirements

- [ripgrep](https://github.com/BurntSushi/ripgrep) command
- [fd](https://github.com/sharkdp/fd) command

### Installation

Use your favorite plugin manager.

- Example: [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'kis9a/vimsidian'
```

## Configuration

1. make `.obsidian` file or directory in your obsidian vault directory.

If the current working directory contains a `.obsidian` file or directory, it will be recognized as an Obsidian vault.

2. configure mappings

~/.vim/ftplugin/vimsidian.vim

```vim
if exists("b:loaded_vimsidian_ftplugin_mappings")
  finish
endif
let b:loaded_vimsidian_ftplugin_mappings = 1

nnoremap <silent> <buffer> <C-k> :VimsidianJump<CR>
nnoremap <silent> <buffer> <2-LeftMouse> :VimsidianJump<CR>
nnoremap <silent> <buffer> sk :VimsidianPrevLink<CR>
nnoremap <silent> <buffer> sj :VimsidianNextLink<CR>
nnoremap <silent> <buffer> sl :VimsidianFindLinks<CR>
nnoremap <silent> <buffer> sg :VimsidianFindBacklinks<CR>
nnoremap <silent> <buffer> st :VimsidianFindTags<CR>
nnoremap <silent> <buffer> sN :VimsidianSearchNotes<Space>
nnoremap <silent> <buffer> sL :VimsidianSearchLinks<Space>

autocmd WinEnter,BufEnter <buffer> silent! VimsidianMatchBrokenLinks
autocmd CursorMoved <buffer> silent! VimsidianMatchCursorLink
```
<!--{{{ Use fzf to list note names -->
<details open>
<summary>Use fzf to list note names</summary>
<br/>

Open listings using fzf instead of quick fix window.
See fzf installation at <https://github.com/junegunn/fzf.vim#installation>

```vim
# e.g
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

if executable('fzf')
  let g:vimsidian_use_fzf = 1
endif
```

</details>
<!--}}}-->

## Help

See [Vim doc - Syntax highlight, Variables and Commands help](./doc/vimsidian.txt)

```vim
:h vimsidian
```

## Developments

<!--{{{ If you contribute to this repository, please use the following tools for linting and testing -->
<details close>
<summary>If you contribute to this repository, please use the following tools for linting and testing</summary>
<br/>

### Linting

Use [vim-parser](https://github.com/ynkdir/vim-vimlparser), [vim-vimlint](https://github.com/syngan/vim-vimlint)

```
make init
make lint
```

When using [vint](https://github.com/Vimjas/vint)

```
make vint-int
make lint-vint
```

### Testing

Use [vim-themis](https://github.com/thinca/vim-themis/issues), CI [.github/workflows/test.yml](./.github/workflows/test.yml)

```
make init
make test
```

</details>
<!--}}}-->

## LICENSE

[WTFPL license - Do What The F\*ck You Want To Public License](./LICENSE)
