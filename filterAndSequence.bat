@echo off

echo welcome to filterAndSequence!!!
echo �t�B���^�ρA�������̓t�B���^�s�v�̏ꍇ�͔��p�X�y�[�X����͂��Ă�������
set /P hatsu="�����̔ԍ�����͂��Ă��������F"
pause

echo �t�B���^�����O���s���Acsv�t�@�C���𐶐����܂�
"C:\Program Files\Wireshark\tshark" -r *_*.* -Y "sip contains\"%hatsu%\"" -w filter.pcap
"C:\Program Files\Wireshark\tshark" -r filter.pcap  -Y "sip contains\"%hatsu%\"" -T fields -E separator=,  -e "frame.number" -e ip.src -e ip.dst  -e _ws.col.Protocol -e _ws.col.Info > filter.csv

echo �������܂���
rem pause

echo csv�𐮌`���܂�
powershell -ExecutionPolicy RemoteSigned -File code\csvDisassembly.ps1
powershell -ExecutionPolicy RemoteSigned -File code\makeMSC.ps1
powershell -ExecutionPolicy RemoteSigned -File code\mscgen.ps1
