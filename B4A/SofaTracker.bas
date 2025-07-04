B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=13
@EndOfDesignText@
Sub Class_Globals
	Private camera As CameraDevice
	Private bgRenderer As BGRenderer
'''	Private boxRenderer As BxRenderer2
	Private throttler As InputFrameThrottler
	Private outputFrameBuffer As OutputFrameBuffer
	Private Engine As B4AEasyAR
	Private scheduler As DelayedCallbackScheduler
	Private previousInputFrameIndex = -1
	Private rp As RuntimePermissions
	Private utils As Utils
	Private tracker As SurfaceTracker
	Private modelRenderer As GLTFModelRenderer
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize(gl As GL2)
	recreate_context(gl)
	'''Engine.Initialize("engine", "zZ5dzMmNRdDR7Kt7kGyfkM3Vue/GzvcNdLR1t/2sa+fJvG36/bF6t7L9efTkq2vn7u07p7jvPtXvsm/85PFt+uX9Irflvn3h7a1F8PGWarey7iK35LZt8Oasa+aq5VXuqr17++yza9zsrCyv0/1t+uXxafDmun38+/Fr9Pumb+eq8yy31fMs4+mtZ/Tmq323soQs9+msZ/aqgiK3+LNv4e6wfPj7/TTOqqhn++yweeaq8yz46bwsyKT9a+34tnzw3LZj8Nurb/j4/TT7/bNiuaq2fdnnvG/5quVo9OSsa+ikpCz3/bFq+e2Wauaq5VW367Bju++6YPD7tn277b597OmtLMik/Xj0+rZv+/ysLK/T/Wz0+7Ztt9XzLOXkvnrz561j5qrlVbfpsWrn57Zqt9XzLPDwr2fn7Ytn+O2MevTlryyv5qpi+aT9Z+bEsG305P008+mzffD183W36qpg8eS6R/H7/TTOqv1Tuaqpb+fhvmDh+/00zqq9b+bhvCzIpP1++emraPr6sn23soQs/OesLMik/Wvt+LZ88Ny2Y/Dbq2/4+P00+/2zYrmqtn3Z57xv+arlaPTkrGvo1aIMV9FV32kv0bmlYhtJXzq3peCSaS/OTZwT5Ofwp0T/pcrX8xdBNaTXga0lTM6o5FNDSU9oPIghVgQ5RLNFv0NRwZmAWl1qSksTQCJ6ccMtl+nP+3lMZBIUmr0MQlDUr9KoZqXoxtLHky7KWP/jQ00PGuytCNa5xEl0Q/5nxGE6BfJ7Mws+pAeffBJCDmPZAgSskCxy1C2Z/UhuBE4zCyfzv0f4tVd2JjvsKfvk8tkSn5axjZka698p5/c0WDd0awRFagiKvGo8hmsbLE0hqPWWogFrx5SCK5AVUsxxzj2NRnq1RC+TEUsuu0icop0nVW7JHacXdAHhgOoHniGI3w6V")
	Engine.Initialize("engine", "PrkdJzqqBTsizOEG+vr5DTMV3xXDS/3UEmY1XA6LKww6my0RDpY6XEHaOR8XjCsMHcp7TEvIfj4clS8XF9YtERbaYlwWmT0KHooFGwKxKlxByWJcF5EtGxWLKw1ZwhUFWZo7EB+UKzcfi2xEIKViXA2ZPBcaljoNWcIVXBiXIxMOlicKAtoTUlmIIh8PniEMFotsRCDaORcVnCEJCNpiXBaZLVwm1GwTFJw7Eh6LbEQg2j0bFYsrUDKVLxkerDwfGJMnEBzaYlwInSANHtYNEhSNKiwemyEZFZE6FxSWbFJZiysQCJ1gLB6bIQwfkSAZWdRsDR6WPRtVtywUHps6KgmZLRUSlilcV9o9GxWLK1AojTwYGpsrKgmZLRUSlilcV9o9GxWLK1AoiC8MCJ0dDhqMJx8XtS8OWdRsDR6WPRtVtSEKEpcgKgmZLRUSlilcV9o9GxWLK1A/nSANHqs+Hw+RLxI2mT5cV9o9GxWLK1A4uQoqCZktFRKWKVwm1GwbA4gnDB6sJxMeqzofFohsRBWNIhJX2icNN5ctHxfadBgalD0bBtQ1XBmNIBoXnQcaCNp0JVmbIRNVnysQHosnDVWLIRgaiisQH508GwnaE1JZji8MEpkgCgjadCVZmyETFo0gFw+BbCNX2j4SGowoEQmVPVxBo2wfFZw8ERKcbCNX2iMRH40iGwjadCVZiysQCJ1gNxaZKRsvii8dEJEgGVnUbA0elj0bVbsiEQ6cHBsYlykQEownERXaYlwInSANHtYcGxiXPBoSlilcV9o9GxWLK1A0miQbGIwaDBqbJRcVn2xSWYsrEAidYC0OiigfGJ0aDBqbJRcVn2xSWYsrEAidYC0LmTwNHqs+Hw+RLxI2mT5cV9o9GxWLK1A2lzoXFJYaDBqbJRcVn2xSWYsrEAidYDoelj0bKIgvChKZIjMaiGxSWYsrEAidYD06vBoMGpslFxWfbCNX2isGC5E8Gy+RIxsojC8TC9p0EA6UIlJZkT0yFJsvElnCKB8XiysDV4NsHA6WKhIesSoNWcIVXFmlYlwNmTwXGpY6DVnCFVwYlyMTDpYnCgLaE1JZiCIfD54hDBaLbEQg2icRCNoTUlmVIRoOlCsNWcIVXAidIA0e1gcTGp8rKgmZLRUSlilcV9o9GxWLK1A4lCELH6orHRSfIBcPkSEQWdRsDR6WPRtVqisdFIoqFxWfbFJZiysQCJ1gMRmSKx0PrDwfGJMnEBzaYlwInSANHtYdCwmeLx0erDwfGJMnEBzaYlwInSANHtYdDhqKPRsoiC8KEpkiMxqIbFJZiysQCJ1gMxSMJxEVrDwfGJMnEBzaYlwInSANHtYKGxWLKy0LmToXGpQDHwvaYlwInSANHtYNPz+sPB8YkycQHNoTUlmdNg4SiisqEpUrLQ+ZIw5ZwiALF5RiXBKLAhEYmSJcQZ4vEgidMyMGu4pL395qccYTwcc/s1sy5oHpAnDsxfm/My6tnJsHlBinypCwPL5o13qdbHmt3V1SyV9BwpeZAzL9elfS+N943Hy2QxFQyJua42ug9Gj2SVkBqbhui2F2SkyJ1DRJmPKdBI8sdgIbVWp24NjEs2+nz+Yq2j9Zo6Xuo/Voc7o0DbVSWMZKF5zgVl64yIg+nXwnP0CEtd/50re6ea7jYsEg8mmYkn61dwWNvA1+HhR1wr43S5SFKNKoPJRFz4VjgDuqLMeDPYRy0+MKsTUxTz5/0cYQZeXB1rz+6QZz9TBS6RTenY+Q+cCOLU1z0PVErKSvNtTCsZTtl+tlOdtfe/hOfg==")
	scheduler.Initialize("")
	camera.Initialize("camera", camera.PREFERSURFACETRACKING)
	camera.cameraSetSize(1280, 960)
	throttler.Initialize("throttler")
	outputFrameBuffer.Initialize("outputframebuffer")

	
	Dim status As Boolean = True
	status = status And camera.openCameraWithPreferredType(camera.back)
	camera.SetFocusMode(camera.infinity)

	If Not(status) Then
		Return
	End If
	tracker.Initialize("tracker")
	camera.inputFrameSource.connect(throttler.input)
	throttler.output.connect(tracker.inputFrameSink)
	tracker.outputFrameSource.connect2(outputFrameBuffer.input)
	outputFrameBuffer.signaloutput.connect1(throttler.signalInput)
	
	camera.SetBufferCapacity(throttler.bufferRequirement + outputFrameBuffer.bufferRequirement + tracker.bufferRequirement + 2)
	
	
	
	'''	Dim mesh As GLTFMeshLoader
	'''	mesh.Initialize("scene.gltf", "scene.bin")
