function! vimsidian#action#OpenQuickFix(lst) abort
  execute 'lcd' g:vimsidian_path
  cexpr a:lst | copen
endfunction

function! vimsidian#action#GetUserInput(label) abort
  let curline = getline('.')
  echohl VimsidianPromptColor
  call inputsave()
  let input=input(a:label . ' > ')
  echohl NONE
  call inputrestore()
  call setline('.', curline)
  return input
endfunction

function! vimsidian#action#OpenFile(opener, file) abort
  execute join([a:opener,  a:file], ' ')
endfunction

function! vimsidian#action#WriteFile(s, f, m) abort
  call writefile(a:s, a:f, a:m)
endfunction

function! vimsidian#action#System(cmd) abort
  return system(join(a:cmd, ' '))
endfunction
