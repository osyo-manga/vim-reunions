" プロセスを実行させた後に終了するまで待ち処理を行う

" 外部コマンドを実行させる
let s:process = reunions#process('ruby -e "puts ''mami'' "')
" プロセスが終了するまで処理を待つ
" Float 値を渡した場合、その秒数だけ待ち処理を行う
if s:process.wait_for(0.5) == g:reunions#process#status_timeout
	" 実行が終了した時に呼び出される関数
	function! s:process.then(result)
		echo a:result
	endfunction
else
	echo s:process.get()
endif

echo "Process Finished"
" PP reunions#tasklist()

