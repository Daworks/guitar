#include-once
#include ".\_include_nhn\_util.au3"
#include ".\_include_nhn\_webdriver.au3"

global $_WebdriverSearchTypeInfo [9][3]
global $_WebdriverSubFramePath = ""
global $_WebdriverMobileLastDragX = ""
global $_WebdriverMobileLastDragY = ""

$_WebdriverSearchTypeInfo[1][1]= "class"
$_WebdriverSearchTypeInfo[1][2]= "class name"

$_WebdriverSearchTypeInfo[2][1]= "css"
$_WebdriverSearchTypeInfo[2][2]= "css selector"

$_WebdriverSearchTypeInfo[3][1]= "id"
$_WebdriverSearchTypeInfo[3][2]= "id"

$_WebdriverSearchTypeInfo[4][1]= "name"
$_WebdriverSearchTypeInfo[4][2]= "name"

$_WebdriverSearchTypeInfo[5][1]= "xpath"
$_WebdriverSearchTypeInfo[5][2]= "xpath"

$_WebdriverSearchTypeInfo[6][1]= "link"
$_WebdriverSearchTypeInfo[6][2]= "link text"

$_WebdriverSearchTypeInfo[7][1]= "partial link"
$_WebdriverSearchTypeInfo[7][2]= "partial link text"

$_WebdriverSearchTypeInfo[8][1]= "tag"
$_WebdriverSearchTypeInfo[8][2]= "tag name"

;local $a, $b
;local $x="   {css ,    123   456 }   "
;debug(getWebdriverParamTypeAndValue ($x, $a, $b))
;debug($a, $b)


; webdriver ���� Ȯ��
func isWebdriverParam ($sStr)

	$sStr = _Trim($sStr)

	return _iif( stringLeft($sStr,1)= "{" and StringRight($sStr,1)= "}", True,False)

endfunc

func getWebdriverParam ($sStr)

	return _Trim(stringmid($sStr,2,stringlen($sStr)-2))

endfunc


; webdriver �˻� Ÿ�԰�, ��� ���� ����
func getWebdriverParamTypeAndValue ($sStr, byref $sSearchType, byref $sSearchValue)

	local $i
	local $bSuccess = False
	local $sSearchTypeKey
	local $sSearchTypeIndex
	local $iSplitPos

	$sStr = _Trim($sStr)
	$sSearchType = ""
	$sSearchValue = ""

	if isWebdriverParam ($sStr) then
		$sStr = stringmid($sStr,2,stringlen($sStr)-2)
		$iSplitPos = StringInStr($sStr,":")

		if $iSplitPos > 0 then



			$sSearchTypeKey = StringLower(_Trim(Stringleft ($sStr, $iSplitPos -1)))
			$sSearchTypeIndex =  _ArraySearch($_WebdriverSearchTypeInfo,$sSearchTypeKey,0,0,0,0,1,1)

			$sSearchValue = StringStripWS(Stringmid ($sStr, $iSplitPos + 1, stringlen($sStr) - $iSplitPos + 1), $STR_STRIPLEADING)
			convertHtmlChar ($sSearchValue)

			if $sSearchTypeIndex > 0 Then
				$sSearchType = $_WebdriverSearchTypeInfo[$sSearchTypeIndex][2]
				$bSuccess = True
			endif
		endif

	endif

	return $bSuccess

endfunc


; ���� ���� �Ķ���� ���� ���� �� Ŀ�ؼ� ���ڿ� �����\

;local $a, $b, $c
;debug(setWebdriverConnectionInfo("{host=172.165.22.22:1711,xxxx=c:\sss,yyty=111}",$a, $b))
;debug($a)
;debug($b)

