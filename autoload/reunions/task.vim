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


function! s:task_group()
	let self = {
\		"tasks" : {},
\		"id_count" : 0,
\		"log" : ""
\	}

	function! self.logs()
		return self.log
	endfunction


	function! self.clear_logs()
		let self.log = ""
	endfunction

	function! self.add_log(id, mes)
		let self.log = self.log
	\		. printf("\n\n======= task_id : %d =======\n", a:id)
	\		. a:mes . "\n"
	\		. 'Caught "' . v:exception "\n"
	\		. '" in ' . v:throwpoint . ""
	endfunction
	
	function! self.make_id()
		let self.id_count += 1
		return self.id_count
	endfunction

	function! self.add(task)
		let id = self.make_id()
		let self.tasks[id] = a:task
		return id
	endfunction

	function! self.get(id)
		return self.tasks[a:id]
	endfunction

	function! self.update(id)
		if !self.has_id(a:id)
			return
		endif
		try
			if self.get(a:id).apply() != 0
				call self.kill_id(a:id)
			endif
		catch
			call self.add_log(a:id, "Except task update")
			call self.kill_id(a:id)
		endtry
	endfunction

	function! self.update_all()
		for id in keys(self.tasks)
			call self.update(id)
		endfor
	endfunction

	function! self.apply()
		call self.update_all()
		if self.size() == 0
			return -1
		endif
	endfunction


	function! self.kill_id(id)
		if !self.has_id(a:id)
			return -1
		endif
		let task = self.get(a:id)
		unlet self.tasks[a:id]
		
		if has_key(task, "kill")
			try
				call task.kill()
			catch
				call self.add_log(a:id, "Except task kill")
			endtry
		endif
	endfunction

	function! self.kill_all()
		for id in keys(self.tasks)
			call self.kill_id(id)
		endfor
		let self.tasks = {}
	endfunction

	function! self.has_id(id)
		return has_key(self.tasks, a:id)
	endfunction

	function! self.size()
		return len(self.tasks)
	endfunction

	return self
endfunction

function! reunions#task#make_group()
	return s:task_group()
endfunction


" let s:logs = ""
" function! s:log_message_except(id, str)
" 	let s:logs = s:logs
" \		. printf("\n\n======= task_id : %d =======\n", a:id)
" \		. a:str . "\n"
" \		. 'Caught "' . v:exception "\n"
" \		. '" in ' . v:throwpoint . ""
" endfunction


function! reunions#task#clear_logs()
" 	let s:logs = ""
	call s:global_tasks.clear_logs()
endfunction


function! reunions#task#logs()
	return s:global_tasks.logs()
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


let s:reltimef = 0
function! s:timer_task(...)
	let s:reltime = reltime()
	let s:reltimef = str2float(reltimestr(reltime()))
" 	echo s:reltimef
endfunction


function! reunions#task#make_timer(task, time)
	let task = {
\		"__reunions" : {
\			"task_timer" : {
\				"base_task" : reunions#task#make_default(a:task),
\				"interval_time" : a:time,
\				"last_time" : s:reltimef,
\			}
\		}
\	}
	function! task.apply()
		let task = self.__reunions.task_timer
		if (s:reltimef - task.last_time) > task.interval_time
			try
				call task.base_task.apply()
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
	function! task.apply()
		call self.__reunions.task_once.base_task.apply()
		return -1
	endfunction

	function! task.kill()
		call self.__reunions.task_once.base_task.kill()
	endfunction

	return task
endfunction



if !exists("s:global_tasks") || 0
	let s:global_tasks = reunions#task#make_group()
endif



function! reunions#task#regist(task)
	return s:global_tasks.add(a:task)
endfunction


function! reunions#task#update_all()
	return s:global_tasks.update_all()
" 	for [id, task] in items(reunions#task#list())
" 		try
" 			call task.apply(id)
" 		catch
" 			call s:log_message_except(id, "Except task update")
" 		endtry
" 	endfor
endfunction


function! reunions#task#kill(id)
	return s:global_tasks.kill_id(a:id)
" 	if has_key(s:tasks, a:task_id)
" 		let task = s:tasks[a:task_id]
" 		unlet s:tasks[a:task_id]
" 		if has_key(task, "kill")
" 			try
" 				call task.kill()
" 			catch
" 			endtry
" 		endif
" 		return 0
" 	else
" 		return -1
" 	endif
endfunction


function! reunions#task#get(id)
	return s:global_tasks.get(a:id)
" 	return s:tasks[a:task_id]
endfunction


function! reunions#task#kill_all()
	for id in keys(s:tasks)
		call reunions#task#kill(id)
	endfor
	let s:tasks = {}
endfunction


function! reunions#task#list()
	return s:global_tasks.tasks
endfunction

function! reunions#task#exist(id)
	return s:global_tasks.has_id(a:id)
endfunction


augroup reunions-task
	autocmd!
	autocmd CursorHold * call s:timer_task()
	autocmd CursorHold  * call feedkeys("g\<ESC>", 'n') | call reunions#task#update_all()
	autocmd CursorHoldI  * call feedkeys("\<C-g>\<ESC>", 'n') |  call reunions#task#update_all()
	autocmd VimLeave  * call reunions#task#kill_all()
augroup END


let &cpo = s:save_cpo
unlet s:save_cpo
