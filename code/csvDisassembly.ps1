# tshark�ō쐬�����L���v�`���t�@�C����csv��ǂݍ���
"csv�t�@�C����ǂݍ��݂܂�"
$csv = Get-Content .\filter.csv | ConvertFrom-CSV -header number,src,dst,protocol,info -Delimiter ","
$lines = (Get-Content -Path .\filter.csv).Length
"�������܂���"

# �O��Ƃ����Z�b�g����
if(Test-Path ".\outputs\*.txt") {
  Remove-Item .\outputs\*.txt
}

# �p�[�c���ƂɊi�[����
"�t�@�C���𕪊����܂�"
for( $i = 0; $i -lt $lines; $i++ ) {
  $csv[$i].src | Add-Content .\outputs\src.txt
  $csv[$i].dst | Add-Content .\outputs\dst.txt
  $csv[$i].protocol | Add-Content .\outputs\protocol.txt
  $csv[$i].info | Add-Content .\outputs\info.txt
}
"�������܂���"

# �A�h���X�����݂̂𒊏o����
"�g�p����Ă���A�h���X�𒊏o���܂�"
Get-Content .\outputs\src.txt | Select-Object -Unique | Add-Content .\outputs\sort.txt
Get-Content .\outputs\dst.txt | Select-Object -Unique | Add-Content .\outputs\sort.txt
Get-Content .\outputs\sort.txt | Select-Object -Unique | Out-File .\outputs\sortAddressList.txt
Remove-Item .\outputs\sort.txt
"�������܂���"

Read-Host "���s���֐i�݂܂� Enter �L�[�������Ă�������..." 
