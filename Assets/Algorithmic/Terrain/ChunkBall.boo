namespace Algorithmic.Terrain

import System.Collections.Generic
import System.Threading
import Algorithmic
import UnityEngine


################################################################################
# Utility and Message Passing Stuff							
class ChunkInfo():
	_chunk as IChunkBlockData
	_mesh as IChunkMeshData
	_bounds as AABB
	
	def constructor(chunk as IChunkBlockData, mesh as IChunkMeshData):
		_chunk = chunk
		_mesh = mesh
		coords = chunk.getCoordinates()
		_bounds = AABB(Vector3(coords.x + Settings.ChunkSize/2, coords.y + Settings.ChunkSize/2, coords.z + Settings.ChunkSize/2),
			       Vector3(Settings.ChunkSize/2, Settings.ChunkSize/2, Settings.ChunkSize/2))

	def getChunk() as IChunkBlockData:
		return _chunk

	def getMesh() as IChunkMeshData:
		return _mesh

enum Message:
	REMOVE
	ADD
	BLOCKS_READY
	MESH_READY

class ChunkBallMessage():
	_message as Message
	_data as object
	
	def constructor(message as Message, data as object):
		_message = message
		_data = data

	def getMessage() as Message:
		return _message

	def getData() as object:
		return _data


################################################################################
# Main ChunkBall class
class ChunkBall (IChunkBall, IObservable):
	_locker = object()
	_origin as Vector3
	_min_distance as byte
	_max_distance as byte
	_chunk_size as byte
	_observers = []
	_outgoing_queue = []
	_chunks as Dictionary[of LongVector3, ChunkInfo]
	_threshold = 10.0
	_mesh_waiting_queue as Dictionary[of LongVector3, ChunkInfo]


	def Update():
		notifyObservers()
		
		# check if new meshes are ready
		ready_mesh_key as duck
		for item in _mesh_waiting_queue:
			chunk_info as ChunkInfo = item.Value
			chunk_mesh as ChunkMeshData = chunk_info.getMesh()
			if chunk_mesh.areNeighborsReady():
				ThreadPool.QueueUserWorkItem(_mesh_worker, chunk_info)
				ready_mesh_key = item.Key
				print "FOUND MESH: $item.key. Length of remaining queue: $(len(_mesh_waiting_queue))"
				break

		if ready_mesh_key != null:
			_mesh_waiting_queue.Remove(ready_mesh_key)
			

	def registerObserver(o as object) as void:
		if _observers.Contains(o):
			pass
		else:
			lock _locker:
				_observers.Push(o)

	def removeObserver(o as object) as void:
		if _observers.Contains(o):
			lock _locker:
				_observers.Remove(o)

	def notifyObservers() as void:
		lock _locker:
			for x as IObserver in _observers:
				for y in _outgoing_queue:
					x.updateObserver(y)
			_outgoing_queue = []

	def constructor(min_distance, max_distance, chunk_size):
		setMinChunkDistance(min_distance)
		setMaxChunkDistance(max_distance)
		_chunk_size = chunk_size
		_chunks = Dictionary[of LongVector3, ChunkInfo]()
		_mesh_waiting_queue = Dictionary[of LongVector3, ChunkInfo]()		
		_origin = Vector3(10000, 10000, 10000)


	def setMinChunkDistance(min_distance as byte) as void:
		_min_distance = min_distance

	def getMinChunkDistance() as byte:
		return _min_distance

	def setMaxChunkDistance(max_distance as byte) as void:
		_max_distance = max_distance

	def getMaxChunkDistance() as byte:
		return _max_distance

	def _add_chunk():
		pass

	def _remove_chunk():
		pass

	def _mesh_worker(chunk_info as ChunkInfo) as WaitCallback:
		try:
			mesh as ChunkMeshData = chunk_info.getMesh()
			chunk as ChunkBlockData = chunk_info.getChunk()
			mesh.CalculateMesh()
			print "Mesh Calculated: $(chunk.getCoordinates())"
			lock _locker:
				_outgoing_queue.Push(ChunkBallMessage(Message.MESH_READY, chunk_info))
		except e:
			print "WHOOPS WE HAVE AN ERROR IN MESH: " + e

	def _noise_worker(chunk_info as ChunkInfo) as WaitCallback:
		try:
			chunk as ChunkBlockData = chunk_info.getChunk()
			chunk.CalculateBlocks()
			lock _locker:
				_mesh_waiting_queue[chunk.getCoordinates()] = chunk_info
		except e:
			print "WHOOPS WE HAVE AN ERROR IN NOISE: " + e

	def getMaxHeight(location as Vector3) as int:
		chunk_coords = Utils.whichChunk(location) # LongVector3
		if chunk_coords in _chunks:
			pass
		else:
			return 300  # TO DO: this should be able to return a failure state if the chunk doesn't exist

		
			

	def SetOrigin(origin as Vector3) as void:
		# only do something if the distance since the
		# last update is greater than some threshold
		a = _origin.x - origin.x
		b = _origin.y - origin.y
		c = _origin.z - origin.z
		if Math.Sqrt(a*a + b*b + c*c) < _threshold:
			return
		_origin = origin


		#############################################
		# determine which chunks are now too far away
		current_chunk_coords = Utils.whichChunk(_origin)
		removal_queue = []
		lock _locker:
			for item in _chunks:
				chunk_info = item.Value
				chunk_blocks = chunk_info.getChunk()
				chunk_mesh  = chunk_info.getMesh()
				chunk_coords = chunk_blocks.getCoordinates()

				if (current_chunk_coords.x - chunk_coords.x)/_chunk_size > _max_distance or \
				    (current_chunk_coords.y - chunk_coords.y)/_chunk_size > _max_distance or \
				    (current_chunk_coords.z - chunk_coords.z)/_chunk_size > _max_distance:
					removal_queue.Push(item.Key)

		# remove all chunks that are too far away
		for key in removal_queue:
			lock _locker:
				_outgoing_queue.Push(ChunkBallMessage(Message.REMOVE, _chunks[key]))
			_chunks.Remove(key)

		###########################################
		# determine which chunks need to be added
		creation_queue = []
		for a in range(_max_distance*2+1):
			for b in range(_max_distance*2+1):
				for c in range(_max_distance*2+1):
					x_coord = (a - _max_distance)*_chunk_size + current_chunk_coords.x
					y_coord = (b - _max_distance)*_chunk_size + current_chunk_coords.y
					z_coord = (c - _max_distance)*_chunk_size + current_chunk_coords.z
					if not _chunks.ContainsKey(LongVector3(x_coord, y_coord, z_coord)):
						creation_queue.Push(LongVector3(x_coord, y_coord, z_coord))
				c = 0
			c = 0
			b = 0

		# sort so that they are from closest to farthest from origin
		creation_queue.Sort() do (left as LongVector3, right as LongVector3):
			return _origin.Distance(_origin, Vector3(right.x, right.y, right.z)) - _origin.Distance(_origin, Vector3(left.x, left.y, left.z))

		# add all new chunks
		for item as LongVector3 in creation_queue:
			size = ByteVector3(_chunk_size, _chunk_size, _chunk_size)
			chunk_blocks = ChunkBlockData(item, size)
			chunk_mesh = ChunkMeshData(chunk_blocks)
			chunk_info = ChunkInfo(chunk_blocks, chunk_mesh)
			_chunks.Add(item, chunk_info)
			ThreadPool.QueueUserWorkItem(_noise_worker, chunk_info)
			#_outgoing_queue.Push(ChunkBallMessage(Message.ADD, chunk_info))
			#coords = chunk_blocks.getCoordinates()
		#notifyObservers()

		# for all chunks, update neighbors
		for item in _chunks:
			chunk_info = item.Value
			chunk_blocks = chunk_info.getChunk()
			chunk_mesh = chunk_info.getMesh()
			chunk_coords = chunk_blocks.getCoordinates()

			west_coords = LongVector3(chunk_coords.x - Settings.ChunkSize, chunk_coords.y, chunk_coords.z)
			east_coords = LongVector3(chunk_coords.x + Settings.ChunkSize, chunk_coords.y, chunk_coords.z)
			south_coords = LongVector3(chunk_coords.x, chunk_coords.y, chunk_coords.z - Settings.ChunkSize)
			north_coords = LongVector3(chunk_coords.x, chunk_coords.y, chunk_coords.z + Settings.ChunkSize)
			down_coords = LongVector3(chunk_coords.x, chunk_coords.y - Settings.ChunkSize, chunk_coords.z)
			up_coords = LongVector3(chunk_coords.x, chunk_coords.y + Settings.ChunkSize, chunk_coords.z)

			if _chunks.ContainsKey(west_coords):
				chunk_mesh.setWestNeighbor(_chunks[west_coords].getChunk())
			if _chunks.ContainsKey(east_coords):
				chunk_mesh.setEastNeighbor(_chunks[east_coords].getChunk())
			if _chunks.ContainsKey(south_coords):
				chunk_mesh.setSouthNeighbor(_chunks[south_coords].getChunk())
			if _chunks.ContainsKey(north_coords):
				chunk_mesh.setNorthNeighbor(_chunks[north_coords].getChunk())
			if _chunks.ContainsKey(down_coords):
				chunk_mesh.setDownNeighbor(_chunks[down_coords].getChunk())
			if _chunks.ContainsKey(up_coords):
				chunk_mesh.setUpNeighbor(_chunks[up_coords].getChunk())


	def CheckCollisions(_object_to_check as AABB):
		for item in _chunks:
			chunk_info = item.Value
			chunk = chunk_info.getChunk()
			chunk_mesh = chunk_info.getMesh()
			tree as BoundingVolumeTree = chunk_mesh.getTree()
			node as Node = tree.getTree()

			collisions = tree.checkCollision(_object_to_check)
			if len(collisions) > 0:
				return true
			
				#x = gameObject.Find("First Person Controller").GetComponent("Player") as Player
				#x.stop()
			#print "COLLISION: $(len()) OBJECTS"

			#print "$node"
			 
			#print "BOUNDING VOLUME CHECK: $(_object_to_check.center), $(node.bounding_volume.center), $(node.bounding_volume.Test(node.bounding_volume, _object_to_check))"
				

		
		


				
		
		

		
	