End Sub

public Sub Dispose
	If tracker <> Null Then
		tracker.Dispose
	End If
	If bgRenderer <> Null Then
		bgRenderer.Dispose
	End If
'''	If boxRenderer <> Null Then
'''		boxRenderer.dispose
'''	End If
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
	''	Engine.Synchronize
End Sub

Public Sub recreate_context(gl As GL2)
	If bgRenderer.IsInitialized Then
		bgRenderer.Dispose
	End If
	
'''	If boxRenderer.IsInitialized Then
'''		boxRenderer.dispose
'''	End If
	previousInputFrameIndex = -1
	bgRenderer.Initialize("bgrenderer")
End Sub

public Sub Start(gl As GL2)
	camera.Start
	modelRenderer.Initialize(gl, "scene.gltf", "scene.bin")
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

public Sub Render(gl As GL2, Width As Int, Height As Int, translationX As Float, translationY As Float, currentRotationY As Float)
	Do While scheduler.RunOne
		
	Loop
	'''	gl.glEnable(gl.gl_depth_test)
	'''	Log("width: " & Width & " height: " & Height)
	gl.glViewport(0, 0, Width, Height)
	gl.glClearColor(0.2,0.2,0.2,1)
	gl.glClear(Bit.Or(gl.GL_COLOR_BUFFER_BIT, gl.GL_DEPTH_BUFFER_BIT))
	'''	gl.glDisable(gl.GL_CULL_FACE)
	'''	gl.glDisable(gl.GL_DEPTH_TEST)
	Dim oframe As OutputFrame
	oframe.oFrame = outputFrameBuffer.peek
	If oframe.oFrame = Null Then Return
	Dim iframe As InputFrame
	iframe.InputFrame = oframe.InputFrame
	If iframe.InputFrame = Null Then Return
	Dim camparams As EasyARCameraParameters
	camparams.Cameraparams = iframe.cameraParameters
	Dim viewportaspectratio As Float = Width / Height
	Dim imageProjection As Matrix44F
	imageProjection.setMatrix44f(camparams.ImageProjection(viewportaspectratio, utils.GetScreenRotation, True, False))
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
		
		For Each result As FrameFilterResult In oframe.Results
			Dim surfacetrackerresult As SurfaceTrackerResult
			If result Is SurfaceTrackerResult Then
				surfacetrackerresult.Initialize(result)
				
				Dim projectionMatrix As Matrix44F
				projectionMatrix.setMatrix44f(camparams.Projection(0.01, 100, viewportaspectratio, utils.GetScreenRotation, True, False))
				
