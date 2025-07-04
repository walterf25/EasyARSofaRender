B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=9.85
@EndOfDesignText@
#Region Shared Files
#CustomBuildAction: folders ready, %WINDIR%\System32\Robocopy.exe,"..\..\Shared Files" "..\Files"
'Ctrl + click to sync files: ide://run?file=%WINDIR%\System32\Robocopy.exe&args=..\..\Shared+Files&args=..\Files&FilesSync=True
#End Region

'Ctrl + click to export as zip: ide://run?File=%B4X%\Zipper.jar&Args=Project.zip

Sub Class_Globals
	Private Root As B4XView
	Private xui As XUI
	
	Private rp As RuntimePermissions
	Private glsurface As GLSurfaceView2
	Private initialized As Boolean = False
	Private hello As SofaTracker
	Private mwidth, mheight As Int
	
	Private GD As GestureDetector
	Private pnlParent As B4XView
	
	Private downloader As ARCoreDownloader
	Private calibration As CalibrationDownloader
	Private func As Function
	Private minimumSupportedVersion As String = "1.3.180604066"
	Private knownLatestVersion As String = "1.31.221020223"
	Public easy As B4AEasyAR
	Type ARCoreDownloaderStatus (Successful As Int, NotMoridifed As Int, ConnectionError As Int, UnexpectedError As Int)
	Private downloaderstatus As ARCoreDownloaderStatus

	Private touchStartX, touchStartY As Float
	Private translationStartX As Float
	Private translationStartY As Float
	Private scaleFactor As Float = 0.01
	Private currentTranslationX As Float
	Private currentTranslationY As Float
	Private dragging As Boolean = False
	
	Private currentScale As Float = 0.002 ' Starting scale to fit sofa
	Private currentRotationX As Float = -90
	Private currentRotationY As Float = 0
	Private currentRotationZ As Float = -90
	Private currentTranslationX As Float = 0
	Private currentTranslationY As Float = 0
	Private currentTranslationZ As Float = -2.2 ' Move sofa in front of camera
	
	Private isTranslateMode As Boolean = False
	Private isRotating As Boolean = False
	Private maxWorldMoveX As Float = 1.0
	Private maxWorldMoveY As Float = 0.5
End Sub

Public Sub Initialize
'	B4XPages.GetManager.LogEvents = True
End Sub

'This event will be called once, before the page becomes visible.
Private Sub B4XPage_Created (Root1 As B4XView)
	Root = Root1
	Root.LoadLayout("MainPage")
	
