" Web 上のスクリプトファイルを読み込みます

function! s:async_nsource(uri)
	" curl からのダウンロードを非同期で行う
	let cmd  = printf("curl -s %s", a:uri)
	let process = reunions#process(cmd)

	" 結果を tempfile に書き出して :source を行う
	function! process.then(result)
		let temp = tempname()
		call writefile(split(a:result, "\n"), temp)
		source `=temp`
	endfunction
endfunction

" gist 上の test.vim を source する
call s:async_nsource("https://gist.github.com/osyo-manga/5805362/raw/da3c5b5882e8469bd8c4e1c46ba2afbdbff29059/test.vim")



