namespace Algorithmic.Chunks

import UnityEngine
import System.Collections.Generic
import System.Math


struct TerrainObject:
	coord as WorldBlockCoordinate
	mesh_type as byte
	hash as int

	def constructor(c as WorldBlockCoordinate, m as byte):
		mesh_type = m
		coord = c
		hash = c.hash ^ (mesh_type * 11)

	override def GetHashCode() as int:
		return hash

	override def Equals(o) as bool:
		v = o cast TerrainObject
		return v.coord.x == coord.x and v.coord.y == coord.y and v.coord.z == coord.z and v.mesh_type == mesh_type

	override def ToString() as string:
		return "$mesh_type: ($coord.x, $coord.y, $coord.z)"

	def CompareTo(o as object) as int:
		c = o cast TerrainObject
		cc = c.coord cast WorldBlockCoordinate
		
		a = Abs(coord.x cast long) + Abs(coord.y cast long) + Abs(coord.z cast long) + Abs(mesh_type cast long)
		b = Abs(cc.x cast long) + Abs(cc.y cast long) + Abs(cc.z cast long) + Abs(c.mesh_type cast long)
		if a < b:
			return -1
		elif a > b:
			return 1
		else:
			return 0

	def UpdateHash():
		coord.UpdateHash()
		hash = coord.hash ^ (mesh_type * 11)
		
		

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
	terrain_objects as Dictionary[of TerrainObject, GameObject]
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
		terrain_objects = Dictionary[of TerrainObject, GameObject]()
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
		
		def _refresh_mesh_object_helper(o as GameObject, terrain_mesh as Mesh, physx_mesh as Mesh):
			mf = o.GetComponent(MeshFilter)
			mc = o.GetComponent(MeshCollider)
			mf.sharedMesh.Clear()
			mc.sharedMesh.Clear()
			mf.sharedMesh = terrain_mesh
			mc.sharedMesh = physx_mesh
		
		# SOLID
		mesh = _create_mesh_helper(c.getMeshData(), false)
		mesh_physx = _create_mesh_helper(c.getMeshPhysXData(), true)
		o = terrain_objects[TerrainObject(c.getCoords(), 0)]   # 0 = solid
		_refresh_mesh_object_helper(o, mesh, mesh_physx)

		# WATER
		mesh_w = _create_mesh_helper(c.getMeshWaterData(), false)
		m_w_physx = _create_mesh_helper(c.getMeshWaterPhysXData(), true)
		o2 = terrain_objects[TerrainObject(c.getCoords(), 200)] # 200 = water
		_refresh_mesh_object_helper(o2, mesh_w, m_w_physx)

	# TO DO: fix this. if a chunk is removed before it is added
	# (they are added when they are queued but removed when the distance
	# metric fails, but, the chunk could still be generating in a
	# thread somewhere in DataManager) it may hang around indefinitely
	# because it will never be removed again.
	def _remove_mesh_object(c as Chunk):
		# if draw_meshes_directly:
		# 	visible_meshes.Remove(c.getCoords())
		# else:
		tobj = TerrainObject(c.getCoords(), 0)
		if tobj in terrain_objects:
			o = terrain_objects[tobj]
			terrain_objects.Remove(tobj)
			gameObject.Destroy(o)
			#SendMessage("RemoveMesh2", c)

		tobj_water = TerrainObject(c.getCoords(), 200)
		if tobj_water in terrain_objects:
			o = terrain_objects[tobj_water]
			terrain_objects.Remove(tobj_water)
			gameObject.Destroy(o)
			#SendMessage("RemoveMesh2", c)
		

	def _create_mesh_helper(m as MeshData, physx as bool) as Mesh:
		mesh = Mesh()
		mesh.vertices = m.vertices
		mesh.triangles = m.triangles
		if not physx:
			mesh.normals = m.normals
			mesh.uv = m.uvs
			mesh.colors = m.lights
		return mesh
		
		
	def _create_mesh_object(c as Chunk):


	
		def _create_mesh_object_helper(obj_name as string,
									   coords as WorldBlockCoordinate,
									   terrain_mesh as Mesh,
									   physx_mesh as Mesh,
									   mat as Material) as GameObject:
			scale = Settings.Chunks.Scale		
			o = GameObject()
			o.name = obj_name
			o.transform.parent = terrain_parent.transform
			o.transform.localScale = Vector3(scale, scale, scale)
			o.transform.position = Vector3(coords.x, coords.y, coords.z)
			o.AddComponent(MeshFilter)
			o.AddComponent(MeshRenderer)
			o.AddComponent(MeshCollider)
			o.GetComponent(MeshRenderer).material = mat
			o.GetComponent(MeshFilter).sharedMesh = terrain_mesh
			o.GetComponent(MeshCollider).sharedMesh = physx_mesh
		
			return o
		
		scale = Settings.Chunks.Scale
		coords = c.getCoords()

		# SOLID
		mesh = _create_mesh_helper(c.getMeshData(), false)
		mesh_physx = _create_mesh_helper(c.getMeshPhysXData(), true)
		o = _create_mesh_object_helper("$c", coords, mesh, mesh_physx, mesh_mat)
		terrain_objects[TerrainObject(coords, 0)] = o

		# WATER
		mesh_w = _create_mesh_helper(c.getMeshWaterData(), false)
		mesh_w_physx = _create_mesh_helper(c.getMeshWaterPhysXData(), true)
		o2 = _create_mesh_object_helper("$c Water", coords, mesh_w, mesh_w_physx, mesh_water_mat)
		o2.AddComponent(Water)
		terrain_objects[TerrainObject(coords, 200)] = o2
		
		c.clearMeshData()

