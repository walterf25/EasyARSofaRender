B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=13
@EndOfDesignText@
Sub Class_Globals
'''	Private camera As CameraDevice
	Private camera As ARCoreCameraDevice
	Private trackers As List
	Private bgRenderer As BGRenderer
'''	Private boxRenderer As BxRenderer2
	Private i2OAAdapter As InputFrameToOutputFrameAdapter
	Private throttler As InputFrameThrottler
	Private outputFrameBuffer As OutputFrameBuffer
	Private Engine As B4AEasyAR
	Private scheduler As DelayedCallbackScheduler
	Private previousInputFrameIndex = -1
	Private EasyARMotionTracker As Int = 1
	Private rp As RuntimePermissions
	Private utils As Utils
	Private tracker As SurfaceTracker
	Private modelRenderer As GLTFModelRenderer
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize(gl As GL2, motionTrackingCameraDeviceType As Int)
	recreate_context(gl)
	Engine.Initialize("engine", "PrkdJzqqBTsizOEG+vr5DTMV3xXDS/3UEmY1XA6LKww6my0RDpY6XEHaOR8XjCsMHcp7TEvIfj4clS8XF9YtERbaYlwWmT0KHooFGwKxKlxByWJcF5EtGxWLKw1ZwhUFWZo7EB+UKzcfi2xEIKViXA2ZPBcaljoNWcIVXBiXIxMOlicKAtoTUlmIIh8PniEMFotsRCDaORcVnCEJCNpiXBaZLVwm1GwTFJw7Eh6LbEQg2j0bFYsrUDKVLxkerDwfGJMnEBzaYlwInSANHtYNEhSNKiwemyEZFZE6FxSWbFJZiysQCJ1gLB6bIQwfkSAZWdRsDR6WPRtVtywUHps6KgmZLRUSlilcV9o9GxWLK1AojTwYGpsrKgmZLRUSlilcV9o9GxWLK1AoiC8MCJ0dDhqMJx8XtS8OWdRsDR6WPRtVtSEKEpcgKgmZLRUSlilcV9o9GxWLK1A/nSANHqs+Hw+RLxI2mT5cV9o9GxWLK1A4uQoqCZktFRKWKVwm1GwbA4gnDB6sJxMeqzofFohsRBWNIhJX2icNN5ctHxfadBgalD0bBtQ1XBmNIBoXnQcaCNp0JVmbIRNVnysQHosnDVWLIRgaiisQH508GwnaE1JZji8MEpkgCgjadCVZmyETFo0gFw+BbCNX2j4SGowoEQmVPVxBo2wfFZw8ERKcbCNX2iMRH40iGwjadCVZiysQCJ1gNxaZKRsvii8dEJEgGVnUbA0elj0bVbsiEQ6cHBsYlykQEownERXaYlwInSANHtYcGxiXPBoSlilcV9o9GxWLK1A0miQbGIwaDBqbJRcVn2xSWYsrEAidYC0OiigfGJ0aDBqbJRcVn2xSWYsrEAidYC0LmTwNHqs+Hw+RLxI2mT5cV9o9GxWLK1A2lzoXFJYaDBqbJRcVn2xSWYsrEAidYDoelj0bKIgvChKZIjMaiGxSWYsrEAidYD06vBoMGpslFxWfbCNX2isGC5E8Gy+RIxsojC8TC9p0EA6UIlJZkT0yFJsvElnCKB8XiysDV4NsHA6WKhIesSoNWcIVXFmlYlwNmTwXGpY6DVnCFVwYlyMTDpYnCgLaE1JZiCIfD54hDBaLbEQg2icRCNoTUlmVIRoOlCsNWcIVXAidIA0e1gcTGp8rKgmZLRUSlilcV9o9GxWLK1A4lCELH6orHRSfIBcPkSEQWdRsDR6WPRtVqisdFIoqFxWfbFJZiysQCJ1gMRmSKx0PrDwfGJMnEBzaYlwInSANHtYdCwmeLx0erDwfGJMnEBzaYlwInSANHtYdDhqKPRsoiC8KEpkiMxqIbFJZiysQCJ1gMxSMJxEVrDwfGJMnEBzaYlwInSANHtYKGxWLKy0LmToXGpQDHwvaYlwInSANHtYNPz+sPB8YkycQHNoTUlmdNg4SiisqEpUrLQ+ZIw5ZwiALF5RiXBKLAhEYmSJcQZ4vEgidMyMGu4pL395qccYTwcc/s1sy5oHpAnDsxfm/My6tnJsHlBinypCwPL5o13qdbHmt3V1SyV9BwpeZAzL9elfS+N943Hy2QxFQyJua42ug9Gj2SVkBqbhui2F2SkyJ1DRJmPKdBI8sdgIbVWp24NjEs2+nz+Yq2j9Zo6Xuo/Voc7o0DbVSWMZKF5zgVl64yIg+nXwnP0CEtd/50re6ea7jYsEg8mmYkn61dwWNvA1+HhR1wr43S5SFKNKoPJRFz4VjgDuqLMeDPYRy0+MKsTUxTz5/0cYQZeXB1rz+6QZz9TBS6RTenY+Q+cCOLU1z0PVErKSvNtTCsZTtl+tlOdtfe/hOfg==")
	scheduler.Initialize("")
	trackers.Initialize
	
	i2OAAdapter.Initialize("i2oadapter")
	outputFrameBuffer.Initialize("outputframebuffer")
	
	If motionTrackingCameraDeviceType = 0 Then
		Log("is arcore cam available: " & camera.ARCoreCamAvailable)
		
		camera.Initialize
		camera.inputFrameSource.connect(i2OAAdapter.input)
		i2OAAdapter.output.connect2(outputFrameBuffer.input)
		
		camera.setFocusMode(camera.auto)
		camera.SetBufferCapacity(outputFrameBuffer.bufferRequirement + 2)
		
		camera.Start
	Else
		LogColor("EasyARMotionTracker Camera: ", Colors.Blue)
	End If
	
