B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=13
@EndOfDesignText@
Sub Class_Globals
	Type ModelData(vertexBuffer As FloatBuffer, indexBuffer As Object, texCoordBuffer As FloatBuffer, indexCount As Int)
	Private binBuffer() As Byte
	Dim j As JSONParser
	Dim json As String
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize(gltFileName As String, binFileName As String)

	json = File.ReadString(File.DirAssets, gltFileName)
	binBuffer = File.ReadBytes(File.DirAssets, binFileName)
	j.Initialize(json)
	
	
End Sub

Public Sub loadGLTFModel As ModelData
	Dim m As Map = j.NextObject
	Log("m: " & m)
	Dim accessors As List = m.Get("accessors")
	Dim bufferViews As List = m.Get("bufferViews")
	Log("accessors: " & accessors)
	Log("bufferViews: " & bufferViews)
	
	Dim mesh As List = m.Get("meshes")
	Log("mesh: " & mesh.Get(0))
	Dim primitive As List = mesh.Get(0).As(Map).Get("primitives")
	Log("primitive: " & primitive)
	' ==== Load Vertex POSITION buffer ===
	Dim posAccessorIndex As Int = primitive.Get(0).As(Map).Get("attributes").As(Map).Get("POSITION")
	Log("posAccessorIndex: " & posAccessorIndex)
	Dim primitiveMode As Int = primitive.Get(0).As(Map).Get("mode")
	LogColor("primitiveModes: " & primitiveMode, Colors.Blue)
	Dim posAccessor As Map = accessors.Get(posAccessorIndex)
	Log("posAccessor: " & posAccessor)
	
	' === Log the min and max coordinates for POSITION ===
	If posAccessor.ContainsKey("min") Then
		Dim minList As List = posAccessor.Get("min")
		LogColor("POSITION min: x=" & minList.Get(0) & ", y=" & minList.Get(1) & ", z=" & minList.Get(2), Colors.Green)
	Else
		LogColor("POSITION min not available", Colors.Red)
	End If

	If posAccessor.ContainsKey("max") Then
		Dim maxList As List = posAccessor.Get("max")
		LogColor("POSITION max: x=" & maxList.Get(0) & ", y=" & maxList.Get(1) & ", z=" & maxList.Get(2), Colors.Green)
	Else
		LogColor("POSITION max not available", Colors.Red)
	End If

	
	Dim posCount As Int = posAccessor.Get("count")
	Log("count: " & posCount)
	'''	Log("posAccessor: " & posAccessor)
	Dim posBufferViewIndex As Int = posAccessor.Get("bufferView")
	Log("posBufferViewIndex: " & posBufferViewIndex)
	Dim posBufferView As Map = bufferViews.Get(posBufferViewIndex)
	Log("posBufferView: " & posBufferView)
	Dim bytestride As Int = posBufferView.GetDefault("byteStride", (4*3))
	Log("byteStride: " & bytestride)
	Dim posByteOffset As Int = posBufferView.GetDefault("byteOffset", 0)
	Log("posByteOffset: " & posByteOffset)
	Dim actualLength As Int = posCount * bytestride
	Log("actualLength: " & actualLength)
	

'''	Dim posByteLenght As Int = posBufferView.Get("byteLength")
'''	Log("posByteLenght: " & posByteLenght)
	
	
	Dim vertexBuffer As FloatBuffer
	vertexBuffer.FloatBuffer = vertexBuffer.allocateDirect(posCount * 3 * 4, vertexBuffer.NATIVE_ORDER)

	Dim rawBuf As ByteBuffer
	rawBuf.Initialize(binBuffer)
	rawBuf.ByteBuffer = rawBuf.wrap(binBuffer, posByteOffset, actualLength)
	rawBuf.Order(rawBuf.LITTLE_ENDIAN)
	
	Log("poscount: " & posCount)
	For i = 0 To posCount - 1
	'''	Dim pos As Int = i * posStride
	'''	rawBuf.Position(pos)
		rawBuf.Position(posByteOffset + i * bytestride)
		Dim x As Float = rawBuf.Float
		Dim y As Float = rawBuf.Float
		Dim z As Float = rawBuf.Float
		
'''		LogColor("x: " & x, Colors.Blue)
'''		LogColor("y: " & y, Colors.Blue)
'''		LogColor("z: " & z, Colors.Blue)
		
		vertexBuffer.put(x)
		vertexBuffer.put(y)
		vertexBuffer.put(z)
