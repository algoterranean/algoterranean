"""Maintains a list of all the existing chunks and manages drawing them to the
screen. Receives updates via SendMessage (CreateMesh, RefreshMesh, and RemoveMesh)
and reacts appropriately. """
namespace Algorithmic.Chunks

import UnityEngine


class DisplayManager (MonoBehaviour):

	add_mesh_queue = []
	remove_mesh_queue = []
	visible_meshes = {}
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
			for x in visible_meshes:
				coords = x.Value[0]
				m = x.Value[1]
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
				
	def CreateMesh(ci as Chunk):
		add_mesh_queue.Push(ci)

	def RemoveMesh(ci as Chunk):
		remove_mesh_queue.Push(ci)

	def RefreshMesh(ci as Chunk):
		_refresh_mesh_object(ci)		


	#
	# helper functions for removing chunks, adding chunks, and refreshing chunks
	#
	
	def _refresh_mesh_object(i as Chunk):
		chunk_mesh as MeshData = i.getMesh()
		actual_mesh = visible_meshes["$i"][1]
		actual_mesh.vertices = chunk_mesh.getVertices()
		actual_mesh.triangles = chunk_mesh.getTriangles()
		actual_mesh.normals = chunk_mesh.getNormals()
		actual_mesh.uv = chunk_mesh.getUVs()
		visible_meshes["$i"][1] = actual_mesh

	def _remove_mesh_object(chunk_info as Chunk):
		if draw_meshes_directly:
			# what if the key doesn't exist yet?
			#if "$chunk_info" in visible_meshes:
			visible_meshes.Remove("$chunk_info")
			# else:
			# 	RemoveMesh(chunk_info)
		else:
			o = gameObject.Find("$chunk_info")
			if o != null:
				gameObject.Destroy(o)
			else:
				# TO DO: add explanation
				RemoveMesh(chunk_info)

	def _create_mesh_object(chunk_info as Chunk):
		chunk_blocks as BlockData = chunk_info.getBlocks()
		chunk_mesh as MeshData = chunk_info.getMesh()
		coords = chunk_blocks.getCoordinates()
		
		mesh = Mesh()
		mesh.vertices = chunk_mesh.getVertices()
		mesh.triangles = chunk_mesh.getTriangles()
		mesh.normals = chunk_mesh.getNormals()
		mesh.uv = chunk_mesh.getUVs()

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
