@echo off

echo welcome to makeSequence!!!
pause

echo csv�t�@�C���𐶐����܂�
"C:\Program Files\Wireshark\tshark" -r *_*.* -w filter.pcap
"C:\Program Files\Wireshark\tshark" -r filter.pcap -T fields -E separator=,  -e "frame.number" -e ip.src -e ip.dst  -e _ws.col.Protocol -e _ws.col.Info > filter.csv

echo �������܂���
rem pause

echo csv�𐮌`���܂�
powershell -ExecutionPolicy RemoteSigned -File code\csvDisassembly.ps1
powershell -ExecutionPolicy RemoteSigned -File code\makeMSC.ps1
powershell -ExecutionPolicy RemoteSigned -File code\mscgen.ps1
