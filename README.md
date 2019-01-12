## はじめに
### （使い方を早く知りたい方は前提条件まで読み飛ばしてください）
仕事柄、よく原因解析のため取得したキャプチャファイルからシーケンス図を描いてくれと言われることがある。  
シーケンス図を描く作業というのは多大な稼働を用し、編集しようにも大変。  
その時、皆さんってどんなツールで描いてますか？  
Excel？　PowerPoint？　ペイント？

> キャプチャファイルから直接シーケンス図作れたらいいのに。。。

探しました。  
良さげなの見つかりました。  
[pcapファイルからシーケンスチャート生成](https://qiita.com/kyrya/items/3c7fa9d0e03bfcae9de9)

hmhm, 「mscgen」っていうのを使えばいけると、  
「mscgen」には"MSCs"（Message Seuence Charts）っていうフォーマットがあって、  
それを食わせるとPNGでもSVGでも画像で出力してあげるということらしい。

そこでキャプチャファイルを"MSCs"にするのが「pcap2msc」。  
pythonのスクリプトみたいです。

しかし私、pythonエンジニアではないので、わかりません。  
リンク先は、Unix系の導入しか載せてない。  
でも...Windowsでやりたい。  
だって、環境がそれしかないから。  
仮想環境でやれ？構築が面倒。

探しました。  
私のググり力では及びませんした。  
Cygwinパッケージ？どうぞどうぞ、私は止めません。


## パパパってやって終わり！って実行も環境構築もしたい
pythonスクリプト動かすにはpythonのインストール？  
Cygwinはなんやんややるからインストールめちゃ時間かかるやん？  
新規ソフトウェアのインストールには管理者の承認がいる？

そんな障害がワサワサワサーって。

そこで、、、  
キャプチャファイルからシーケンス図を作成するヤツをPowerShellで書きました。  
キャプチャファイルをcsvに落とし込んで、あとはおまかせ。  
そんなやつです。  
※本ツールは社内用にチューニングしています。  
　GitHubにも上げるんで、都合の良いように改良しちゃってください。

# 前提条件
* tsharkのインストール
	+ キャプチャファイルをcsvにするときに使います。
* mscgenのインストール
	+ 今回のキモです。
	+ コマンドプロンプトなどで「mscgen」と入力してhelpが出ればOKです。
	+ 後述しますが、未インストールでも問題なかったりします。
* PowerShellの実行セキュリティポリシーを変更
	+ 一応やっときましょ
	+ verは2.0以上だったらいけるはず

# フォルダ構成
<p><img src="https://qiita-image-store.s3.amazonaws.com/0/93932/6f74fa90-a295-c9a2-c092-f0d1d758c523.png" width="250" height="350"></p>

* Ｘ：ツールを使用する上で使用しない
* ★：ツールの使用中にできるファイル
* Example_filter.pcapng：SIPのキャプチャファイルです。  
ありがたく動作確認などに利用させていただきましょう。  
元ファイル：<a href="https://www.cloudshark.org/captures/2b0d15028b9e/" target="_blank">リンク</a>
* Release版にはinstallerフォルダはつきません。各自ダウンロードしてください。

# キャプチャファイルのcsv化
キャプチャファイルをcsv化するにはtsharkを使用します。  
インストールが終わりましたら、filterAndSequence.bat内のtsharkがインストールされているディレクトリの確認をお忘れなく。  
ファイル名は「\*_\*.\*」として **ひとつだけ**配置してください。  
※複数の出力には対応していません。

確認が終わったら`filterAndSequence.bat`をダブルクリック！  
プログラムが起動するよ！

また、csv化する前にキャプチャをフィルタリングする機能もつけています。  
※元からしている方は必要ありません。  
　半角スペースでフィルタなしで継続可能です。
<p><img src="https://qiita-image-store.s3.amazonaws.com/0/93932/6a615c27-d359-b5fc-666e-d196433a9a61.png" width="350" height="350"></p>
※何度も言いますが、社内用にチューニングしています。<br>
　指定しているファイル名も然り、フィルタも然り。<br>
　デフォルトでは`sip contains "@@@"`となっています。

作業が完了すると`filter.pcap`と`filter.csv`が出力されます。  
その後、問題がなければ画像生成まで自動で行います。  
※mscgenをインストールしている場合のみ画像生成

これより、Example_filter.pcapngを使った各機能の説明です。

# csvファイルの整形
### 1. filter.csvから、各データごとに取り除く
取り除かれるデータは以下の通り

* Source（src）
* Destination（dst）
* protocol
* info

src.txt
```
10.33.6.101
10.33.6.100
10.33.6.100
10.33.6.100
10.33.6.101
10.33.6.100
10.33.6.101
```

dst.txt
```
10.33.6.100
10.33.6.101
10.33.6.101
10.33.6.101
10.33.6.100
10.33.6.101
10.33.6.100
```

protocol.txt
```
SIP/SDP
SIP
SIP
SIP/SDP
SIP
SIP
SIP
```

info.txt
```
Request: INVITE sip:101@10.33.6.100;user=phone |
Status: 100 Trying |
Status: 180 Ringing |
Status: 200 OK |
Request: ACK sip:101@10.33.6.100:5060 |
Request: BYE sip:201@10.33.6.101:5060 |
Status: 200 OK |
```

### 2. アドレス部分のみを抽出し、ソートする
srcとdstから使用されているアドレスを抽出する。  
使用用途は追々説明。

sortAddressList.txt
```
10.33.6.101
10.33.6.100
```

# "MSCs"フォーマットの作成
### 0. "MSCs"フォーマットとは

Ex.公式サイトより引用
```
# MSC for some fictional process
msc {
  hscale = "2";

  a,b,c;

  a->b [ label = "ab()" ] ;
  b->c [ label = "bc(TRUE)"];
  c=>c [ label = "process(1)" ];
  c=>c [ label = "process(2)" ];
  ...;
  c=>c [ label = "process(n)" ];
  c=>c [ label = "process(END)" ];
  a<<=c [ label = "callback()"];
  ---  [ label = "If more to run", ID="*" ];
  a->a [ label = "next()"];
  a->c [ label = "ac1()\nac2()"];
  b<-c [ label = "cb(TRUE)"];
  b->b [ label = "stalled(...)"];
  a<-b [ label = "ab() = FALSE"];
}
```

このように、エンティティを初期化（`a,b,c;`）し、そのエンティティが、どのエンティティへ  
メッセージを送信（`a->b`）したか、どんなメッセージを送信した（`"ab()"`）かを書くだけです。  
ここで、csvファイルの整形で説明したアドレス抽出を思い出してください。  
そうです、このエンティティ初期化で使用する値です。

詳しい構文は公式サイトをご確認ください。

### 1. 抽出したデータを構文に当てはめる
以下は、Example_filter.pcapngより抽出したアドレスである。

sortAddressList.txt
```
10.33.6.101
10.33.6.100
```

このままだとカンマ（,）もついてない、最後尾にはセミコロン（;）も必要になってくる。  
また、「mscgen」の仕様上、"."は許容されていないのだ。  
許容されているのは、","と";"である。  
`ポイント`：Labelに落とし込むという裏ワザもあるが今回は省きます。

じゃあ、どうしたか。  
"."を" "に置き換えました。  
あれ、" "も許容されてないんじゃ。  
`ポイント`：問題ありません、エンティティに" "を含む場合、""で囲むことができます。

なんやかんややって構文に当てはまる形になったのがこれ。

sortAddressListMSC.txt
```
  "10 33 6 101",
  "10 33 6 100";
```

ついでにsrcとdstも当てはまる形にします。

srcMSC.txt
```
10 33 6 101
10 33 6 100
10 33 6 100
10 33 6 100
10 33 6 101
10 33 6 100
10 33 6 101
```

dstMSC.txt
```
10 33 6 100
10 33 6 101
10 33 6 101
10 33 6 101
10 33 6 100
10 33 6 101
10 33 6 100
```

それとinfoについてたパイプ（|）も消しときます。  
動作には影響ありませんが、ＩＫＩ（粋）ってやつです。

infoMSC.txt
```
Request: INVITE sip:101@10.33.6.100;user=phone
Status: 100 Trying
Status: 180 Ringing
Status: 200 OK
Request: ACK sip:101@10.33.6.100:5060
Request: BYE sip:201@10.33.6.101:5060
Status: 200 OK
```

### 2. できあがった情報を入れていく
イメージとしてはこんな感じです。

other/mscTemp.txt
```
# test
msc {
  hscale = "1";

  "src" or "dst" filtering entities;

  "src" =>> "dst" [ label = "info" ];
}
```

矢印の形は、固定です。  
好きなように変えてください。

`ポイント`：srcを左固定にすることで矢印の向きを変えなくて良いのだ。  
つまり、`a->b`と`c<-a`とあったとして矢印の向きを揃えれば同じでしょ、てことです。

で、できあがったのがこんな感じです。

msc.txt
```
# test
msc {
  hscale = "1";

  "10 33 6 101",
  "10 33 6 100";

  "10 33 6 101" =>> "10 33 6 100" [ label = "SIP/SDP Request: INVITE sip:101@10.33.6.100;user=phone" ];
  "10 33 6 100" =>> "10 33 6 101" [ label = "SIP Status: 100 Trying" ];
  "10 33 6 100" =>> "10 33 6 101" [ label = "SIP Status: 180 Ringing" ];
  "10 33 6 100" =>> "10 33 6 101" [ label = "SIP/SDP Status: 200 OK" ];
  "10 33 6 101" =>> "10 33 6 100" [ label = "SIP Request: ACK sip:101@10.33.6.100:5060" ];
  "10 33 6 100" =>> "10 33 6 101" [ label = "SIP Request: BYE sip:201@10.33.6.101:5060" ];
  "10 33 6 101" =>> "10 33 6 100" [ label = "SIP Status: 200 OK" ];
}
```

# 画像の生成
いよいよです。  
生成は、ただただコマンドに対してオプションを付与してあげるだけです。  
画像フォーマットPNGで`msc.png`という名前で保存としてあります。  
※mscgenが未インストールの方はfilterAndSequence.batの以下の行をコメントアウトしてください。

filterAndSequence.bat
```
powershell -ExecutionPolicy RemoteSigned -File code¥csvDisassembly.ps1
powershell -ExecutionPolicy RemoteSigned -File code¥makeMSC.ps1
rem powershell -ExecutionPolicy RemoteSigned -File code¥mscgen.ps1
```
<!-- `ポイント`：msc.txtがUTF-8で書かれていた場合、Labelが正しく表示されないかもっていう忠告が出る。
大丈夫です、コピー元ファイルがSJISなのでNPです。 -->

mscgen.ps1
```
"mscファイルから画像を生成します"
mscgen -i .\outputs\msc.txt -T png -o msc.png
"完了しました msc.pngをご確認ください"

Read-Host "全行程が終了しました Enter キーを押してください..."
```

できあがった画像を確認してみましょう。

msc.png
<p><img src="https://qiita-image-store.s3.amazonaws.com/0/93932/c0a1f1ef-7eb4-451f-b18e-fdfc8ae56c01.png"></p>

お疲れさまでした。

# 余談
### 読み込ませるファイルについて
読み込むキャプチャファイル名などは各自の環境に合わせて使用してください。  
「\*_\*.\*」となっているのはただただ私の職場での保存形式に則っただけです。

### pause
結構頻繁にpauseとかRead-Hostを入れてますが、これはただ私が、動作を一つ一つ確かめるために置いているだけなので  
除けるなりなんなりしていただいて構いません。  
大規模なファイルのシーケンスができるのをコーヒー片手に待つってこともできちゃうわけです。  
あ、当然ながらマシンスペックに依存しますよ

### 他ツールとの連携
できあがったmsc.txtの中身を <a href="https://mscgen.js.org/" target="_blank">mscgen_js</a> に食わせることもできますよ。
<p><img src="https://qiita-image-store.s3.amazonaws.com/0/93932/38382394-d983-3810-af17-e2a0381ee013.png"></p>
きれいなシーケンスで上司もニッコリ:smiling_imp:

# QA
### Wiresharkの「Flow Graph」機能でいいんじゃないの？
どうぞ、ご自由に、使いたい方を選んでください。

### エンティティ同士が詰まって画像が見にくい
キャプチャによってはプロキシなどを挟んでいたりして、アドレスがたくさん出てくるかもしれません。  
その際は、dataフォルダにあるmscTemp.txtの3行目の`hscale = "2";`の""内の数字を増やしてお試しください。

# さいごに
それ○○でもできるよ、大歓迎です。  
今回は、自身の勉強も兼ねてPowerShellで開発しました。  
改良も引き続き行っていきたいと思います。

それでは良きmscライフを。
