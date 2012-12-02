import UnityEngine
import System.Threading

class ChunkManager (MonoBehaviour, IObserver, IObservable):
	terrain_chunks as (Chunk, 3)
	_locker = object()
	chunks_completed = 0
	chunk_queue = []
	_observers = []

	# we'll keep the observer/observable interface for now
	def Subscribe(obj as IObserver):
		if obj not in _observers:
			_observers.Add(obj)

	def Unsubscribe(obj as IObserver):
		if obj in _observers:
			_observers.Remove(obj)

	def OnData(obj as IObservable):
		pass


	def ChunkWorkItem(chunk as Chunk) as WaitCallback:
		try:
			chunk.CalculateNoise()
			coord = chunk.getCoordinates()
			print "Completed chunk @ coordinates [$(coord[0]), $(coord[1]), $(coord[2])]."
			while not chunk.areNeighborsReady():
				Thread.Sleep(0.01)
				#print "Neighbors for [$(coord[0]), $(coord[1]), $(coord[2])]: $(chunk.getWestChunk().isNull()), $(chunk.getEastChunk().isNull()), $(chunk.getSouthChunk().isNull()), $(chunk.getNorthChunk().isNull()), $(chunk.getDownChunk().isNull()), $(chunk.getUpChunk().isNull())"
			chunk.CalculateMesh()
			print "Completed mesh calculation for [$(coord[0]), $(coord[1]), $(coord[2])]."		
		except e:
			print "WHOOPS WE HAVE AN ERROR: " + e
		lock _locker:
			chunk_queue.Push(chunk)
		
		

		# lock_taken = false
		# try:
		# 	Monitor.Enter(_locker)
		# 	#terrain_chunks[coordinates[0], coordinates[1], coordinates[2]] = x
		# 	#chunks_completed += 1
		# 	chunk_queue.Push(chunk)
		# ensure:
		# 	Monitor.Exit(_locker)
		

	def Awake ():
		# initialize the memory for the array
		#size = Settings.ChunkSize * Settings.ChunkCount + 2  # +1 per side for calculated but undisplayed blocks
		terrain_chunks = matrix(Chunk, Settings.ChunkCountX, Settings.ChunkCountZ, Settings.ChunkCountY)
		#ThreadPool.SetMaxThreads(8, 50)
		#terrain_blocks = matrix(byte, size, size, size)

		# work packages will be tossed off to the thread pool
		# and divided up by chunks for efficiency
		for x in range(Settings.ChunkCountX):
			for z in range(Settings.ChunkCountZ):
				for y in range(Settings.ChunkCountY):
					c = Chunk(x * Settings.ChunkSize,
						    z * Settings.ChunkSize,
						    y * Settings.ChunkSize,
						    Settings.ChunkSize,
						    Settings.ChunkSize,
						    Settings.ChunkSize)
					terrain_chunks[x,z,y] = c


		for x in range(Settings.ChunkCountX):
			for z in range(Settings.ChunkCountZ):
				for y in range(Settings.ChunkCountY):
					chunk = terrain_chunks[x, z, y]
					if x > 0:
						chunk.setWestChunk(terrain_chunks[x-1, z, y])
					if x < Settings.ChunkCountX - 1:
						chunk.setEastChunk(terrain_chunks[x+1, z, y])
					if z > 0:
						chunk.setSouthChunk(terrain_chunks[x, z-1, y])
					if z < Settings.ChunkCountZ - 1:
						chunk.setNorthChunk(terrain_chunks[x, z+1, y])
					if y > 0:
						chunk.setDownChunk(terrain_chunks[x, z, y-1])
					if y < Settings.ChunkCountY - 1:
						chunk.setUpChunk(terrain_chunks[x, z, y+1])
					ThreadPool.QueueUserWorkItem(ChunkWorkItem, terrain_chunks[x, z, y])

	def Update():
		# lock_taken = false
		# try:
		# 	Monitor.Enter(_locker)
		lock _locker:
			if len(chunk_queue) > 0:
				chunk = chunk_queue.Pop() as Chunk
				coords = chunk.getCoordinates()
				print "Generating Mesh [$(coords[0]), $(coords[1]), $(coords[2])]"
				
				o = GameObject()
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
		# ensure:
		# 	Monitor.Exit(_locker)
		
