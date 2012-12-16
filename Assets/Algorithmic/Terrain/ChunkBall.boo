
import System.Collections.Generic
import System.Threading
import Algorithmic
import UnityEngine

# class ChunkBall ():
# 	chunks as Dictionary[of double, Chunk]
	
# 	def constructor():
# 		chunks = Dictionary[of double, Chunk]()

# 	def GetEnumerator():
# 		return chunks.GetEnumerator()

# 	def calculateDistance(x_pos as double, z_pos as double, y_pos as double):
# 		for chunk in chunks:
# 			chunk.Value.setDistance(x_pos, z_pos, y_pos)

# 	def Contains(x_pos as long, z_pos as long, y_pos as long):
# 		return chunks.ContainsKey(x_pos + Settings.ChunkSize*z_pos + Settings.ChunkSize*Settings.ChunkSize*y_pos)

# 	def Set(x_pos as long, z_pos as long, y_pos as long, chunk as Chunk):
# 		chunks.Add(x_pos + Settings.ChunkSize*z_pos + Settings.ChunkSize*Settings.ChunkSize*y_pos, chunk)
# 		#updateNeighbors(x_pos, z_pos, y_pos)
# 		#chunks.Add("$x_pos, $z_pos, $y_pos", chunk)

# 	def cullChunks():
# 		to_remove = []
# 		to_remove2 = []
# 		for d in chunks:
# 			chunk = d.Value
# 			key = d.Key
# 			if chunk.getDistance() > Settings.MinChunkDistance:
# 				to_remove.Push(d.Key)
# 				to_remove2.Push(d.Value)

# 		for key in to_remove:
# 			chunks.Remove(key)
# 		return to_remove2
		


# 	def updateNeighbors(): #:x_pos as long, z_pos as long, y_pos as long):
# 		for d in chunks:
# 			chunk = d.Value
# 			key = d.Key
# 			coords = chunk.getCoordinates()
# 			x = coords[0]
# 			z = coords[1]
# 			y = coords[2]
		
# 			# chunk = chunks[x_pos + z_pos * x_pos + z_pos * x_pos * y_pos]
# 			# x = x_pos
# 			# z = z_pos
# 			# y = y_pos
			
# 			# west_name = (x-Settings.ChunkSize, z, y) #"$(x - Settings.ChunkSize), $z, $y"
# 			# east_name = (x+Settings.ChunkSize, z, y) #"$(x + Settings.ChunkSize), $z, $y"
# 			# south_name = (x, z-Settings.ChunkSize, y) #"$x, $(z - Settings.ChunkSize), $y"
# 			# north_name = (x, z+Settings.ChunkSize, y) #"$x, $(z + Settings.ChunkSize), $y"
# 			# down_name = (x, z, y-Settings.ChunkSize) #"$x, $z, $(y - Settings.ChunkSize)"
# 			# up_name = (x, z, y+Settings.ChunkSize) #"$x, $z, $(y + Settings.ChunkSize)"

# 			# west_name = "$(x - Settings.ChunkSize), $z, $y"
# 			# east_name = "$(x + Settings.ChunkSize), $z, $y"
# 			# south_name = "$x, $(z - Settings.ChunkSize), $y"
# 			# north_name = "$x, $(z + Settings.ChunkSize), $y"
# 			# down_name = "$x, $z, $(y - Settings.ChunkSize)"
# 			# up_name = "$x, $z, $(y + Settings.ChunkSize)"

# 			west_name = (x - Settings.ChunkSize) + Settings.ChunkSize * z + Settings.ChunkSize * Settings.ChunkSize * y
# 			east_name = (x + Settings.ChunkSize) + Settings.ChunkSize * z + Settings.ChunkSize * Settings.ChunkSize * y
# 			south_name = x + (z - Settings.ChunkSize) * Settings.ChunkSize + Settings.ChunkSize * Settings.ChunkSize * y
# 			north_name = x + (z + Settings.ChunkSize) * Settings.ChunkSize + Settings.ChunkSize * Settings.ChunkSize * y
# 			down_name = x + Settings.ChunkSize * z + Settings.ChunkSize * Settings.ChunkSize * (y - Settings.ChunkSize)
# 			up_name = x + Settings.ChunkSize * z + Settings.ChunkSize * Settings.ChunkSize * (y + Settings.ChunkSize)

