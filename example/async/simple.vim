" Vim script の関数を非同期で実行する
" この関数は現在起動している Vim とは別の Vim で実行される
" 実行する関数は関数外のスコープの変数を参照する事は出来ない

" 非同期で処理する関数
" この関数で return した値は then(result) に渡される
function! Func()
	sleep 3
	return "homu"
endfunction


" 呼び出したい関数名を渡す
" この関数はグローバル関数、もしくは <SID> 付きな名前の関数でなければならない
let s:async = reunions#async("Func")

" 関数が終了したら呼ばれる関数
" このファイルを :source してから3秒後に呼ばれる
function! s:async.then(result)
	echo "Finished"
	echo "result : " . a:result
endfunction

