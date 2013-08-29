scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim

silent! let g:reunions#process#status_ready = 1
lockvar! g:reunions#process#status_ready

silent! let g:reunions#process#status_timeout = 2
lockvar! g:reunions#process#status_timeout


let s:process = {
\	"__reunions" : {
\		"process" : {
\			"result"  : "",
\		}
\	}
\}

function! s:process.__reunions.process.update()
	let vimproc = self.vimproc
	if !vimproc.stdout.eof
		let self.result .= vimproc.stdout.read()
	endif

	if !vimproc.stderr.eof
		let self.result .= vimproc.stderr.read()
	endif
	let self.result = substitute(self.result, "\r\n", "\n", "g")
endfunction


function! s:process.apply()
	let process = self.__reunions.process
	let vimproc = process.vimproc
	try
		call process.update()
		if !self.is_exit()
			return
		endif
	catch
		call self.kill()
	endtry

	if has_key(self, "then")
		call self.then(process.result)
	endif

	call self.kill()
endfunction


function! s:process.kill()
	let vimproc = self.__reunions.process.vimproc
	call vimproc.stdout.close()
	call vimproc.stderr.close()
	call vimproc.waitpid()
endfunction


function! s:process.is_exit()
	let vimproc = self.__reunions.process.vimproc
	return vimproc.stdout.eof || vimproc.stderr.eof
endfunction


function! s:process.log()
	return self.__reunions.process.result
endfunction

function! s:process.wait_for(timeout)
	let timeout = a:timeout
	let start_time = reltime()
	while !self.is_exit()
		if timeout > 0.0 && str2float(reltimestr(reltime(start_time))) > timeout
			return g:reunions#process#status_timeout
		endif
		call self.__reunions.process.update()
	endwhile
	return g:reunions#process#status_ready
endfunction


function! s:process.wait()
	return self.wait_for(0)
endfunction


function! s:process.get()
	call self.wait()
	return self.__reunions.process.result
endfunction


function! reunions#process#make(command)
	let vimproc = vimproc#pgroup_open(a:command)

	let process = copy(s:process)
	let process.__reunions = deepcopy(process.__reunions)
	let process.__reunions.process.vimproc = vimproc
	let process.__reunions.process.command = a:command

	return process
endfunction


function! reunions#process#make_task(process)
	let task = {
\		"__reunions" : {
\			"process" : a:process
\		}
\	}
	function! task.apply()
		call self.__reunions.process.apply()
		if self.__reunions.process.is_exit()
			return -1
		endif
	endfunction
	function! task.kill()
		call self.__reunions.process.kill()
	endfunction
	return task
endfunction


function! reunions#process#regist_task(process)
	let task = reunions#process#make_task(a:process)
	call reunions#task(task)
	return task
endfunction



let &cpo = s:save_cpo
unlet s:save_cpo
