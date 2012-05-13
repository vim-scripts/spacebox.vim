" Select a block of indentation whitespace in Visual block mode based on
" the indentation of the current line.  Try it with ":SpaceBox"!
"
" Author: glts <676c7473@gmail.com>
" Date: 2012-05-13

function! s:is_blank(line)
  return match(getline(a:line), '^\s*$') != -1
endfunction

function! s:top_line()
  let l:curr = s:line
  let l:top = l:curr
  while l:curr > 0
    if indent(l:curr-1) >= s:indent
      let l:top = l:curr - 1
    elseif !s:is_blank(l:curr-1)
      break
    endif
    let l:curr = l:curr - 1
  endwhile
  return l:top
endfunction

function! s:bottom_line()
  let l:curr = s:line
  let l:bottom = l:curr
  let l:last = line("$")
  while l:curr < l:last
    if indent(l:curr+1) >= s:indent
      let l:bottom = l:curr + 1
    elseif !s:is_blank(l:curr+1)
      break
    endif
    let l:curr = l:curr + 1
  endwhile
  return l:bottom
endfunction

function! s:top_line_noindent()
  let l:top = s:line
  while l:top > 0
    if indent(l:top-1) > 0 || s:is_blank(l:top-1)
      break
    endif
    let l:top = l:top - 1
  endwhile
  return l:top
endfunction

function! s:bottom_line_noindent()
  let l:bottom = s:line
  let l:last = line("$")
  while l:bottom < l:last
    if indent(l:bottom+1) > 0 || s:is_blank(l:bottom+1)
      break
    endif
    let l:bottom = l:bottom + 1
  endwhile
  return l:bottom
endfunction

function! s:visual_box(top, bottom, width)
  call cursor(a:top, 1)
  let l:linespan = a:bottom - a:top
  if l:linespan == 0
    exec "normal! \<C-V>" . a:width . "|"
  else
    exec "normal! \<C-V>" . l:linespan . "j" . a:width . "|"
  endif
endfunction

function! s:spacebox()
  let s:line = line(".")
  let s:indent = indent(s:line)
  let s:col = col(".")

  if !s:is_blank(s:line)
    if s:indent > 0
      let l:top = s:top_line()
      let l:bottom = s:bottom_line()
      call s:visual_box(l:top, l:bottom, s:indent)
    else
      let l:top = s:top_line_noindent()
      let l:bottom = s:bottom_line_noindent()
      call s:visual_box(l:top, l:bottom, s:col)
    endif
  endif
endfunction

command! SpaceBox call s:spacebox()
