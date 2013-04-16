namespace Algorithmic.Terrain

import System.Collections.Generic
import System.Threading
import Algorithmic
import UnityEngine
import Algorithmic.Misc


################################################################################
# Utility and Message Passing Stuff
class ChunkInfo():
	chunk as IChunkBlockData
	mesh as IChunkMeshData
	bounds as AABB

	def constructor(chunk as IChunkBlockData, mesh as IChunkMeshData):
		self.chunk = chunk
		self.mesh = mesh
		coords = chunk.getCoordinates()
		radius = Settings.ChunkSize/2
		bounds = AABB(Vector3(coords.x + radius, coords.y + radius, coords.z + radius),
					  Vector3(radius, radius, radius))

	def getChunk() as IChunkBlockData:
		return chunk

	def getMesh() as IChunkMeshData:
		return mesh
	

enum Message:
	REMOVE
	ADD
	BLOCKS_READY
	MESH_READY

class ChunkBallMessage():
	message as Message
	data as object

	def constructor(message as Message, data as object):
		self.message = message
		self.data = data

	def getMessage() as Message:
		return message

	def getData() as object:
		return data


	

################################################################################
# Main ChunkBall class
class ChunkBall (IChunkBall, IObservable):
	locker = object()
	origin as Vector3
	min_distance as byte
	max_distance as byte
	chunk_size as byte
	observers = []
	outgoing_queue = []
	thread_queue = []
	chunks as Dictionary[of LongVector3, ChunkInfo]
	threshold = 10.0
	mesh_waiting_queue as Dictionary[of LongVector3, ChunkInfo]


	def Update():
		notifyObservers()

		# check if new meshes are ready
		ready_mesh_key as duck
		lock locker:
			for item in mesh_waiting_queue:
				chunk_info as ChunkInfo = item.Value
				chunk_mesh as ChunkMeshData = chunk_info.getMesh()
				if chunk_mesh.areNeighborsReady():
					ThreadPool.QueueUserWorkItem(_mesh_worker, chunk_info)
					ready_mesh_key = item.Key
					#print "FOUND MESH: $item.key. Length of remaining queue: $(len(mesh_waiting_queue))"
					break

			if ready_mesh_key != null:
				mesh_waiting_queue.Remove(ready_mesh_key)

			if len(thread_queue) > 0:
				ci = thread_queue.Pop()
				ThreadPool.QueueUserWorkItem(_noise_worker, ci)


	def registerObserver(o as object) as void:
		if observers.Contains(o):
			pass
		else:
			lock locker:
				observers.Push(o)

	def removeObserver(o as object) as void:
		if observers.Contains(o):
			lock locker:
				observers.Remove(o)

	def notifyObservers() as void:
		lock locker:
			for x as IObserver in observers:
				for y in outgoing_queue:
					x.updateObserver(y)
			outgoing_queue = []

	def constructor(min_distance, max_distance, chunk_size):
		setMinChunkDistance(min_distance)
		setMaxChunkDistance(max_distance)
		self.chunk_size = chunk_size
		chunks = Dictionary[of LongVector3, ChunkInfo]()
		mesh_waiting_queue = Dictionary[of LongVector3, ChunkInfo]()
		origin = Vector3(10000, 10000, 10000)


	def setMinChunkDistance(m as byte) as void:
		min_distance = m

	def getMinChunkDistance() as byte:
		return min_distance

	def setMaxChunkDistance(m as byte) as void:
		max_distance = m

	def getMaxChunkDistance() as byte:
		return max_distance

	def _add_dchunk():
		pass

	def _remove_chunk():
		pass

	def _mesh_worker(chunk_info as ChunkInfo) as WaitCallback:
		try:
			mesh as ChunkMeshData = chunk_info.getMesh()
			chunk as ChunkBlockData = chunk_info.getChunk()
			mesh.CalculateMesh()
			#print "Mesh Calculated: $(chunk.getCoordinates())"
			lock locker:
				outgoing_queue.Push(ChunkBallMessage(Message.MESH_READY, chunk_info))
		except e:
			print "WHOOPS WE HAVE AN ERROR IN MESH: " + e

	def _noise_worker(chunk_info as ChunkInfo) as WaitCallback:
		try:
			chunk as ChunkBlockData = chunk_info.getChunk()
			chunk.CalculateBlocks()
			lock locker:
				mesh_waiting_queue[chunk.getCoordinates()] = chunk_info
		except e:
			print "WHOOPS WE HAVE AN ERROR IN NOISE: " + e

	def getMaxHeight(location as Vector3) as int:
		chunk_coords = Utils.whichChunk(location) # LongVector3
		if chunk_coords in chunks:
			pass
		else:
			return 300  # TO DO: this should be able to return a failure state if the chunk doesn't exist




	def SetOrigin(o as Vector3) as void:
		# watch = System.Diagnostics.Stopwatch()
		# watch.Start()
		# only do something if the distance since the
		# last update is greater than some threshold
		a = origin.x - o.x
		b = origin.y - o.y
		c = origin.z - o.z
		if Math.Sqrt(a*a + b*b + c*c) < threshold:
			return
		origin = o


		#############################################
		# determine which chunks are now too far away
		current_chunk_coords = Utils.whichChunk(origin)
		removal_queue = []
		lock locker:
			for item in chunks:
				chunk_info = item.Value
				chunk_blocks = chunk_info.getChunk()
				chunk_mesh  = chunk_info.getMesh()
				chunk_coords = chunk_blocks.getCoordinates()

				if (current_chunk_coords.x - chunk_coords.x)/chunk_size > max_distance or \
					(current_chunk_coords.y - chunk_coords.y)/chunk_size > max_distance or \
					(current_chunk_coords.z - chunk_coords.z)/chunk_size > max_distance:
					removal_queue.Push(item.Key)

		# remove all chunks that are too far away
		for key in removal_queue:
			lock locker:
				outgoing_queue.Push(ChunkBallMessage(Message.REMOVE, chunks[key]))
			chunks.Remove(key)
		
		# watch.Stop()
		# print "Elapsed1: $(watch.Elapsed.Seconds):$(watch.Elapsed.Milliseconds)"			
		# watch = System.Diagnostics.Stopwatch()
		# watch.Start()
		###########################################
		# determine which chunks need to be added
		creation_queue = []
		for a in range(max_distance*2+1):
			for b in range(max_distance*2+1):
				for c in range(max_distance*2+1):
					x_coord = (a - max_distance)*chunk_size + current_chunk_coords.x
					y_coord = (b - max_distance)*chunk_size + current_chunk_coords.y
					z_coord = (c - max_distance)*chunk_size + current_chunk_coords.z
					if not chunks.ContainsKey(LongVector3(x_coord, y_coord, z_coord)):
						creation_queue.Push(LongVector3(x_coord, y_coord, z_coord))
				c = 0
			c = 0
			b = 0

		# sort so that they are from closest to farthest from origin
		creation_queue.Sort() do (left as LongVector3, right as LongVector3):
			return origin.Distance(origin, Vector3(right.x, right.y, right.z)) - origin.Distance(origin, Vector3(left.x, left.y, left.z))
		# watch.Stop()
		# print "Elapsed2: $(watch.Elapsed.Seconds):$(watch.Elapsed.Milliseconds)"			
		# watch = System.Diagnostics.Stopwatch()
		# watch.Start()
		

		# add all new chunks
		for item as LongVector3 in creation_queue:
			size = ByteVector3(chunk_size, chunk_size, chunk_size)
			chunk_blocks = ChunkBlockData(item, size)
			chunk_mesh = ChunkMeshData(chunk_blocks)
			chunk_info = ChunkInfo(chunk_blocks, chunk_mesh)
			chunks.Add(item, chunk_info)
			thread_queue.Push(chunk_info)
			
		# watch.Stop()
		# print "Elapsed3: $(watch.Elapsed.Seconds):$(watch.Elapsed.Milliseconds)"			
		# watch = System.Diagnostics.Stopwatch()
		# watch.Start()
			

		# for all chunks, update neighbors
		for item in chunks:
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

			if chunks.ContainsKey(west_coords):
				chunk_mesh.setWestNeighbor(chunks[west_coords].getChunk())
			if chunks.ContainsKey(east_coords):
				chunk_mesh.setEastNeighbor(chunks[east_coords].getChunk())
			if chunks.ContainsKey(south_coords):
				chunk_mesh.setSouthNeighbor(chunks[south_coords].getChunk())
			if chunks.ContainsKey(north_coords):
				chunk_mesh.setNorthNeighbor(chunks[north_coords].getChunk())
			if chunks.ContainsKey(down_coords):
				chunk_mesh.setDownNeighbor(chunks[down_coords].getChunk())
			if chunks.ContainsKey(up_coords):
				chunk_mesh.setUpNeighbor(chunks[up_coords].getChunk())
		# watch.Stop()
		# print "Elapsed4: $(watch.Elapsed.Seconds):$(watch.Elapsed.Milliseconds)"


	def getBlock(world as LongVector3):
		size = Settings.ChunkSize
		x = world.x
		y = world.y
		z = world.z
		# c_x = world.x/size - (1 if world.x < 0 else 0)
		# c_y = world.y/size - (1 if world.y < 0 else 0)
		# c_z = world.z/size - (1 if world.z < 0 else 0)

		# b_x = world.x % size + (size - 1 if world.x < 0 else 0)
		# b_y = world.y % size + (size - 1 if world.y < 0 else 0)
		# b_z = world.z % size + (size - 1 if world.z < 0 else 0)
		if x < 0:
			new_x = x + 1
		else:
			new_x = x
		c_x = new_x / size - (1 if x < 0 else 0)
		start_x = c_x * size
		end_x = start_x + size - 1
		b_x = x - start_x

		if y < 0:
			new_y = y + 1
		else:
			new_y = y
		c_y = new_y / size - (1 if y < 0 else 0)
		start_y = c_y * size
		end_y = start_y + size - 1
		b_y = y - start_y

		if z < 0:
			new_z = z + 1
		else:
			new_z = z
		c_z = new_z / size - (1 if z < 0 else 0)
		start_z = c_z * size
		end_z = start_z + size - 1
		b_z = z - start_z


		
		chunk_coords = LongVector3(c_x * size, c_y * size, c_z * size)
		block_coords = ByteVector3(b_x, b_y, b_z)
		#print "GetBlock: $world, $chunk_coords, $block_coords"
	
		if chunk_coords in chunks:
			#print "Found Chunk"
			i as ChunkInfo = chunks[chunk_coords]
			c as ChunkBlockData = i.getChunk()
			b = c.getBlock(block_coords)
			if b > 0:
				Log.Log("GET BLOCK: WORLD: $world, CHUNK: $(chunk_coords), LOCAL: $block_coords", LOG_MODULE.CONTACTS)

			return b
			#print "Found Block: $b"
		else:
			print "Could not find the chunk"			
			return 0
			

					   
		#print "Chunk ($chunk_x, $chunk_y, $chunk_z), Block: ($block_x, $block_y, $block_z)"