# 			if chunks.ContainsKey(west_name):
# 				chunk.setWestChunk(chunks[west_name])
# 			if chunks.ContainsKey(east_name):
# 				chunk.setEastChunk(chunks[east_name])
# 			if chunks.ContainsKey(south_name):
# 				chunk.setSouthChunk(chunks[south_name])
# 			if chunks.ContainsKey(north_name):
# 				chunk.setNorthChunk(chunks[north_name])
# 			if chunks.ContainsKey(down_name):
# 				chunk.setDownChunk(chunks[down_name])
# 			if chunks.ContainsKey(up_name):
# 				chunk.setUpChunk(chunks[up_name])
							

			
class ChunkBall (IChunkBall, IObservable):
	_origin as Vector3
	_min_distance as byte
	_max_distance as byte
	_chunk_size as byte
	_observers = []
	_outgoing_queue = []
	_chunks = {} #Dictionary[of double, ChunkBlockData]
	_threshold = 10.0
	

	def registerObserver(o as object) as void:
		if _observers.Contains(o):
			pass
		else:
			_observers.Push(o)

	def removeObserver(o as object) as void:
		if _observers.Contains(o):
			_observers.Remove(o)

	def notifyObservers() as void:
		lock _outgoing_queue:
			for x as IObserver in _observers:
				for y in _outgoing_queue:
					x.updateObserver(y)

	def constructor(min_distance, max_distance, chunk_size):
		setMinChunkDistance(min_distance)
		setMaxChunkDistance(max_distance)
		_chunk_size = chunk_size
		chunks = Dictionary[of double, ChunkBlockData]()


	def setMinChunkDistance(min_distance as byte) as void:
		_min_distance = min_distance

	def getMinChunkDistance() as byte:
		return _min_distance

	def setMaxChunkDistance(max_distance as byte) as void:
		_max_distance = max_distance

	def getMaxChunkDistance() as byte:
		return _max_distance

	def _noise_worker(chunk as IChunkBlockData) as WaitCallback:
		try:
			#Thread.CurrentThread.Priority = System.Threading.ThreadPriority.Lowest
			chunk.CalculateBlocks()
			coord = chunk.getCoordinates()
		except e:
			print "WHOOPS WE HAVE AN ERROR IN NOISE: " + e
		# lock _locker:
		# 	noise_calculated_queue.Push(chunk)	

	def SetOrigin(origin as Vector3) as void:
		# only do something if the distance since the
		# last update is greater than some threshold
		a = _origin.x - origin.x
		b = _origin.z - origin.z
		c = _origin.y - origin.y
		if Math.Sqrt(a*a + b*b + c*c) < _threshold:
			pass
		_origin = origin


		# determine which chunks are now too far away
		current_chunk_coords = Utils.whichChunk(_origin)
		removal_queue = []
		for key in _chunks:
			#key = chunk.Key
			#value as List = chunk.Value
			value as List = _chunks[key]
			chunk_blocks as duck = value[0]
			chunk_mesh as duck = value[1]
			chunk_coords = chunk_blocks.getCoordinates()
			
			if (current_chunk_coords.x - chunk_coords.x)/_chunk_size > _max_distance or \
			    (current_chunk_coords.z - chunk_coords.z)/_chunk_size > _max_distance or \
			    (current_chunk_coords.y - chunk_coords.y)/_chunk_size > _max_distance:
				removal_queue.Push(key)

		# remove all chunks that are too far away
 		_outgoing_queue = []
		for key in removal_queue:
			_chunks.Remove(key)
			_outgoing_queue.Push(key)
		# notify all observers that the chunks have been removed
		notifyObservers()
		

		# determine which chunks need to be added
		creation_queue = []
		for a in range(_max_distance*2):
			for b in range(_max_distance*2):
				for c in range(_max_distance*2):
					x_coord = (a - _max_distance)*_chunk_size + current_chunk_coords.x
					z_coord = (b - _max_distance)*_chunk_size + current_chunk_coords.z
					y_coord = (c - _max_distance)*_chunk_size + current_chunk_coords.y
					if not _chunks.Contains(LongVector3(x_coord, y_coord, z_coord)):
						creation_queue.Push(LongVector3(x_coord, y_coord, z_coord))

		# add all new chunks
		_outgoing_queue = []
		for key in creation_queue:
			coords = key
			size = ByteVector3(_chunk_size, _chunk_size, _chunk_size)
			chunk_blocks = ChunkBlockData(coords, size)
			chunk_mesh = ChunkMeshData(chunk_blocks)
			_chunks.Add(coords, [chunk_blocks, chunk_mesh])
		notifyObservers()

		# add the new chunks to the thread pool to begin
		# generating blocks and meshes
			


		
		


				
		
		

		
	
