" タスクを定義
" CursorHold のタイミングでカウントダウンして出力する
let s:task = {
\	"count" : 5
\}

" 毎回呼ばれる関数
" 引数にはタスクの id を受け取る
function! s:task.apply(id)
	echo self.count
	let self.count -= 1

	if self.count < 0
		echo "kill"
		" タスクを終了させる
		call reunions#taskkill(a:id)
	endif
endfunction

" タスクを作成する
let s:id = reunions#task(s:task)
echo s:id

