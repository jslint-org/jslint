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
