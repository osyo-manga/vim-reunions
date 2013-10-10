

function! s:test_get()
	call reunions#task_clear_logs()

	let process1 = reunions#process('ruby -e "print 1"')
	let process2 = reunions#process('ruby -e "print ''mami''"')
	let process3 = reunions#process('ruby -e "puts ''mami''"')
	let process4 = reunions#process('ruby -e "print [1, 2, 3]"')
	let process5 = reunions#process('ruby -e "print ''mami'' ; print ''homu''"')
	let process6 = reunions#process('ruby -e "puts ''mami'' ; puts ''homu''"')
	let process7 = reunions#process('ls')

	OwlCheck process1.get() == 1

	OwlCheck process2.get() == "mami"
	OwlCheck process3.get() == "mami\n"
	OwlCheck process4.get() == "[1, 2, 3]"
	OwlCheck process5.get() == "mamihomu"
	
	let check6 = "mami\nhomu\n"
	OwlCheck process6.get() == check6

	let check7 = "process.vim\ntask.vim\n"
	OwlCheck process7.get() == check7

	OwlCheck reunions#task_logs() == ""
endfunction


function! s:test_wait()
	let process = reunions#process('ruby -e "puts 1"')
	call process.wait()
	OwlCheck process.is_exit()
endfunction


function! s:test_wait_for()
	let process = reunions#process("ruby -e \" sleep 1; puts 'mami' \"")
	if process.wait_for(1.5) == g:reunions#process#status_ready
		OwlCheck 1
	else
		OwlCheck 0
	endif

	let process2 = reunions#process("ruby -e \" sleep 1; puts 'homu' \"")
	if process2.wait_for(0.5) == g:reunions#process#status_timeout
		OwlCheck 1
	else
		OwlCheck 0
	endif
endfunction


function! s:test_copy()
	let process = reunions#process('ls')
	let process.__reunions.hoge = 10
	let process2 = reunions#process('ls')
	OwlCheck !has_key(process2.__reunions, "hoge")
endfunction


function! s:test_kill()
	let process = reunions#process('cmd')
	call process.kill()
	OwlCheck process.is_exit()
endfunction


function! s:test_group()
	let group = reunions#process_group()
	for i in [3, 5, 0, 1, 8, 2, 7, 4, 6, 9]
		let process = group.make_process(printf("ruby -e \" sleep %s; puts %d \"", i, i))
		function! process.then(output)
			echo "homu" . a:output
		endfunction
	endfor

	call group.wait_all()
" 	call reunions#task(group)
" 	echo len(reunions#tasklist())
endfunction

