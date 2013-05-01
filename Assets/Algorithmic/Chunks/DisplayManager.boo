namespace Algorithmic.Chunks

import UnityEngine
import Algorithmic.Player
import Algorithmic.Misc

#import System.Threading
#import System.Collections
#import Amib.Threading


class DisplayManager (MonoBehaviour):
	origin as Vector3
	data_manager as DataManager
	add_mesh_queue = []
	remove_mesh_queue = []

	visible_meshes = {}
	mesh_mat as Material

	initialized as bool = false
	wait_for_init_queue = []
	draw_meshes_directly = true


	def getChunkBall():
		return data_manager


	def CreateMesh(ci as ChunkInfo):
		add_mesh_queue.Push(ci)

	def RefreshMesh(ci as ChunkInfo):
		refresh_mesh(ci)		

	def RemoveMesh(ci as ChunkInfo):
		remove_mesh_queue.Push(ci)
		

	def Awake():
		data_manager = GetComponent("DataManager")
		#DataManager() #Settings.MaxChunks, Settings.ChunkSize)
		#data_manager.registerObserver(self)
		mesh_mat = Resources.Load("Materials/Measure") as Material
		Screen.lockCursor = true
		#_registry = ForceParticleRegistry()

	def Start():
		# intialize world
		setOrigin(Vector3(0, 0, 0))
		wait_for_init_queue.Push(LongVector3(0, 0, 0))

		#x = gameObject.Find("Player").GetComponent("Player") as Player
		#_registry.add(x, Gravity())

	def Update():
		#chunk_info as ChunkInfo
		#data_manager.Update()
		
		# check if all the needed chunks in initial load are completed
		if len(wait_for_init_queue) == 0:
			initialized = true

		if len(add_mesh_queue) > 0:
			chunk_info = add_mesh_queue.Pop()
			chunk = chunk_info.getChunk()
			coord = chunk.getCoordinates()
			_create_mesh_object(chunk_info)
			if coord in wait_for_init_queue:
				wait_for_init_queue.Remove(coord)

		if len(remove_mesh_queue) > 0:
			chunk_info = remove_mesh_queue.Pop()
			_remove_mesh_object(chunk_info)

		if draw_meshes_directly:
			for x in visible_meshes:
				coords = x.Value[0]
				m = x.Value[1]
				Graphics.DrawMesh(m, Vector3(coords.x, coords.y, coords.z), Quaternion.identity, mesh_mat, 0)
			

		# check AABB bounding volumes
		# if isInitialized():
		# 	_player = gameObject.Find("Player").GetComponent("Player") as Player
		# 	_player_aabb = _player.getAABB()
		# 	x = gameObject.Find("Player").GetComponent("Player") as Player
			# if data_manager.CheckCollisions(_player_aabb):
			#     x.stopGravity()
			# else:
			#     x.startGravity()

	def FixedUpdate():
		pass
		# apply gravity to the player
		#_registry.updateForces(Time.deltaTime)

		## x = gameObject.Find("First Person Controller").GetComponent("Player") as Player
		## x.addForce(Vector3(0, -9.8, 0))

	def isInitialized() as bool:
		return initialized

	def areInitialChunksComplete() as bool:
		pass

	def setOrigin(origin as Vector3) as void:
		data_manager.SetOrigin(origin)
		self.origin = origin

	def refresh_mesh(i as ChunkInfo):
		chunk_blocks as BlockData = i.getChunk()
		chunk_mesh as MeshData = i.getMesh()
		coords = chunk_blocks.getCoordinates()
		
		n = "$i"
		#visible_meshes.Remove(n)
		
		actual_mesh = visible_meshes[n][1]
		actual_mesh.vertices = chunk_mesh.getVertices()
		actual_mesh.triangles = chunk_mesh.getTriangles()
		actual_mesh.normals = chunk_mesh.getNormals()
		actual_mesh.uv = chunk_mesh.getUVs()
		visible_meshes[n][1] = actual_mesh
		#visible_meshes[n] = [coords, m]

	def _remove_mesh_object(chunk_info as ChunkInfo):
		chunk_blocks as BlockData = chunk_info.getChunk()
		coords = chunk_blocks.getCoordinates()
		if draw_meshes_directly:
			visible_meshes.Remove("$chunk_info")
		else:
			o = gameObject.Find("$chunk_info")
			if o != null:
				gameObject.Destroy(o)
			# else: # TO DO: THIS IS REQUIRED WHEN NOT DRAWING MESHES DIRECTLY for when some meshes are not instantiated before being removed
			#  	updateObserver(ChunkGeneratorMessage(Message.REMOVE, chunk_info))

	def _create_mesh_object(chunk_info as ChunkInfo):
		chunk_blocks as BlockData = chunk_info.getChunk()
		chunk_mesh as MeshData = chunk_info.getMesh()
		coords = chunk_blocks.getCoordinates()
		
		mesh = Mesh()
		mesh.vertices = chunk_mesh.getVertices()
		mesh.triangles = chunk_mesh.getTriangles()
		mesh.normals = chunk_mesh.getNormals()
		mesh.uv = chunk_mesh.getUVs()
		#visible_meshes.Push(m)
		if draw_meshes_directly:
			visible_meshes["$chunk_info"] = [coords, mesh]
		else:
			o = GameObject()
			o.name = "$chunk_info"
			o.AddComponent(MeshFilter)
			o.AddComponent(MeshRenderer)
			o.AddComponent(MeshCollider)
			o.GetComponent(MeshRenderer).material = Resources.Load("Materials/Measure") as Material
			o.GetComponent(MeshFilter).sharedMesh = mesh
			o.GetComponent(MeshCollider).sharedMesh = mesh

			# t = gameObject.Find("Terrain").transform
			# o.transform.parent = t
			o.transform.position = Vector3(coords.x, coords.y, coords.z)
