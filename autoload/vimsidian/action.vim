function! vimsidian#action#OpenQuickFix(lst)
  execute 'lcd' g:vimsidian_path
  cexpr a:lst | copen
endfunction

function! vimsidian#action#GetUserInput(label)
  let curline = getline('.')
  echohl VimsidianPromptColor
  call inputsave()
  let input=input(a:label . " > ")
  echohl NONE
  call inputrestore()
  call setline('.', curline)
  return input
endfunction

function! vimsidian#action#WriteFile(s, f, m)
  call writefile(a:s, a:f, a:m)
endfunction

function! vimsidian#action#System(cmd)
  return system(join(a:cmd, " "))
endfunction