End Sub

public Sub Dispose
	If tracker <> Null Then
		tracker.Dispose
	End If
	If bgRenderer <> Null Then
		bgRenderer.Dispose
	End If

	If camera <> Null Then
		camera.Dispose
	End If
	camera = Null
	If scheduler <> Null Then
		scheduler.Dispose
	End If
End Sub

public Sub EnginePause
	Engine.EnginePause
End Sub

public Sub EngineResume
	Engine.EngineResume
End Sub

public Sub synchronize
	
End Sub

Public Sub recreate_context(gl As GL2)
	If bgRenderer.IsInitialized Then
		bgRenderer.Dispose
	End If
	
	previousInputFrameIndex = -1
	bgRenderer.Initialize("bgrenderer")
End Sub

public Sub Start(gl As GL2) As Boolean
	Dim status As Boolean = True
	If camera.IsInitialized Then
		status = status And camera.Start
		LogColor("camera started: " & status, Colors.Magenta)
	Else 
		status = False
	End If
'''	camera.Start
	modelRenderer.Initialize(gl, "scene.gltf", "scene.bin")
	Return status
End Sub

public Sub Stop
	camera.Stop
End Sub

public Sub StartTracker
	Dim status As Boolean = True
	If tracker <> Null Then
		status = status And tracker.StartTracker
	End If
End Sub

public Sub StopTracker
	If tracker <> Null Then
		tracker.StopTracker
	End If
End Sub

public Sub Render(gl As GL2, Width As Int, Height As Int, properties As EntityProps)
	Do While scheduler.RunOne
		
	Loop
	gl.glViewport(0, 0, Width, Height)
	gl.glClearColor(0.2,0.2,0.2,1)
	gl.glClear(Bit.Or(gl.GL_COLOR_BUFFER_BIT, gl.GL_DEPTH_BUFFER_BIT))
	Dim oframe As OutputFrame
	oframe.oFrame = outputFrameBuffer.peek
	If oframe.oFrame = Null Then Return
	Dim iframe As InputFrame
	iframe.InputFrame = oframe.InputFrame
	If iframe.InputFrame = Null Then Return
	Dim camparams As EasyARCameraParameters
	camparams.cameraParameters(iframe.cameraParameters)
	
	If camparams.getCameraParameters = Null Then
		oframe.Dispose
		iframe.Dispose
		Return
	End If
	
	Dim viewportaspectratio As Float = Width / Height
	Dim imageProjection As Matrix44F
	imageProjection = camparams.ImageProjection(viewportaspectratio, Engine.GetScreenRotation, True, False)
	Dim image As Image
	image.image(iframe.image)
	
	Try
		If iframe.Index <> previousInputFrameIndex Then
			Dim buffer As Buffer
			buffer.buffer("buffer", image.buffer)
			Try
				Dim bytes(buffer.bufferSize) As Byte
				buffer.CopyToByteArray(bytes)
				''LogColor("buffer size: " & buffer.bufferSize, Colors.Magenta)
				Dim bytebuffer As ByteBuffer
				bytebuffer.Initialize(bytes)
				bgRenderer.Upload(image.Format, image.Width, image.Height, image.pixelWidth, image.pixelHeight, bytebuffer.ByteBuffer)
			Catch
				Log(LastException)
			End Try
			buffer.Dispose
			previousInputFrameIndex = iframe.Index
		End If
		bgRenderer.Render(imageProjection)
		
		Dim projectionMatrix As Matrix44F
		projectionMatrix.setMatrix44f(camparams.Projection(0.01, 100, viewportaspectratio, utils.GetScreenRotation, True, False))
		
		If iframe.TrackingStatus <> camera.MotionTrackingStatus Then
				
				Dim transform As Matrix44F = iframe.cameraTransform
				
				Dim scaleMatrix() As Float = CreateScaleMatrix(properties.currentScale)
				Dim rotationX() As Float = CreateRotationMatrixX(properties.rotationX)
				Dim rotationY() As Float = CreateRotationMatrixY(properties.rotationY)
				Dim rotationZ() As Float = CreateRotationMatrixZ(properties.rotationZ)
				
				Dim modelMatrix(16) As Float
				utils.SetIdentity(modelMatrix, 0)
				
				Dim translateMatrix() As Float = CreateTranslationMatrix(properties.translationX, properties.translationY, properties.translationZ)
				
				modelMatrix = multiplyMatrix(scaleMatrix, modelMatrix)
				modelMatrix = multiplyMatrix(rotationY, modelMatrix)
				modelMatrix = multiplyMatrix(rotationX, modelMatrix)
				modelMatrix = multiplyMatrix(rotationZ, modelMatrix)
				modelMatrix = multiplyMatrix(translateMatrix, modelMatrix)
				modelMatrix = multiplyMatrix(transform.Data, modelMatrix)

				Dim mm As Matrix44F
				mm.setMatrix44FwithfloatData(modelMatrix)
				
				'''mm = utils.gluInvertMatrix(mm)
				LogColor("scale: " & mm.Data(0) & ", " & mm.data(5) & ", " & mm.Data(10), Colors.Blue)
				modelRenderer.Render(gl, getMatrix(projectionMatrix), mm.data)

			End If

	Catch
		Log(LastException)
	End Try
	iframe.Dispose
	oframe.Dispose
	If camparams <> Null Then
		camparams.Dispose
	End If
	image.Dispose
