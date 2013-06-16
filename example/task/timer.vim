" 指定した時間ごとに処理が呼ばれる

if exists(":TestReunionsTaskKill")
	:TestReunionsTaskKill
endif

" 引数にはタスクの id を受け取る
function! TestReunionsTask(id)
	echo strftime("%c", localtime())
endfunction

" 関数を登録
" 3秒毎に処理が呼ばれる
let s:id = reunions#task_timer(function("TestReunionsTask"), 3.0)


" タスク終了用のコマンド
command! TestReunionsTaskKill call reunions#taskkill(s:id)



