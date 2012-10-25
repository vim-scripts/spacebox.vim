" Select a block of indentation whitespace in Visual block mode based on the
" indentation of the current line.  Try it with ":SpaceBox"!
"
" Author: glts <676c7473@gmail.com>
" Date: 2012-10-25

let g:spacebox_skip_blank_lines = 1
let g:spacebox_skip_blank_lines_noindent = 0

function! s:IsBlank(line)
  return getline(a:line) =~? '^\s*$'
endfunction

" The spacebox object represents one application of the :SpaceBox command.
" Once it has been decorated with an "expansible()" function, a "skip", and a
" "width", it can be calculated and drawn via its "Draw()" method.

let s:spacebox = {}

function! s:spacebox.CalculateTop()
  let current = s:line
  let self.top = s:line
  while current >? 0
    if self.expansible(current-1)
      let self.top = current - 1
    elseif !s:IsBlank(current-1) || !self.skip
      break
    endif
    let current -= 1
  endwhile
endfunction

function! s:spacebox.CalculateBottom()
  let current = s:line
  let self.bottom = s:line
  let last = line("$")
  while current <? last
    if self.expansible(current+1)
      let self.bottom = current + 1
    elseif !s:IsBlank(current+1) || !self.skip
      break
    endif
    let current += 1
  endwhile
endfunction

function! s:spacebox.Draw()
  call self.CalculateTop()
  call self.CalculateBottom()
  exec "normal! " . self.top . "G\<C-V>" . (self.bottom-self.top+1) . "_0O" . self.width . "|"
endfunction

function! s:DecorateSpaceboxIndent()
  let s:spacebox.expansible = function("s:IsExpansibleIndent")
  let s:spacebox.skip = g:spacebox_skip_blank_lines
  let s:spacebox.width = s:indent
endfunction

function! s:DecorateSpaceboxNoindent()
  let s:spacebox.expansible = function("s:IsExpansibleNoindent")
  let s:spacebox.skip = g:spacebox_skip_blank_lines_noindent
  let s:spacebox.width = virtcol(".")
endfunction

function! s:DecorateSpaceboxBlank()
  let s:spacebox.expansible = function("s:IsExpansibleBlank")
  let s:spacebox.skip = 1
  let s:spacebox.width = 1
  let s:spacebox.cwidth = s:indent
endfunction

function! s:IsExpansibleIndent(line) dict
  return !s:IsBlank(a:line) && indent(a:line) >=? self.width
endfunction

function! s:IsExpansibleNoindent(line) dict
  return !s:IsBlank(a:line) && indent(a:line) ==? 0
endfunction

function! s:IsExpansibleBlank(line) dict
  let blank = s:IsBlank(a:line)
  if !blank
    let self.width = max([self.cwidth, self.width])
  endif
  let self.cwidth = blank ? indent(a:line) : s:indent
  return blank
endfunction

function! s:SpaceBox()
  let s:line = line(".")
  let s:indent = indent(s:line)

  normal! m`
  if !s:IsBlank(s:line)
    if s:indent >? 0
      call s:DecorateSpaceboxIndent()
    else
      call s:DecorateSpaceboxNoindent()
    endif
  else
    call s:DecorateSpaceboxBlank()
  endif
  call s:spacebox.Draw()
endfunction

command! -nargs=0 SpaceBox call s:SpaceBox()
