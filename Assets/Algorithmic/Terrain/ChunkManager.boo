namespace Algorithmic

import UnityEngine
import System.Threading


class ChunkManager (MonoBehaviour):
	origin as Vector3
	chunk_ball = {}
	_locker = object()
	_observers = []
	
	new_chunk_queue = []
	noise_calculated_queue = []
	mesh_calculated_queue = []
	completed_chunk_count = 0
	initial_chunks_complete = false


	def NoiseWorker(chunk as Chunk) as WaitCallback:
		try:
			chunk.CalculateNoise()
			coord = chunk.getCoordinates()
		except e:
			print "WHOOPS WE HAVE AN ERROR IN NOISE: " + e
		lock _locker:
			noise_calculated_queue.Push(chunk)

	def MeshWorker(chunk as Chunk) as WaitCallback:
		try:
			chunk.CalculateMesh()
		except e:
			print "WHOOPS WE HAVE AN ERROR IN MESH: " + e
		lock _locker:
			mesh_calculated_queue.Push(chunk)
		

	def Awake ():
		origin = Vector3(0,0,0)
		o = GameObject()
		o.name = "Terrain Parent"
		initial_chunks_complete = true
		#ThreadPool.SetMaxThreads(8, 50)
		

	def areInitialChunksComplete() as bool:
		return initial_chunks_complete

	def _which_chunk(x as double, z as double, y as double) as List:
		x_pos = System.Math.Floor(x / Settings.ChunkSize)
		z_pos = System.Math.Floor(z / Settings.ChunkSize)
		y_pos = System.Math.Floor(y / Settings.ChunkSize)
		return [x_pos * Settings.ChunkSize, z_pos * Settings.ChunkSize,  y_pos * Settings.ChunkSize]

	def getOrigin() as Vector3:
		return origin
		

	def setOrigin(x_pos as double, z_pos as double, y_pos as double) as void:
		origin = Vector3(x_pos,z_pos, y_pos)
		chunks_to_remove = []
		for chunk_info in chunk_ball:
			i = chunk_info.Value cast ChunkInfo
			i.calculateDistance(x_pos, z_pos, y_pos)
			if i.getDistance() > Settings.MinChunkDistance:
				chunks_to_remove.Push(chunk_info.Key)

		for key in chunks_to_remove:
			o = gameObject.Find("Chunk ($key)")
			if o != null:
				gameObject.Destroy(o)
				#chunk_ball.Remove(key)



		x = x_pos - Settings.MinChunkDistance + Settings.ChunkSize/2.0
		z = z_pos - Settings.MinChunkDistance + Settings.ChunkSize/2.0
		y = y_pos - Settings.MinChunkDistance + Settings.ChunkSize/2.0
		total_chunks = 0
		#safe_chunks = {}
		while x <= x_pos + Settings.MinChunkDistance:
			while z <= z_pos + Settings.MinChunkDistance:
				while y <= y_pos + Settings.MinChunkDistance:
					chunk_coord = _which_chunk(x cast double, z cast double, y cast double)
					if not chunk_ball.Contains("$(chunk_coord[0]), $(chunk_coord[1]), $(chunk_coord[2])"):
						#print "NOT FOUND $chunk_coord"
						chunk = Chunk(chunk_coord[0], chunk_coord[1], chunk_coord[2], Settings.ChunkSize, Settings.ChunkSize, Settings.ChunkSize)
						chunk_info = ChunkInfo(chunk)
						chunk_info.calculateDistance(x_pos, z_pos, y_pos)
						if chunk_info.getDistance() <= Settings.MinChunkDistance:
							chunk_ball["$(chunk_coord[0]), $(chunk_coord[1]), $(chunk_coord[2])"] = chunk_info
							new_chunk_queue.Push(chunk)

						
					total_chunks += 1
					y += Settings.ChunkSize
				z += Settings.ChunkSize
				y = y_pos - Settings.MinChunkDistance + Settings.ChunkSize/2.0
			x += Settings.ChunkSize
			y = y_pos - Settings.MinChunkDistance + Settings.ChunkSize/2.0
			z = z_pos - Settings.MinChunkDistance + Settings.ChunkSize/2.0

		for chunk_dict in chunk_ball:
			chunk_info = chunk_dict.Value as ChunkInfo
			x = chunk_info.getCoords()[0]
			z = chunk_info.getCoords()[1]
			y = chunk_info.getCoords()[2]
			chunk = chunk_info.getChunk()
			west_name = "$(x-Settings.ChunkSize), $z, $y"
			east_name = "$(x+Settings.ChunkSize), $z, $y"
			south_name = "$x, $(z-Settings.ChunkSize), $y"
			north_name = "$x, $(z+Settings.ChunkSize), $y"
			down_name = "$x, $z, $(y-Settings.ChunkSize)"
			up_name = "$x, $z, $(y+Settings.ChunkSize)"

			if chunk_ball.Contains(west_name):
				c = chunk_ball[west_name] as ChunkInfo
				chunk.setWestChunk(c.getChunk())
			if chunk_ball.Contains(east_name):
				c = chunk_ball[east_name] as ChunkInfo				
				chunk.setEastChunk(c.getChunk())
			if chunk_ball.Contains(south_name):
				c = chunk_ball[south_name] as ChunkInfo				
				chunk.setSouthChunk(c.getChunk())
			if chunk_ball.Contains(north_name):
				c = chunk_ball[north_name] as ChunkInfo				
				chunk.setNorthChunk(c.getChunk())
			if chunk_ball.Contains(down_name):
				c = chunk_ball[down_name] as ChunkInfo				
				chunk.setDownChunk(c.getChunk())
			if chunk_ball.Contains(up_name):
				c = chunk_ball[up_name] as ChunkInfo				
				chunk.setUpChunk(c.getChunk())
			if chunk.isMeshDirty():
				noise_calculated_queue.Push(chunk)
				#print 'REDRAWING CHUNK'

		print "setOrigin: TOTAL CHUNKS: $total_chunks"
			

	def Update():
		lock _locker:
			# calculate the noise for a chunk if it's new
			for chunk as Chunk in new_chunk_queue:
				ThreadPool.QueueUserWorkItem(NoiseWorker, chunk)
			new_chunk_queue = []
			
			# calculate a mesh if the noise has been completed on a chunk
			not_ready = []
			for chunk as Chunk in noise_calculated_queue:
				if chunk.areNeighborsReady():
					ThreadPool.QueueUserWorkItem(MeshWorker, chunk)
				else:
					not_ready.Push(chunk)
			noise_calculated_queue = not_ready

			# display a mesh if the mesh was calculated on a chunk
			if len(mesh_calculated_queue) > 0:
				chunk = mesh_calculated_queue.Pop() as Chunk
				coords = chunk.getCoordinates()
				#print "Displaying Chunk [$(coords[0]), $(coords[1]), $(coords[2])]"

				#name = 
				#print gameObject.Find(name)
				if gameObject.Find("Chunk ($(coords[0]), $(coords[1]), $(coords[2]))") == null:
					o = GameObject()
					o.name = "Chunk ($(coords[0]), $(coords[1]), $(coords[2]))"
					#o.transform.parent = gameObject.Find("Terrain Parent").transform
					o.AddComponent(MeshFilter)
					o.AddComponent(MeshRenderer)
					o.AddComponent(MeshCollider)
					mesh = Mesh()
					mesh.vertices = chunk.vertices
					mesh.triangles = chunk.triangles
					mesh.uv = chunk.uvs
					mesh.RecalculateNormals()
					o.GetComponent(MeshRenderer).material = Resources.Load("Materials/Measure") as Material
					o.GetComponent(MeshFilter).sharedMesh = mesh
					#o.GetComponent(MeshCollider).sharedMesh = mesh
					o.transform.position = Vector3(coords[0], coords[2], coords[1])
				else:
					o = gameObject.Find("Chunk ($(coords[0]), $(coords[1]), $(coords[2]))")
					mesh = Mesh()
					mesh.vertices = chunk.vertices
					mesh.triangles = chunk.triangles
					mesh.uv = chunk.uvs
					mesh.RecalculateNormals()
					o.GetComponent(MeshFilter).sharedMesh = mesh
					#o.GetComponent(MeshCollider).sharedMesh = mesh
					
				completed_chunk_count += 1

			if completed_chunk_count == (Settings.ChunkCountA * Settings.ChunkCountB * Settings.ChunkCountC) and not initial_chunks_complete:
				initial_chunks_complete = true
				# load some more chunks

			# remove chunk_ball objects that are out of range
			# for chunk_info in chunk_ball:
			# 	i = chunk_info.Value as ChunkInfo
			# 	coords = i.getCoords()
			# 	if i.getDistance() > Settings.MinChunkDistance:
			# 		c = gameObject.Find("Chunk ($(coords[0]), $(coords[1]), $(coords[2]))")
			# 		gameObject.DestroyImmediate(c)

		
				
