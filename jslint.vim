"" jslint.vim
""
"" jslint-plugin for vim
""
"" 1. save this file to directory ~/.vim/
"" 2. save file jslint.mjs to directory ~/.vim/
"" 3. add vim command ":source ~/.vim/jslint.vim" to file ~/.vimrc
"" 4. you can now jslint files (via nodejs) with command ":JslintFileAfterSave"
"" 5. you can now jslint files (via nodejs) with key-combo "<ctrl-s> <ctrl-j>"

"" this function will jslint the file of current buffer after saving it
function! JslintFileAfterSave(bang)
    "" save file
    if a:bang == "!" | write! | else | write | endif
    "" jslint file
    let &l:errorformat = "%f:%n:%l:%c:%m"
    let &l:makeprg = " node"
	\ . " \"" . $HOME . "/.vim/jslint.mjs\""
        \ . " \"" . fnamemodify(bufname("%"), ":p") . "\""
        \ . " --mode-vim-plugin"
    silent make! | cwindow | redraw!
endfunction

"" create vim command ":JslintFileAfterSave"
command! -nargs=* -bang JslintFileAfterSave call JslintFileAfterSave("<bang>")

"" map vim key-combo "<ctrl-s> <ctrl-j>" to :JslintFileAfterSave
nnoremap <silent> <c-s><c-j> :JslintFileAfterSave <cr>
