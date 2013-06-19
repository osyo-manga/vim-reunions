

function! s:test_get()
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
endfunction


function! s:test_wait()
	let process = reunions#process('ruby -e "puts 1"')
	call process.wait()
	OwlCheck process.is_exit()
endfunction


function! s:test_wait_for()
	let process = reunions#process("ruby -e \" sleep 1; puts 'mami' \"")
	if process.wait_for(0.5) == g:reunions#process#status_ready
		OwlCheck 0
	else
		OwlCheck 1
	endif

	let process2 = reunions#process("ruby -e \" sleep 1; puts 'homu' \"")
	if process2.wait_for(1.5) == g:reunions#process#status_ready
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
	let process = reunions#process('ls')
	call process.kill()
	OwlCheck process.is_exit()
endfunction

