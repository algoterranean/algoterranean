import UnityEngine
import System.Threading

class ChunkManager (MonoBehaviour, IObserver, IObservable):
	terrain_chunks as (Chunk, 3)
	_locker = object()
	_observers = []
	
	new_chunk_queue = []
	noise_calculated_queue = []
	mesh_calculated_queue = []

	# we'll keep the observer/observable interface for now
	def Subscribe(obj as IObserver):
		if obj not in _observers:
			_observers.Add(obj)

	def Unsubscribe(obj as IObserver):
		if obj in _observers:
			_observers.Remove(obj)

	def OnData(obj as IObservable):
		pass


	def AddRowNorth():
		pass
	

	def NoiseWorker(chunk as Chunk) as WaitCallback:
		try:
			chunk.CalculateNoise()
			coord = chunk.getCoordinates()
			print "Completed NOISE: [$(coord[0]), $(coord[1]), $(coord[2])]."
		except e:
			print "WHOOPS WE HAVE AN ERROR IN NOISE: " + e
		lock _locker:
			noise_calculated_queue.Push(chunk)

	def MeshWorker(chunk as Chunk) as WaitCallback:
		try:
			chunk.CalculateMesh()
			coord = chunk.getCoordinates()
			print "Completed MESH: [$(coord[0]), $(coord[1]), $(coord[2])]."
		except e:
			print "WHOOPS WE HAVE AN ERROR IN MESH: " + e
		lock _locker:
			mesh_calculated_queue.Push(chunk)
		

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
					ThreadPool.QueueUserWorkItem(NoiseWorker, terrain_chunks[x, z, y])
					#Thread.Sleep(100)


	def Update():
		# lock_taken = false
		# try:
		# 	Monitor.Enter(_locker)
		lock _locker:
			not_ready = []
			for chunk as Chunk in noise_calculated_queue:
				if chunk.areNeighborsReady():
					ThreadPool.QueueUserWorkItem(MeshWorker, chunk)
				else:
					not_ready.Push(chunk)
			noise_calculated_queue = not_ready

			if len(mesh_calculated_queue) > 0:
				chunk = mesh_calculated_queue.Pop() as Chunk
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
		
