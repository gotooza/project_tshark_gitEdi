# �l���_�u���R�[�e�[�V�����ň͂݁A�����ɃJ���}������A�������Ō�̍s�̓Z�~�R����������
"�A�h���X��msc�`���ɕϊ����܂�"
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
"�������܂���"

"���̑��̃f�[�^��msc�`���ɕϊ����܂�"
# ���̃f�[�^���u��������msc���ǂݍ��߂�`�ɂ���
$src = Get-Content .\outputs\src.txt | foreach { $_ -replace "\.", " " }
$dst = Get-Content .\outputs\dst.txt | foreach { $_ -replace "\.", " " }

# tshark�̏o�͎��ɏo���s�v�p�C�v������
$info = Get-Content .\outputs\info.txt | foreach { $_ -replace " \| ", "" }

# msc�p�Ƃ��ďo��
$src | Out-File -Encoding default .\outputs\srcMSC.txt
$dst | Out-File -Encoding default .\outputs\dstMSC.txt
$info | Out-File -Encoding default .\outputs\infoMSC.txt
"�������܂���"


"msc�t�@�C�����쐬���܂�"

# �e���v���[�g�t�@�C�����o�b�N�A�b�v����
Copy-Item .\data\mscTemp.txt .\outputs\msc.txt

# ���s�}���p
$esc = "`n"
$esc | Add-Content .\outputs\msc.txt

# �T�[�o�A�N���C�A���g�̏���}������
$f = (Get-Content .\outputs\sortAddressListMSC.txt) -as [string[]]
$i=1
foreach ($l in $f) {
    $l | Add-Content .\outputs\msc.txt
    $i++
}
$esc | Add-Content .\outputs\msc.txt


# �e�t�@�C����ǂݍ����msc�ɏ������ޓ��e����������
$srcLines = Get-Content -Path .\outputs\srcMSC.txt
$dstLines = Get-Content -Path .\outputs\dstMSC.txt
$protocolLines = Get-Content -Path .\outputs\protocol.txt
$infoLines = Get-Content -Path .\outputs\infoMSC.txt

# �z��̒����̔c��
$infoLength = (Get-Content -Path .\outputs\infoMSC.txt).Length

# �e����}������s
for( $i = 0; $i -lt $infoLength; $i++ ) {
  $input = "  `"" + $srcLines[$i] + "`" =>> `"" + $dstLines[$i] + "`" [ label = `"" + $protocolLines[$i] + " " + $infoLines[$i] + "`" ];"
  $input | Add-Content .\outputs\msc.txt
}

# �Ō�̂Ƃ�������
$close = $esc + "}" | Add-Content .\outputs\msc.txt
"�������܂���"

Read-Host "���s���֐i�݂܂� Enter �L�[�������Ă�������..." 
