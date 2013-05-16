"""Maintains a list of all the existing chunks and manages drawing them to the
screen. Receives updates via SendMessage (CreateMesh, RefreshMesh, and RemoveMesh)
and reacts appropriately. """
namespace Algorithmic.Chunks

import UnityEngine
import System.Collections.Generic


class DisplayManager (MonoBehaviour):

	add_mesh_queue = [] #List[of Chunk]()
	remove_mesh_queue = [] #List[of Chunk]()
	visible_meshes = Dictionary[of WorldBlockCoordinate, Mesh]()
	mesh_mat as Material
	draw_meshes_directly = true


	def Awake():
		mesh_mat = Resources.Load("Materials/Measure") as Material
		Screen.lockCursor = true

	def Update():
		# if there is a mesh to add, pop it off and add it
		if len(add_mesh_queue) > 0:
			_create_mesh_object(add_mesh_queue.Pop())

		# if there is a mesh to remove, pop it off and remove it
		if len(remove_mesh_queue) > 0:
			_remove_mesh_object(remove_mesh_queue.Pop())

		# draw all of the visible meshes every frame.
		# this is much faster than creating and using traditional GameObjects
		if draw_meshes_directly:
			for coords as WorldBlockCoordinate in visible_meshes.Keys:
				m as Mesh = visible_meshes[coords]
				Graphics.DrawMesh(m, Vector3(coords.x, coords.y, coords.z), Quaternion.identity, mesh_mat, 0)
				
	#
	# message functions for communicating chunk state changes. can be called
	# via SendMessage (as a substitute for Observer/Observable) or directly.
	#
	# Add and Remove use queues so that it only updates one mesh per frame
	# to keep frame rates consistent. Refresh will make changes directly as
	# the update needs to occur immediately (due to digging/building taking
	# presidence over new mesh creation/displaying).
	#
				
	def CreateMesh(c as Chunk):
		if c.getCoords() in visible_meshes:
			_refresh_mesh_object(c)
		else:
			add_mesh_queue.Push(c)

	def RemoveMesh(c as Chunk):
		remove_mesh_queue.Push(c)

	def RefreshMesh(c as Chunk):
		_refresh_mesh_object(c)		


	#
	# helper functions for removing chunks, adding chunks, and refreshing chunks
	#
	
	def _refresh_mesh_object(c as Chunk):

		chunk_mesh as MeshData = c.getMesh()
		actual_mesh = visible_meshes[c.getCoords()]
		actual_mesh.Clear()
		actual_mesh.vertices = chunk_mesh.getVertices()
		actual_mesh.triangles = chunk_mesh.getTriangles()
		actual_mesh.normals = chunk_mesh.getNormals()
		actual_mesh.uv = chunk_mesh.getUVs()
		visible_meshes[c.getCoords()] = actual_mesh

	# TO DO: fix this. if a chunk is removed before it is added
	# (they are added when they are queued but removed when the distance
	# metric fails, but, the chunk could still be generating in a
	# thread somewhere in DataManager) it may hang around indefinitely
	# because it will never be removed again.
	def _remove_mesh_object(c as Chunk):
		if draw_meshes_directly:
			visible_meshes.Remove(c.getCoords())
		else:
			o = gameObject.Find("$c")
			if o != null:
				gameObject.Destroy(o)
			else:
				pass

	def _create_mesh_object(c as Chunk):
		chunk_blocks as BlockData = c.getBlocks()
		chunk_mesh as MeshData = c.getMesh()
		coords = chunk_blocks.getCoordinates()
		
		mesh = Mesh()
		mesh.vertices = chunk_mesh.getVertices()
		mesh.triangles = chunk_mesh.getTriangles()
		mesh.normals = chunk_mesh.getNormals()
		mesh.uv = chunk_mesh.getUVs()

		if draw_meshes_directly:
			visible_meshes[c.getCoords()] = mesh
		else:
			o = GameObject()
			o.name = "$c"
			o.AddComponent(MeshFilter)
			o.AddComponent(MeshRenderer)
			o.AddComponent(MeshCollider)
			o.GetComponent(MeshRenderer).material = Resources.Load("Materials/Measure") as Material
			o.GetComponent(MeshFilter).sharedMesh = mesh
			o.GetComponent(MeshCollider).sharedMesh = mesh

			# t = gameObject.Find("Terrain").transform
			# o.transform.parent = t
			o.transform.position = Vector3(coords.x, coords.y, coords.z)
