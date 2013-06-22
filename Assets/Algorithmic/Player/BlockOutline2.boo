import UnityEngine
import Algorithmic.Chunks

class BlockOutline2 (MonoBehaviour):
	_enabled = false
	position = Vector3(0, 0, 0)
	size = 1

	blocks as (byte, 3)
	mesh_generator = generateMeshOutline
	mesh_data as MeshData2
	mesh as Mesh
	block_object as GameObject
	data_manager as DataManager


	
	def Start ():
		data_manager = gameObject.Find("Engine/ChunkManager").GetComponent("DataManager")
		
		blocks = matrix(byte, size, size, size)
		blocks[0, 0, 0] = 50
		mesh_data = mesh_generator(blocks)
		mesh = Mesh()
		mesh.vertices = mesh_data.vertices
		mesh.triangles = mesh_data.triangles
		mesh.normals = mesh_data.normals
		mesh.uv = mesh_data.uvs
		
		block_object = GameObject()
		block_object.name = "Block Outline 9"
		block_object.AddComponent(MeshFilter)
		block_object.AddComponent(MeshRenderer)
		block_object.GetComponent(MeshRenderer).material = Resources.Load("Materials/BlockOutline") as Material
		block_object.GetComponent(MeshFilter).sharedMesh = mesh

		scale = Settings.ChunkScale * 1.02/1.0
		offset = scale - Settings.ChunkScale
		block_object.transform.position = Vector3(position.x - offset, position.y - offset, position.z - offset)
		block_object.transform.localScale = Vector3(scale, scale, scale)
		
		block_object.GetComponent(MeshRenderer).enabled = true
		
	# def Update ():
	# 	if _enabled:
	# 		pass

	def refreshMesh(world as WorldBlockCoordinate, _size as byte):
		size = _size
		blocks = data_manager.getBlocks(world, size)
		#matrix(byte, size, size, size)
		#blocks[0, 0, 0] = 50
		
		mesh_data = mesh_generator(blocks)
		mesh = Mesh()
		mesh.vertices = mesh_data.vertices
		mesh.triangles = mesh_data.triangles
		mesh.normals = mesh_data.normals
		mesh.uv = mesh_data.uvs

		block_object.GetComponent(MeshFilter).sharedMesh = mesh
		
		scale = Settings.ChunkScale #* 1.02/1.0
		offset = 0 #0.0005/4.0 #scale - Settings.ChunkScale
		block_object.transform.position = Vector3(position.x - offset, position.y - offset, position.z - offset)
		block_object.transform.localScale = Vector3(scale, scale, scale)
		

		

	def setPosition(p as Vector3):
		scale = Settings.ChunkScale #* 1.01/1.0
		offset = 0.005/4.0 #scale - Settings.ChunkScale
		position = Vector3(p.x,
						   p.y,
						   p.z)
		block_object.transform.position = position

	def setSize(s as int):
		size = s

	def disable():
		block_object.GetComponent(MeshRenderer).enabled = false

	def enable():
		block_object.GetComponent(MeshRenderer).enabled = true

							 
