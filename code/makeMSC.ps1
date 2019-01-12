# 値をダブルコーテーションで囲み、文末にカンマをつける、ただし最後の行はセミコロンをつける
"アドレスをmsc形式に変換します"
$lines = (Get-Content -Path .\outputs\sortAddressList.txt).Length
$f = (Get-Content .\outputs\sortAddressList.txt) -as [string[]]
$i=1
foreach ($l in $f) {
  if ($i -lt $lines) {
    $add = "  `"" + $l + "`","
  }

  else {
    $add = "  `"" + $l + "`";"
  }
    $add | Add-Content .\outputs\sortAddressListMSC.txt
    $i++
}
$sort = Get-Content .\outputs\sortAddressListMSC.txt | foreach { $_ -replace "\.", " " }
$sort | Out-File -Encoding default .\outputs\sortAddressListMSC.txt
"完了しました"

"その他のデータをmsc形式に変換します"
# 他のデータも置き換えてmscが読み込める形にする
$src = Get-Content .\outputs\src.txt | foreach { $_ -replace "\.", " " }
$dst = Get-Content .\outputs\dst.txt | foreach { $_ -replace "\.", " " }

# tsharkの出力時に出た不要パイプを消す
$info = Get-Content .\outputs\info.txt | foreach { $_ -replace " \| ", "" }

# msc用として出す
$src | Out-File -Encoding default .\outputs\srcMSC.txt
$dst | Out-File -Encoding default .\outputs\dstMSC.txt
$info | Out-File -Encoding default .\outputs\infoMSC.txt
"完了しました"


"mscファイルを作成します"

# テンプレートファイルをバックアップする
Copy-Item .\data\mscTemp.txt .\outputs\msc.txt

# 改行挿入用
$esc = "`n"
$esc | Add-Content .\outputs\msc.txt

# サーバ、クライアントの情報を挿入する
$f = (Get-Content .\outputs\sortAddressListMSC.txt) -as [string[]]
$i=1
foreach ($l in $f) {
    $l | Add-Content .\outputs\msc.txt
    $i++
}
$esc | Add-Content .\outputs\msc.txt


# 各ファイルを読み込んでmscに書き込む内容を準備する
$srcLines = Get-Content -Path .\outputs\srcMSC.txt
$dstLines = Get-Content -Path .\outputs\dstMSC.txt
$protocolLines = Get-Content -Path .\outputs\protocol.txt
$infoLines = Get-Content -Path .\outputs\infoMSC.txt

# 配列の長さの把握
$infoLength = (Get-Content -Path .\outputs\infoMSC.txt).Length

# 各情報を挿入するs
for( $i = 0; $i -lt $infoLength; $i++ ) {
  $input = "  `"" + $srcLines[$i] + "`" =>> `"" + $dstLines[$i] + "`" [ label = `"" + $protocolLines[$i] + " " + $infoLines[$i] + "`" ];"
  $input | Add-Content .\outputs\msc.txt
}

# 最後のとじかっこ
$close = $esc + "}" | Add-Content .\outputs\msc.txt
"完了しました"

Read-Host "次行程へ進みます Enter キーを押してください..." 