func getWebdriverConnectionInfo($sParam, byref $sHost, byref $aParamInfo)

	local $bSuccess = True
	local $sConnectionInfo  = ""
	local $aDumyParamInfo[1][3]
	local $aMainParamInfo
	local $aSubParamInfo

	$aParamInfo = $aDumyParamInfo

	if isWebdriverParam($sParam)  then

		$sParam = _Trim(stringmid($sParam,2,stringlen($sParam)-2))
		$aMainParamInfo = StringSplit($sParam,",",1)

		redim $aParamInfo[ubound($aMainParamInfo,1) -1][3]

		for $i=1 to ubound ($aMainParamInfo) -1

			$aSubParamInfo = StringSplit($aMainParamInfo[$i],"=",1)
			; xxx=yyy ���°� �ƴ� ��� �ٷ� ����

			if ubound($aSubParamInfo) <> 3 then
				$bSuccess =False
				exitloop
			endif

			; ù��°�� "host" ������ �����Ǿ�� ��.
			if $i=1 then
				if _Trim($aSubParamInfo[1]) = "host" Then
					$sHost = _Trim($aSubParamInfo[2])
				Else
					$bSuccess =False
					exitloop
				endif
			else
				$aParamInfo [$i-1][1] = _Trim($aSubParamInfo[1])

				$aParamInfo [$i-1][2] = _Trim($aSubParamInfo[2])

				; T/F �� ��� �ش� ���ڷ� ����
				if StringLower($aParamInfo [$i-1][2]) = "true" then $aParamInfo [$i-1][2] = True
				if StringLower($aParamInfo [$i-1][2]) = "false" then $aParamInfo [$i-1][2] = False

			endif

		next

	endif

	return $bSuccess

endfunc


func _WD_getBrowserType()

	local $sbrowserType

	;debug("_WD_getBrowserName =" & _WD_getBrowserName())

	Switch StringLower(_Trim(_WD_getBrowserName()))
		case "chrome","firefox","internet explorer","ie","safari"
			$sbrowserType = "WEB"
	EndSwitch

	return $sbrowserType

endfunc


func _WD_getBrowserName()

	local $i, $j
	local $aSessions
	local $aSession
	local $acapabilities
	local $iSessionIndex = -1
	local $icapabilitiesIndex = -1
	local $sbrowserName
	local $sRet = ""
	local $sSessionID

	$sSessionID = $_webdriver_current_sessionid

	if _WD_get_sessions ($sRet) then
		;_jdebug($sRet)
		$aSessions = _jsonquery($sRet, "value")
		;$aSessions = $sRet

		;debug($aSessions)

		for $i=0 to ubound($aSessions) -1

			$aSession = $aSessions[$i]
			;debug($aSession)

			for $j=0 to ubound($aSession) -1
				;debug($aSession[$j][0],$aSession[$j][1] ,$sSessionID)
				if $aSession[$j][0] = "id" and $aSession[$j][1] = $sSessionID then
					$iSessionIndex = $i
				endif
				if $aSession[$j][0] = "capabilities" then $icapabilitiesIndex = $j
			next

			if $iSessionIndex > -1 then
				;_msg("�Ծ�")
				$acapabilities = $aSession[$icapabilitiesIndex][1]

				for $j=0 to ubound($acapabilities) -1

					if $acapabilities[$j][0] = "browserName" then

						$sbrowserName = $acapabilities[$j][1]
						exitloop
					endif
				next
			endif

		next

	endif

	return $sbrowserName

endfunc


func _appium_actions_tap($sElementID, $x="", $y="")

	local $bSuccess = False
	local $sRet
	local $sActions
	local $aActionsOptions[2]

	$aActionsOptions[0] = MakeJSonActionsOptionPress ($sElementID, $x, $y)
	$aActionsOptions[1] = MakeJSonActionsOptionRelease ()

	$sActions = MakeJSonActions ($_webdriver_current_sessionid, $aActionsOptions)
	$bSuccess = _appium_action ($sActions)

	return $bSuccess

endfunc


func _appium_action ($sActions)

	local $bSuccess = False
	local $sRet

	;debug($sActions)
	$bSuccess = requestWebdriver("POST", "session/" & $_webdriver_current_sessionid & "/touch/perform" , $sActions, $sRet )


	return $bSuccess

