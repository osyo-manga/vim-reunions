scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim

let g:reunions_async_default_vimrc = get(g:, "g:reunions_async_default_vimrc", "NONE")

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
\	  + ["let result = call(".string(funcname).", ".string(a:args).")"]
\	  + ["echo type(result) == type('') ? string(result) : result"],
\		temp
\	)
	return temp
endfunction



function! s:make_from_funcname(funcname, ...)
	let args = get(a:, 1, [])
	let sourcefile = s:make_sourcefile(a:funcname, args)
	let cmd = s:make_source_command(sourcefile, g:reunions_async_default_vimrc)
" 	return reunions#process#make(cmd)
	let process = reunions#process#make(cmd)
	let async = {
\		"__reunions" : {
\			"async" : {
\				"process" : process,
\			}
\		}
\	}
	let process.__reunions.async  = async
	function! process.then(result)
		return self.__reunions.async.then(eval(a:result))
	endfunction

	function! async.apply(id)
		return self.__reunions.async.process.apply(a:id)
	endfunction

	function! async.kill()
		return self.__reunions.async.process.kill()
	endfunction

	function! async.wait(...)
		let process = self.__reunions.async.process
		return call(process.wait, a:000, process)
	endfunction

	return async
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