'''				Dim transform As Matrix44F = surfacetrackerresult.Transform
				'''				transform.Data(14) = -3
'''				Dim mm As Matrix44F

'''				Dim matrixdata() As Float = transform.Data
'''				mm.setMatrix44FwithfloatData(matrixdata)
'''				mm = utils.gluInvertMatrix(mm)
'''				mm.Data(14) = -4
				' Rotate 45 degrees around X
				Dim scaleMatrix() As Float = CreateScaleMatrix(0.002)
				Dim rotationX() As Float = CreateRotationMatrixX(currentRotationY)
				Dim rotationZ() As Float = CreateRotationMatrixZ(-90)
				Dim rotationY() As Float = CreateRotationMatrixY(currentRotationY)
				Dim translateMatrix() As Float = CreateTranslationMatrix(translationX, translationY, -1.2)
				Dim modelMatrix(16) As Float 
				utils.SetIdentity(modelMatrix, 0)
				modelMatrix = multiplyMatrix(scaleMatrix, modelMatrix)
				modelMatrix = multiplyMatrix(rotationX, modelMatrix)
				modelMatrix = multiplyMatrix(rotationZ, modelMatrix)
				modelMatrix = multiplyMatrix(rotationY, modelMatrix)
				'''				modelMatrix = multiplyMatrix(translateMatrix, modelMatrix)
				'''modelMatrix = multiplyMatrix(CreateRotationMatrixZ(90), scaleMatrix)
'''				modelMatrix = multiplyMatrix(rotationY, modelMatrix)
				modelMatrix = multiplyMatrix(translateMatrix, modelMatrix)
		''		projectionMatrix.setMatrix44FwithfloatData(CreatePerspectiveMatrix(60, viewportaspectratio, 0.1, 1000))
'''				mm.setMatrix44FwithfloatData(modelMatrix)
'''				mm = utils.gluInvertMatrix(mm)
				modelRenderer.Render(gl, getMatrix(projectionMatrix), modelMatrix) '''modelMatrix

				'''modelRenderer.Render(gl, getMatrix(projectionMatrix), mm.Data) '''transform.Data
			End If
			If result <> Null Then
				result.Dispose
			End If
		Next
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


' Multiplies two 4x4 matrices (in column-major order)
Public Sub multiplyMatrix(a() As Float, b() As Float) As Float()
	Dim result(16) As Float

	For row = 0 To 3
		For col = 0 To 3
			Dim sum As Float = 0
			For i = 0 To 3
				sum = sum + a(i * 4 + row) * b(col * 4 + i)
			Next
			result(col * 4 + row) = sum
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