endfunc


func _WD_MoveAndAction($sElementID, $sActionCommand, $Button = 0, $iOffsetX=0, $iOffsetY=0)

	local $bSuccess = False
	local $sRet = ""
	local $ElementX, $ElementY, $x, $y
	local $x, $y
	local $i
	local $iClickCount = 1
	local $sMobileCommand
	local $sBodyID
	local $bForceDirectClick = False
	local $ilast_elementID =""
	local $ilast_elementX =""
	local $ilast_elementY =""

	$bSuccess = False

	;$iOffsetX = String($iOffsetX)
	;$iOffsetY = String($iOffsetY)

	;if True then
	if _WD_isTestPlatformWEB() then
		;debug("appium click")
		;�� ������ ���

		Switch $sActionCommand

			case "/moveto", "/click", "/buttondown", "/buttonup", "/doubleclick"


				if $sElementID <> ""  and $bForceDirectClick = False  then
					; TAG ���·� ã�Ƽ� Ŭ��
					; �÷����� ���� ��쿡�� �̵��� Ŭ���ϵ���

					$bSuccess = _WD_get_element_location($sElementID,  $ElementX,  $ElementY)

					if $ElementX = 0 or $ElementY = 0 then $bForceDirectClick = True

					;debug("directclick.. : " & $bForceDirectClick)

					if $bForceDirectClick = False then
						$bSuccess = _getWebdriverParam("POST", "/moveto", $sRet, 'element', $sElementID,"xoffset",$iOffsetX,"yoffset", $iOffsety)
					endif
					;$bSuccess= _WD_click($sElementID, $Button)


				else
					; WEB ���� �̹��� Ÿ������ ã�Ƽ� Ŭ��

					; ���� ����� ID�� ���� ��� �ش� ID�������� �����ǥ ���
					if $_webdriver_last_elementid <> "" then
						if _WD_get_element_location_in_view($_webdriver_last_elementid, $ilast_elementX, $ilast_elementY) Then
							$ilast_elementID = $_webdriver_last_elementid
						endif
					endif

					; �ֱٻ�� ID�� ���ų� ��ǥ���� �������µ� ������ ���� ��� "body"�� �������� �����
					if $ilast_elementID = "" then
							$ilast_elementID = _WD_find_element_by("xpath", "//body")
							$ilast_elementX = 0
							$ilast_elementY = 0
					endif

					;debug($ilast_elementX,$ilast_elementY)

					$bSuccess = _getWebdriverParam("POST", "/moveto" , $sRet, "element",$ilast_elementID, "xoffset", $iOffsetX - $ilast_elementX, "yoffset" , $iOffsety - $ilast_elementY)


					;$sBodyID = _WD_find_element_by("xpath", "//*")
					;$bSuccess = _WD_actions_tap($sBodyID)
					;$bSuccess = _appium_actions_tap ("", $iOffsetX, $iOffsetY)

				endif

				if $bSuccess then

					if $sElementID <> "" then $_webdriver_last_elementid = $sElementID

					if not($sActionCommand = "/moveto") then
						sleep(1)
						;msg($sActionCommand)


						; OPTION �� ���� ��ǥ�� ���� ��쿡�� �ٷ� Ŭ���ϵ��� ��
						if $bForceDirectClick then
							$bSuccess = _WD_click($sElementID, "")
						else
							$bSuccess = _getWebdriverParam("POST", $sActionCommand, $sRet, 'button', $Button)
						endif

					endif

				endif

			case Else
				$_webdriver_last_errormsg = "Webdriver���� �������� �ʴ� ����Դϴ�." & $sActionCommand
				$bSuccess = False

		EndSwitch

	else
		;debug("webdriver click")
		$_webdriver_last_elementid = $sElementID

		$bSuccess = _WD_get_element_location($sElementID,  $ElementX,  $ElementY)

		$x = $ElementX +  $iOffsetX
		$y = $ElementY +  $iOffsetY



		Switch $sActionCommand


			; "/longClick" ���� ���̵� ���� �߻�
			case  "/click", "/doubleclick"

				if $sActionCommand = "/doubleclick" then $iClickCount = 2

				;$bSuccess = _getWebdriverParam("POST", "/touch/tap" , $sRet, "element",  $sElementID, "touchCount", _iif($sActionCommand="/click","1","2"))
				;$bSuccess =_WD_execute_script ("mobile: tap", $sRet, "element",  $sElementID, "touchCount", _iif($sActionCommand="/click","1","2"))
				;$bSuccess = _getWebdriverParam("POST", "/execute" , $sRet, "script", "mobile: tap", "args", _JSONEncode(_JSONArray(_JSONObject("touchCount","2"))))
				;$bSuccess = requestWebdriver("POST","session/" & $_webdriver_current_sessionid & "/execute", _JSONEncode(_JSONObject("script", "mobile: tap","args",_JSONArray(_JSONObject("touchCount","2", "element",$sElementID)))), $sRet)
				;$bSuccess = requestWebdriver("POST","session/" & $_webdriver_current_sessionid & "/touch/tap", _JSONEncode(_JSONObject("element",number($sElementID) )), $sRet)
				;$bSuccess = requestWebdriver("POST","session/" & $_webdriver_current_sessionid & "/touch/cliock", _JSONEncode(_JSONObject("element",$sElementID )), $sRet)


				; Appium ��
				;for $i=1 to $iClickCount
				;	$bSuccess = requestWebdriver("POST","session/" & $_webdriver_current_sessionid & "/execute", _JSONEncode(_JSONObject("script", "mobile: tap" ,"args",_JSONArray(_JSONObject("x",$x , "y",$y ,"touchCount","1")))), $sRet)
				;next

				;Not yet implemented
				;$bSuccess = requestWebdriver("POST","session/" & $_webdriver_current_sessionid & "/touch/down", _JSONEncode(_JSONObject("x",$x,"y",$y )), $sRet)

				;Not yet implemented
				;$bSuccess = requestWebdriver("POST","session/" & $_webdriver_current_sessionid & "/buttondown", _JSONEncode(_JSONObject("x",$x,"y",$y )), $sRet)

				; Webdriver �⺻

				; ����Ŭ���� ��� 0.1�� �� �� Ŭ��
				for $i=1 to $iClickCount
					if $i=2 then sleep (100)
					$bSuccess = _getWebdriverParam("POST", "/element/" & $sElementID &  $sActionCommand, $sRet)
				next


			case "/buttondown"
				$_WebdriverMobileLastDragX = $x
				$_WebdriverMobileLastDragY = $y
				$bSuccess = True

			case "/buttonup"
				$bSuccess = requestWebdriver("POST","session/" & $_webdriver_current_sessionid & "/execute", _JSONEncode(_JSONObject("script", "mobile: swipe","args",_JSONArray(_JSONObject("startX",$_WebdriverMobileLastDragX , "startY",$_WebdriverMobileLastDragY, "endX",$x , "endY",$y, "duration","1.8" )))), $sRet)
				$_WebdriverMobileLastDragX = ""
				$_WebdriverMobileLastDragY = ""

			case Else
				$_webdriver_last_errormsg = "Webdriver(Mobile)���� �������� �ʴ� ����Դϴ�." & $sActionCommand
		EndSwitch

	endif

	return $bSuccess

