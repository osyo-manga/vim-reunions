scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim

function! s:SID()
	return matchstr(expand('<sfile>'), '<SNR>\zs\d\+\ze_SID$')
endfun

function! s:to_SNR(name)
	return "<SNR>" . s:SID() . "_" . a:name
endfunction


function! s:sfunction(name)
	return function(s:to_SNR(a:name))
endfunction


let s:logs = ""
function! s:log_message_except(id, str)
	let s:logs = s:logs
\		. printf("\n\n======= task_id : %d =======\n", a:id)
\		. a:str . "\n"
\		. 'Caught "' . v:exception "\n"
\		. '" in ' . v:throwpoint . ""
endfunction


function! reunions#task#clear_logs()
	let s:logs = ""
endfunction


function! reunions#task#logs()
	return s:logs
endfunction


if !exists("s:tasks")
	let s:tasks = {}
endif


function! s:make_id()
	let id = get(s:, "task_num", 0) + 1
	let s:task_num = id
	return id
endfunction


function! reunions#task#make_default(task)
	if type(a:task) == type(function("tr"))
		return reunions#task#make_default({ "apply" : a:task })
	endif
	return a:task
endfunction


function! s:timer_task(...)
	let s:reltime = reltime()
	let s:reltimef = str2float(reltimestr(reltime()))
" 	echo s:reltimef
endfunction


function! reunions#task#make_timer(task, time)
	if !exists("s:task_timer_id") || !reunions#task#exist(s:task_timer_id)
		let s:task_timer_id = reunions#task(s:sfunction("timer_task"))
	endif
	let task = {
\		"__reunions" : {
\			"task_timer" : {
\				"base_task" : reunions#task#make_default(a:task),
\				"interval_time" : a:time,
\				"last_time" : s:reltimef,
\			}
\		}
\	}
	function! task.apply(id)
		let task = self.__reunions.task_timer
" 		echo "time : ". string(s:reltimef) ." - ". string(self.__reunions.task_timer.last_time) . " = ". string(s:reltimef - self.__reunions.task_timer.last_time)
		if (s:reltimef - task.last_time) > task.interval_time
			try
				call task.base_task.apply(a:id)
			finally
				let task.last_time = s:reltimef
			endtry
		endif
	endfunction
	
	function! task.kill()
		call self.__reunions.task_timer.base_task.kill()
	endfunction

	return task
endfunction


function! reunions#task#make_once(task)
	let task =  {
\		"__reunions" : {
\			"task_once" : {
\				"base_task" : reunions#task#make_default(a:task)
\			}
\		}
\	}
	function! task.apply(id)
		call self.__reunions.task_once.base_task.apply(a:id)
		return reunions#taskkill(a:id)
	endfunction

	function! task.kill()
		call self.__reunions.task_once.base_task.kill()
	endfunction

	return task
endfunction


function! reunions#task#regist(task)
	let id = s:make_id()
	let s:tasks[id] = a:task
	return id
endfunction


function! reunions#task#update_all()
	for [id, task] in items(reunions#task#list())
		try
			call task.apply(id)
		catch
			call s:log_message_except(id, "Except task update")
		endtry
	endfor
endfunction


function! reunions#task#kill(task_id)
	if has_key(s:tasks, a:task_id)
		let task = s:tasks[a:task_id]
		unlet s:tasks[a:task_id]
		if has_key(task, "kill")
			try
				call task.kill()
			catch
			endtry
		endif
		return 0
	else
		return -1
	endif
endfunction


function! reunions#task#get(task_id)
	return s:tasks[a:task_id]
endfunction


function! reunions#task#kill_all()
	for id in keys(s:tasks)
		call reunions#task#kill(id)
	endfor
	let s:tasks = {}
endfunction


function! reunions#task#list()
	return s:tasks
endfunction

function! reunions#task#exist(id)
	return has_key(reunions#task#list(), a:id)
endfunction


augroup reunions-task
	autocmd!
	autocmd CursorHold  * call reunions#task#update_all()  | call feedkeys("g\<ESC>", 'n')
" 	autocmd CursorHoldI  * call reunions#task#update_all() | call feedkeys("\<C-g>\<ESC>", 'n')
	autocmd VimLeave  * call reunions#task#kill_all()
augroup END


let &cpo = s:save_cpo
unlet s:save_cpo
