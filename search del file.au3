#include <ButtonConstants.au3>
#include <GUIConstantsEx.au3>
#include <GuiStatusBar.au3>
#include <ListViewConstants.au3>
#include <WindowsConstants.au3>
#include <GuiListView.au3>
#include <File.au3>
#include <GUIConstants.au3>


#Region ### START Koda GUI section ### Form=
$Form1 = GUICreate("Search And Delete", 900, 500, 192, 124)
$StatusBar1 = _GUICtrlStatusBar_Create($Form1)
_GUICtrlStatusBar_SetMinHeight($StatusBar1, 33)
_GUICtrlStatusBar_SetText($StatusBar1, "Idle")
$search = GUICtrlCreateButton("Search", 750, 418, 129, 33)
$del = GUICtrlCreateButton("Delete", 608, 418, 129, 33)
$delall = GUICtrlCreateButton("Delete All", 465, 418, 129, 33)
$list = GUICtrlCreateListView("Files", 0, 0, 900, 410,$LBS_MULTIPLESEL)
_GUICtrlListView_SetColumnWidth ( $list, 0, 875 )
GUISetState(@SW_SHOW)
$warn = GUICtrlCreateRadio("Warning List", 360, 418, 75, 41)
$delete = GUICtrlCreateRadio("Delete List", 260, 418, 75, 41)
#EndRegion ### END Koda GUI section ###

Global $file = "F:\Download\dl\warninglst.txt"

While 1
	$nMsg = GUIGetMsg()
	If $nMsg = $GUI_EVENT_CLOSE Then Exit
	If $nMsg = $search Then search()
	If $nMsg = $del Then del()
	If $nMsg =$delall Then delall()
	If $nMsg = $warn Then $file = "F:\Download\dl\warninglst.txt"
	If $nMsg = $delete Then $file = "F:\Download\dl\dellist.txt"

WEnd

Func delall()
	_GUICtrlListView_SetItemSelected($list, -1, True, False)
	del()
	EndFunc

Func del()
	$a =0
	$delar=_GUICtrlListView_GetSelectedIndices($list, True)
	If IsArray($delar) Then
		For $y =1 to $delar[0]
			$item = _GUICtrlListView_GetItemText($list,$delar[$y]-$a)
			;MsgBox(1,"l", $delar[1])
			If FileRecycle($item)==1 Then
				_GUICtrlListView_DeleteItem($list, $delar[$y] -$a)
				$a=$a+1
			Else
				MsgBox(1, "Alert!", $item & "was not deleted.")
			EndIf
			Next
		EndIf
	EndFunc

Func search()
	_GUICtrlListView_DeleteAllItems($list)
	_GUICtrlStatusBar_SetText($StatusBar1, "Searching...")
	FileOpen($file, 0)
	For $i = 1 to _FileCountLines($file)
		$line = FileReadLine($file, $i)

		;GUICtrlCreateListViewItem($line, $list)
		$array = _FileListToArrayRec("F:\Download\dl\Unread\", "*" & $line & "*", 1, 1, 0,2)
		If IsArray($array) Then addlist($array)
	Next
	FileClose($file)
	_GUICtrlStatusBar_SetText($StatusBar1, "Done")
EndFunc

Func addlist($var)
	For $x = 1 to ($var[0])
			If _GUICtrlListView_FindText($list, $var[$x],-1)== -1 Then
			GUICtrlCreateListViewItem($var[$x], $list)
			;MsgBox(1, "k", "printing from sec " & $x)
			EndIf
			Next
	EndFunc