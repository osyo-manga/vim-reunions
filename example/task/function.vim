" 関数を登録する

if exists(":TestReunionsTaskKill")
	:TestReunionsTaskKill
endif

" 引数にはタスクの id を受け取る
function! TestReunionsTask(id)
	echo strftime("%c", localtime())
endfunction

" 関数を登録
let s:id = reunions#task(function("TestReunionsTask"))

" reti.vim を使用する場合は直接処理を渡すことが出来る
" let s:id = reunions#task(reti#lambda(':echo strftime("%c", localtime())'))


" タスク終了用のコマンド
command! TestReunionsTaskKill call reunions#taskkill(s:id)