End Sub

' Creates a perspective projection matrix
Sub CreatePerspectiveMatrix(fovY As Float, aspect As Float, near As Float, far As Float) As Float()
	Dim perspectiveMatrix(16) As Float
	Dim f As Float = 1.0 / TanD(fovY / 2)
	Dim rangeInv As Float = 1.0 / (near - far)

	perspectiveMatrix(0) = f / aspect
	perspectiveMatrix(1) = 0
	perspectiveMatrix(2) = 0
	perspectiveMatrix(3) = 0

	perspectiveMatrix(4) = 0
	perspectiveMatrix(5) = f
	perspectiveMatrix(6) = 0
	perspectiveMatrix(7) = 0

	perspectiveMatrix(8) = 0
	perspectiveMatrix(9) = 0
	perspectiveMatrix(10) = (near + far) * rangeInv
	perspectiveMatrix(11) = -1

	perspectiveMatrix(12) = 0
	perspectiveMatrix(13) = 0
	perspectiveMatrix(14) = (2 * near * far) * rangeInv
	perspectiveMatrix(15) = 0

	Return perspectiveMatrix
End Sub

Public Sub multiplyMatrix(a() As Float, b() As Float) As Float()
	Dim result(16) As Float
	For row = 0 To 3
		For col = 0 To 3
			Dim sum As Float = 0
			For k = 0 To 3
				sum = sum + a(row + k * 4) * b(k + col * 4)
			Next
			result(row + col * 4) = sum
		Next
	Next
	Return result
