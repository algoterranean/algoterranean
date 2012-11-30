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
		chunk.GenerateNoise()
		coord = chunk.GetCoordinates()
		print "Completed chunk @ coordinates [$(coord['x']), $(coord['z']), $(coord['y'])]."
		while not chunk.AreNeighborsReady():
			Thread.Sleep(0.01)
		chunk.GenerateMesh()
		lock_taken = false
		try:
			Monitor.Enter(_locker)
			#terrain_chunks[coordinates[0], coordinates[1], coordinates[2]] = x
			#chunks_completed += 1
			#chunk_queue.Push([coordinates[0], coordinates[1], coordinates[2]])
		ensure:
			Monitor.Exit(_locker)
		

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
					if x >= 1:
						chunk.SetWestChunk(terrain_chunks[x-1, z, y])
					if x < Settings.ChunkCountX - 1:
						chunk.SetEastChunk(terrain_chunks[x+1, z, y])
					if z >= 1:
						chunk.SetSouthChunk(terrain_chunks[x, z-1, y])
					if z < Settings.ChunkCountZ - 1:
						chunk.SetNorthChunk(terrain_chunks[x, z+1, y])
					if y >= 1:
						chunk.SetDownChunk(terrain_chunks[x, z, y-1])
					if y < Settings.ChunkCountY - 1:
						chunk.SetUpChunk(terrain_chunks[x, z, y+1])
					ThreadPool.QueueUserWorkItem(ChunkWorkItem, terrain_chunks[x, z, y])

	def Update():
		lock_taken = false
		try:
			Monitor.Enter(_locker)
			#if len(chunk_queue) > 0:
			for x in range(Settings.ChunkCountX):
				for z in range(Settings.ChunkCountZ):
					for y in range(Settings.ChunkCountY):
						chunk = terrain_chunks[x, z, y]						
						if chunk.MeshGenerated() and not chunk.IsVisible():
							chunk.SetVisible(true)
							print "Generating Mesh [$x, $z, $y]"
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
							o.transform.position = Vector3(x * Settings.ChunkSize, y* Settings.ChunkSize, z* Settings.ChunkSize)
		ensure:
			Monitor.Exit(_locker)
		
