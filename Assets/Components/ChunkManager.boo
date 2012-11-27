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


	def ChunkWorkItem(coordinates as List) as WaitCallback:
		x = Chunk(coordinates[0], coordinates[1], coordinates[2],
			  coordinates[3], coordinates[4], coordinates[5])
		print "Completed Chunk $coordinates"
		lock_taken = false
		try:
			Monitor.Enter(_locker)
			terrain_chunks[coordinates[0], coordinates[1], coordinates[2]] = x
			chunks_completed += 1
			chunk_queue.Push([coordinates[0], coordinates[1], coordinates[2]])
		ensure:
			Monitor.Exit(_locker)
		

	def Awake ():
		# initialize the memory for the array
		#size = Settings.ChunkSize * Settings.ChunkCount + 2  # +1 per side for calculated but undisplayed blocks
		terrain_chunks = matrix(Chunk, Settings.ChunkCountX, Settings.ChunkCountZ, Settings.ChunkCountY)
		ThreadPool.SetMaxThreads(8, 50)
		#terrain_blocks = matrix(byte, size, size, size)

		# work packages will be tossed off to the thread pool
		# and divided up by chunks for efficiency
		for x in range(Settings.ChunkCountX):
			for z in range(Settings.ChunkCountZ):
				for y in range(Settings.ChunkCountY):
					ThreadPool.QueueUserWorkItem(ChunkWorkItem, [x, z, y, Settings.ChunkSize, Settings.ChunkSize, Settings.ChunkSize])

	def Update():
		lock_taken = false
		try:
			Monitor.Enter(_locker)
			for x as List in chunk_queue:
				chunk = terrain_chunks[x[0], x[1], x[2]]
				o = GameObject()
				o.AddComponent(MeshFilter)
				o.AddComponent(MeshRenderer)
				#o.AddComponent(MeshCollider)
				
				mesh = Mesh()
				mesh.vertices = chunk.vertices
				mesh.triangles = chunk.triangles
				mesh.uv = chunk.uvs
				mesh.RecalculateNormals()
				o.GetComponent(MeshRenderer).material = Resources.Load("Materials/Measure") as Material
				o.GetComponent(MeshFilter).sharedMesh = mesh
				o.transform.position = Vector3((x[0] cast int)* Settings.ChunkSize, (x[1] cast int)* Settings.ChunkSize, (x[2] cast int)* Settings.ChunkSize)
				#o.transform.Rotate()

			chunk_queue = []
		ensure:
			Monitor.Exit(_locker)
		
