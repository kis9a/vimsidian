# vimsidian

![](https://img.shields.io/github/workflow/status/kis9a/vimsidian/test)

Vim plugin to help edit [Obsidian](https://obsidian.md/) notes in Vim. Links, backlink resolution and jumps, search and completion and highlighting, daily notes. Even if you don't use [Obsidian](https://obsidian.md/), you can use it to manage your notes locally.

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
- Default syntax highlighting settings.
- Custom formatting of link spacing.
- Manage multiple `g:vimsidian_path` (Obsidian Vault).
- Daily note feature.
- Highlighting broken links.
- Fewer dependencies.

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

#### • Minimal

```vim
let g:vimsidian_path = $HOME . '/obsidian'
let g:vimsidian_complete_paths = [g:vimsidian_path]
let $VIMSIDIAN_PATH_PATTERN = g:vimsidian_path . '/*.md'

function! s:vimsidianNewNoteAtNotesDirectory()
  execute ':VimsidianNewNote ' . g:vimsidian_path . '/notes'
endfunction

augroup vimsidian_augroup
  au!
  au BufNewFile,BufReadPost $VIMSIDIAN_PATH_PATTERN nn <buffer> sl :VimsidianFdLinkedNotesByThisNote<CR>
  au BufNewFile,BufReadPost $VIMSIDIAN_PATH_PATTERN nn <buffer> sg :VimsidianRgNotesLinkingThisNote<CR>
  au BufNewFile,BufReadPost $VIMSIDIAN_PATH_PATTERN nn <buffer> sm :VimsidianRgNotesWithMatchesInteractive<CR>
  au BufNewFile,BufReadPost $VIMSIDIAN_PATH_PATTERN nn <buffer> si :VimsidianRgLinesWithMatchesInteractive<CR>
  au BufNewFile,BufReadPost $VIMSIDIAN_PATH_PATTERN nn <buffer> st :VimsidianRgTagMatches<CR>
  au BufNewFile,BufReadPost $VIMSIDIAN_PATH_PATTERN nn <buffer> <C-k> :VimsidianMoveToLink<CR>
  au BufNewFile,BufReadPost $VIMSIDIAN_PATH_PATTERN nn <buffer> <2-LeftMouse> :VimsidianMoveToLink<CR>
  au BufNewFile,BufReadPost $VIMSIDIAN_PATH_PATTERN nn <buffer> sk :VimsidianMoveToPreviousLink<CR>
  au BufNewFile,BufReadPost $VIMSIDIAN_PATH_PATTERN nn <buffer> sj :VimsidianMoveToNextLink<CR>
  au BufNewFile,BufReadPost $VIMSIDIAN_PATH_PATTERN nn <buffer> sN :call <SID>vimsidianNewNoteAtNotesDirectory()<CR>
  au BufNewFile,BufReadPost $VIMSIDIAN_PATH_PATTERN nn <buffer> sO :VimsidianNewNoteInteractive<CR>
  au BufNewFile,BufReadPost $VIMSIDIAN_PATH_PATTERN nn <buffer> sd :VimsidianDailyNote<CR>
  au BufNewFile,BufReadPost $VIMSIDIAN_PATH_PATTERN nn <buffer> sf :VimsidianFormatLink<CR>
  au WinEnter,BufEnter $VIMSIDIAN_PATH_PATTERN silent! call vimsidian#MatchBrokenLinks()
  au CursorMoved $VIMSIDIAN_PATH_PATTERN silent! call vimsidian#MatchCursorLink()
augroup END
```

#### • Advance, ideas

<!--{{{ Multiple g:vimsidian_path (Vault) -->
<details open>
<summary>Multiple g:vimsidian_path</summary>

Multiple vimsidian_paths can be managed. The `$VIMSIDIAN_PATH_PATTERN` is the autocmd path-pattern (:h autocmd-pattern).
`g:vimsidian_path` variable is the path where notes and completion suggestions are searched.

```vim
let g:vimsidian_path_main = $HOME . '/obsidian'
let g:vimsidian_path_sub = $HOME . '/Nsidian'
let g:vimsidian_path = g:vimsidian_path_main
let $VIMSIDIAN_PATH_PATTERN = g:vimsidian_path_main . '/*.md,' . g:vimsidian_path_sub . '/*.md'

function! s:vimsidianSwitchVault()
  if stridx(expand('%:p'), g:vimsidian_path_main) !=# '-1'
    let g:vimsidian_path = g:vimsidian_path_main
    let g:vimsidian_complete_paths = [g:vimsidian_path_main . '/notes', g:vimsidian_path_main  . '/images']
  elseif stridx(expand('%:p'), g:vimsidian_path_sub) !=# '-1'
    let g:vimsidian_path = g:vimsidian_path_sub
    let g:vimsidian_complete_paths = [g:vimsidian_path_sub . '/Nnotes']
  endif
endfunction

augroup vimsidian_augroup
  au!
  au VimEnter,BufNewFile,BufReadPost,WinEnter,BufEnter *.md call s:vimsidianSwitchVault()
" ry ...
```

</details>
<!--}}}-->

<!--{{{ Change link open mode -->
<details close>
<summary>Change link open mode</summary>
<br/>

Change the way the buffer opens when opening a new note.

```vim
" default
let g:vimsidian_link_open_mode = 'e!'

" newtab
let g:vimsidian_link_open_mode = 'newtab'

" vsplit
let g:vimsidian_link_open_mode = 'vnew'

" hsplit
let g:vimsidian_link_open_mode = 'new'
```

</details>
<!--}}}-->

<!--{{{ Use fzf to list note names -->
<details close>
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

<!--{{{ Define the colors yourself -->
<details close>
<summary>Define the colors yourself</summary>
<br/>

```vim
let g:vimsidian_color_definition_use_default = 0

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
```

</details>
<!--}}}-->

<!--{{{ Custom daily note template -->
<details close>
<summary>Custom daily note template</summary>
<br/>

```vim
let g:vimsidian_daily_note_path = g:vimsidian_path . "/daily/" . strftime("%Y-%m")
let g:vimsidian_daily_note_template_path = g:vimsidian_path . "/daily/Daily template.md"
```

The template file can use some parameters. (:h g:vimsidian_daily_note_template_path)

```
[[{{date}}]]

< [[{{previous_date}}]] | [[{{next_date}}]] >

[[{{year}}-{{month}}]] [[{{day}}]] [[{{day_of_week}}]]
```

</details>
<!--}}}-->

<!--{{{ Create new note same directory as current file -->
<details close>
<summary>Create new note same directory as current file</summary>
<br/>

```vim
function! s:vimsidianNewNoteSameDirectoryAsCurrentFile()
  execute ':VimsidianNewNote ' . fnamemodify(expand('%:p'), ':h')
endfunction

au BufNewFile,BufReadPost $VIMSIDIAN_PATH_PATTERN nn <silent> sC :call <SID>vimsidianNewNoteSameDirectoryAsCurrentFile()<CR>
```

</details>
<!--}}}-->

<!--{{{ Refine complete_paths to speed up search for completions -->
<details close>
<summary>Refine complete_paths to speed up search for completions</summary>
<br/>

```vim
" vimsidian complete paths search use ls command
let g:vimsidian_complete_paths_search_use_fd = 0
let g:vimsidian_complete_paths = [g:vimsidian_path . '/notes/foo', g:vimsidian_path . '/notes/b']
```

</details>
<!--}}}-->

<!--{{{ Disable required commands checks to make plugins load a bit faster -->
<details close>
<summary>Disable required commands checks to make plugins load a bit faster</summary>
<br/>

```vim
" It is assumed that the following commands are already installed
" :echo g:vimsidian_required_commands
let g:vimsidian_check_required_commands_executable = 0
```

</details>
<!--}}}-->

<!--{{{ #vimsidian functions -->
<details close>
<summary>#vimsidian functions</summary>
<br/>

```vim
function! s:MocByFd(noteKeyword)
  let files = split(vimsidian#unit#Fd(g:vimsidian_path, []), '\n')
  for f in files
    if f =~# '\v^.*' . a:noteKeyword
      put='[[' . fnamemodify(f, ':t:r') . ']]'
    endif
  endfor
  return vimsidian#unit#Find(files, '^.*/' . a:noteKeyword)
endfunction

command! -nargs=1 VimsidianMocByFd call s:MocByFd(<q-args>)

function! s:MocByRg(keyword)
  for path in vimsidian#unit#RgNotes(a:keyword)
    put='[[' . fnamemodify(path, ':t:r') . ']]'
  endfor"
endfunction

command! -nargs=1 VimsidianMocByRg call s:MocByRg(<q-args>)

function! s:HiCursorLink()
  let link = vimsidian#unit#CursorLink()
  if link !=# v:null
    normal! "zyiw:let @/ = '\<' . @z . '\>'<CR>:set hlsearch<CR>
  endif
endfunction

command! VimsidianHiCursorLink call s:HiCursorLink()
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

[WTFPL license - Do What The F\*ck You Want To Public License](./LICENSE.md)
