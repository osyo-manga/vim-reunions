scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim

silent! let g:reunions#process#status_ready = 1
lockvar! g:reunions#process#status_ready

silent! let g:reunions#process#status_timeout = 2
lockvar! g:reunions#process#status_timeout


function! reunions#process#make(command)
	let vimproc = vimproc#pgroup_open(a:command)
	let process = {
\		"__reunions" : {
\			"process" : {
\				"vimproc" : vimproc,
\				"command" : a:command,
\				"result"  : "",
\			}
\		}
\	}
	function! process.__reunions.process.update()
		let vimproc = self.vimproc
		if !vimproc.stdout.eof
			let self.result .= vimproc.stdout.read()
		endif

		if !vimproc.stderr.eof
			let self.result .= vimproc.stderr.read()
		endif

	endfunction

	function! process.apply(id)
		let self.__reunions.process.task_id = a:id
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

	function! process.kill()
		let vimproc = self.__reunions.process.vimproc
		call vimproc.stdout.close()
		call vimproc.stderr.close()
		call vimproc.waitpid()
		call vimproc.kill(19)
		if has_key(self.__reunions.process, "task_id")
			call reunions#taskkill(self.__reunions.process.task_id)
		endif
	endfunction

	function! process.is_exit()
		let vimproc = self.__reunions.process.vimproc
		return vimproc.stdout.eof || vimproc.stderr.eof
	endfunction

	function! process.wait_for(timeout)
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

	function! process.wait()
		return self.wait_for(0)
	endfunction


	function! process.get()
		call self.wait()
		return self.__reunions.process.result
	endfunction

	return process
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