'''	easy.Initialize("easy", "/SMnMvkwPy7hVoh9YDVOcPhG2bCP7ADaHTgPSc0RERn5ARcEzQwASYJAAwrUFhEZ3lBBWYhSRCvfDxUC1EwXBNVAWEnVAwcf3RA/DsErEEmCU1hJ1AsXDtYRERiaWC8QmgABBdwOESLcEVZR4z9YSc4DBgLZDAAYmlgvSdsNGQbNDB0fwUApR5oSGArMBBsZ1RFWUeNAAwLWBhscy0BYSdUDF0nlTlYG1wYBB90RVlHjQAcO1hERRfEPFQzdNgYK2wkdBd9AWEnLBxoY3Uw3B9cXEDndARsM1gsAAtcMVkeaEREFywdaOd0BGxncCxoMmk5WGN0MBw6WLRYB3QEAP8oDFwDRDBNJlEAHDtYREUXrFwYN2QERP8oDFwDRDBNJlEAHDtYREUXrEhUZywcnG9kWHQrULxUbmk5WGN0MBw6WLxsf0Q0aP8oDFwDRDBNJlEAHDtYREUX8BxoY3TEECswLFQf1AwRJlEAHDtYREUX7IzA/ygMXANEME0nlTlYOwBIdGd02HQbdMQAK1RJWUdYXGAeUQB0Y9A0XCtRATg3ZDgcOxU4PSdoXGg/UBz0Py0BOMJoBGwaWBREF3REdGJYHFRjBAwZJ5U5WHdkQHQrWFgdJgjlWCNcPGR7WCwASmj9YScgOFR/eDQYGy0BOMJoDGg/KDR0Pmj9YSdUNEB7UBwdJgjlWGN0MBw6WKxkK3wcgGdkBHwLWBVZHmhERBcsHWijUDQEP6gcXBN8MHR/RDRpJlEAHDtYREUXqBxcEygYdBd9AWEnLBxoY3Uw7CdIHFx/sEBUI0wsaDJpOVhjdDAcOljEBGd4DFw7sEBUI0wsaDJpOVhjdDAcOljEECsoRETjIAwAC2Q45CshAWEnLBxoY3Uw5BMwLGwXsEBUI0wsaDJpOVhjdDAcOliYRBcsHJxvZFh0K1C8VG5pOVhjdDAcOliE1L+wQFQjTCxoMmj9YSd0aBALKByAC1QcnH9kPBEmCDAEH1E5WAssuGwjZDlZR3gMYGN0fWBCaAAEF3A4RItwRVlHjQFY2lEACCsoLFQXMEVZR40AXBNUPAQXRFg1J5U5WG9QDAA3XEBkYmlgvSdENB0nlTlYG1wYBB90RVlHjQAcO1hERRfEPFQzdNgYK2wkdBd9AWEnLBxoY3Uw3B9cXEDndARsM1gsAAtcMVkeaEREFywdaOd0BGxncCxoMmk5WGN0MBw6WLRYB3QEAP8oDFwDRDBNJlEAHDtYREUXrFwYN2QERP8oDFwDRDBNJlEAHDtYREUXrEhUZywcnG9kWHQrULxUbmk5WGN0MBw6WLxsf0Q0aP8oDFwDRDBNJlEAHDtYREUX8BxoY3TEECswLFQf1AwRJlEAHDtYREUX7IzA/ygMXANEME0nlTlYOwBIdGd02HQbdMQAK1RJWUdYXGAeUQB0Y9A0XCtRATg3ZDgcOxT8J2YyJ41xnH7mRl21U+18rsCouUe/2Br385CIFGROpcHDzJSY7lsH2SNvNAxG9HhHArchAk0tck9EXLjENPJ5qE+olUPfJgBegreKhSzab6hEZE4tCL49ztBIpara9l5tgG+aiOLnmQHtQBsZrvONXl++zfFKmpv72hDmugleVOZ3Jh2K+6tXbJGFmiJ44juN26F5If6RhSauxumUBQm5N2MFB7m5Osq92yY9S0Rmt0gnYvV6wXHVyQuWjAxqrwTmzMrpQJDBEGXwZpK9aVYs6TRqj9cY1UjX1uMcnv8dkKU2j7HYLY3egxPzrRPlKbVyXqoQg0rMMWwb7fw+BuGJ0aw==")
'''	
'''	downloaderstatus.Initialize
'''	downloaderstatus.Successful = 0
'''	downloaderstatus.NotMoridifed = 1
'''	downloaderstatus.ConnectionError = 2
'''	downloaderstatus.UnexpectedError = 3
'''
'''	rp.CheckAndRequest(rp.PERMISSION_CAMERA)
'''	wait for B4XPage_PermissionResult (Permission As String, Result As Boolean)
'''	
'''	If Result = True Then
'''		LogColor("permission granted...", xui.Color_Blue)
'''	End If
'''	
'''	downloader.Initialize("downloader")
'''	calibration.Initialize("calibration")
'''	func.Initialize("func")
'''
'''	downloader.Download
	
'''	glsurface.Initialize3(glsurface.RENDERMODE_CONTINUOUSLY, "glsurface")
	
'''	Root.AddView(glsurface, 0, 0, 100%x, 100%y)

End Sub

Private Sub InitializeGL
	Log("initializing GL")
	pnlParent = xui.CreatePanel("parent")
	Root.AddView(pnlParent, 0, 0, 100%x, 100%y)
	pnlParent.SetLayoutAnimated(0, 0, 0, 100%x, 100%y)
	GD.SetOnGestureListener(pnlParent, "gesture")
	pnlParent.AddView(glsurface, 0, 0, 100%x, 100%y)
	glsurface.Resume