'''		Log("Vertex #" & i & ": x=" & x & ", y=" & y & ", z=" & z)
	Next
	vertexBuffer.position(0)
	rawBuf.Position(0)
	
	' === Load INDEX buffer ===
	Dim idxAccessorIndex As Int = primitive.Get(0).As(Map).Get("indices")
	Log("idxAccessorIndex: " & idxAccessorIndex)
	Dim idxAccessor As Map = accessors.Get(idxAccessorIndex)
	Log("idxAccessor: " & idxAccessor)
	Dim componentType As Int = idxAccessor.Get("componentType")
	Log("componentType: " & componentType)
	Dim idxCount As Int = idxAccessor.Get("count")
	Log("idxCount: " & idxCount)
	Dim idxBufferViewIndex As Int = idxAccessor.Get("bufferView")
	Log("idxBufferViewIndex: " & idxBufferViewIndex)
	Dim idxBufferView As Map = bufferViews.Get(idxBufferViewIndex)
	Log("idxBufferView: " & idxBufferView)
	Dim idxByteOffset As Int = idxBufferView.GetDefault("byteOffset", 0)
	Log("idxByteOffset: " & idxByteOffset)
	Dim idxByteLength As Int = idxBufferView.Get("byteLength")
	Log("idxByteLength: " & idxByteLength)
	
	Dim idxBuffer As ByteBuffer
	idxBuffer.Initialize(binBuffer)
	idxBuffer.ByteBuffer = idxBuffer.wrap(binBuffer, idxByteOffset, idxByteLength)
	idxBuffer.Order(idxBuffer.LITTLE_ENDIAN)
	'''check componentType here to decide whether to use a intBuffer, or a shortBuffer
	
	'''Dim indexBuffer As Object
	Dim indexBuffer As Object
	Select componentType
		Case 5123
			Dim shortBuf As ShortBuffer
			shortBuf.ShortBuffer = shortBuf.allocateDirect(idxCount * 2, shortBuf.NATIVE_ORDER)
			For i = 0 To idxCount - 1
				Dim idx As Short = idxBuffer.Short
				shortBuf.put(idx)
			Next
				shortBuf.position(0)
				indexBuffer = shortBuf
		Case 5125
			idxBuffer.Position(idxByteOffset / 4)
			Dim indexrawBuffer As IntBuffer
			indexrawBuffer = indexrawBuffer.Initialize(idxCount*4, indexrawBuffer.NATIVE_ORDER)
			For j1 = 0 To idxCount - 1
				indexrawBuffer.put(idxBuffer.Int)
			Next
			indexrawBuffer.position(0)
			indexBuffer = indexrawBuffer
			
	End Select
	
	

	
	Dim materials As List = m.Get("materials")
	Dim textures As List = m.Get("textures")
	Dim images As List = m.Get("images")
	Dim textureID As Int
	For Each material As Map In materials
		Dim name As String = material.GetDefault("name", "Unnamed")
		Dim doubleSided As Boolean = material.GetDefault("doubleSided", False)
		Dim textureID As Int = -1

		' Try new specular-glossiness extension
		If material.ContainsKey("extensions") Then
			Dim extensions As Map = material.Get("extensions")
			If extensions.ContainsKey("KHR_materials_pbrSpecularGlossiness") Then
				Dim pbrSG As Map = extensions.Get("KHR_materials_pbrSpecularGlossiness")
				If pbrSG.ContainsKey("diffuseTexture") Then
					Dim diffuseTexture As Map = pbrSG.Get("diffuseTexture")
					textureID = diffuseTexture.Get("index")
				End If
			End If
		End If

		' Fallback to normalTexture if needed
		If textureID = -1 And material.ContainsKey("normalTexture") Then
			Dim normalTexture As Map = material.Get("normalTexture")
			textureID = normalTexture.Get("index")
		End If

		If textureID <> -1 Then
			Dim imageDef As Map = images.Get(textureID)
			Dim imageUri As String = imageDef.Get("uri")
			Common.imageURI = imageUri
			LogColor("Texture image URI (from extension): " & imageUri, Colors.Green)
		Else
			LogColor("No usable texture found for material: " & name, Colors.Red)
		End If
	Next
	LogColor("imageIndex: " & textureID, Colors.Blue)

'''	Dim imageDef As Map = images.Get(textureID)
'''	Dim imageUri As String = imageDef.Get("uri") ' Should be "Cube_baseColor.png"
'''	Common.imageURI = imageUri
'''	Log("Texture image URI: " & imageUri)
	
	Dim texCoordAccessorIndex As Int = primitive.Get(0).As(Map).Get("attributes").As(Map).Get("TEXCOORD_0")
	Common.texCoordAccessorIndex = texCoordAccessorIndex
	LogColor("common.texCoordAccessorIndex: " & Common.texCoordAccessorIndex, Colors.Magenta)
	Dim texCoordAccessor As Map = accessors.Get(texCoordAccessorIndex)
	Dim texCoordCount As Int = texCoordAccessor.Get("count")
	LogColor("texCoordCount: " & texCoordCount, Colors.Magenta)
	Dim texCoordByteOffset As Int = texCoordAccessor.GetDefault("byteOffset", 0)
	Dim componentType As Int = texCoordAccessor.Get("componentType")
	LogColor("componentType: " & componentType, Colors.Magenta)
	Dim accessorType As String = texCoordAccessor.Get("type")
	LogColor("accessorType: " & accessorType, Colors.Magenta)
	Dim texCoordBufferViewIndex As Int = texCoordAccessor.Get("bufferView")
	Dim texCoordBufferView As Map = bufferViews.Get(texCoordBufferViewIndex)
	Dim texCoordBufferByteOffset As Int = texCoordBufferView.GetDefault("byteOffset", 0)
	Dim stride As Int = texCoordBufferView.GetDefault("byteStride", 0)
	Log("TEXCOORD_0 stride: " & stride)
	Dim texCoordOffset As Int = texCoordBufferView.GetDefault("byteOffset", 0) + texCoordAccessor.GetDefault("byteOffset", 0)
	Dim byteLength As Int = texCoordCount * 2 * 4
	
	If stride = 0 Then stride = 8 ' 2 floats (u, v) = 8 bytes
	
'''	Dim texCoordBuf As ByteBuffer
'''	texCoordBuf.Initialize(binBuffer)
'''	texCoordBuf.ByteBuffer = texCoordBuf.wrap(binBuffer, texCoordOffset, texCoordCount * 8)
'''	texCoordBuf.Order(texCoordBuf.LITTLE_ENDIAN)
	Dim texCoordBuf As ByteBuffer
	texCoordBuf.Initialize(binBuffer)
	texCoordBuf.Order(texCoordBuf.LITTLE_ENDIAN)
'''	
'''	Dim floatStride As Int = stride / 4
'''	texCoordBuf.Position(texCoordOffset / 4)
'''	Dim texCoords As FloatBuffer
'''	texCoords.FloatBuffer = texCoords.allocateDirect(texCoordCount * 2 * 4, texCoords.NATIVE_ORDER)
'''
'''	For i = 0 To texCoordCount - 1
'''		Dim pos As Int = (texCoordOffset / 4) + i * floatStride
'''		texCoordBuf.position(pos)
'''		Dim u As Float = texCoordBuf.Float
'''		Dim v As Float = texCoordBuf.Float
''''''		u = Max(0, Min(1, (u + 1) / 2)) ' Clip just in case
'''		'''		v = Max(0, Min(1, (v + 1) / 2))
'''		If i = 0 Then
'''			Log($"First texcoord: u=${u}, v=${v}"$)
'''		End If
'''		texCoords.put(u)
'''		texCoords.put(v)
'''	Next
	'''	texCoords.position(0)
	
	' Total offset in bytes
	Dim totalByteOffset As Int = texCoordBufferByteOffset + texCoordByteOffset
	Dim floatStride As Int = stride / 4
	Dim offsetInFloats As Int = totalByteOffset / 4

	texCoordBuf.position(0)
	Dim texCoords As FloatBuffer
	texCoords.FloatBuffer = texCoords.allocateDirect(texCoordCount * 2 * 4, texCoords.NATIVE_ORDER)

'''	For i = 0 To texCoordCount - 1
'''		Dim pos As Int = offsetInFloats + i * floatStride
'''		If pos + 1 >= texCoordBuf.capacity Then
'''			Log($"[Warning] texCoord position ${pos} is out of bounds, skipping"$)
'''			Exit
'''		End If
'''
'''		texCoordBuf.position(pos)
'''		Dim u As Float = texCoordBuf.Float
'''		Dim v As Float = texCoordBuf.Float
'''
'''		If i = 0 Then Log($"First texcoord: u=${u}, v=${v}"$)
'''
'''		texCoords.put(u)
'''		texCoords.put(v)
	'''	Next

	For i = 0 To texCoordCount - 1
		Dim offset As Int = texCoordOffset + i * stride
		texCoordBuf.Position(offset)
		Dim u As Float = texCoordBuf.Float
		Dim v As Float = texCoordBuf.Float
'''		u = Max(0, Min(1, (u + 1) / 2)) ' Clip just in case
'''		v = Max(0, Min(1, (v + 1) / 2))
		u = Max(0, Min(1, u))
		v = Max(0, Min(1, v))
'''		If i = 0 Then
			Log($"First texcoord: u=${u}, v=${v}"$)
