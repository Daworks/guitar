#include ".\_include_nhn\_util.au3"
#include ".\_include_nhn\_image.au3"

; ADB�� �̿��� ȭ�� ĸ�� (adb exec-out screencap -p �� ���� ���� ������ ������)
func ADBScreenshot($sFile,  $iRatio=100)

	local $sTempFile = _TempFile( @TempDir,"~g",".png",Default)
	local $iRet
	local $sCmdLine
	local $iPid
	; ĸ��
	local $x=TimerInit()

;~ 	$sCmdLine = "adb.exe shell screencap -p ""/mnt/sdcard/" & $sTempFile & """"
;~ 	;debug($sCmdLine)
;~ 	$iRet =RunWait(@ComSpec & " /c" & $sCmdLine ,@TempDir, @SW_HIDE)
;~ 	;debug($iRet)

;~ 	$sCmdLine =  "adb.exe pull  ""/mnt/sdcard/" & $sTempFile  & """" & " " & """" &  $sTempFile & """"
;~ 	;debug($sCmdLine)
;~ 	$iRet =RunWait(@ComSpec & " /c" &  $sCmdLine  ,@TempDir, @SW_HIDE)
;~ 	;debug($iRet)


	$sCmdLine = "adb exec-out screencap -p > """ & $sTempFile & """"
	_debug($sCmdLine)

	FileDelete($sFile)

	RunWait(@ComSpec & " /c" & $sCmdLine ,@TempDir, @SW_HIDE)

	;debug($iRet)

	if FileExists($sTempFile) = 1 then

		if $iRatio = 100 then
			FileMove (@TempDir & "\" & $sTempFile, $sFile)
		Else
			;_debug("�Ծ�")
			_ImageResizeFromFile($sTempFile, $sFile, $iRatio)
		endif

	endif

	FileDelete($sTempFile)
	;debug("��������", FileExists($sFile))
	$iRet = (FileExists($sFile) = 1)

	return $iRet

EndFunc



Func _RunADB($sCommand, $bWait = True, $bShow = False)
	_debug($sCommand)
	return _Run($sCommand, $bWait, $bShow)

endfunc
