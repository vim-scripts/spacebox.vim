" Select a block of indentation whitespace in Visual block mode based on the
" indentation of the current line.  Try it with ":SpaceBox"!
"
" Author: glts <676c7473@gmail.com>
" Date: 2012-06-03

let g:spacebox_skip_blank_lines = 1
let g:spacebox_skip_blank_lines_noindent = 0

function! s:IsBlank(line)
  return match(getline(a:line), '^\s*$') != -1
endfunction

function! s:CreateTemplateParams()
  let params = {}
  let params.expand = function("s:ExpandCondition")
  let params.skip = g:spacebox_skip_blank_lines
  let params.width = s:indent
  return params
endfunction

function! s:CreateTemplateParamsNoindent()
  let params = {}
  let params.expand = function("s:ExpandConditionNoindent")
  let params.skip = g:spacebox_skip_blank_lines_noindent
  let params.width = virtcol(".")
  return params
endfunction

function! s:ExpandCondition(line)
  return indent(a:line) >= s:indent
endfunction

function! s:ExpandConditionNoindent(line)
  return indent(a:line) ==? 0
endfunction

function! s:CalculateTop(expand, skip)
  let current = s:line
  let top = s:line
  while current > 0
    if !s:IsBlank(current-1)
      if a:expand(current-1)
        let top = current - 1
      else
        break
      endif
    elseif !a:skip
      break
    endif
    let current -= 1
  endwhile
  return top
endfunction

function! s:CalculateBottom(expand, skip)
  let current = s:line
  let bottom = s:line
  let last = line("$")
  while current < last
    if !s:IsBlank(current+1)
      if a:expand(current+1)
        let bottom = current + 1
      else
        break
      endif
    elseif !a:skip
      break
    endif
    let current += 1
  endwhile
  return bottom
endfunction

function! s:MakeSpaceBox(params)
  let bottom = s:CalculateBottom(a:params.expand, a:params.skip)
  let top = s:CalculateTop(a:params.expand, a:params.skip)
  let width = a:params.width

  call cursor(top, 1)
  let linespan = bottom - top
  if linespan == 0
    exec "normal! \<C-V>" . width . "|"
  else
    exec "normal! \<C-V>" . linespan . "j" . width . "|"
  endif
endfunction

function! s:SpaceBox()
  let s:line = line(".")
  let s:indent = indent(s:line)

  if !s:IsBlank(s:line)
    normal! m`
    if s:indent > 0
      let params = s:CreateTemplateParams()
    else
      let params = s:CreateTemplateParamsNoindent()
    endif
    call s:MakeSpaceBox(params)
  endif
endfunction

command! -nargs=0 SpaceBox call s:SpaceBox()