EndFunc



func _WD_get_windowhandles()

	local $sRet
	local $aWindowHandles [1]

	if _getWebdriverParam("GET", "/window_handles" , $sRet) then
		$aWindowHandles = (_jsonquery($sRet, "value"))
	endif

	return $aWindowHandles

endfunc


func _WD_find_element_with_highlight_by($sUsing, $sSearchTarget, $bhighlight, $iDelay)

	local $sRet
	local $sID
	local $i
	local $aCurrentFrames
	local $iLastUsedFrameIndex

	;debug("������ã�� 1"  )
	$iDelay = Number($iDelay)

	; ���� �����ӿ��� ���� ã�� ��
	$sID = _WD_find_element_by($sUsing, $sSearchTarget)

	; ������ ���ο��� �ѹ��� ã�ƺ�
	if $sID = ""  and _WD_isTestPlatformWEB() = True and $_WebdriverSubFramePath <> "" then
		_WD_focus_frame($_JSONNull)
		$sID = _WD_find_element_by($sUsing, $sSearchTarget)
	endif


	; ����ȭ�鿡 ���� ��� ���� �������� �˻���.
	if $sID = "" and  _WD_isTestPlatformWEB() = True Then

		; ��ü ������ ������ �о��
		;debug("������ã�� 2.5"  )

		do
			if checkScriptStopping() then return ""
		until _WD_get_allframes($aCurrentFrames)

		;debug("������ã�� 3"  )

		; ������ ��Ʈ ������ ã�� �������� ���� ��� 1�� ������ ������
		 $iLastUsedFrameIndex = _ArraySearch($aCurrentFrames,$_WebdriverSubFramePath,1,0,0,0,1,1)
		;debug($aCurrentFrames)
		if $iLastUsedFrameIndex > 0 then
			;debug("������ã�� XX : " & $iLastUsedFrameIndex  & " , " & $_WebdriverSubFramePath)
			;_ArrayDisplay($aCurrentFrames, "Original", Default, 8)
			_ArraySwap($aCurrentFrames,2,$iLastUsedFrameIndex)
			;_ArrayDisplay($aCurrentFrames, "Original", Default, 8)
		endif

		for $i=2 to ubound($aCurrentFrames) -1
			if checkScriptStopping() then return ""
			;debug("������ã�� : " & $i )
			if _WD_go_frame($aCurrentFrames[$i][1]) = True then

				$_WebdriverSubFramePath = $aCurrentFrames[$i][1]
				$sID = _WD_find_element_by($sUsing, $sSearchTarget)
				if $sID <> "" then
					ExitLoop
				endif
			endif
		next

	endif

	if $sID <> "" then $_webdriver_last_elementid = $sID

	; �÷����� ���ϰ�쿡��
	if $bhighlight and $sID <> "" and _WD_isTestPlatformWEB() = True  and ($iDelay > 0)  then

		_WD_execute_script ("arguments[0].setAttribute('style', 'color: yellow; border: 2px solid red;')",$sRet, _JSONObject("ELEMENT",$sID))
 		sleep($iDelay)
		_WD_execute_script ("arguments[0].setAttribute('style', '')",$sRet, _JSONObject("ELEMENT",$sID))
		sleep($iDelay)
	endif

	return $sID

