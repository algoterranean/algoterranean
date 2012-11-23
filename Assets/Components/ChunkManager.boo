import UnityEngine
import System.Threading

class ChunkManager (MonoBehaviour, IObserver, IObservable):
	terrain_blocks as (byte, 3)   # 3 dimensional array of bytes
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

	def ChunkCallback(state as List) as WaitCallback:
		print "Chunk $state processing"

	def QueueChunk(x as int, z as int, y as int):
		callback as WaitCallback
		callback = WaitCallback(ChunkCallback)
		ThreadPool.QueueUserWorkItem(ChunkCallback, [x, z, y])


	def Awake ():
		# initialize the memory for the array
		size = Settings.ChunkSize * Settings.ChunkCount + 2  # +1 per side for calculated but undisplayed blocks
		terrain_blocks = matrix(byte, size, size, size)

		# work packages will be tossed off to the thread pool
		# and divided up by chunks for efficiency
		for x in range(Settings.ChunkCount):
			for z in range(Settings.ChunkCount):
				for y in range(Settings.ChunkCount):
					QueueChunk(x, z, y)
					
