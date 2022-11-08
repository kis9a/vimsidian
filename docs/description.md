### Syntax highlight

- link: `\v\[\[.{-}\]\]`
- link media: `\v\!\[\[.{-}\]\]`
- link heading: `\v\[\[#.{-}\]\]`
- link block: `\v\[\[\^.{-}\]\]`
- tag: `\v\#(\w+)`

### Variables

- `g:loaded_vimsidian_plugin`: `0` : A variable that indicates if the plugin is already loaded. You can disable vimsidian by setting value 1
- `g:vimsidian_log_level 2` : `0` : NONE, 1:ERROR, 2:INFO, 3:DEBUG
- `g:vimsidian_enable_syntax_highlight` : `1` : Variable to control whether syntax highlighting is enabled or disabled, enabled by default
- `g:vimsidian_enable_complete_functions` : `1` : Variable that controls enable/disable of note input completion function, enabled by default
- `g:vimsidian_complete_paths_search_use_fd` : `1` : Whether to search files under g:vimsidian_complete_paths using fd, use ls when 0
- `g:vimsidian_color_definition_use_default` : `1` : A variable that specifies whether to use the default color definition
- `g:vimsidian_check_required_commands_executable` : `1` : A variable to check if the necessary command can be executed when loading the plugin
- `g:vimsidian_complete_paths` : `[]` : A list of directories containing notes that complete the input
- `g:vimsidian_required_commands` : `['rg', 'fd', 'grep']` : List of commands required to use vimsidian
- `g:vimsidian_unsuitable_link_chars` : `['^', '\|', '#', '[', ']']` : List of characters unsuitable for use in link names
- `g:vimsidian_internal_link_chars` : `['^', '\|', '#']` : List of characters used for internal links
- `g:vimsidian_media_extensions` : `["png", "svg", "gif", ...]` : [A list of extensions](https://help.obsidian.md/Obsidian+Publish/Hosting+media+files) to recognize as media when interpreting the link under the cursor.

### Commands

- `VimsidianRgNotesWithMatches $keyword` : Search `$vimsidian_path` for a list of notes containing the argument keyword and display it in the quickfix list
- `VimsidianRgLinesWithMatches $keyword` : Search `$vimsidian_path` for a list of lines containing the argument keyword and display it in the quickfix list
- `VimsidianRgNotesWithMatchesInteractive` : Enter the $keyword for the arguments of the VimsidianRgNotesWithMatches command at the prompt
- `VimsidianRgLinesWithMatchesInteractive` : Enter the $keyword for the arguments of the VimsidianRgLinesWithMatches command at the prompt
- `VimsidianFdLinkedNotesByThisNote` : Search `$vimsidian_path` for list of notes linked to by this note and display it in the quickfix list
- `VimsidianRgNotesLinkingThisNote` : Search `$vimsidian_path` for list of notes linking this note and display it in the quickfix list
- `VimsidianRgTagMatches` : Search `$vimsidian_path` for list of matches containing the under cursor tag name and display it in the quickfix list
- `VimsidianMoveToLink` : Search `$vimsidian_path` for the link you are cursor on and move it.
- `VimsidianMoveToPreviousLink` : Go to link before current cursor
- `VimsidianMoveToNextLink` : Go to link after current cursor position
- `VimsidianNewNote $baseDir` : Creates a note with the name of the link under the cursor in a directory with the name of the argument
- `VimsidianFormatLink` : Format vimsidian link string for the current file
