"============================================================================
" File:         syntastic-use-node-bin.vim
" Description:  Plugin which extends Syntastic to use checker executables in
"               node_modules/.bin.
" Maintainer:	Kevin Locke <kevin@kevinlocke.name>
" Repository:	https://github.com/kevinoid/syntastic-use-node-bin
" License:      This program is free software. It comes without any warranty,
"               to the extent permitted by applicable law. You can redistribute
"               it and/or modify it under the terms of the Do What The Fuck You
"               Want To Public License, Version 2, as published by Sam Hocevar.
"               See http://sam.zoy.org/wtfpl/COPYING for more details.
" Last Change:	20 January 2019
"============================================================================

if exists('g:loaded_syntastic_use_node_bin')
    finish
endif
let g:loaded_syntastic_use_node_bin = 1

let s:save_cpo = &cpo
set cpo&vim

" For each checker matching a:ftalias and a:hints_list, if its executable is
" present in node_modules/.bin above a:path, set
" b:syntastic_{ftalias}_{name}_exec to use it.
function! SyntasticUseNodeBin(ftalias, hints_list, path) abort " {{{
    call syntastic#log#debug(
        \ g:_SYNTASTIC_DEBUG_CHECKERS,
        \ 'SyntasticUseNodeBin: Resolving ' . a:ftalias . ' checkers in node_modules/.bin')

    let registry = g:SyntasticRegistry.Instance()
    let node_modules_dirs = finddir('node_modules', a:path . ';', -1)

    for checker in registry.getCheckers(a:ftalias, a:hints_list)
        call checker.syncExec()
        let checker_exec = checker.getExec()

        if stridx(checker_exec, '/') != -1
            \ || (stridx(checker_exec, '\') != -1 && has('win32'))
            " User has configured _exec with a path.  Respect user config.
            call syntastic#log#debug(
                \ g:_SYNTASTIC_DEBUG_CHECKERS,
                \ 'SyntasticUseNodeBin: Skipping ' . checker.getCName()
                \ . ': _exec is a path (' . checker_exec . ')')
            continue
        endif

        for node_modules in node_modules_dirs
            let checker_path = node_modules . '/.bin/' . checker_exec
            if executable(checker_path)
                let cname = checker.getCName()
                let names = split(cname, '/')
                call syntastic#log#debug(
                    \ g:_SYNTASTIC_DEBUG_CHECKERS,
                    \ 'SyntasticUseNodeBin: Found ' . cname . ' in: '
                    \ . checker_path)
                call setbufvar(
                    \ '%',
                    \ 'syntastic_' . names[0] . '_' . names[1] . '_exec',
                    \ checker_path)
                call checker.syncExec()
                break
            endif
        endfor
    endfor
endfunction " }}}

if get(g:, 'syntastic_use_node_bin', 1)
    augroup syntasticUseNodeBin
        autocmd!

        autocmd FileType javascript call SyntasticUseNodeBin(&filetype, [], '.')
        autocmd FileType typescript call SyntasticUseNodeBin(&filetype, [], '.')
    augroup END
endif

let &cpo = s:save_cpo
unlet s:save_cpo
