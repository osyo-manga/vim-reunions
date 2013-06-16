" プロセスを実行させた後に終了するまで待ち処理を行う

" 外部コマンドを実行させる
let s:process = reunions#process('ruby -e "puts ''mami'' "')

" 実行が終了した時に呼び出される関数
function! s:process.then(result)
	echo a:result
endfunction

" プロセスが終了するまで処理を待つ
" Float 値を渡した場合、その秒数だけ待ち処理を行う
call s:process.wait(0.5)

echo "Process Finished"

