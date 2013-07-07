" 非同期でプロセスを実行する

" 外部コマンドを実行させる
let s:process = reunions#process("ls")

" 実行が終了した時に呼び出される関数
" result にはコマンドの出力結果が渡される
" この関数は reunions#task により呼び出される
function! s:process.then(result)
	" ls の実行結果を出力
	echo a:result
	echo "Process Finished"
endfunction

echo "Process Started"

