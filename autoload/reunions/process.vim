scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim



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

	function! process.apply(id)
		let self.__reunions.process.task_id = a:id
		let process = self.__reunions.process
		let vimproc = process.vimproc
		try
			if !vimproc.stdout.eof
				let process.result .= vimproc.stdout.read()
			endif

			if !vimproc.stderr.eof
				let process.result .= vimproc.stderr.read()
			endif

			if !self.is_exit()
				return
			endif
		catch
			call self.kill()
" 			call reunions#taskkill(a:id)
		endtry
		if has_key(self, "then")
			call self.then(process.result)
		endif
		call self.kill()
" 		call reunions#taskkill(a:id)
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

	function! process.wait(...)
		let timeout = get(a:, 1, 0.0)
		let start_time = reltime()
		while !self.is_exit()
			if timeout > 0.0 && str2float(reltimestr(reltime(start_time))) > timeout
				break
			endif
			call self.apply(get(self.__reunions.process, "taks_id", -1))
		endwhile
	endfunction

	function! process.get()
		call self.wait()
		return self.__reunions.process.result
	endfunction

	return process
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
