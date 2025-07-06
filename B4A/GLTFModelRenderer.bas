B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=13
@EndOfDesignText@
Sub Class_Globals
	Private model As GLTFMeshLoader
	Private modelData As ModelData
	Private attrPosition As Int
	Private uProjectionMatrix As Int
	Private uModelMatrix As Int
	Private shaderProgram As Int
	Private vbo(2) As Int
	Private ibo(1) As Int
	Private utils As Utils
	Private vertexShader As String
	Private fragmentShader As String
	Private textureID As Int
	Private attrTexCoord As Int
	Private uSampler As Int
	Private attrColor As Int
	Private colorBuffer As FloatBuffer
	Private clrBuffer As ByteBuffer
	Private indexBuffer As IntBuffer
	Private indexBuffer2 As ShortBuffer
End Sub

Public Sub Initialize(gl As GL2, gltfFile As String, binFile As String)
	'''model.Initialize('''e(gltfFile, binFile)
	model.Initialize(gltfFile, binFile)
	modelData = model.loadGLTFModel

	Log("Loaded model with " & modelData.indexCount & " indices.")
	Log("Vertex buffer size: " & modelData.vertexBuffer.Capacity)
	
	Dim texId(1) As Int
	gl.glGenTextures(1, texId, 0)
	textureID = texId(0)
	
	gl.glEnable(gl.GL_DEPTH_TEST)
	gl.glEnable(gl.GL_CULL_FACE)
	gl.glCullFace(gl.GL_BACK)

	' Load vertex shader and fragment shader
	vertexShader = File.ReadString(File.DirAssets, "gltf_vertex2.vert")
	fragmentShader = File.ReadString(File.DirAssets, "gltf_fragment2.frag")

	' Compile shaders
	Dim vert As Int = CompileShader(gl, gl.GL_VERTEX_SHADER, vertexShader)
	Dim frag As Int = CompileShader(gl, gl.GL_FRAGMENT_SHADER, fragmentShader)

	' Create shader program
	shaderProgram = gl.glCreateProgram
	gl.glAttachShader(shaderProgram, vert)
	gl.glAttachShader(shaderProgram, frag)

	gl.glBindAttribLocation(shaderProgram, 0, "aPosition")
	gl.glBindAttribLocation(shaderProgram, 1, "aTexCoord")
'''	gl.glBindAttribLocation(shaderProgram, 1, "aColor")

	gl.glLinkProgram(shaderProgram)
	gl.glUseProgram(shaderProgram)

	CheckProgramLink(gl, shaderProgram)

	gl.glDeleteShader(vert)
	gl.glDeleteShader(frag)

	attrPosition = gl.glGetAttribLocation(shaderProgram, "aPosition")
	uSampler = gl.glGetUniformLocation(shaderProgram, "uTexture")
	attrTexCoord = gl.glGetAttribLocation(shaderProgram, "aTexCoord")
	uProjectionMatrix = gl.glGetUniformLocation(shaderProgram, "uProjectionMatrix")
	uModelMatrix = gl.glGetUniformLocation(shaderProgram, "uModelMatrix")
	
	Log("attrPosition: " & attrPosition)

	gl.glGenBuffers(2, vbo, 0)
	
	gl.glBindTexture(gl.GL_TEXTURE_2D, textureID)
	gl.glTexParameteri(gl.GL_TEXTURE_2D, gl.GL_TEXTURE_MIN_FILTER, gl.GL_LINEAR)
	gl.glTexParameteri(gl.GL_TEXTURE_2D, gl.GL_TEXTURE_MAG_FILTER, gl.GL_LINEAR)
	gl.glTexParameteri(gl.GL_TEXTURE_2D, gl.GL_TEXTURE_WRAP_S, gl.GL_CLAMP_TO_EDGE)
	gl.glTexParameteri(gl.GL_TEXTURE_2D, gl.GL_TEXTURE_WRAP_T, gl.GL_CLAMP_TO_EDGE)

	' Upload vertex buffer
	gl.glBindBuffer(gl.GL_ARRAY_BUFFER, vbo(0))
	modelData.vertexBuffer.position(0)
	gl.glBufferData(gl.GL_ARRAY_BUFFER, modelData.vertexBuffer.Capacity * 4, modelData.vertexBuffer, gl.GL_STATIC_DRAW)

	gl.glBindBuffer(gl.GL_ARRAY_BUFFER, vbo(1))
	modelData.texCoordBuffer.position(0)
	gl.glBufferData(gl.GL_ARRAY_BUFFER, modelData.texCoordBuffer.Capacity * 4, modelData.texCoordBuffer, gl.GL_STATIC_DRAW)
	' Upload index buffer
	gl.glGenBuffers(1, ibo, 0)
	gl.glBindBuffer(gl.GL_ELEMENT_ARRAY_BUFFER, ibo(0))
	LogColor("getType: " & GetType(modelData.indexBuffer), Colors.Magenta)
'''	modelData.indexBuffer.position(0)
	If GetType(modelData.indexBuffer) = "java.nio.ByteBufferAsIntBuffer" Then
		indexBuffer = modelData.indexBuffer
		indexBuffer.position(0)
		LogColor("setting object to IntBuffer", Colors.Blue)
	else if GetType(modelData.indexBuffer) = "java.nio.ByteBufferAsShortBuffer" Then
		indexBuffer2 = modelData.indexBuffer
		indexBuffer2.position(0)
		LogColor("setting object to shortBuffer", Colors.Blue)
	End If
	gl.glBufferData(gl.GL_ELEMENT_ARRAY_BUFFER, modelData.indexCount * 4, modelData.indexBuffer, gl.GL_STATIC_DRAW)
	
	Dim bmp As Bitmap = LoadBitmap(File.DirAssets, Common.imageURI)
	Dim jo As JavaObject
	jo = Me
	jo.RunMethod("loadTextureFromBitmap", Array(textureID, bmp))
