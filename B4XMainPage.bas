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
	Private minScale As Float = 0.001
	Private maxScale As Float = 0.5
	Private currentRotationX As Float = 90   ''90
	Private currentRotationY As Float = -90
	Private currentRotationZ As Float = -90
	Private currentTranslationX As Float = 0
	Private currentTranslationY As Float = 0
	Private currentTranslationZ As Float = -1.5 ' Move sofa in front of camera
	
	Private isTranslateMode As Boolean = False
	Private isRotatingX As Boolean = False
	Private isRotatingY As Boolean = False
	Private isScaling As Boolean = False
	Private maxWorldMoveX As Float = 1.0
	Private maxWorldMoveY As Float = 2.0
	
	Type EntityProps(currentScale As Float, rotationX As Float, rotationY As Float, rotationZ As Float, translationX As Float, translationY As Float, translationZ As Float)
	Private Properties As EntityProps
	Private pnlMenu As B4XView
End Sub

Public Sub Initialize
'	B4XPages.GetManager.LogEvents = True
End Sub

'This event will be called once, before the page becomes visible.
Private Sub B4XPage_Created (Root1 As B4XView)
	Root = Root1
	Root.LoadLayout("MainPage")
End Sub

Private Sub InitializeGL
	Log("initializing GL")
	pnlParent = xui.CreatePanel("parent")
	Root.AddView(pnlParent, 0, 0, 100%x, 100%y)
	pnlParent.SetLayoutAnimated(0, 0, 0, 100%x, 100%y)
	GD.SetOnGestureListener(pnlParent, "gesture")
	pnlParent.AddView(glsurface, 0, 0, 100%x, 100%y)
	glsurface.Resume
	pnlParent.LoadLayout("Menu")
	pnlMenu.BringToFront
End Sub

private Sub B4XPage_Appear
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
	
	Properties.Initialize
	
	Properties.currentScale = currentScale
	Properties.rotationX = currentRotationX
	Properties.rotationY = currentRotationY
	Properties.rotationZ = currentRotationZ
	Properties.translationX = currentTranslationX
	Properties.translationY = currentTranslationY
	Properties.translationZ = currentTranslationZ
	
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
		hello.Initialize(gl, Common.motionTrackingCameraDeviceType)
		initialized = True
	Else
		hello.recreate_context(gl)
	End If
	hello.Start(gl)
'''	hello.StartTracker
End Sub

private Sub glsurface_SurfaceChanged(gl As GL2, width As Int, height As Int) 'Called when the surface has changed size.
	Log("glsurface_SurfaceChanged")
	mwidth = width
	mheight = height
End Sub

private Sub glsurface_Draw(gl As GL2) 'The view wants to be drawn using the supplied GL10
	If Not(initialized) Then Return
	
	gl.glClear(Bit.Or(gl.GL_COLOR_BUFFER_BIT, gl.GL_DEPTH_BUFFER_BIT))
	hello.Render(gl, mwidth, mheight, Properties)
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
	
End Sub

Sub calibration_CalibrationDownloadStatus (Status As Int, Error As String)
	LogColor($"calibration status: ${Status} Error: ${Error}"$, Colors.Magenta)

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

	func.ARCoreIsInstalled(minimumSupportedVersion, knownLatestVersion)

End Sub

Sub func_CameraDeviceTypeSupported (CamType As Int)
	Log("cameraDeviceTypeSupported: " & CamType)
	Common.motionTrackingCameraDeviceType = CamType
	
	glsurface.Initialize2(glsurface.RENDERMODE_CONTINUOUSLY, "glsurface", 16, 0)
	CallSubDelayed(Me, "InitializeGL")
	LogColor("initialized glsurface", Colors.Blue)

	calibration.Dispose

End Sub

Private Sub DownloaderDispose
	downloader.Dispose
End Sub

private Sub CalibrationDispose
	calibration.Dispose
End Sub

Sub Gesture_onTouch(Action As Int, X As Float, Y As Float, MotionEvent As Object) As Boolean
	Select Action
		Case GD.ACTION_DOWN
			touchStartX = X
			touchStartY = Y
			dragging = False
			isTranslateMode = False
			translationStartX = currentTranslationX
			translationStartY = currentTranslationY
'''			Log("touch down at: " & X & " , " & Y)
		Case GD.ACTION_MOVE
			If isTranslateMode And Not(isRotatingX) And Not(isRotatingY) And Not(isScaling) Then
				Dim dx As Float = x - touchStartX
				Dim dy As Float = Y - touchStartY
				
				Dim percentX As Float = dx / GetDeviceLayoutValues.Width
				Dim percentY As Float = dy / GetDeviceLayoutValues.Height
				
				If Abs(dx) > 5 Or Abs(dy) > 5 Then
					dragging = True
