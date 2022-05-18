"" The Unlicense
""
"" This is free and unencumbered software released into the public domain.
""
"" Anyone is free to copy, modify, publish, use, compile, sell, or
"" distribute this software, either in source code form or as a compiled
"" binary, for any purpose, commercial or non-commercial, and by any
"" means.
""
"" In jurisdictions that recognize copyright laws, the author or authors
"" of this software dedicate any and all copyright interest in the
"" software to the public domain. We make this dedication for the benefit
"" of the public at large and to the detriment of our heirs and
"" successors. We intend this dedication to be an overt act of
"" relinquishment in perpetuity of all present and future rights to this
"" software under copyright law.
""
"" THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
"" EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
"" MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
"" IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
"" OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
"" ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
"" OTHER DEALINGS IN THE SOFTWARE.
""
"" For more information, please refer to <https://unlicense.org/>


"" jslint_wrapper_vim.vim
""
"" jslint wrapper for vim
""
"" 1. Save this file and "jslint.mjs" to directory "~/.vim/"
"" 2. Add vim-command ":source ~/.vim/jslint_wrapper_vim.vim" to file "~/.vimrc"
"" 3. Vim can now jslint files (via nodejs):
""    - with vim-command ":SaveAndJslint"
""    - with vim-key-combo "<Ctrl-S> <Ctrl-J>"

"" this function will save current file and jslint it (via nodejs)
function! SaveAndJslint(bang)
    "" save file
    if a:bang == "!" | write! | else | write | endif
    "" jslint file (via nodejs)
    let &l:errorformat = "%f:%n:%l:%c:%m"
    let &l:makeprg = "node \"" . $HOME . "/.vim/jslint.mjs\" jslint_wrapper_vim"
        \ . " \"" . fnamemodify(bufname("%"), ":p") . "\""
    silent make! | cwindow | redraw!
endfunction

"" create vim-command ":SaveAndJslint"
command! -nargs=* -bang SaveAndJslint call SaveAndJslint("<bang>")

"" map vim-key-combo "<ctrl-s> <ctrl-j>" to ":SaveAndJslint"
inoremap <c-s><c-j> <esc> :SaveAndJslint <cr>
nnoremap <c-s><c-j> :SaveAndJslint <cr>