endfunc

func _WD_get_allframes(byref $aAllFrames)
	; 2���� �迭�� ������ ��� ���� ������ ������ �о��

	local $i, $j
	local $aTemp[2][3]
	local $bAllSearch = True
	local $iAllFramesUbound
	local $iAllFrameNewIndex
	local $aFrames
	local $aTemp

	; ���� ���Խ�
	if IsArray($aAllFrames) = False then
		$aAllFrames = $aTemp
		$aAllFrames[1][1] = "X"
	endif

	$iAllFramesUbound = ubound($aAllFrames,1)
	;debug("���� : " & $iAllFramesUbound)
	for $i=1 to $iAllFramesUbound - 1
		; �湮 ����� ������ �湮�Ͽ� �ű� ���� frame�� �߰�
		if $aAllFrames[$i][2] = "" then
			$bAllSearch = False
			$aAllFrames[$i][2] = "S"
			if _WD_go_frame($aAllFrames[$i][1]) then
				$aFrames = _WD_find_elements_by("tag name", "iframe")
				;debug("�ű��߰� : " & ubound($aFrames,1))
				if ubound($aFrames,1) >  0 then
					;_msg("�ű��߰�21 : " & ubound($aFrames,1))
					redim $aAllFrames[$iAllFramesUbound + ubound($aFrames,1)][3]
					;debug (ubound($aAllFrames,1))
					;msg($aFrames)
					;msg("�ű��߰�22 : " & ubound($aFrames,1))
					;msg($aFrames)
					for $j=1 to ubound($aFrames,1)
						;debug("�ű��߰�3: " & ubound($aFrames,1))
						;debug("����:" &  ubound($aFrames,1) -1)
						$iAllFrameNewIndex = ($iAllFramesUbound -1) + $j
						$aTemp = $aFrames[$j-1]
						;_msg($aTemp)
						;debug ("�߰�:" & $iAllFrameNewIndex)
						$aAllFrames [$iAllFrameNewIndex][1] = $aAllFrames[$i][1] & "-" & $aTemp[1][1]
					next
				endif
			endif
		endif
	next

	return $bAllSearch

