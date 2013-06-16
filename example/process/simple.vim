" 非同期でプロセスを実行する

" Ruby を実行させる
let s:process = reunions#process('ruby -e " sleep 3; puts ''mami'' "')

" 実行が終了した時に呼び出される関数
function! s:process.then(result)
	" このファイルを :source してから3秒後に 
	" 'mami' と出力される
	echo a:result
endfunction

echo "Process Started"