'''					Log("Dragging: Δx=" & dx & ", Δy=" & dy)
					currentTranslationX = translationStartX + percentX * maxWorldMoveX
					currentTranslationY = translationStartY - percentY * maxWorldMoveY
					Properties.translationX = currentTranslationX
					Properties.translationY = currentTranslationY
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
			isRotatingX = False
			isRotatingY = False
			isScaling = False
	End Select
	Return True 'True = Handle this touch event, False = Ignore it
End Sub

Sub Gesture_onScroll(distanceX As Float, distanceY As Float, MotionEvent1 As Object, MotionEvent2 As Object)
	isTranslateMode = True
End Sub

Sub Gesture_onRotation(Degrees As Double, MotionEvent As Object)
	If isScaling Then Return
	
	Dim pointerCount As Int = GD.getPointerCount(MotionEvent)
	LogColor("pointerCount: " & pointerCount, xui.Color_Magenta)
	Dim smoothedDegrees As Double = Degrees * 0.02
'''	LogColor("Degrees: " & Degrees, xui.Color_Red)
	If pointerCount >= 2 Then
'''		Dim x0 As Float = GD.getX(MotionEvent, 0)
'''		Dim y0 As Float = GD.getY(MotionEvent, 0)
'''		Dim x1 As Float = GD.getX(MotionEvent, 1)
'''		Dim y1 As Float = GD.gety(MotionEvent, 1)
		
'''		Dim dx As Float = Abs(x1 - x0)
'''		Dim dy As Float = Abs(y1 - y0)
		
		'''If dx > dy Then
		If isRotatingX Then
			LogColor("rotating X", xui.Color_Blue)
			Properties.rotationX = (Properties.rotationX + smoothedDegrees) Mod 360
		Else if isRotatingY Then
			Properties.rotationY = (Properties.rotationY + smoothedDegrees) Mod 360
			LogColor("rotating Y", xui.Color_Green)
		End If
	End If
'''	End If
End Sub

Sub Gesture_onPinchOpen(NewDistance As Float, PreviousDistance As Float, MotionEvent As Object)
	If isRotatingX Or isRotatingY Then Return
	
'''	isScaling = True
	If isScaling Then
	Dim scaleFactor As Float = NewDistance / PreviousDistance
	LogColor("Pinch Open - ScaleFactor: " & scaleFactor, xui.Color_Green)

	' Apply scale (increase)
	Properties.currentScale = Min(Properties.currentScale * scaleFactor, maxScale)
	LogColor("Scaled Up: " & Properties.currentScale, xui.Color_Blue)
	End If
End Sub

Sub Gesture_onPinchClose(NewDistance As Float, PreviousDistance As Float, MotionEvent As Object)
	If isRotatingX Or isRotatingY Then Return
	
	If isScaling Then
	Dim scaleFactor As Float = NewDistance / PreviousDistance
	LogColor("Pinch Close - ScaleFactor: " & scaleFactor, xui.Color_Red)

	' Apply scale (decrease)
	Properties.currentScale = Max(Properties.currentScale * scaleFactor, minScale)
	LogColor("Scaled Down: " & Properties.currentScale, xui.Color_Magenta)
	End If
End Sub

Private Sub btnMenu_Click
	Dim btn As Button = Sender
	Select btn.Tag
		Case "RotateX"
			isRotatingX = True
			isRotatingY = False
			isScaling = False
		Case "RotateY"
			isRotatingY = True
			isRotatingX = False
			isScaling = False
		Case "Resize"
			isRotatingY = False
			isRotatingX = False
			isScaling = True
	End Select
End Sub