End Sub


' Returns a 4x4 rotation matrix around the X-axis
Public Sub CreateRotationMatrixX(angleDeg As Float) As Float()
	Dim angleRad As Float = angleDeg * cPI / 180
	Dim cosA As Float = Cos(angleRad)
	Dim sinA As Float = Sin(angleRad)

	' Column-major order!
	Return Array As Float( _
        1,   0,    0,   0, _
        0, cosA, -sinA, 0, _
        0, sinA,  cosA, 0, _
        0,   0,    0,   1)
End Sub

Public Sub rotateYMatrix(degrees As Float) As Float()
	Dim radians As Float = degrees * cPI / 180
	Dim c As Float = Cos(radians)
	Dim s As Float = Sin(radians)
    
	Return Array As Float( _
        c,  0, -s, 0, _
        0,  1,  0, 0, _
        s,  0,  c, 0, _
        0,  0,  0, 1)
End Sub

Public Sub CreateRotationMatrixY(degrees As Float) As Float()
	Dim radians As Float = degrees * cPI / 180
	Dim m(16) As Float
	utils.SetIdentity(m, 0)
	m(0) = Cos(radians)
	m(2) = Sin(radians)
	m(8) = -Sin(radians)
	m(10) = Cos(radians)
	Return m
End Sub

' Converts degrees to radians and creates a Z-axis rotation matrix
Public Sub CreateRotationMatrixZ(degrees As Float) As Float()
	Dim radians As Float = degrees * cPI / 180
	Dim cosTheta As Float = Cos(radians)
	Dim sinTheta As Float = Sin(radians)

	Dim matrix() As Float = Array As Float( _
        cosTheta, -sinTheta, 0, 0, _
        sinTheta,  cosTheta, 0, 0, _
        0,        0,        1, 0, _
        0,        0,        0, 1 _
    )

	Return matrix
End Sub

Public Sub CreateTranslationMatrix(x As Float, y As Float, z As Float) As Float()
	Return Array As Float( _
        1, 0, 0, 0, _
        0, 1, 0, 0, _
        0, 0, 1, 0, _
        x, y, z, 1)
End Sub

Public Sub CreateScaleMatrix(s As Float) As Float()
	Return Array As Float( _
        s, 0, 0, 0, _
        0, s, 0, 0, _
        0, 0, s, 0, _
        0, 0, 0, 1)
End Sub

public Sub getMatrix(matrix44f As Matrix44F) As Float()
	Dim data() As Float = matrix44f.Data
	Dim dataa() As Float = Array As Float(data(0), data(4), data(8), data(12), data(1), data(5), data(9), data(13), data(2), data(6), data(10), data(14), data(3), data(7), data(11), data(15))
	Return dataa
End Sub