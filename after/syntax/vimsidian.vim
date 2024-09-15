if exists('b:loaded_vimsidian_after_syntax') && b:loaded_vimsidian_after_syntax 
  finish
endif

let b:loaded_vimsidian_after_syntax = 1

if exists("g:vimsidian_enable_syntax_highlight") && g:vimsidian_enable_syntax_highlight
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
  hi link VimsidianLink VimsidianLinkColor
  hi link VimsidianLinkMedia VimsidianLinkMediaColor
  hi link VimsidianLinkHeader VimsidianLinkHeaderColor
  hi link VimsidianLinkBlock VimsidianLinkBlockColor
  hi link VimsidianLinkBlockFlag VimsidianLinkBlockFlagColor
  hi link VimsidianTag VimsidianTagColor
  hi link VimsidianCallout VimsidianCalloutColor
endif
