# tsharkで作成したキャプチャファイルのcsvを読み込む
"csvファイルを読み込みます"
$csv = Get-Content .\filter.csv | ConvertFrom-CSV -header number,src,dst,protocol,info -Delimiter ","
$lines = (Get-Content -Path .\filter.csv).Length
"完了しました"

# 前作業をリセットする
if(Test-Path ".\outputs\*.txt") {
  Remove-Item .\outputs\*.txt
}

# パーツごとに格納する
"ファイルを分割します"
for( $i = 0; $i -lt $lines; $i++ ) {
  $csv[$i].src | Add-Content .\outputs\src.txt
  $csv[$i].dst | Add-Content .\outputs\dst.txt
  $csv[$i].protocol | Add-Content .\outputs\protocol.txt
  $csv[$i].info | Add-Content .\outputs\info.txt
}
"完了しました"

# アドレス部分のみを抽出する
"使用されているアドレスを抽出します"
Get-Content .\outputs\src.txt | Select-Object -Unique | Add-Content .\outputs\sort.txt
Get-Content .\outputs\dst.txt | Select-Object -Unique | Add-Content .\outputs\sort.txt
Get-Content .\outputs\sort.txt | Select-Object -Unique | Out-File .\outputs\sortAddressList.txt
Remove-Item .\outputs\sort.txt
"完了しました"

Read-Host "次行程へ進みます Enter キーを押してください..." 