End Sub

private Sub B4XPage_Appear
'''	If glsurface.IsInitialized Then
'''		glsurface.Resume
'''	End If
	Log("B4XPage_Appear")
	
	easy.Initialize("easy", "PrkdJzqqBTsizOEG+vr5DTMV3xXDS/3UEmY1XA6LKww6my0RDpY6XEHaOR8XjCsMHcp7TEvIfj4clS8XF9YtERbaYlwWmT0KHooFGwKxKlxByWJcF5EtGxWLKw1ZwhUFWZo7EB+UKzcfi2xEIKViXA2ZPBcaljoNWcIVXBiXIxMOlicKAtoTUlmIIh8PniEMFotsRCDaORcVnCEJCNpiXBaZLVwm1GwTFJw7Eh6LbEQg2j0bFYsrUDKVLxkerDwfGJMnEBzaYlwInSANHtYNEhSNKiwemyEZFZE6FxSWbFJZiysQCJ1gLB6bIQwfkSAZWdRsDR6WPRtVtywUHps6KgmZLRUSlilcV9o9GxWLK1AojTwYGpsrKgmZLRUSlilcV9o9GxWLK1AoiC8MCJ0dDhqMJx8XtS8OWdRsDR6WPRtVtSEKEpcgKgmZLRUSlilcV9o9GxWLK1A/nSANHqs+Hw+RLxI2mT5cV9o9GxWLK1A4uQoqCZktFRKWKVwm1GwbA4gnDB6sJxMeqzofFohsRBWNIhJX2icNN5ctHxfadBgalD0bBtQ1XBmNIBoXnQcaCNp0JVmbIRNVnysQHosnDVWLIRgaiisQH508GwnaE1JZji8MEpkgCgjadCVZmyETFo0gFw+BbCNX2j4SGowoEQmVPVxBo2wfFZw8ERKcbCNX2iMRH40iGwjadCVZiysQCJ1gNxaZKRsvii8dEJEgGVnUbA0elj0bVbsiEQ6cHBsYlykQEownERXaYlwInSANHtYcGxiXPBoSlilcV9o9GxWLK1A0miQbGIwaDBqbJRcVn2xSWYsrEAidYC0OiigfGJ0aDBqbJRcVn2xSWYsrEAidYC0LmTwNHqs+Hw+RLxI2mT5cV9o9GxWLK1A2lzoXFJYaDBqbJRcVn2xSWYsrEAidYDoelj0bKIgvChKZIjMaiGxSWYsrEAidYD06vBoMGpslFxWfbCNX2isGC5E8Gy+RIxsojC8TC9p0EA6UIlJZkT0yFJsvElnCKB8XiysDV4NsHA6WKhIesSoNWcIVXFmlYlwNmTwXGpY6DVnCFVwYlyMTDpYnCgLaE1JZiCIfD54hDBaLbEQg2icRCNoTUlmVIRoOlCsNWcIVXAidIA0e1gcTGp8rKgmZLRUSlilcV9o9GxWLK1A4lCELH6orHRSfIBcPkSEQWdRsDR6WPRtVqisdFIoqFxWfbFJZiysQCJ1gMRmSKx0PrDwfGJMnEBzaYlwInSANHtYdCwmeLx0erDwfGJMnEBzaYlwInSANHtYdDhqKPRsoiC8KEpkiMxqIbFJZiysQCJ1gMxSMJxEVrDwfGJMnEBzaYlwInSANHtYKGxWLKy0LmToXGpQDHwvaYlwInSANHtYNPz+sPB8YkycQHNoTUlmdNg4SiisqEpUrLQ+ZIw5ZwiALF5RiXBKLAhEYmSJcQZ4vEgidMyMGu4pL395qccYTwcc/s1sy5oHpAnDsxfm/My6tnJsHlBinypCwPL5o13qdbHmt3V1SyV9BwpeZAzL9elfS+N943Hy2QxFQyJua42ug9Gj2SVkBqbhui2F2SkyJ1DRJmPKdBI8sdgIbVWp24NjEs2+nz+Yq2j9Zo6Xuo/Voc7o0DbVSWMZKF5zgVl64yIg+nXwnP0CEtd/50re6ea7jYsEg8mmYkn61dwWNvA1+HhR1wr43S5SFKNKoPJRFz4VjgDuqLMeDPYRy0+MKsTUxTz5/0cYQZeXB1rz+6QZz9TBS6RTenY+Q+cCOLU1z0PVErKSvNtTCsZTtl+tlOdtfe/hOfg==")
	
	rp.CheckAndRequest(rp.PERMISSION_CAMERA)
	wait for B4XPage_PermissionResult (Permission As String, Result As Boolean)
	
	If Result = True Then
		LogColor("permission granted...", xui.Color_Blue)
	End If
	
	downloaderstatus.Initialize
	downloaderstatus.Successful = 0
	downloaderstatus.NotMoridifed = 1
	downloaderstatus.ConnectionError = 2
	downloaderstatus.UnexpectedError = 3
	
	Log("initializing downloader")
	downloader.Initialize("downloader")
	Log("initializing calibration")
	calibration.Initialize("calibration")
	Log("initializing func")
	func.Initialize("func")

	Log("calling downloader")
	downloader.Download
End Sub

private Sub B4XPage_Disappear
	If glsurface.IsInitialized Then
		glsurface.Pause
		If initialized Then
			initialized = False
			hello.Stop
			hello.Dispose
			Dim hello As SofaTracker
		End If
	End If
End Sub

private Sub B4XPage_Foreground
	
End Sub

private Sub B4XPage_Background
	
End Sub

private Sub B4XPage_CloseRequest As ResumableSub
	LogColor("page close request: ", xui.Color_Red)
	initialized = False
	Return True
End Sub

private Sub glsurface_SurfaceCreated(gl As GL2) 'Called when the surface is created or recreated.
	Log("glsurface_Surfacecreated")
	Log("initialized from glsurface_SurfaceCreated: " & initialized)
	If Not(initialized) Then
		hello.Initialize(gl)
		initialized = True
	Else
		hello.recreate_context(gl)
	End If
	hello.Start(gl)
	hello.StartTracker
End Sub

private Sub glsurface_SurfaceChanged(gl As GL2, width As Int, height As Int) 'Called when the surface has changed size.
	Log("glsurface_SurfaceChanged")
	mwidth = width
	mheight = height
End Sub

private Sub glsurface_Draw(gl As GL2) 'The view wants to be drawn using the supplied GL10
'''	Log("glsurface_draw")
'''	Log("initialized: " & initialized)
	If Not(initialized) Then Return
	
	gl.glClear(Bit.Or(gl.GL_COLOR_BUFFER_BIT, gl.GL_DEPTH_BUFFER_BIT))
	hello.Render(gl, mwidth, mheight, currentTranslationX, currentTranslationY, currentRotationX)
End Sub

Sub downloader_ArCoreDeviceListDownloadStatus (Status As Int, Error As String)
	LogColor($"downloader status:  ${Status} Error: ${Error}"$, Colors.Blue)
	'''downloader.Dispose
	If Status = downloaderstatus.Successful Then
		LogColor("calibration file downloaded successfully", Colors.Blue)
	else if Status = downloaderstatus.NotMoridifed Then
		LogColor("calibration file is already the latest", Colors.Blue)
	else if Status = downloaderstatus.ConnectionError Then
		LogColor("calibration file download connection error", Colors.Blue)
	else if Status = downloaderstatus.UnexpectedError Then
		LogColor("calibration file download unexpected error", Colors.Blue)
	Else
		LogColor("calibration file download failed", Colors.Blue)
	End If
	
	
	calibration.Download
	
	downloader.Dispose
	
	'''CallSubDelayed(Me, "DownloaderDispose")
End Sub

Sub calibration_CalibrationDownloadStatus (Status As Int, Error As String)
	LogColor($"calibration status: ${Status} Error: ${Error}"$, Colors.Magenta)
	'''calibration.Dispose
	If Status = downloaderstatus.Successful Then
		LogColor("calibration file downloaded successfully", Colors.Magenta)
	else if Status = downloaderstatus.NotMoridifed Then
		LogColor("calibration file is already the latest", Colors.Magenta)
	else if Status = downloaderstatus.ConnectionError Then
		LogColor("calibration file download connection error", Colors.Magenta)
	else if Status = downloaderstatus.UnexpectedError Then
		LogColor("calibration file download unexpected error", Colors.Magenta)
	Else
		LogColor("calibration file download failed", Colors.Magenta)
	End If
	
	'''	calibration.Dispose

	
	func.ARCoreIsInstalled(minimumSupportedVersion, knownLatestVersion)
	
	

	
	'''	CallSubDelayed(Me, "CalibrationDispose")
