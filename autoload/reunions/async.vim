scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim

function! s:to_slash_path(path)
	return substitute(a:path, '\\', '/', 'g')
endfunction


function! s:make_source_command(source, vimrc)
	let file = s:to_slash_path(fnamemodify(a:source, ":p"))
" 	let vimrc = get(a:, 1, "NONE")
	let vimrc = filereadable(a:vimrc) ? s:to_slash_path(a:vimrc) : "NONE"
	let cmd = printf('vim -N -u %s -i NONE -V1 -e -s -c "source %s" -c "qall!"', vimrc, file)
	return cmd
endfunction


function! s:capture(cmd)
" 	redir => result
" 	execute a:cmd
" 	redir END
" 	return result
	let output = tempname()

	let verbosefile = &verbosefile
	let &verbosefile = output
	try
		silent execute a:cmd
	finally
		let &verbosefile = verbosefile
	endtry
	return readfile(output)[1:]
endfunction

function! Func(a, b)
	return a:a + a:b
endfunction


function! s:function(name, ...)
	let listchars = &listchars
	let &listchars = ""
	let &listchars = "tab:  "
	try
		let cap = a:0 == 0 ? s:capture("function " . a:name) : a:1
		return [substitute(substitute(cap[0], '^\s*function', 'function!', 'g'), '<SNR>\d\+_', 's:', 'g')]
\			 + map(cap[1:-2], 'matchstr(v:val, ''^\d\+\zs.*'')')
\			 + ["endfunction"]
	finally
		let &listchars   = listchars
	endtry
endfunction


function! s:make_sourcefile(funcname, args)
	let temp = tempname()
	let funcname = substitute(a:funcname, '<SNR>\d\+_', 's:', 'g')
	call writefile(
\		s:function(a:funcname)
\	  + ["echo call(".string(funcname).", ".string(a:args).")"],
\		temp
\	)
	return temp
endfunction



function! s:make_from_funcname(funcname, ...)
	let args = get(a:, 1, [])
	let sourcefile = s:make_sourcefile(a:funcname, args)
	let cmd = s:make_source_command(sourcefile, "NONE")
" 	let cmd = s:make_source_command(sourcefile, "D:/home/Dropbox/work/vim/runtime/neobundle/vim-reunions/reunions_test/test/async/vimrc")
	return reunions#process#make(cmd)
endfunction


function! s:funcref_to_string(funcref)
	return eval(matchstr(string(a:funcref), "'.\\+'"))
endfunction


function! s:make_from_funcref(funcref, ...)
	return call("s:make_from_funcname", [ s:funcref_to_string(a:funcref) ] + a:000)
endfunction

function! reunions#async#make(func, ...)
	let args = [a:func] + a:000
	return type(a:func) == type(function("tr")) ? call("s:make_from_funcref", args)
\		 : call("s:make_from_funcname", args)
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