endfunc


func _WD_go_frame($sFrameID)

	; "0-11-22" ������ ���ڿ� ������ ������ �м��Ͽ� �ش� ���������� �̵�
	local $aID = StringSplit($sFrameID,"-")
	local $i
	local $bSuccess

	;debug("�̵�: " & $sFrameID)

	for $i=1 to ubound($aID,1)-1

		if $i=1 then
			$bSuccess = _WD_focus_frame($_JSONNull)
		else
			$bSuccess = _WD_focus_frame(_JSONObject("ELEMENT",$aID[$i]))
		endif

		if $bSuccess = False then ExitLoop
	next

	return $bSuccess

endfunc


func _WD_isTestPlatformWEB()

	if $_webdriver_testplatform = "" then $_webdriver_testplatform = _WD_getBrowserType()

	;_msg($_webdriver_testplatform)

	return _iif($_webdriver_testplatform = "WEB",True, False)

endfunc




; Appium ����


func MakeJSonActionstest()


	local $aActionsOptions[3]

	$aActionsOptions[0] = MakeJSonActionsOptionPress (8)
	$aActionsOptions[1] = MakeJSonActionsOptionMoveTo (4)
	$aActionsOptions[2] = MakeJSonActionsOptionRelease ()


	;{"sessionId":"23bad50b-59d9-4756-9222-a7b0dac18c15","actions":[{"options":{"element":"8","x":null,"y":null},"action":"press"},{"options":{"element":"4","x":null,"y":null},"action":"moveTo"},{"options":{},"action":"release"}]}

	return MakeJSonActions ("23bad50b-59d9-4756-9222-a7b0dac18c15", $aActionsOptions)

endfunc


func MakeJSonActions ($sSessionID, $aActionsOptions)

	local $sActionsObject  =""
	local $sActionsArray  =""
	local $sRet

	$sActionsObject = _JSONObject("sessionId",$sSessionID,"actions", $aActionsOptions)

	$sRet =_JSONEncode($sActionsObject)

	return  $sRet

endfunc


func MakeJSonActionsOptionPress ($sElementID="", $x = $_JSONNull, $y = $_JSONNull)

	return MakeJSonActionsOptionIDXYZ ("press", $sElementID, $x,  $y)


endfunc


func MakeJSonActionsOptionMoveTo ($sElementID="", $x = $_JSONNull, $y = $_JSONNull)

	return MakeJSonActionsOptionIDXYZ ("moveTo", $sElementID, $x,  $y)

endfunc


func MakeJSonActionsOptionIDXYZ ($sAction, $sElementID="", $x = $_JSONNull, $y = $_JSONNull)


	if $sElementID = "" Then
		return   _JSONObject("options",_JSONObject("x", $x, "y", $y),"action", $sAction)
	Else
		return   _JSONObject("options",_JSONObject("element",string($sElementID),"x", $x, "y", $y),"action", $sAction)
	endif


endfunc


func MakeJSonActionsOptionRelease ()

	return _JSONObject("options",_JSONObject(""),"action", "release")

endfunc