End Sub

Sub func_CameraDeviceTypeSupported (CamType As Int)
	Log("cameraDeviceTypeSupported: " & CamType)
	Common.motionTrackingCameraDeviceType = CamType
	
	glsurface.Initialize2(glsurface.RENDERMODE_CONTINUOUSLY, "glsurface", 16, 0)
	'''Activity.AddView(glsurface, 0, 0, 100%x, 100%y)
	CallSubDelayed(Me, "InitializeGL")
	LogColor("initialized glsurface", Colors.Blue)
	
	'''	func.ARCoreCameraDeviceSupported(minimumSupportedVersion, knownLatestVersion)
	
	calibration.Dispose
	'''CallSubDelayed(Me, "InitializeGL")
End Sub

Private Sub DownloaderDispose
	downloader.Dispose
End Sub

private Sub CalibrationDispose
	calibration.Dispose
End Sub

Sub Gesture_onTouch(Action As Int, X As Float, Y As Float, MotionEvent As Object) As Boolean
'''	Log("onTouch action=" & Action & ", x=" & X & ", y=" & Y & ", ev=" & MotionEvent)
	Select Action
		Case GD.ACTION_DOWN
			touchStartX = X
			touchStartY = Y
			dragging = False
			isTranslateMode = False
			isRotating = False
			translationStartX = currentTranslationX
			translationStartY = currentTranslationY
