let s:suite = themis#suite('vimsidian')
let s:assert = themis#helper('assert')

if empty($VIMSIDIAN_TEST_PATH)
  let g:vimsidian_path = $VIMSIDIAN_TEST_PATH
  echoerr '$VIMSIDIAN_TEST_PATH is empty'
endif

if empty(glob($VIMSIDIAN_TEST_PATH))
  echoerr '$VIMSIDIAN_TEST_PATH: ' . $VIMSIDIAN_TEST_PATH . ' is does not exists'
endif

function! s:edit_A() abort
  execute 'e ' . $VIMSIDIAN_TEST_PATH . '/A.md'
endfunction

function! s:edit_B() abort
  execute 'e ' . $VIMSIDIAN_TEST_PATH . '/sub/B.md'
endfunction

function! s:suite.cursor_tag() abort
  call s:edit_A()
  call cursor(9, 1)
  call s:assert.equal(vimsidian#unit#CursorTag(), '#foo')
  call cursor(1, 1)
  call s:assert.equal(vimsidian#unit#CursorTag(), 1)
endfunction

function! s:suite.links_in_this_note() abort
  call s:edit_A()
  call s:assert.equal(vimsidian#unit#LinksInThisNote(), ['B'])

  call s:edit_B()
  call s:assert.equal(vimsidian#unit#LinksInThisNote(), ['Hello', 'Vimsidian'])
endfunction

function! s:suite.cursor_link() abort
  call s:edit_A()
  call cursor(2, 1)
  call s:assert.equal(vimsidian#unit#CursorLink(), 1)
  call cursor(5, 4)
  call s:assert.equal(vimsidian#unit#CursorLink(), 'B#^6313b0')
  call cursor(7, 7)
  call s:assert.equal(vimsidian#unit#CursorLink(), '#A Header')

  call s:edit_B()
  call cursor(5, 1)
  call s:assert.equal(vimsidian#unit#CursorLink(), 'Hello')
  call cursor(9, 1)
  call s:assert.equal(vimsidian#unit#CursorLink(), '#^World')
  call cursor(11, 1)
  call s:assert.equal(vimsidian#unit#CursorLink(), 'Vimsidian|GJ')
endfunction

function! s:suite.link_set_to_move() abort
  call s:edit_A()
  call s:assert.equal(vimsidian#unit#LinkSetToMove(''), ['', ''])
  call s:assert.equal(vimsidian#unit#LinkSetToMove('Link'), ['Link', ''])
  call s:assert.equal(vimsidian#unit#LinkSetToMove('#Link'), ['A', 'Link'])
  call s:assert.equal(vimsidian#unit#LinkSetToMove('#^Link'), ['A', '^Link'])
  call s:assert.equal(vimsidian#unit#LinkSetToMove('Hello#World'), ['Hello', 'World'])
  call s:assert.equal(vimsidian#unit#LinkSetToMove('Hello#^World'), ['Hello', '^World'])
  call s:assert.equal(vimsidian#unit#LinkSetToMove('Hello|World'), ['Hello', ''])

  call s:edit_B()
  call s:assert.equal(vimsidian#unit#LinkSetToMove('#Link'), ['B', 'Link'])
  call s:assert.equal(vimsidian#unit#LinkSetToMove('#^Link'), ['B', '^Link'])
endfunction

function! s:suite.internal_link_position() abort
  call s:edit_A()
  call s:assert.equal(vimsidian#unit#InternalLinkPosition('A Header'), [1, 1])

  call s:edit_B()
  call s:assert.equal(vimsidian#unit#InternalLinkPosition('^6313b0'), [3, 1])

  call cursor(2, 1)
  call s:assert.equal(vimsidian#unit#InternalLinkPosition('#NOTHING'), [2, 1])
endfunction

function! s:suite.previous_link_position() abort
  call s:edit_A()
  call cursor(1, 1)
  call s:assert.equal(vimsidian#unit#PreviousLinkPosition(), [7, 6])
  call cursor(6, 1)
  call s:assert.equal(vimsidian#unit#PreviousLinkPosition(), [5, 3])
endfunction

function! s:suite.next_link_position() abort
  call s:edit_A()
  call cursor(6, 1)
  call s:assert.equal(vimsidian#unit#NextLinkPosition(), [7, 6])
  call cursor(8, 1)
  call s:assert.equal(vimsidian#unit#NextLinkPosition(), [3, 1])
endfunction

function! s:suite.trim_link_token() abort
  call s:assert.equal(vimsidian#unit#TrimLinkToken(''), '')
  call s:assert.equal(vimsidian#unit#TrimLinkToken('[[Link]]'), 'Link')
  call s:assert.equal(vimsidian#unit#TrimLinkToken('[[[Link]]]'), 'Link')
  call s:assert.equal(vimsidian#unit#TrimLinkToken('[[[Link[Hello]]]]'), 'LinkHello')
  call s:assert.equal(vimsidian#unit#TrimLinkToken('[[Link#hello]]'), 'Link#hello')
  call s:assert.equal(vimsidian#unit#TrimLinkToken('[[Link\]]'), 'Link\')
endfunction

function! s:suite.rg_notes() abort
  call s:assert.equal(vimsidian#unit#RgNotes('[[B]]'), $VIMSIDIAN_TEST_PATH . "/A.md\n")
  call s:assert.equal(vimsidian#unit#RgNotes('[[A]]'), $VIMSIDIAN_TEST_PATH . "/sub/Vimsidian.md\n")
endfunction

function! s:suite.fd_note() abort
  call s:assert.equal(vimsidian#unit#FdNote('A.md'), $VIMSIDIAN_TEST_PATH . "/A.md\n")
  call s:assert.equal(vimsidian#unit#FdNote('B.md'), $VIMSIDIAN_TEST_PATH . "/sub/B.md\n")
endfunction

function! s:suite.fd_notes() abort
  call s:edit_A()
  call s:assert.equal(vimsidian#unit#FdNotes(vimsidian#unit#LinksInThisNote()), $VIMSIDIAN_TEST_PATH . "/sub/B.md\n")

  call s:edit_B()
  call s:assert.equal(vimsidian#unit#FdNotes(vimsidian#unit#LinksInThisNote()), $VIMSIDIAN_TEST_PATH . "/Hello.md\n" . $VIMSIDIAN_TEST_PATH . "/sub/Vimsidian.md\n")
endfunction

function! s:suite.append_number_to_line_for_list() abort
  call s:assert.equal(vimsidian#unit#AppendNumberToLineForList("\n"), ":1: \n")
  call s:assert.equal(vimsidian#unit#AppendNumberToLineForList("A\nB C\n"), "A:1: \nB C:1: \n")
endfunction

function! s:suite.link_extension() abort
  call s:assert.equal(vimsidian#unit#LinkExtension('Link'), '.md')
  call s:assert.equal(vimsidian#unit#LinkExtension('Link.png'), '')
  call s:assert.equal(vimsidian#unit#LinkExtension('Link.gif'), '')
endfunction

function! s:suite.format_link_string() abort
  call s:assert.equal(vimsidian#unit#FormatLinkString('a[[b]]'), 'a [[b]]')
  call s:assert.equal(vimsidian#unit#FormatLinkString('a,[[b]]'), 'a, [[b]]')
  call s:assert.equal(vimsidian#unit#FormatLinkString('([[b]]'), '([[b]]')
  call s:assert.equal(vimsidian#unit#FormatLinkString('[[a]]is'), '[[a]] is')
  call s:assert.equal(vimsidian#unit#FormatLinkString('[[a]],'), '[[a]],')
  call s:assert.equal(vimsidian#unit#FormatLinkString('[[a]].'), '[[a]].')
  call s:assert.equal(vimsidian#unit#FormatLinkString('![[a]]'), '![[a]]')
  call s:assert.equal(vimsidian#unit#FormatLinkString('    [[a]]'), '    [[a]]')
  call s:assert.equal(vimsidian#unit#FormatLinkString('b    [[a]]'), 'b [[a]]')
  call s:assert.equal(vimsidian#unit#FormatLinkString(',               [[a]]'), ', [[a]]')
endfunction

function! s:suite.format_link_string() abort
  call s:assert.equal(vimsidian#util#PathJoin(['/a/', '//b', '/c']), '/a/b/c')
  call s:assert.equal(vimsidian#util#PathJoin(['a', 'b', 'c']), 'a/b/c')
  call s:assert.equal(vimsidian#util#PathJoin('a', 'b', 'c'), 'a/b/c')
endfunction
