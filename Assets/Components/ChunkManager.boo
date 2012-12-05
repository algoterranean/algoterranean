import UnityEngine
import System.Threading

class ChunkManager (MonoBehaviour, IObserver, IObservable):
	terrain_chunks as (Chunk, 3)
	origin as Vector3
	chunk_ball = {}
	_locker = object()
	_observers = []
	
	new_chunk_queue = []
	noise_calculated_queue = []
	mesh_calculated_queue = []
	completed_chunk_count = 0
	initial_chunks_complete = false

	# we'll keep the observer/observable interface for now
	def Subscribe(obj as IObserver):
		if obj not in _observers:
			_observers.Add(obj)

	def Unsubscribe(obj as IObserver):
		if obj in _observers:
			_observers.Remove(obj)

	def OnData(obj as IObservable):
		pass


	def NoiseWorker(chunk as Chunk) as WaitCallback:
		try:
			chunk.CalculateNoise()
			coord = chunk.getCoordinates()
			#print "Completed NOISE: [$(coord[0]), $(coord[1]), $(coord[2])]."
		except e:
			print "WHOOPS WE HAVE AN ERROR IN NOISE: " + e
		lock _locker:
			noise_calculated_queue.Push(chunk)

	def MeshWorker(chunk as Chunk) as WaitCallback:
		try:
			chunk.CalculateMesh()
			#coord = chunk.getCoordinates()
			#print "Completed MESH: [$(coord[0]), $(coord[1]), $(coord[2])]."
		except e:
			print "WHOOPS WE HAVE AN ERROR IN MESH: " + e
		lock _locker:
			mesh_calculated_queue.Push(chunk)
		

	def Awake ():
		# initialize the memory for the array
		#size = Settings.ChunkSize * Settings.ChunkCount + 2  # +1 per side for calculated but undisplayed blocks
		origin = Vector3(0,0,0)
		terrain_chunks = matrix(Chunk, Settings.ChunkCountA, Settings.ChunkCountB, Settings.ChunkCountC)
		o = GameObject()
		o.name = "Terrain Parent"
		initial_chunks_complete = true		
		#ThreadPool.SetMaxThreads(8, 50)
		#terrain_blocks = matrix(byte, size, size, size)

		# work packages will be tossed off to the thread pool
		# and divided up by chunks for efficiency
		# for x in range(Settings.ChunkCountA):
		# 	for z in range(Settings.ChunkCountB):
		# 		for y in range(Settings.ChunkCountC):
		# 			c = Chunk(x * Settings.ChunkSize,
		# 				    z * Settings.ChunkSize,
		# 				    y * Settings.ChunkSize,
		# 				    Settings.ChunkSize,
		# 				    Settings.ChunkSize,
		# 				    Settings.ChunkSize)
		# 			i = ChunkInfo(c)
		# 			chunk_ball["$x,$z,$y"] = i
		# 			terrain_chunks[x,z,y] = c


		# for x in range(Settings.ChunkCountA):
		# 	for z in range(Settings.ChunkCountB):
		# 		for y in range(Settings.ChunkCountC):
		# 			chunk = terrain_chunks[x, z, y]
		# 			if x > 0:
		# 				chunk.setWestChunk(terrain_chunks[x-1, z, y])
		# 			if x < Settings.ChunkCountA - 1:
		# 				chunk.setEastChunk(terrain_chunks[x+1, z, y])
		# 			if z > 0:
		# 				chunk.setSouthChunk(terrain_chunks[x, z-1, y])
		# 			if z < Settings.ChunkCountB - 1:
		# 				chunk.setNorthChunk(terrain_chunks[x, z+1, y])
		# 			if y > 0:
		# 				chunk.setDownChunk(terrain_chunks[x, z, y-1])
		# 			if y < Settings.ChunkCountC - 1:
		# 				chunk.setUpChunk(terrain_chunks[x, z, y+1])
		# 			new_chunk_queue.Push(chunk)
					
					#ThreadPool.QueueUserWorkItem(NoiseWorker, terrain_chunks[x, z, y])

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
		for chunk_info in chunk_ball:
			i = chunk_info.Value cast ChunkInfo
			i.calculateDistance(x_pos, z_pos, y_pos)

		x = x_pos - Settings.MinChunkDistance + Settings.ChunkSize/2.0
		z = z_pos - Settings.MinChunkDistance + Settings.ChunkSize/2.0
		y = y_pos - Settings.MinChunkDistance + Settings.ChunkSize/2.0
		total_chunks = 0
		safe_chunks = {}
		while x <= x_pos + Settings.MinChunkDistance:
			while z <= z_pos + Settings.MinChunkDistance:
				while y <= y_pos + Settings.MinChunkDistance:
					chunk_coord = _which_chunk(x cast double, z cast double, y cast double)
					if chunk_ball.Contains("$(chunk_coord[0]), $(chunk_coord[1]), $(chunk_coord[2])"):
						print "FOUND $chunk_coord"
					else:
						print "NOT FOUND $chunk_coord"
						chunk = Chunk(chunk_coord[0], chunk_coord[1], chunk_coord[2], Settings.ChunkSize, Settings.ChunkSize, Settings.ChunkSize)
						chunk_info = ChunkInfo(chunk)
						chunk_info.calculateDistance(x_pos, z_pos, y_pos)
						if chunk_info.getDistance() <= Settings.MinChunkDistance:
							chunk_ball["$(chunk_coord[0]), $(chunk_coord[1]), $(chunk_coord[2])"] = chunk_info
							new_chunk_queue.Push(chunk)
							safe_chunks["$(chunk_coord[0]), $(chunk_coord[1]), $(chunk_coord[2])"] = true
						
					total_chunks += 1
					y += Settings.ChunkSize
				z += Settings.ChunkSize
				y = y_pos - Settings.MinChunkDistance + Settings.ChunkSize/2.0
			x += Settings.ChunkSize
			y = y_pos - Settings.MinChunkDistance + Settings.ChunkSize/2.0
			z = z_pos - Settings.MinChunkDistance + Settings.ChunkSize/2.0

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
				print "Displaying Chunk [$(coords[0]), $(coords[1]), $(coords[2])]"

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

				completed_chunk_count += 1

			if completed_chunk_count == (Settings.ChunkCountA * Settings.ChunkCountB * Settings.ChunkCountC) and not initial_chunks_complete:
				initial_chunks_complete = true
				# load some more chunks

			# remove chunk_ball objects that are out of range
			for chunk_info in chunk_ball:
				i = chunk_info.Value as ChunkInfo
				coords = i.getCoords()
				if i.getDistance() > Settings.MinChunkDistance:
					c = gameObject.Find("Chunk ($(coords[0]), $(coords[1]), $(coords[2]))")
					gameObject.Destroy(c)

		
				