'''			Log("touch down at: " & X & " , " & Y)
		Case GD.ACTION_MOVE
			If isTranslateMode And Not(isRotating) Then
				Dim dx As Float = x - touchStartX
				Dim dy As Float = Y - touchStartY
				
				Dim percentX As Float = dx / GetDeviceLayoutValues.Width
				Dim percentY As Float = dy / GetDeviceLayoutValues.Height
				
				If Abs(dx) > 5 Or Abs(dy) > 5 Then
					dragging = True
					Log("Dragging: Δx=" & dx & ", Δy=" & dy)
					currentTranslationX = translationStartX + percentY * maxWorldMoveX
					currentTranslationY = translationStartY + percentX * maxWorldMoveY
'''					LogColor("currentTranslationX: " & currentTranslationX, xui.Color_Blue)
'''					LogColor("currentTranslationY: " & currentTranslationY, xui.Color_Blue)
				End If
			End If
		Case GD.ACTION_UP
			If dragging Then
				Log("Drag finished.")
			Else
				Log("Tap detected.")
			End If
			dragging = False
			isTranslateMode = False
			isRotating = False
	End Select
	Return True 'True = Handle this touch event, False = Ignore it
End Sub

Sub Gesture_onScroll(distanceX As Float, distanceY As Float, MotionEvent1 As Object, MotionEvent2 As Object)
	isTranslateMode = True
End Sub

Sub Gesture_onRotation(Degrees As Double, MotionEvent As Object)
	isRotating = True
	LogColor("Degrees: " & Degrees, xui.Color_Red)
	currentRotationX = Degrees
	LogColor("currentRotationY: " & currentRotationX, xui.Color_Magenta)
End Sub