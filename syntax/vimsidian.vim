runtime! syntax/markdown.vim

if exists("b:current_syntax")
  unlet b:current_syntax
endif

syn match VimsidianLink /\v\[\[.{-}\]\]/
syn match VimsidianLinkMedia containedin=VimsidianLink /\v\!\[\[.{-}\]\]/
syn match VimsidianLinkHeader containedin=VimsidianLink /\v\[\[#.{-}\]\]/
syn match VimsidianLinkBlock containedin=VimsidianLink /\v\[\[#\^.{-}\]\]/
syn match VimsidianLinkBlockFlag /\v\^(\w)+$/
syn match VimsidianTag /\v\#(\w+)/
syn match VimsidianCallout /\v^\>(\s)+\[!(\w)+\]$/

let b:current_syntax = 'vimsidian'
