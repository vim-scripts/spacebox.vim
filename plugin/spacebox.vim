" Select a block of indentation whitespace in Visual block mode based on the
" indentation of the current line.  Try it with ":SpaceBox"!
"
" Author: glts <676c7473@gmail.com>
" Date: 2012-05-24

let g:spacebox_skip_blank_lines = 1
let g:spacebox_skip_blank_lines_noindent = 0

function! s:IsBlank(line)
  return match(getline(a:line), '^\s*$') != -1
endfunction

function! s:CreateTemplateParams()
  let params = {}
  let params.expandtop = function("s:ExpandTopCondition")
  let params.expandbottom = function("s:ExpandBottomCondition")
  let params.skip = g:spacebox_skip_blank_lines
  let params.width = s:indent
  return params
endfunction

function! s:CreateTemplateParamsNoindent()
  let params = {}
  let params.expandtop = function("s:ExpandTopConditionNoindent")
  let params.expandbottom = function("s:ExpandBottomConditionNoindent")
  let params.skip = g:spacebox_skip_blank_lines_noindent
  let params.width = col(".")
  return params
endfunction

function! s:ExpandTopCondition(current)
  return indent(a:current-1) >= s:indent
endfunction

function! s:ExpandBottomCondition(current)
  return indent(a:current+1) >= s:indent
endfunction

function! s:ExpandTopConditionNoindent(current)
  return indent(a:current-1) ==? 0
endfunction

function! s:ExpandBottomConditionNoindent(current)
  return indent(a:current+1) ==? 0
endfunction

function! s:CalculateTop(expand, skip)
  let current = s:line
  let top = s:line
  while current > 0
    if !s:IsBlank(current-1)
      if a:expand(current)
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
      if a:expand(current)
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
  let bottom = s:CalculateBottom(a:params.expandbottom, a:params.skip)
  let top = s:CalculateTop(a:params.expandtop, a:params.skip)
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
    if s:indent > 0
      let params = s:CreateTemplateParams()
    else
      let params = s:CreateTemplateParamsNoindent()
    endif
    call s:MakeSpaceBox(params)
  endif
endfunction

command! -nargs=0 SpaceBox call s:SpaceBox()
