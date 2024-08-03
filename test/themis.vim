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
  call s:assert.equal(vimsidian#unit#CursorTag(), v:null)
endfunction

function! s:suite.link_line_numbers() abort
  call s:edit_A()
  call s:assert.equal(vimsidian#unit#LinkLineNumbers(expand('%:p')), [3, 5, 7])

  call s:edit_B()
  call s:assert.equal(vimsidian#unit#LinkLineNumbers(expand('%:p')), [5, 7, 9, 11])
endfunction

function! s:suite.links_in_this_note() abort
  call s:edit_A()
  call s:assert.equal(vimsidian#unit#LinksInNote(), ['#A Header', 'B', 'B#^6313b0', 'C'])

  call s:edit_B()
  call s:assert.equal(vimsidian#unit#LinksInNote(), ['#^World', 'Hello', 'Vimsidian|GJ'])
endfunction

function! s:suite.note_names_in_note() abort
  call s:edit_A()
  call s:assert.equal(vimsidian#unit#NoteNamesInNote(), ['B', 'C'])

  call s:edit_B()
  call s:assert.equal(vimsidian#unit#NoteNamesInNote(), ['Hello', 'Vimsidian'])
endfunction

function! s:suite.cursor_link() abort
  call s:edit_A()
  call cursor(2, 1)
  call s:assert.equal(vimsidian#unit#CursorLink(), v:null)

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
  call s:assert.equal(vimsidian#unit#LinkSetToMove('#Link String'), ['B', 'Link String'])
endfunction

function! s:suite.internal_link_header_line_numbers() abort
  call s:edit_A()
  call s:assert.equal(vimsidian#unit#InternalLinkHeaderLineNumbers(expand('%:p')), [1])
  call s:edit_B()
  call s:assert.equal(vimsidian#unit#InternalLinkHeaderLineNumbers(expand('%:p')), [13])
endfunction

function! s:suite.internal_link_block_line_numbers() abort
  call s:edit_A()
  call s:assert.equal(vimsidian#unit#InternalLinkBlockLineNumbers(expand('%:p')), [])
  call s:edit_B()
  call s:assert.equal(vimsidian#unit#InternalLinkBlockLineNumbers(expand('%:p')), [3])
endfunction

function! s:suite.internal_link_headers() abort
  call s:edit_A()
  call s:assert.equal(vimsidian#unit#InternalLinkHeaders(expand('%:p')), ['A Header'])
  call s:edit_B()
  call s:assert.equal(vimsidian#unit#InternalLinkHeaders(expand('%:p')), ['B Header'])
endfunction

function! s:suite.internal_link_blocks() abort
  call s:edit_A()
  call s:assert.equal(vimsidian#unit#InternalLinkBlocks(expand('%:p')), [])
  call s:edit_B()
  call s:assert.equal(vimsidian#unit#InternalLinkBlocks(expand('%:p')), ['^6313b0'])
endfunction

function! s:suite.internal_link_position() abort
  call s:edit_A()
  call cursor(4, 4)
  call s:assert.equal(vimsidian#unit#InternalLinkPosition(expand('%:p'), 'A Header'), [1, 1])

  call s:edit_B()
  call s:assert.equal(vimsidian#unit#InternalLinkPosition(expand('%:p'), '^6313b0'), [3, 1])

  call s:assert.equal(vimsidian#unit#InternalLinkPosition(expand('%:p'), 'B Header'), [13, 1])

  call cursor(4, 1)
  call s:assert.equal(vimsidian#unit#InternalLinkPosition(expand('%:p'), '#NOTHING'), [4, 1])
endfunction

function! s:suite.is_exists_internal_link() abort
  call s:edit_A()
  call cursor(4, 4)
  call s:assert.equal(vimsidian#unit#IsExistsInternalLink(expand('%:p'), 'A Header'), v:true)

  call s:edit_B()
  call s:assert.equal(vimsidian#unit#IsExistsInternalLink(expand('%:p'), '^6313b0'), v:true)

  call s:assert.equal(vimsidian#unit#IsExistsInternalLink(expand('%:p'), 'B Header'), v:true)

  call cursor(4, 1)
  call s:assert.equal(vimsidian#unit#IsExistsInternalLink(expand('%:p'), '#NOTHING'), 0)
endfunction

function! s:suite.previous_link_position() abort
  call s:edit_A()
  call cursor(1, 1)
  call s:assert.equal(vimsidian#unit#PreviousLinkPosition(), [7, 6])
  call cursor(5, 21)
  call s:assert.equal(vimsidian#unit#PreviousLinkPosition(), [5, 3])
  call cursor(6, 1)
  call s:assert.equal(vimsidian#unit#PreviousLinkPosition(), [5, 32])
endfunction

function! s:suite.next_link_position() abort
  call s:edit_A()
  call cursor(6, 1)
  call s:assert.equal(vimsidian#unit#NextLinkPosition(), [7, 6])
  call cursor(5, 21)
  call s:assert.equal(vimsidian#unit#NextLinkPosition(), [5, 32])
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
  call s:assert.equal(vimsidian#unit#RgNotes('[[B]]'), [$VIMSIDIAN_TEST_PATH . '/A.md'])
  call s:assert.equal(vimsidian#unit#RgNotes('[[A]]'), [$VIMSIDIAN_TEST_PATH . '/sub/Vimsidian.md'])
endfunction

function! s:suite.fd_note() abort
  call s:assert.equal(vimsidian#unit#FdNote('A.md'), $VIMSIDIAN_TEST_PATH . '/A.md')
  call s:assert.equal(vimsidian#unit#FdNote('B.md'), $VIMSIDIAN_TEST_PATH . '/sub/B.md')
endfunction

 function! s:suite.fd_notes() abort
   call s:edit_A()
   call s:assert.equal(vimsidian#unit#FdNotes(vimsidian#unit#NoteNamesInNote()), [$VIMSIDIAN_TEST_PATH . '/sub/B.md'])

   call s:edit_B()
   call s:assert.equal(vimsidian#unit#FdNotes(vimsidian#unit#NoteNamesInNote()), [$VIMSIDIAN_TEST_PATH . '/Hello.md', $VIMSIDIAN_TEST_PATH . '/sub/Vimsidian.md'])
endfunction

function! s:suite.is_broken_link() abort
  call s:edit_A()
  call s:assert.equal(vimsidian#unit#IsBrokenLink('A'), v:null)
  call s:assert.equal(vimsidian#unit#IsBrokenLink('NOTHING'), v:true)
endfunction

function! s:suite.broken_links() abort
  call s:edit_A()
  call s:assert.equal(vimsidian#unit#BrokenLinksInNote(), ['C'])

  call s:edit_B()
  call s:assert.equal(vimsidian#unit#BrokenLinksInNote(), ['#^World'])
endfunction

function! s:suite.append_number_to_line_for_list() abort
  call s:assert.equal(vimsidian#unit#AppendNumberToLineForList(''), ":1: \n")
  call s:assert.equal(vimsidian#unit#AppendNumberToLineForList("A\nB C"), "A:1: \nB C:1: \n")
endfunction

function! s:suite.link_extension() abort
  call s:assert.equal(vimsidian#unit#LinkExtension('Link'), '.md')
  call s:assert.equal(vimsidian#unit#LinkExtension('Link.png'), '')
  call s:assert.equal(vimsidian#unit#LinkExtension('Link.gif'), '')
endfunction

function! s:suite.path_join() abort
  call s:assert.equal(vimsidian#util#PathJoin(['/a/', '//b', '/c']), '/a/b/c')
  call s:assert.equal(vimsidian#util#PathJoin(['a', 'b', 'c']), 'a/b/c')
  call s:assert.equal(vimsidian#util#PathJoin('a', 'b', 'c'), 'a/b/c')
endfunction

function! s:suite.camel_case() abort
  call s:assert.equal(vimsidian#util#CamelCase(''), '')
  call s:assert.equal(vimsidian#util#CamelCase('a b c'), 'ABC')
  call s:assert.equal(vimsidian#util#CamelCase('[[a b c]]'), 'ABC')
  call s:assert.equal(vimsidian#util#CamelCase('a*& %.b#| c'), 'ABC')
endfunction

function! s:suite.remove_unsuitable_link_chars() abort
  call s:assert.equal(vimsidian#unit#RemoveUnsuitableLinkChars('a b| #^c[]'), 'a b c')
endfunction

function! s:suite.link_stack_push() abort
  call s:assert.equal(vimsidian#linkStack#Push('string'), v:null)

  let w:vimsidian_link_stack = []
  let s:v1 = {'path': 'path', 'line': 3, 'col': 5}
  let s:v2 = {'path': 'pathhh', 'line': 1, 'col': 2}
  call s:assert.equal(vimsidian#linkStack#Push(s:v1), [s:v1])
  call s:assert.equal(vimsidian#linkStack#Push(s:v1), [s:v1])
  call s:assert.equal(vimsidian#linkStack#Push(s:v1), w:vimsidian_link_stack)
  call s:assert.equal(vimsidian#linkStack#Push(s:v2), [s:v1, s:v2])
  call s:assert.equal(vimsidian#linkStack#Push(s:v1), [s:v1, s:v2, s:v1])
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

function! s:suite.link_stack_winnew() abort
  call s:edit_A()
  let Atabpagenr = tabpagenr()
  let Awinid = win_getid()
  let s:v1 = {'path': 'path', 'line': 3, 'col': 5}
  let w:vimsidian_link_stack = [s:v1]

  execute 'tab split'
  let A1tabpagenr = win_getid()
  let A1winid = win_getid()
  call s:assert.not_equal(Awinid, A1winid)
  call s:assert.not_equal(Atabpagenr, A1tabpagenr)

  call cursor(3, 1)
  let [line, col] = vimsidian#unit#CursorLinkPosition()
  let v = { 'path': expand('%:p'), 'line': line, 'col': col }
  call vimsidian#linkStack#Push(v)
  call s:assert.equal(w:vimsidian_link_stack, [s:v1, v])

  call s:assert.equal(gettabwinvar(Atabpagenr, Awinid, 'vimsidian_link_stack'), [s:v1])
endfunction

function! s:suite.link_top_curidx() abort
  let w:vimsidian_link_stack = []
  call vimsidian#linkStack#TopCuridx()
  call s:assert.equal(w:vimsidian_link_stack_curidx, -1)

  let s:v1 = {'path': 'path', 'line': 3, 'col': 5}
  let w:vimsidian_link_stack = [s:v1]

  call vimsidian#linkStack#TopCuridx()
  call s:assert.equal(w:vimsidian_link_stack_curidx, 0)

  let w:vimsidian_link_stack = [s:v1, s:v1, s:v1, s:v1]
  call vimsidian#linkStack#TopCuridx()
  call s:assert.equal(w:vimsidian_link_stack_curidx, 3)
endfunction

function! s:suite.link_stack_pop_to_curidx() abort
  let s:v1 = {'path': 'path', 'line': 3, 'col': 5}
  let w:vimsidian_link_stack = [s:v1, s:v1, s:v1]
  let w:vimsidian_link_stack_curidx = 1

  call vimsidian#linkStack#PopToCuridx()
  call s:assert.equal(w:vimsidian_link_stack, [s:v1, s:v1])

  let w:vimsidian_link_stack_curidx = 0
  call vimsidian#linkStack#PopToCuridx()
  call s:assert.equal(w:vimsidian_link_stack, [s:v1])
endfunction

function! s:suite.link_stack_previous_entry() abort
  let s:v0 = {'path': 'path', 'line': 0, 'col': 0}
  let s:v1 = {'path': 'path', 'line': 1, 'col': 1}
  let s:v2 = {'path': 'path', 'line': 2, 'col': 2}

  let w:vimsidian_link_stack = []
  let w:vimsidian_link_stack_curidx = -1
  call s:assert.equal(vimsidian#linkStack#PreviousEntry(), v:null)

  let w:vimsidian_link_stack = [s:v0]
  let w:vimsidian_link_stack_curidx = 0
  call s:assert.equal(vimsidian#linkStack#PreviousEntry(), s:v0)

  let w:vimsidian_link_stack = [s:v0]
  let w:vimsidian_link_stack_curidx = 0
  call s:assert.equal(vimsidian#linkStack#PreviousEntry(), s:v0)

  let w:vimsidian_link_stack_curidx = -1
  call s:assert.equal(vimsidian#linkStack#PreviousEntry(), v:null)

  let w:vimsidian_link_stack = [s:v0, s:v1]
  let w:vimsidian_link_stack_curidx = 1
  call s:assert.equal(vimsidian#linkStack#PreviousEntry(), s:v1)

  let w:vimsidian_link_stack = [s:v0, s:v1, s:v2]
  let w:vimsidian_link_stack_curidx = 2
  call s:assert.equal(vimsidian#linkStack#PreviousEntry(), s:v2)

  let w:vimsidian_link_stack_curidx = 1
  call s:assert.equal(vimsidian#linkStack#PreviousEntry(), s:v1)

  let w:vimsidian_link_stack_curidx = 0
  call s:assert.equal(vimsidian#linkStack#PreviousEntry(), s:v0)

  let w:vimsidian_link_stack_curidx = -1
  call s:assert.equal(vimsidian#linkStack#PreviousEntry(), v:null)
endfunction

function! s:suite.link_stack_next_entry() abort
  let s:v0 = {'path': 'path', 'line': 0, 'col': 0}
  let s:v1 = {'path': 'path', 'line': 1, 'col': 1}
  let s:v2 = {'path': 'path', 'line': 2, 'col': 2}

  let w:vimsidian_link_stack = []
  let w:vimsidian_link_stack_curidx = -1
  call s:assert.equal(vimsidian#linkStack#NextEntry(), v:null)

  let w:vimsidian_link_stack = [s:v0]
  let w:vimsidian_link_stack_curidx = -1
  call s:assert.equal(vimsidian#linkStack#NextEntry(), s:v0)

  let w:vimsidian_link_stack_curidx = 0
  call s:assert.equal(vimsidian#linkStack#NextEntry(), v:null)

  let w:vimsidian_link_stack = [s:v0, s:v1]
  let w:vimsidian_link_stack_curidx = -1
  call s:assert.equal(vimsidian#linkStack#NextEntry(), s:v0)

  let w:vimsidian_link_stack_curidx = 0
  call s:assert.equal(vimsidian#linkStack#NextEntry(), s:v1)

  let w:vimsidian_link_stack_curidx = 1
  call s:assert.equal(vimsidian#linkStack#NextEntry(), v:null)

  let w:vimsidian_link_stack = [s:v0, s:v1, s:v2]
  let w:vimsidian_link_stack_curidx = -1
  call s:assert.equal(vimsidian#linkStack#NextEntry(), s:v0)

  let w:vimsidian_link_stack_curidx = 0
  call s:assert.equal(vimsidian#linkStack#NextEntry(), s:v1)

  let w:vimsidian_link_stack_curidx = 1
  call s:assert.equal(vimsidian#linkStack#NextEntry(), s:v2)

  let w:vimsidian_link_stack_curidx = 2
  call s:assert.equal(vimsidian#linkStack#NextEntry(), v:null)
endfunction