End Sub


Public Sub Render(gl As GL2, projectionMatrix() As Float, modelMatrix() As Float)
	
	gl.glDisable(gl.GL_CULL_FACE)
	gl.glUseProgram(shaderProgram)

	gl.glUniformMatrix4fv(uProjectionMatrix, 1, False, projectionMatrix, 0)

	gl.glUniformMatrix4fv(uModelMatrix, 1, False, modelMatrix, 0) '''rotatedModelMatrix

	' Enable and bind position buffer
	gl.glBindBuffer(gl.GL_ARRAY_BUFFER, vbo(0))
	gl.glEnableVertexAttribArray(attrPosition)
	gl.glVertexAttribPointer(attrPosition, 3, gl.GL_FLOAT, False, 12, 0)
	
	gl.glBindBuffer(gl.GL_ARRAY_BUFFER, vbo(1))
	gl.glEnableVertexAttribArray(attrTexCoord)
	gl.glVertexAttribPointer(attrTexCoord, 2, gl.GL_FLOAT, False, 8, 0)
	
	gl.glActiveTexture(gl.GL_TEXTURE0)
	gl.glBindTexture(gl.GL_TEXTURE_2D, textureID)
	'''gl.glUniform1f(uSampler, 0)
	gl.glUniform1i(uSampler, 0)

	' Draw cube
	gl.glBindBuffer(gl.GL_ELEMENT_ARRAY_BUFFER, ibo(0))
	indexBuffer.position(0)
	gl.glDrawElements2(gl.GL_TRIANGLES, modelData.indexCount, gl.GL_UNSIGNED_INT, 0)

	gl.glDisableVertexAttribArray(attrPosition)
	gl.glDisableVertexAttribArray(attrColor)
End Sub

Private Sub CreateScaleMatrix(scale As Float) As Float()
	Return Array As Float( _
		scale, 0, 0, 0, _
		0, scale, 0, 0, _
		0, 0, scale, 0, _
		0, 0, -5, 1)
End Sub

Private Sub CompileShader(gl As GL2, shaderType As Int, source As String) As Int
	Dim shader As Int = gl.glCreateShader(shaderType)
	gl.glShaderSource(shader, source)
	gl.glCompileShader(shader)
	Dim status(1) As Int
	gl.glGetShaderiv(shader, gl.GL_COMPILE_STATUS, status, 0)
	If status(0) = 0 Then
		Dim typeStr As String = IIf(shaderType = gl.GL_VERTEX_SHADER, "Vertex", "Fragment")
		LogColor(typeStr & " Shader compile error: " & gl.glGetShaderInfoLog(shader), Colors.Red)
	End If
	Return shader
End Sub

Private Sub CheckProgramLink(gl As GL2, program As Int)
	Dim status(1) As Int
	gl.glGetProgramiv(program, gl.GL_LINK_STATUS, status, 0)
	If status(0) <> gl.GL_TRUE Then
		LogColor("Program link failed: " & gl.glGetProgramInfoLog(program), Colors.Red)
	Else
		Log("Shader program linked successfully.")
	End If
End Sub

Private Sub CreateRotationYMatrix(deg As Float) As Float()
	Dim rad As Float = deg * cPI / 180
	Dim cosA As Float = Cos(rad)
	Dim sinA As Float = Sin(rad)
	
	Return Array As Float( _
		cosA, 0, sinA, 0, _
		0, 1, 0, 0, _
		-sinA, 0, cosA, 0, _
		0, 0, -5, 1) ' keep translated back
End Sub


Public Sub Dispose(gl As GL2)
	If shaderProgram <> 0 Then utils.glDeletePogram(shaderProgram)
	If vbo.Length > 0 Then utils.DeleteOneBuffer(1, vbo, 0)
	If ibo.Length > 0 Then utils.DeleteOneBuffer(1, ibo, 0)
End Sub

public Sub getMatrix(matrix44f As Matrix44F) As Float()
	Dim data() As Float = matrix44f.Data
	Dim dataa() As Float = Array As Float(data(0), data(4), data(8), data(12), data(1), data(5), data(9), data(13), data(2), data(6), data(10), data(14), data(3), data(7), data(11), data(15))
	Return dataa
End Sub

Sub MakePerspectiveMatrix(fovY As Float, aspect As Float, nearZ As Float, farZ As Float) As Float()
	Dim f As Float = 1 / Tan(fovY / 2 * cPI / 180)
	Dim result(16) As Float
    
	result(0) = f / aspect
	result(5) = f
	result(10) = -(farZ + nearZ) / (farZ - nearZ)
	result(11) = -1
	result(14) = -(2 * farZ * nearZ) / (farZ - nearZ)
	result(15) = 0
    
	Return result
End Sub

Sub MakeModelMatrix(tx As Float, ty As Float, tz As Float) As Float()
	Dim result(16) As Float = Array As Float( _
        1, 0, 0, 0, _
        0, 1, 0, 0, _
        0, 0, 1, 0, _
        tx, ty, tz, 1)
	Return result
End Sub

#if Java
import android.graphics.Bitmap;
import android.opengl.GLUtils;
import android.opengl.GLES20;
import android.opengl.GLES30;

public static void loadTextureFromBitmap(int textureId, Bitmap bmp) {
    GLUtils.texImage2D(GLES20.GL_TEXTURE_2D, 0, bmp, 0);
}
#End If
