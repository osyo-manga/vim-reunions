" プロセスを実行させた後に終了するまで待ち処理を行う

" 外部コマンドを実行させる
let s:process = reunions#process('ruby -e " sleep 3; puts ''mami'' "')

" 実行が終了した時に呼び出される関数
function! s:process.then(result)
	echo a:result
endfunction

" プロセスが終了するまで処理を待つ
" この関数内でプロセスが終了すれば then が呼ばれる
call s:process.wait()

echo "Process Finished"

