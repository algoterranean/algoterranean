"""Keeps track of an origin that defines the center of the visible world as well as
a distance Metric that, combined, define which chunks to load and unload. Notifies
other MonoBehavrious when these Chunks are loaded, unload, and refreshed. Since DataManager
tracks all loaded Chunks, it also provides helper functions for getting and setting blocks
in the world.

DataManager is multi-threaded and is the main work-horse of the application."""
namespace Algorithmic.Chunks

import Algorithmic
import UnityEngine
import System.Collections.Generic
import System.Threading


class DataManager (MonoBehaviour, IChunkGenerator):

	locker = object()
	chunks = Dictionary[of LongVector3, Chunk]()
	origin_initialized = false
	# metric stuff
	origin as Vector3
	max_distance as byte
	distance_metric as Metric
	threshold = 10.0
	chunk_size as byte
	# queues
	outgoing_queue = [] 
	noise_queue = []
	#mesh_queue as Dictionary[of LongVector3, Chunk]
	mesh_queue = []


	def Awake():
		max_distance = Settings.MaxChunks
		chunk_size = Settings.ChunkSize
		distance_metric = Metric(Settings.ChunkSize * Settings.MaxChunks)
		#mesh_queue = Dictionary[of LongVector3, Chunk]()

	def Update():
		# send updates for any previously queued up items
		lock locker:
			for y in outgoing_queue:
				if y[0] == "REMOVE":
					SendMessage("RemoveMesh", y[1])
				elif y[0] == "CREATE":
					SendMessage("CreateMesh", y[1])
			outgoing_queue = []
			
		# check if new meshes are ready
		ready_mesh_key as duck
		lock locker:
			# for item in mesh_queue:
			# 	chunk_info as Chunk = item.Value
			# 	chunk_mesh as MeshData = chunk_info.getMesh()
			# 	if chunk_mesh.areNeighborsReady():
			# 		ThreadPool.QueueUserWorkItem(_mesh_worker, chunk_info)
			# 		ready_mesh_key = item.Key
			# 		#print "FOUND MESH: $item.key. Length of remaining queue: $(len(mesh_queue))"
			# 		break

			# if ready_mesh_key != null:
			# 	mesh_queue.Remove(ready_mesh_key)
			for c in chunks:
				if c.Value.getFlagMesh():
					ThreadPool.QueueUserWorkItem(_mesh_create_worker, c.Value)
					c.Value.setFlagMesh(false)
					break
				
			for c in chunks:
				if c.Value.getFlagNoise():
					ThreadPool.QueueUserWorkItem(_noise_worker, c.Value)
					c.Value.setFlagNoise(false)
					break
												 
			# if len(mesh_queue) > 0:
			# 	ci = mesh_queue.Pop()
			# 	ThreadPool.QueueUserWorkItem(_mesh_create_worker, ci)

			# if len(noise_queue) > 0:
			# 	ci = noise_queue.Pop()
			# 	ThreadPool.QueueUserWorkItem(_noise_worker, ci)


	#
	# helper functions for calculating the block data and mesh data
	# off in the ThreadPool
	#

	def _mesh_thread() as WaitCallback:
		while true:
			pass

	def _noise_thread() as WaitCallback:
		while true:
			pass


	def _mesh_create_worker(chunk as Chunk) as WaitCallback:
		try:
			coords = chunk.getCoords()
			mesh as MeshData = chunk.getMesh()

			east_neighbor = LongVector3(coords.x + Settings.ChunkSize, coords.y, coords.z)
			west_neighbor = LongVector3(coords.x - Settings.ChunkSize, coords.y, coords.z)
			north_neighbor = LongVector3(coords.x, coords.y, coords.z + Settings.ChunkSize)
			south_neighbor = LongVector3(coords.x, coords.y, coords.z - Settings.ChunkSize)
			up_neighbor = LongVector3(coords.x, coords.y + Settings.ChunkSize, coords.z)
			down_neighbor = LongVector3(coords.x, coords.y - Settings.ChunkSize, coords.z)
			if chunks.ContainsKey(east_neighbor):
				mesh.setEastNeighbor(chunks[east_neighbor].getBlocks())
			if chunks.ContainsKey(west_neighbor):
				mesh.setWestNeighbor(chunks[west_neighbor].getBlocks())
			if chunks.ContainsKey(north_neighbor):
				mesh.setNorthNeighbor(chunks[north_neighbor].getBlocks())
			if chunks.ContainsKey(south_neighbor):
				mesh.setSouthNeighbor(chunks[south_neighbor].getBlocks())
			if chunks.ContainsKey(up_neighbor):
				mesh.setUpNeighbor(chunks[up_neighbor].getBlocks())
			if chunks.ContainsKey(down_neighbor):
				mesh.setDownNeighbor(chunks[down_neighbor].getBlocks())
			mesh.CalculateMesh()

			lock locker:
				chunk.setFlagMesh(false)
				# TO DO: do not push this chunk out if it has already
				# exceeded the distance metric! (in which case its
				# already been removed in the Update call)
				if LongVector3(coords.x, coords.y, coords.z) in chunks:
					outgoing_queue.Push(["CREATE", chunk])
		except e:
			print "WHOOPS WE HAVE AN ERROR IN MESH: " + e

	def _noise_worker(chunk as Chunk) as WaitCallback:
		try:
			blocks as BlockData = chunk.getBlocks()
			blocks.CalculateBlocks()
			coords = chunk.getCoords()
			east_neighbor = LongVector3(coords.x + Settings.ChunkSize, coords.y, coords.z)
			west_neighbor = LongVector3(coords.x - Settings.ChunkSize, coords.y, coords.z)
			north_neighbor = LongVector3(coords.x, coords.y, coords.z + Settings.ChunkSize)
			south_neighbor = LongVector3(coords.x, coords.y, coords.z - Settings.ChunkSize)
			up_neighbor = LongVector3(coords.x, coords.y + Settings.ChunkSize, coords.z)
			down_neighbor = LongVector3(coords.x, coords.y - Settings.ChunkSize, coords.z)
			
			lock locker:
				chunk.setFlagNoise(false)
				chunk.setFlagMesh(true)
				
				# mesh_queue.Push(chunk)
				if east_neighbor in chunks:
					chunks[east_neighbor].setFlagMesh(true)
					#mesh_queue.Push(chunks[east_neighbor])
				if west_neighbor in chunks:
					chunks[west_neighbor].setFlagMesh(true)
					#mesh_queue.Push(chunks[west_neighbor])
				if north_neighbor in chunks:
					chunks[north_neighbor].setFlagMesh(true)
					#mesh_queue.Push(chunks[north_neighbor])
				if south_neighbor in chunks:
					chunks[south_neighbor].setFlagMesh(true)
					#mesh_queue.Push(chunks[south_neighbor])
				if up_neighbor in chunks:
					chunks[up_neighbor].setFlagMesh(true)
					#mesh_queue.Push(chunks[up_neighbor])
				if down_neighbor in chunks:
					chunks[down_neighbor].setFlagMesh(true)
					#mesh_queue.Push(chunks[down_neighbor])

				
		except e:
			print "WHOOPS WE HAVE AN ERROR IN NOISE: " + e


	#
	# uses the distance metric to determine whether to load or unload
	# various chunks.
	#
			
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
		origin_coords = Utils.whichChunk(origin)
		removal_queue = []
		lock locker:
			for item in chunks:
				chunk_coords = item.Value.getCoords()
				if distance_metric.tooFar(origin_coords, chunk_coords):
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
					x_coord = (a - max_distance)*chunk_size + origin_coords.x
					y_coord = (b - Settings.MaxChunksVertical)*chunk_size + origin_coords.y
					z_coord = (c - max_distance)*chunk_size + origin_coords.z
					sc = LongVector3(x_coord, y_coord, z_coord)
					if not chunks.ContainsKey(sc):
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
			chunks.Add(LongVector3(item.x, item.y, item.z), chunk_info)
			#noise_queue.Push(chunk_info)
			
		# # for all chunks, update neighbors
		# for item as LongVector3 in creation_queue:
		# 	chunk_info = chunks[item]
		# 	chunk_blocks = chunk_info.getBlocks()
		# 	chunk_mesh = chunk_info.getMesh()
		# 	chunk_coords = chunk_blocks.getCoordinates()
			
		# 	west_coords = LongVector3(chunk_coords.x - Settings.ChunkSize, chunk_coords.y, chunk_coords.z)
		# 	east_coords = LongVector3(chunk_coords.x + Settings.ChunkSize, chunk_coords.y, chunk_coords.z)
		# 	south_coords = LongVector3(chunk_coords.x, chunk_coords.y, chunk_coords.z - Settings.ChunkSize)
		# 	north_coords = LongVector3(chunk_coords.x, chunk_coords.y, chunk_coords.z + Settings.ChunkSize)
		# 	down_coords = LongVector3(chunk_coords.x, chunk_coords.y - Settings.ChunkSize, chunk_coords.z)
		# 	up_coords = LongVector3(chunk_coords.x, chunk_coords.y + Settings.ChunkSize, chunk_coords.z)

		# 	if chunks.ContainsKey(west_coords):
		# 		chunks[west_coords].getMesh().setEastNeighbor(chunk_blocks)
		# 	if chunks.ContainsKey(east_coords):
		# 		chunks[east_coords].getMesh().setWestNeighbor(chunk_blocks)
		# 	if chunks.ContainsKey(south_coords):
		# 		chunks[south_coords].getMesh().setNorthNeighbor(chunk_blocks)
		# 	if chunks.ContainsKey(north_coords):
		# 		chunks[north_coords].getMesh().setSouthNeighbor(chunk_blocks)
		# 	if chunks.ContainsKey(down_coords):
		# 		chunks[down_coords].getMesh().setUpNeighbor(chunk_blocks)
		# 	if chunks.ContainsKey(up_coords):
		# 		chunks[up_coords].getMesh().setDownNeighbor(chunk_blocks)


	#
	# functions to get and set blocks in _global coordinates_
	#

	def convertGlobalToLocal(world as LongVector3):
		pass

	def setBlock(world as LongVector3, block as byte):
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
		#chunk_coords = "$(c_x*size),$(c_y*size),$(c_z*size)"
		block_coords = ByteVector3(b_x, b_y, b_z)
		#print "GetBlock: $world, $chunk_coords, $block_coords"
	
		if chunk_coords in chunks:
			#print "Found Chunk"
			i as Chunk = chunks[chunk_coords]
			c as BlockData = i.getBlocks()
			c.setBlock(block_coords, block)
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


	# def getBlock(x as long, y as long, z as long):
	# 	pass

	#def getBlock(world as LongVector3):
	def getBlock(x as long, y as long, z as long):
		size = Settings.ChunkSize
		# x = world.x
		# y = world.y
		# z = world.z
		
		if x < 0:
			new_x = x + 1
		else:
			new_x = x
		c_x = new_x / size - (1 if x < 0 else 0)
		start_x = c_x * size
		#end_x = start_x + size - 1
		b_x as byte = x - start_x

		if y < 0:
			new_y = y + 1
		else:
			new_y = y
		c_y = new_y / size - (1 if y < 0 else 0)
		start_y = c_y * size
		#end_y = start_y + size - 1
		b_y as byte = y - start_y

		if z < 0:
			new_z = z + 1
		else:
			new_z = z
		c_z = new_z / size - (1 if z < 0 else 0)
		start_z = c_z * size
		#end_z = start_z + size - 1
		b_z as byte = z - start_z

		
		chunk_coords = LongVector3(c_x * size, c_y * size, c_z * size)
		#chunk_coords = "$(c_x*size),$(c_y*size),$(c_z*size)"
		#block_coords = ByteVector3(b_x, b_y, b_z)
		#print "GetBlock: $world, $chunk_coords, $block_coords"

		chunk = chunks[chunk_coords]
		if chunk:
		#if chunk_coords in chunks:
			b = chunk.getBlocks().getBlock(b_x, b_y, b_z)
			# if b > 0:
			#Log.Log("GET BLOCK: WORLD: $world, CHUNK: $(chunk_coords), LOCAL: $block_coords", LOG_MODULE.CONTACTS)
			return b
		else:
			print "Could not find the chunk"			
			return 0


		
		
		
			












