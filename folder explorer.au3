#include <ButtonConstants.au3>
#include <GUIConstantsEx.au3>
#include <GuiStatusBar.au3>
#include <ListViewConstants.au3>
#include <WindowsConstants.au3>
#include <GuiListView.au3>
#include <File.au3>
#include <GUIConstants.au3>


#Region ### START Koda GUI section ### Form=
$Form1 = GUICreate("Folder Explorer", 900, 500, 152, 32)
$StatusBar1 = _GUICtrlStatusBar_Create($Form1)
_GUICtrlStatusBar_SetMinHeight($StatusBar1, 33)
_GUICtrlStatusBar_SetText($StatusBar1, "Idle")
$search = GUICtrlCreateButton("Search (5)", 750, 418, 129, 33)
$del = GUICtrlCreateButton("Delete (9)", 608, 418, 129, 33)
$delall = GUICtrlCreateButton("Delete and List (7)", 465, 418, 129, 33)
$list = GUICtrlCreateListView("Files", 0, 0, 900, 410,$LBS_MULTIPLESEL)
_GUICtrlListView_SetColumnWidth ( $list, 0, 875 )
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###

Global $path = "F:\Download\dl\Unread"
Global $once = True
Global $warn = "F:\Download\dl\warninglst.txt"
Global $delete = "F:\Download\dl\dellist.txt"
HotKeySet ("{NUMPAD6}", "sel")
HotKeySet ("{NUMPAD2}", "down")
HotKeySet ("{NUMPAD8}", "up")
HotKeySet ("{NUMPAD4}","back")
HotKeySet ("{NUMPAD7}","delist")
HotKeySet ("{NUMPAD9}","del")
HotKeySet ("{NUMPAD5}","search")
;HotKeySet ("{NUMPAD8}","add")

While 1
	$nMsg = GUIGetMsg()
	If $once Then
		search()
		$once = False
	EndIf
	If $nMsg = $GUI_EVENT_CLOSE Then Exit
	If $nMsg = $search Then search()
	If $nMsg = $del Then del()
	If $nMsg =  $delall Then delist()

WEnd

Func back()
	$t = $path
	$pos = StringInStr($path, "\", 0, -1)
	$path = StringTrimRight($path, StringLen($path) - $pos + 1)
	search()
	$x = _GUICtrlListView_FindText($list, $t, -1, False)
	If Not ($x == -1) Then
		_GUICtrlListView_SetItemSelected($list, -1, False)
		_GUICtrlListView_SetItemSelected($list, $x, True)
		EndIf
	EndFunc

Func del()
	$a =0
	$delar=_GUICtrlListView_GetSelectedIndices($list, True)
	If IsArray($delar) Then
		For $y =1 to $delar[0]
			$item = _GUICtrlListView_GetItemText($list,$delar[$y]-$a)
			If FileRecycle($item)  Then
				_GUICtrlListView_DeleteItem($list, $item)
				$a=$a+1
			Else
				MsgBox(0, "Alert!", $item & " was not deleted.")
			EndIf
			Next
		EndIf
	_GUICtrlListView_SetItemSelected($list, 0, True)
	EndFunc

Func delist()
	$a =0
	$delar=_GUICtrlListView_GetSelectedIndices($list, True)
	If IsArray($delar) Then
		For $y =1 to $delar[0]
			$item = _GUICtrlListView_GetItemText($list,$delar[$y]-$a)
			If FileExists($item)==1 Then
				$file = $item
				$start = StringInStr($file,"[", 0)
				$file= StringTrimLeft($file, $start)
				$start = StringInStr($file, "]", 0)
				$file = StringTrimRight($file, StringLen($file) - $start+1)
				filesearch($file)
				_GUICtrlListView_DeleteItem($list, $item)
				If FileRecycle($item) == 0 Then MsgBox(0, "Alert!", $item & " was not deleted.")
				$a=$a+1
			Else
				MsgBox(0, "Alert!", $item & " was not found.")
			EndIf
			Next
		EndIf
	del()
	EndFunc

Func filesearch($name)
	$file = $warn
	$found = False
	$handle = FileOpen($file)
	For $i = 1 to _FileCountLines($file)
		$line = FileReadLine($file, $i)
		If $line == $name Then
			$found = True
			ExitLoop
		EndIf
		Next
	FileClose($handle)
	If Not $found Then
		$handle = FileOpen($file, 1)
		If FileWriteLine($handle, $name) == 0 Then MsgBox(0, "Alert!", "error")
	Else
		MsgBox(0, "Alert!", $name & " is already on the list.")
	EndIf
	FileClose($handle)
	EndFunc

Func search()
	_GUICtrlListView_DeleteAllItems($list)
	_GUICtrlStatusBar_SetText($StatusBar1, "Searching...")
	$array = _FileListToArrayRec($path, "*", 0, 0, 1, 2)
	If IsArray($array) Then addlist($array)
	_GUICtrlListView_SetItemSelected($list, 0, True)
	_GUICtrlStatusBar_SetText($StatusBar1, "Done")
EndFunc

Func down()
	$location = _GUICtrlListView_GetSelectedIndices($list, True)
	If UBound($location) > 1 Then
		If _GUICtrlListView_GetItemCount($list) -1 == $location[1] Then
			_GUICtrlListView_SetItemSelected($list, $location[1], True)
		ElseIf _GUICtrlListView_GetItemCount($list) > $location[1] Then
			_GUICtrlListView_SetItemSelected($list, $location[1], False)
			_GUICtrlListView_SetItemSelected($list, $location[1]+1, True)
		EndIf
	Else
	_GUICtrlListView_SetItemSelected($list, 0, True)
	EndIf
EndFunc

Func up()
	$location = _GUICtrlListView_GetSelectedIndices($list, True)
	If UBound($location) > 1 Then
		If $location[1] ==0 Then
			_GUICtrlListView_SetItemSelected($list, $location[1], True)
		ElseIf _GUICtrlListView_GetItemCount($list) > $location[1] Then
			_GUICtrlListView_SetItemSelected($list, $location[1], False)
			_GUICtrlListView_SetItemSelected($list, $location[1]-1, True)
		EndIf
	Else
	_GUICtrlListView_SetItemSelected($list, 0, True)
	EndIf
EndFunc

Func sel()
	$location = _GUICtrlListView_GetSelectedIndices($list, True)
	If UBound($location) > 1 Then
	$files = _GUICtrlListView_GetItemText($list,$location[1])

		If DirGetSize($files) < 0 Then ;If not a directory
			ShellExecute($files)
		Else
			$path = $files
			search()
		EndIf
	EndIf
EndFunc

Func addlist($var)
	For $x = 1 to ($var[0])
			If _GUICtrlListView_FindText($list, $var[$x],-1, False)== -1 Then
			GUICtrlCreateListViewItem($var[$x], $list)
			EndIf
			Next
	EndFunc