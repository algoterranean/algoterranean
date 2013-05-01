namespace Algorithmic.Chunks

import System.Collections.Generic
import System.Threading
import Algorithmic
import UnityEngine


class DataManager (MonoBehaviour, IChunkGenerator):

	locker = object()
	origin as Vector3
	max_distance as byte
	chunk_size as byte
	observers = []
	outgoing_queue = []
	thread_queue = []
	chunks = Dictionary[of LongVector3, Chunk]()
	threshold = 10.0
	mesh_waiting_queue as Dictionary[of LongVector3, Chunk]
	origin_initialized = false

	def Awake():
		max_distance = Settings.MaxChunks
		chunk_size = Settings.ChunkSize
		mesh_waiting_queue = Dictionary[of LongVector3, Chunk]()

	def Update():
		notifyObservers()

		# check if new meshes are ready
		ready_mesh_key as duck
		lock locker:
			for item in mesh_waiting_queue:
				chunk_info as Chunk = item.Value
				chunk_mesh as MeshData = chunk_info.getMesh()
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
			for y in outgoing_queue:
				if y[0] == "REMOVE":
					SendMessage("RemoveMesh", y[1])
				elif y[0] == "CREATE":
					SendMessage("CreateMesh", y[1])
			outgoing_queue = []


	def _add_dchunk():
		pass

	def _remove_chunk():
		pass

	def _mesh_worker(chunk as Chunk) as WaitCallback:
		try:
			mesh as MeshData = chunk.getMesh()
			mesh.CalculateMesh()
			lock locker:
				outgoing_queue.Push(["CREATE", chunk])
		except e:
			print "WHOOPS WE HAVE AN ERROR IN MESH: " + e

	def _noise_worker(chunk as Chunk) as WaitCallback:
		try:
			blocks as BlockData = chunk.getBlocks()
			blocks.CalculateBlocks()
			lock locker:
				mesh_waiting_queue[chunk.getCoords()] = chunk
		except e:
			print "WHOOPS WE HAVE AN ERROR IN NOISE: " + e


	def SetOrigin(o as Vector3) as void:
		# only do something if the distance since the
		# last update is greater than some threshold
		if origin_initialized:
			a = origin.x - o.x
			b = origin.y - o.y
			c = origin.z - o.z
			if Math.Sqrt(a*a + b*b + c*c) < threshold:
				return
			origin = o
		else:
			origin_initialized = true
			origin = o

		# determine which chunks are now too far away
		current_chunk_coords = Utils.whichChunk(origin)
		removal_queue = []
		lock locker:
			for item in chunks:
				chunk = item.Value
				chunk_blocks = chunk.getBlocks()
				chunk_mesh = chunk.getMesh()
				chunk_coords = chunk.getCoords()

				if Math.Abs(current_chunk_coords.x - chunk_coords.x)/chunk_size > max_distance or \
					Math.Abs(current_chunk_coords.y - chunk_coords.y)/chunk_size > Settings.MaxChunksVertical or \
					Math.Abs(current_chunk_coords.z - chunk_coords.z)/chunk_size > max_distance:
					removal_queue.Push(item.Key)

		# remove all chunks that are too far away
		lock locker:					
			for key in removal_queue:
				outgoing_queue.Push(["REMOVE", chunks[key]])
				chunks.Remove(key)
		
		# determine which chunks need to be added
		creation_queue = []
		for a in range(max_distance*2+1):
			for b in range(Settings.MaxChunksVertical*2+1):
				for c in range(max_distance*2+1):
					x_coord = (a - max_distance)*chunk_size + current_chunk_coords.x
					y_coord = (b - Settings.MaxChunksVertical)*chunk_size + current_chunk_coords.y
					z_coord = (c - max_distance)*chunk_size + current_chunk_coords.z
					if not chunks.ContainsKey(LongVector3(x_coord, y_coord, z_coord)):
						creation_queue.Push(LongVector3(x_coord, y_coord, z_coord))
				c = 0
			c = 0
			b = 0

		# sort so that they are from closest to farthest from origin
		creation_queue.Sort() do (left as LongVector3, right as LongVector3):
			return origin.Distance(origin, Vector3(right.x, right.y, right.z)) - origin.Distance(origin, Vector3(left.x, left.y, left.z))

		# add all new chunks
		for item as LongVector3 in creation_queue:
			size = ByteVector3(chunk_size, chunk_size, chunk_size)
			chunk_blocks = BlockData(item, size)
			chunk_mesh = MeshData(chunk_blocks)
			chunk_info = Chunk(chunk_blocks, chunk_mesh)
			chunks.Add(item, chunk_info)
			thread_queue.Push(chunk_info)
			
		# for all chunks, update neighbors
		for item as LongVector3 in creation_queue:
			chunk_info = chunks[item]
			chunk_blocks = chunk_info.getBlocks()
			chunk_mesh = chunk_info.getMesh()
			chunk_coords = chunk_blocks.getCoordinates()
			
			west_coords = LongVector3(chunk_coords.x - Settings.ChunkSize, chunk_coords.y, chunk_coords.z)
			east_coords = LongVector3(chunk_coords.x + Settings.ChunkSize, chunk_coords.y, chunk_coords.z)
			south_coords = LongVector3(chunk_coords.x, chunk_coords.y, chunk_coords.z - Settings.ChunkSize)
			north_coords = LongVector3(chunk_coords.x, chunk_coords.y, chunk_coords.z + Settings.ChunkSize)
			down_coords = LongVector3(chunk_coords.x, chunk_coords.y - Settings.ChunkSize, chunk_coords.z)
			up_coords = LongVector3(chunk_coords.x, chunk_coords.y + Settings.ChunkSize, chunk_coords.z)

			if chunks.ContainsKey(west_coords):
				chunks[west_coords].getMesh().setEastNeighbor(chunk_blocks)
			if chunks.ContainsKey(east_coords):
				chunks[east_coords].getMesh().setWestNeighbor(chunk_blocks)
			if chunks.ContainsKey(south_coords):
				chunks[south_coords].getMesh().setNorthNeighbor(chunk_blocks)
			if chunks.ContainsKey(north_coords):
				chunks[north_coords].getMesh().setSouthNeighbor(chunk_blocks)
			if chunks.ContainsKey(down_coords):
				chunks[down_coords].getMesh().setUpNeighbor(chunk_blocks)
			if chunks.ContainsKey(up_coords):
				chunks[up_coords].getMesh().setDownNeighbor(chunk_blocks)

				

	def setBlock(world as LongVector3):
		size = Settings.ChunkSize
		x = world.x
		y = world.y
		z = world.z
		
		if x < 0:
			new_x = x + 1
		else:
			new_x = x
		c_x = new_x / size - (1 if x < 0 else 0)
		start_x = c_x * size
		#end_x = start_x + size - 1
		b_x = x - start_x

		if y < 0:
			new_y = y + 1
		else:
			new_y = y
		c_y = new_y / size - (1 if y < 0 else 0)
		start_y = c_y * size
		#end_y = start_y + size - 1
		b_y = y - start_y

		if z < 0:
			new_z = z + 1
		else:
			new_z = z
		c_z = new_z / size - (1 if z < 0 else 0)
		start_z = c_z * size
		#end_z = start_z + size - 1
		b_z = z - start_z


		
		chunk_coords = LongVector3(c_x * size, c_y * size, c_z * size)
		block_coords = ByteVector3(b_x, b_y, b_z)
		#print "GetBlock: $world, $chunk_coords, $block_coords"
	
		if chunk_coords in chunks:
			#print "Found Chunk"
			i as Chunk = chunks[chunk_coords]
			c as BlockData = i.getBlocks()
			c.setBlock(block_coords, 0)
			m = MeshData(c)
			m.CalculateMesh()
			i.setMesh(m)
			# mesh = i.getMesh()
			# mesh.setBlockData(c)
			# mesh.CalculateMesh()
			# i.setMesh(mesh)
			lock locker:
				SendMessage("RefreshMesh", i)
			#outgoing_queue = []
			
			return 0
		else:
			print "Could not find the chunk"			
			return 0


	def getBlock(world as LongVector3):
		size = Settings.ChunkSize
		x = world.x
		y = world.y
		z = world.z
		
		if x < 0:
			new_x = x + 1
		else:
			new_x = x
		c_x = new_x / size - (1 if x < 0 else 0)
		start_x = c_x * size
		#end_x = start_x + size - 1
		b_x = x - start_x

		if y < 0:
			new_y = y + 1
		else:
			new_y = y
		c_y = new_y / size - (1 if y < 0 else 0)
		start_y = c_y * size
		#end_y = start_y + size - 1
		b_y = y - start_y

		if z < 0:
			new_z = z + 1
		else:
			new_z = z
		c_z = new_z / size - (1 if z < 0 else 0)
		start_z = c_z * size
		#end_z = start_z + size - 1
		b_z = z - start_z


		
		chunk_coords = LongVector3(c_x * size, c_y * size, c_z * size)
		block_coords = ByteVector3(b_x, b_y, b_z)
		#print "GetBlock: $world, $chunk_coords, $block_coords"
	
		if chunk_coords in chunks:
			#print "Found Chunk"
			i as Chunk = chunks[chunk_coords]
			c as BlockData = i.getBlocks()
			b = c.getBlock(block_coords)
			if b > 0:
				pass
				#Log.Log("GET BLOCK: WORLD: $world, CHUNK: $(chunk_coords), LOCAL: $block_coords", LOG_MODULE.CONTACTS)

			return b
			#print "Found Block: $b"
		else:
			print "Could not find the chunk"			
			return 0


		
		
		
			











