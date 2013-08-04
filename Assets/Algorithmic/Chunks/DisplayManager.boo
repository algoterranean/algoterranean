namespace Algorithmic.Chunks

import UnityEngine
import System.Collections.Generic

# main class responsible for receiving notifications from the
# DataManager that chunks need to be added, refreshed, or removed
# from the actual game world.
class DisplayManager (MonoBehaviour):

	# work queues. used in case we want to limit the number of
	# mesh updates handled at once so we can keep frame rates consistent.
	add_mesh_queue as Queue[of Chunk]
	remove_mesh_queue as Queue[of Chunk]
	
	# use the same mesh_mat instance so that Unity can use draw batching
	mesh_mat as Material
	mesh_water_mat as Material

	# draw_meshes_directly = false
	# dictionary for quick look up when removing or refreshing meshes
	# used when creating GameObjects and not drawing the Meshes directly.
	terrain_objects as Dictionary[of WorldBlockCoordinate, GameObject]
	terrain_parent as GameObject
	# # uses more direct calls to the "OpenGL" environment provided by Unity.
	# # used when the overhead of creating GameObjects outweighs the benefit.
	# visible_meshes as Dictionary[of WorldBlockCoordinate, Mesh]



	def Awake():
		add_mesh_queue = Queue[of Chunk]()
		remove_mesh_queue = Queue[of Chunk]()
		mesh_mat = Resources.Load("Materials/Terrain") as Material
		mesh_water_mat = Resources.Load("Materials/Water") as Material		

		terrain_parent = gameObject.Find("Terrain")
		terrain_objects = Dictionary[of WorldBlockCoordinate, GameObject]()
		# visible_meshes as Dictionary[of WorldBlockCoordinate, Mesh]()

		# TODO: move this elsewhere
		Screen.lockCursor = true
		

	def Update():
		# if there are meshes to create, create them
		# clear the entire work queue in one Update
		for i in range(len(add_mesh_queue)):
			_create_mesh_object(add_mesh_queue.Dequeue())

		# if there are meshes to remove, remove them
		# clear the entire work queue in one Update
		for i in range(len(remove_mesh_queue)):
			_remove_mesh_object(remove_mesh_queue.Dequeue())

		# # draw all of the visible meshes every frame if enabled.
		# if draw_meshes_directly:
		# 	for item in visible_meshes:
		# 		coords = item.Key
		# 		mesh = item.Value
		# 		Graphics.DrawMesh(mesh,
		# 						  Vector3(coords.x, coords.y, coords.z),
		# 						  Quaternion.identity,
		# 						  mesh_mat,
		# 						  0)
				
	# public functions for message passing purposes.
	def CreateMesh(c as Chunk):
		add_mesh_queue.Enqueue(c)

	def RemoveMesh(c as Chunk):
		remove_mesh_queue.Enqueue(c)

	def RefreshMesh(c as Chunk):
		_refresh_mesh_object(c)


	# this mesh already exists so instead of creating it we need to
	# find it and then update the mesh
	def _refresh_mesh_object(c as Chunk):
		m = c.getMeshData()
		mesh = Mesh()
		mesh.vertices = m.vertices
		mesh.triangles = m.triangles
		mesh.normals = m.normals
		mesh.uv = m.uvs
		mesh.colors = m.lights
		
		m2 = c.getMeshPhysXData()
		mesh_physx = Mesh()
		mesh_physx.vertices = m.vertices
		mesh_physx.triangles = m.triangles

		o = terrain_objects[c.getCoords()]
		mf = o.GetComponent(MeshFilter)
		mc = o.GetComponent(MeshCollider)
		mf.sharedMesh.Clear()
		mc.sharedMesh.Clear()
		mf.sharedMesh = mesh
		mc.sharedMesh = mesh_physx

		# actual_mesh = visible_meshes[c.getCoords()]
		# actual_mesh.Clear()
		# actual_mesh.vertices = chunk_mesh.getVertices()
		# actual_mesh.triangles = chunk_mesh.getTriangles()
		# actual_mesh.normals = chunk_mesh.getNormals()
		# actual_mesh.uv = chunk_mesh.getUVs()
		# # visible_meshes[c.getCoords()] = actual_mesh

	# TO DO: fix this. if a chunk is removed before it is added
	# (they are added when they are queued but removed when the distance
	# metric fails, but, the chunk could still be generating in a
	# thread somewhere in DataManager) it may hang around indefinitely
	# because it will never be removed again.
	def _remove_mesh_object(c as Chunk):
		# if draw_meshes_directly:
		# 	visible_meshes.Remove(c.getCoords())
		# else:
		coords = c.getCoords()
		if coords in terrain_objects:
			o = terrain_objects[coords]
			terrain_objects.Remove(coords)
			gameObject.Destroy(o)
			SendMessage("RemoveMesh2", c)
			

	def _create_mesh_object(c as Chunk):
		# print "DISPLAYING $c"
		scale = Settings.Chunks.Scale

		# SOLID TERRAIN
		m = c.getMeshData()
		mesh = Mesh()
		mesh.vertices = m.vertices
		mesh.triangles = m.triangles
		mesh.normals = m.normals
		mesh.uv = m.uvs
		mesh.colors = m.lights
		
		m2 = c.getMeshPhysXData()		
		mesh_physx = Mesh()
		mesh_physx.vertices = m2.vertices
		mesh_physx.triangles = m2.triangles
		
		o = GameObject()
		o.name = "$c"
		coords = c.getCoords()
		o.transform.parent = terrain_parent.transform
		o.transform.localScale = Vector3(scale, scale, scale)
		o.transform.position = Vector3(coords.x, coords.y, coords.z)
			
		o.AddComponent(MeshFilter)
		o.AddComponent(MeshRenderer)
		o.AddComponent(MeshCollider)
		o.GetComponent(MeshRenderer).material = mesh_mat #Resources.Load("Materials/Measure") as Material
		o.GetComponent(MeshFilter).sharedMesh = mesh
		o.GetComponent(MeshCollider).sharedMesh = mesh_physx
		
		terrain_objects[coords] = o

		# WATER TERRAIN
		m_w = c.getMeshWaterData()
		mesh_w = Mesh()
		mesh_w.vertices = m_w.vertices
		mesh_w.triangles = m_w.triangles
		mesh_w.normals = m_w.normals
		mesh_w.uv = m_w.uvs
		mesh_w.colors = m_w.lights

		o2 = GameObject()
		o2.name = "$c Water"
		coords = c.getCoords()
		o2.transform.parent = terrain_parent.transform
		o2.transform.localScale = Vector3(scale, scale, scale)
		o2.transform.position = Vector3(coords.x, coords.y, coords.z)
			
		o2.AddComponent(MeshFilter)
		o2.AddComponent(MeshRenderer)
		o2.AddComponent(MeshCollider)
		o2.GetComponent(MeshRenderer).material = mesh_water_mat #Resources.Load("Materials/Measure") as Material
		o2.GetComponent(MeshFilter).sharedMesh = mesh_w
		# o.GetComponent(MeshCollider).sharedMesh = mesh_physx
		

		c.clearMeshData()

