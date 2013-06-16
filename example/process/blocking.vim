" 非同期で処理しない場合
let s:process = reunions#process('ruby -e " sleep 3; puts ''mami'' "')

" プロセスが終了するまで待ち処理が行われる
let s:result = s:process.get()
echo s:result
" => mami

