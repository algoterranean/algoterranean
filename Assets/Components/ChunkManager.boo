import UnityEngine
import System.Threading

class ChunkManager (MonoBehaviour, IObserver, IObservable):
	terrain_chunks as (Chunk, 3)
	#terrain_blocks as (byte, 3)   # 3 dimensional array of bytes
	#thread_pool as ThreadPool
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
	


	def AddChunk(chunk as Chunk, x as int, z as int, y as int):
		lock terrain_chunks:
			terrain_chunks[x, z, y] = chunk


	def ChunkWorkItem(coordinates as List) as WaitCallback:
		print "Processing Chunk $coordinates"
		x = Chunk(coordinates[0], coordinates[1], coordinates[2])
		print "Completed Chunk $coordinates"
		AddChunk(x, coordinates[0], coordinates[1], coordinates[2])
		

	def QueueChunk(x as int, z as int, y as int):
		ThreadPool.QueueUserWorkItem(ChunkWorkItem, [x, z, y])


	def Awake ():
		# initialize the memory for the array
		#size = Settings.ChunkSize * Settings.ChunkCount + 2  # +1 per side for calculated but undisplayed blocks
		terrain_chunks = matrix(Chunk, Settings.ChunkCount, Settings.ChunkCount, Settings.ChunkCount)
		#terrain_blocks = matrix(byte, size, size, size)

		# work packages will be tossed off to the thread pool
		# and divided up by chunks for efficiency
		for x in range(Settings.ChunkCount):
			for z in range(Settings.ChunkCount):
				for y in range(Settings.ChunkCount):
					QueueChunk(x, z, y)
					