'''		End If
		texCoords.put(u)
		texCoords.put(v)
	Next

	texCoords.position(0)
	
	Dim model As ModelData
	model.Initialize
	model.texCoordBuffer = texCoords.FloatBuffer
	model.vertexBuffer = vertexBuffer
	model.indexBuffer = indexBuffer
	model.indexCount = idxCount
	
	Return model
End Sub

'''Public Sub extractBuffer(accessor As Map, bufferView As Map) As FloatBuffer
'''	Dim byteOffset As Int = bufferView.Get("byteOffset") + accessor.GetDefault("byteOffset", 0)
'''	Dim byteLength As Int = accessor.Get("count") * 4 * NumComponents(accessor.Get("type"))
'''    Dim inpstream As InputStream = File.OpenInput(File.DirAssets, "Cube.bin") 
'''	Dim byteData() As Byte 
'''	inpstream.ReadBytes(byteData, byteOffset, byteLength)
'''	Dim bb As ByteBuffer
'''	bb.Initialize(byteData)
'''	Return bb.As(FloatBuffer)
'''End Sub
'''
'''Private Sub NumComponents(accessorType As String) As Int
'''	Select accessorType
'''		Case "SCALAR": Return 1
'''		Case "VEC2": Return 2
'''		Case "VEC3": Return 3
'''		Case "VEC4": Return 4
'''		Case Else: Return 0
'''	End Select
'''End Sub