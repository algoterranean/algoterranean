namespace Algorithmic.Terrain

import UnityEngine
import Algorithmic.Player

#import System.Threading
#import System.Collections
#import Amib.Threading


class ChunkManager (MonoBehaviour, IObserver):
	origin as Vector3
	chunk_ball as ChunkBall
	add_mesh_queue = []
	remove_mesh_queue = []

	visible_meshes = {}
	mesh_mat as Material
	#mesh_cleanup_queue = []

	initialized as bool = false
	wait_for_init_queue = []

	#_registry as ForceParticleRegistry

	def getChunkBall():
		return chunk_ball

	def updateObserver(o as object):
		if o isa ChunkGeneratorMessage:
			cm = o cast ChunkGeneratorMessage
			message = cm.getMessage()
			chunk_info as ChunkInfo = cm.getData()
			chunk_blocks as IChunkBlockData = chunk_info.getChunk()
			#chunk_mesh as IChunkMeshData = chunk_info.getMesh()
			coords = chunk_blocks.getCoordinates()

			#print "ChunkManager: Receiving ChunkBall Update: $message ($(coords.x), $(coords.y), $(coords.z))"
			if message == Message.MESH_READY:
				add_mesh_queue.Push(chunk_info)
			elif message == Message.REMOVE:
				remove_mesh_queue.Push(chunk_info)

	def Awake():
		#chunk_ball = ChunkBall(Settings.ChunkWidth, Settings.ChunkDepth, Settings.ChunkSize)
		chunk_ball = ChunkBall(Settings.MaxChunks, Settings.ChunkSize)
		chunk_ball.registerObserver(self)
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
		chunk_info as ChunkInfo
		chunk_ball.Update()
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

		for x in visible_meshes:
			#m = visible_meshes[x]
			#print "DRAWING MESH $x"
			coords = x.Value[0]
			m = x.Value[1]
			Graphics.DrawMesh(m, Vector3(coords.x, coords.y, coords.z), Quaternion.identity, mesh_mat, 0)
			

		# check AABB bounding volumes
		# if isInitialized():
		# 	_player = gameObject.Find("Player").GetComponent("Player") as Player
		# 	_player_aabb = _player.getAABB()
		# 	x = gameObject.Find("Player").GetComponent("Player") as Player
			# if chunk_ball.CheckCollisions(_player_aabb):
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
		chunk_ball.SetOrigin(origin)
		self.origin = origin

	def _remove_mesh_object(chunk_info as ChunkInfo):
		chunk_blocks as ChunkBlockData = chunk_info.getChunk()
		coords = chunk_blocks.getCoordinates()
		n = "Chunk ($(coords.x), $(coords.y), $(coords.z))"
		visible_meshes.Remove(n)
		# o = gameObject.Find("Chunk ($(coords.x), $(coords.y), $(coords.z))")
		# if o != null:
		# 	gameObject.Destroy(o)
		# else:
		# 	updateObserver(ChunkBallMessage(Message.REMOVE, chunk_info))

	def _create_mesh_object(chunk_info as ChunkInfo):
		chunk_blocks as ChunkBlockData = chunk_info.getChunk()
		chunk_mesh as ChunkMeshData = chunk_info.getMesh()
		coords = chunk_blocks.getCoordinates()
		
		c_name = "Chunk ($(coords.x), $(coords.y), $(coords.z))"
		m = Mesh()
		m.vertices = chunk_mesh.getVertices()
		m.triangles = chunk_mesh.getTriangles()
		m.normals = chunk_mesh.getNormals()
		m.uv = chunk_mesh.getUVs()
		#visible_meshes.Push(m)
		visible_meshes[c_name] = [coords, m]

		# o = GameObject()
		# o.name = "Chunk ($(coords.x), $(coords.y), $(coords.z))"
		# #o.transform.parent = gameObject.Find("Terrain Parent").transform
		# o.AddComponent(MeshFilter)
		# o.AddComponent(MeshRenderer)
		# o.AddComponent(MeshCollider)
		# mesh = Mesh()
		# mesh.vertices = chunk_mesh.getVertices()
		# mesh.triangles = chunk_mesh.getTriangles()
		# mesh.normals = chunk_mesh.getNormals()
		# mesh.uv = chunk_mesh.getUVs()
		# o.GetComponent(MeshRenderer).material = Resources.Load("Materials/Measure") as Material
		# o.GetComponent(MeshFilter).sharedMesh = mesh
		# #o.GetComponent(MeshCollider).sharedMesh = mesh

		# t = gameObject.Find("Terrain").transform
		# o.transform.parent = t
		# o.transform.position = Vector3(coords.x, coords.y, coords.z)
