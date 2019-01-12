@echo off

echo welcome to filterAndSequence!!!
echo フィルタ済、もしくはフィルタ不要の場合は半角スペースを入力してください
set /P hatsu="発側の番号を入力してください："
pause

echo フィルタリングを行い、csvファイルを生成します
"C:\Program Files\Wireshark\tshark" -r *_*.* -Y "sip contains\"%hatsu%\"" -w filter.pcap
"C:\Program Files\Wireshark\tshark" -r filter.pcap  -Y "sip contains\"%hatsu%\"" -T fields -E separator=,  -e "frame.number" -e ip.src -e ip.dst  -e _ws.col.Protocol -e _ws.col.Info > filter.csv

echo 完了しました
rem pause

echo csvを整形します
powershell -ExecutionPolicy RemoteSigned -File code\csvDisassembly.ps1
powershell -ExecutionPolicy RemoteSigned -File code\makeMSC.ps1
powershell -ExecutionPolicy RemoteSigned -File code\mscgen.ps1
