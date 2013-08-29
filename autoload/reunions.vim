scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim


function! reunions#tasklist()
	return reunions#task#list()
endfunction


function! reunions#taskkill(task_id)
	return reunions#task#kill(a:task_id)
endfunction


function! reunions#task(expr)
	return reunions#task#regist(reunions#task#make_default(a:expr))
endfunction


function! reunions#task_once(expr)
	return reunions#task#regist(reunions#task#make_once(a:expr))
endfunction


function! reunions#task_timer(expr, time)
	return reunions#task#regist(reunions#task#make_timer(a:expr, a:time))
endfunction


function! reunions#task_timer_once(expr, time)
	return reunions#task#regist(reunions#task#make_timer(reunions#task#make_once(a:expr), a:time))
endfunction


function! reunions#task_logs()
	return reunions#task#logs()
endfunction


function! reunions#task_clear_logs()
	call reunions#task#clear_logs()
endfunction


function! reunions#task_group()
	return reunions#task#make_group()
endfunction


function! reunions#process(command)
	let process = reunions#process#make(a:command)
	call reunions#process#regist_task(process)
	return process
endfunction


function! reunions#async(...)
	let async = call("reunions#async#make", a:000)
	call reunions#task#regist(async)
	return async
endfunction



let &cpo = s:save_cpo
unlet s:save_cpo
