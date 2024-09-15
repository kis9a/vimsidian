let s:suite = themis#suite('vimsidian')
let s:assert = themis#helper('assert')

function! s:edit_A() abort
  execute 'e ' . $VIMSIDIAN_TEST_PATH . '/A.md'
endfunction

function! s:edit_B() abort
  execute 'e ' . $VIMSIDIAN_TEST_PATH . '/sub/B.md'
endfunction

function! s:suite.cursor_tag() abort
  call s:edit_A()
  call cursor(9, 1)
  call s:assert.equal(vimsidian#utils#CursorTag(), '#foo')
  call cursor(1, 1)
  call s:assert.equal(vimsidian#utils#CursorTag(), v:null)
endfunction

function! s:suite.link_line_numbers() abort
  call s:edit_A()
  call s:assert.equal(vimsidian#utils#LinkLineNumbers(expand('%:p')), [3, 5, 7])

  call s:edit_B()
  call s:assert.equal(vimsidian#utils#LinkLineNumbers(expand('%:p')), [5, 7, 9, 11])
endfunction

function! s:suite.links_in_this_note() abort
  call s:edit_A()
  call s:assert.equal(vimsidian#utils#LinksInNote(), ['#A Header', 'B', 'B#^6313b0', 'C'])

  call s:edit_B()
  call s:assert.equal(vimsidian#utils#LinksInNote(), ['#^World', 'Hello', 'Vimsidian|GJ'])
endfunction

function! s:suite.note_names_in_note() abort
  call s:edit_A()
  call s:assert.equal(vimsidian#utils#NoteNamesInNote(), ['B', 'C'])

  call s:edit_B()
  call s:assert.equal(vimsidian#utils#NoteNamesInNote(), ['Hello', 'Vimsidian'])
endfunction

function! s:suite.cursor_link() abort
  call s:edit_A()
  call cursor(2, 1)
  call s:assert.equal(vimsidian#utils#CursorLink(), v:null)

  call cursor(5, 4)
  call s:assert.equal(vimsidian#utils#CursorLink(), 'B#^6313b0')
  call cursor(7, 7)
  call s:assert.equal(vimsidian#utils#CursorLink(), '#A Header')

  call s:edit_B()
  call cursor(5, 1)
  call s:assert.equal(vimsidian#utils#CursorLink(), 'Hello')
  call cursor(9, 1)
  call s:assert.equal(vimsidian#utils#CursorLink(), '#^World')
  call cursor(11, 1)
  call s:assert.equal(vimsidian#utils#CursorLink(), 'Vimsidian|GJ')
endfunction

function! s:suite.link_set_to_move() abort
  call s:edit_A()
  call s:assert.equal(vimsidian#utils#LinkSetToMove(''), ['', ''])
  call s:assert.equal(vimsidian#utils#LinkSetToMove('Link'), ['Link', ''])
  call s:assert.equal(vimsidian#utils#LinkSetToMove('#Link'), ['A', 'Link'])
  call s:assert.equal(vimsidian#utils#LinkSetToMove('#^Link'), ['A', '^Link'])
  call s:assert.equal(vimsidian#utils#LinkSetToMove('Hello#World'), ['Hello', 'World'])
  call s:assert.equal(vimsidian#utils#LinkSetToMove('Hello#^World'), ['Hello', '^World'])
  call s:assert.equal(vimsidian#utils#LinkSetToMove('Hello|World'), ['Hello', ''])

  call s:edit_B()
  call s:assert.equal(vimsidian#utils#LinkSetToMove('#Link'), ['B', 'Link'])
  call s:assert.equal(vimsidian#utils#LinkSetToMove('#^Link'), ['B', '^Link'])
  call s:assert.equal(vimsidian#utils#LinkSetToMove('#Link String'), ['B', 'Link String'])
endfunction

function! s:suite.internal_link_header_line_numbers() abort
  call s:edit_A()
  call s:assert.equal(vimsidian#utils#InternalLinkHeaderLineNumbers(expand('%:p')), [1])
  call s:edit_B()
  call s:assert.equal(vimsidian#utils#InternalLinkHeaderLineNumbers(expand('%:p')), [13])
endfunction

function! s:suite.internal_link_block_line_numbers() abort
  call s:edit_A()
  call s:assert.equal(vimsidian#utils#InternalLinkBlockLineNumbers(expand('%:p')), [])
  call s:edit_B()
  call s:assert.equal(vimsidian#utils#InternalLinkBlockLineNumbers(expand('%:p')), [3])
endfunction

function! s:suite.internal_link_headers() abort
  call s:edit_A()
  call s:assert.equal(vimsidian#utils#InternalLinkHeaders(expand('%:p')), ['A Header'])
  call s:edit_B()
  call s:assert.equal(vimsidian#utils#InternalLinkHeaders(expand('%:p')), ['B Header'])
endfunction

function! s:suite.internal_link_blocks() abort
  call s:edit_A()
  call s:assert.equal(vimsidian#utils#InternalLinkBlocks(expand('%:p')), [])
  call s:edit_B()
  call s:assert.equal(vimsidian#utils#InternalLinkBlocks(expand('%:p')), ['^6313b0'])
endfunction

function! s:suite.internal_link_position() abort
  call s:edit_A()
  call cursor(4, 4)
  call s:assert.equal(vimsidian#utils#InternalLinkPosition(expand('%:p'), 'A Header'), [1, 1])

  call s:edit_B()
  call s:assert.equal(vimsidian#utils#InternalLinkPosition(expand('%:p'), '^6313b0'), [3, 1])

  call s:assert.equal(vimsidian#utils#InternalLinkPosition(expand('%:p'), 'B Header'), [13, 1])

  call cursor(4, 1)
  call s:assert.equal(vimsidian#utils#InternalLinkPosition(expand('%:p'), '#NOTHING'), [4, 1])
endfunction

function! s:suite.is_exists_internal_link() abort
  call s:edit_A()
  call cursor(4, 4)
  call s:assert.equal(vimsidian#utils#IsExistsInternalLink(expand('%:p'), 'A Header'), v:true)

  call s:edit_B()
  call s:assert.equal(vimsidian#utils#IsExistsInternalLink(expand('%:p'), '^6313b0'), v:true)

  call s:assert.equal(vimsidian#utils#IsExistsInternalLink(expand('%:p'), 'B Header'), v:true)

  call cursor(4, 1)
  call s:assert.equal(vimsidian#utils#IsExistsInternalLink(expand('%:p'), '#NOTHING'), 0)
endfunction

function! s:suite.previous_link_position() abort
  call s:edit_A()
  call cursor(1, 1)
  call s:assert.equal(vimsidian#utils#PreviousLinkPosition(), [7, 6])
  call cursor(5, 21)
  call s:assert.equal(vimsidian#utils#PreviousLinkPosition(), [5, 3])
  call cursor(6, 1)
  call s:assert.equal(vimsidian#utils#PreviousLinkPosition(), [5, 32])
endfunction

function! s:suite.next_link_position() abort
  call s:edit_A()
  call cursor(6, 1)
  call s:assert.equal(vimsidian#utils#NextLinkPosition(), [7, 6])
  call cursor(5, 21)
  call s:assert.equal(vimsidian#utils#NextLinkPosition(), [5, 32])
  call cursor(8, 1)
  call s:assert.equal(vimsidian#utils#NextLinkPosition(), [3, 1])
endfunction

function! s:suite.trim_link_token() abort
  call s:assert.equal(vimsidian#utils#TrimLinkToken(''), '')
  call s:assert.equal(vimsidian#utils#TrimLinkToken('[[Link]]'), 'Link')
  call s:assert.equal(vimsidian#utils#TrimLinkToken('[[[Link]]]'), 'Link')
  call s:assert.equal(vimsidian#utils#TrimLinkToken('[[[Link[Hello]]]]'), 'LinkHello')
  call s:assert.equal(vimsidian#utils#TrimLinkToken('[[Link#hello]]'), 'Link#hello')
  call s:assert.equal(vimsidian#utils#TrimLinkToken('[[Link\]]'), 'Link\')
endfunction

function! s:suite.is_broken_link() abort
  call s:edit_A()
  call s:assert.equal(vimsidian#utils#IsBrokenLink('A'), v:null)
  call s:assert.equal(vimsidian#utils#IsBrokenLink('NOTHING'), v:true)
endfunction

function! s:suite.broken_links() abort
  call s:edit_A()
  call s:assert.equal(vimsidian#utils#BrokenLinksInNote(), ['C'])

  call s:edit_B()
  call s:assert.equal(vimsidian#utils#BrokenLinksInNote(), ['#^World'])
endfunction

function! s:suite.append_number_to_line_for_list() abort
  call s:assert.equal(vimsidian#utils#AppendNumberToLineForList(''), ":1: \n")
  call s:assert.equal(vimsidian#utils#AppendNumberToLineForList("A\nB C"), "A:1: \nB C:1: \n")
endfunction

function! s:suite.link_extension() abort
  call s:assert.equal(vimsidian#utils#LinkExtension('Link'), '.md')
  call s:assert.equal(vimsidian#utils#LinkExtension('Link.png'), '')
  call s:assert.equal(vimsidian#utils#LinkExtension('Link.gif'), '')
endfunction

function! s:suite.path_join() abort
  call s:assert.equal(vimsidian#utils#PathJoin(['/a/', '//b', '/c']), '/a/b/c')
  call s:assert.equal(vimsidian#utils#PathJoin(['a', 'b', 'c']), 'a/b/c')
  call s:assert.equal(vimsidian#utils#PathJoin('a', 'b', 'c'), 'a/b/c')
endfunction

function! s:suite.camel_case() abort
  call s:assert.equal(vimsidian#utils#CamelCase(''), '')
  call s:assert.equal(vimsidian#utils#CamelCase('a b c'), 'ABC')
  call s:assert.equal(vimsidian#utils#CamelCase('[[a b c]]'), 'ABC')
  call s:assert.equal(vimsidian#utils#CamelCase('a*& %.b#| c'), 'ABC')
endfunction

function! s:suite.remove_unsuitable_link_chars() abort
  call s:assert.equal(vimsidian#utils#RemoveUnsuitableLinkChars('a b| #^c[]'), 'a b c')
endfunction

function! s:suite.local_window_variable_scoped() abort
  call s:edit_A()
  let w:vimsidian_foo = ['A']
  let Atabpagenr = tabpagenr()
  let Awinid = win_getid()

  execute 'tab split'
  if !exists('w:vimsidian_foo')
    let w:vimsidian_foo = 'NOT EXISTS'
  endif

  call s:assert.equal(w:vimsidian_foo, 'NOT EXISTS')

  execute 'tab split'
  let w:vimsidian_foo = ['B']
  call settabwinvar(tabpagenr(), win_getid(), 'vimsidian_foo', ['C'])
  call s:assert.equal(w:vimsidian_foo, ['C'])
  call s:assert.equal(gettabwinvar(Atabpagenr, Awinid, 'vimsidian_foo'), ['A'])

  call add(w:vimsidian_foo, 'D')
  call s:assert.equal(w:vimsidian_foo, ['C', 'D'])
  call s:assert.equal(gettabwinvar(Atabpagenr, Awinid, 'vimsidian_foo'), ['A'])
endfunction
