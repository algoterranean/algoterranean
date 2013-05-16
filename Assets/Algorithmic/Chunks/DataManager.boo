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
#import System.Collections.Concurrent
import System.Threading

struct DMMessage:
	message as string
	chunk as Chunk
	def constructor(m as string, c as Chunk):
		message = m
		chunk = c
		

class DataManager (MonoBehaviour, IChunkGenerator):
	chunk_size as byte
	chunks as Dictionary[of LongVector3, Chunk]
	mesh_queue as Queue[of LongVector3]
	noise_queue as Queue[of LongVector3]
	outgoing_queue as Queue[of DMMessage]
	# store the references to the threads so that when this class goes out of scope
	# (e.g., the class is destroyed) the threads are automatically closed out
	# t1 as Thread 
	# t2 as Thread
	
	# metric stuff
	origin_initialized = false	
	origin as Vector3
	max_distance as byte
	distance_metric as Metric
	threshold = 10.0
	meshes_generated = 0
	chunks_generated = 0
	t1 as Thread
	t2 as Thread

	[volatile]
	public run_threads = true

	def getChunk(coords as LongVector3) as Chunk:
		lock chunks:
			if coords in chunks:
				return chunks[coords]

	def Awake():
		max_distance = Settings.MaxChunks
		chunk_size = Settings.ChunkSize
		distance_metric = Metric(Settings.ChunkSize * Settings.MaxChunks)
		chunks = Dictionary[of LongVector3, Chunk]()
		mesh_queue = Queue[of LongVector3]()
		noise_queue = Queue[of LongVector3]()
		outgoing_queue = Queue[of DMMessage]()
		# ThreadPool.QueueUserWorkItem(_noise_thread)
		# ThreadPool.QueueUserWorkItem(_mesh_thread)
		t1 = Thread(ThreadStart(_noise_thread))
		t2 = Thread(ThreadStart(_mesh_thread))
		t1.Start()		
		t2.Start()
		#mesh_queue = Dictionary[of LongVector3, Chunk]()

	def OnDisable():
		run_threads = false
		t1.Abort()
		t1.Join()
		t2.Abort()
		t2.Join()
		#yield WaitForSeconds(1)

	# def OnDestroy():
	# 	run_threads = false
	# 	t1.Abort()
	# 	t2.Abort()
	# 	#yield WaitForSeconds(1)

	def Update():
		print "Meshes Generated: $meshes_generated, Chunks Generated: $chunks_generated"
		# send updates for any previously queued up items
		lock outgoing_queue:
			for i in range(outgoing_queue.Count):
				dmm = outgoing_queue.Dequeue()
				SendMessage(dmm.message, dmm.chunk)
		

		lock chunks:
			for coord in chunks.Keys:
				if chunks[coord].getFlagMesh() and not chunks[coord].getFlagNoise():
					lock mesh_queue:
						mesh_queue.Enqueue(coord)
					chunks[coord].setFlagMesh(false)
				if chunks[coord].getFlagNoise():
					lock noise_queue:
						noise_queue.Enqueue(coord)
					chunks[coord].setFlagNoise(false)
					
		
		# lock locker:
		# 	for i as int in range(len(outgoing_queue)):
		# 		x = []
		# 		x = outgoing_queue[i]
		# 		if x[0] == "REMOVE":
		# 			SendMessage("RemoveMesh", x[1])
		# 		elif x[0] == "CREATE":
		# 			SendMessage("CreateMesh", x[1])
		# 	outgoing_queue = []
			
		# # check if new meshes are ready
		# ready_mesh_key as duck
		# lock locker:
		# 	for c in chunks:
		# 		if c.Value.getFlagMesh():
		# 			ThreadPool.QueueUserWorkItem(_mesh_create_worker, c.Value)
		# 			c.Value.setFlagMesh(false)
		# 			break
				
		# 	for c in chunks:
		# 		if c.Value.getFlagNoise():
		# 			ThreadPool.QueueUserWorkItem(_noise_worker, c.Value)
		# 			c.Value.setFlagNoise(false)
		# 			break

	#
	# helper functions for calculating the block data and mesh data
	# off in the ThreadPool
	#


	def _mesh_thread(): #as WaitCallback:
		try:
			while run_threads:
				found = false
				lock mesh_queue:
					if mesh_queue.Count > 0:
						found = true
						coord = mesh_queue.Dequeue()
				if found:
					still_relevant = false
					lock chunks:
						if coord in chunks:
							still_relevant = true
							chunk = chunks[coord]
					if still_relevant:
						print "Generating Mesh"
						chunk.getMesh().CalculateMesh()
						lock outgoing_queue:
							outgoing_queue.Enqueue(DMMessage("CreateMesh", chunk))
							meshes_generated += 1
				# else:
				# 	Thread.Sleep(0.1)
		except e:
			print "THREAD ERROR WITH MESH, $e"
			

	def _noise_thread(): #as WaitCallback:
		try:		
			while run_threads:
				found = false
				lock noise_queue:
					if noise_queue.Count > 0:
						found = true
						coord = noise_queue.Dequeue()
				if found:
					still_relevant = false
					lock chunks:
						if coord in chunks:
							still_relevant = true
							chunk = chunks[coord]
					if still_relevant:
						print "Generating Blocks"
						chunk.getBlocks().CalculateBlocks()
						chunk.setFlagMesh(true)
						chunks_generated += 1
						en = LongVector3(coord.x + Settings.ChunkSize, coord.y, coord.z)
						wn = LongVector3(coord.x - Settings.ChunkSize, coord.y, coord.z)
						nn = LongVector3(coord.x, coord.y, coord.z + Settings.ChunkSize)
						sn = LongVector3(coord.x, coord.y, coord.z - Settings.ChunkSize)
						un = LongVector3(coord.x, coord.y + Settings.ChunkSize, coord.z)
						dn = LongVector3(coord.x, coord.y - Settings.ChunkSize, coord.z)
						lock chunks:
							chunks[LongVector3(coord.x, coord.y, coord.z)].setFlagMesh(true)
							# if en in chunks:
							# 	chunks[en].setFlagMesh(true)
							# if wn in chunks:
							# 	chunks[wn].setFlagMesh(true)
							# if nn in chunks:
							# 	chunks[nn].setFlagMesh(true)
							# if sn in chunks:
							# 	chunks[sn].setFlagMesh(true)
							# if un in chunks:
							# 	chunks[un].setFlagMesh(true)
							# if dn in chunks:
							# 	chunks[dn].setFlagMesh(true)

						
						
				# else:
				# 	Thread.Sleep(0.1)
		except e:
			print "THREAD ERROR WITH BLOCKS + $e"


	# def _mesh_create_worker(chunk as Chunk) as WaitCallback:
	# 	try:
	# 		coords = chunk.getCoords()
	# 		mesh as MeshData = chunk.getMesh()

	# 		east_neighbor = LongVector3(coords.x + Settings.ChunkSize, coords.y, coords.z)
	# 		west_neighbor = LongVector3(coords.x - Settings.ChunkSize, coords.y, coords.z)
	# 		north_neighbor = LongVector3(coords.x, coords.y, coords.z + Settings.ChunkSize)
	# 		south_neighbor = LongVector3(coords.x, coords.y, coords.z - Settings.ChunkSize)
	# 		up_neighbor = LongVector3(coords.x, coords.y + Settings.ChunkSize, coords.z)
	# 		down_neighbor = LongVector3(coords.x, coords.y - Settings.ChunkSize, coords.z)
	# 		if chunks.ContainsKey(east_neighbor):
	# 			mesh.setEastNeighbor(chunks[east_neighbor].getBlocks())
	# 		if chunks.ContainsKey(west_neighbor):
	# 			mesh.setWestNeighbor(chunks[west_neighbor].getBlocks())
	# 		if chunks.ContainsKey(north_neighbor):
	# 			mesh.setNorthNeighbor(chunks[north_neighbor].getBlocks())
	# 		if chunks.ContainsKey(south_neighbor):
	# 			mesh.setSouthNeighbor(chunks[south_neighbor].getBlocks())
	# 		if chunks.ContainsKey(up_neighbor):
	# 			mesh.setUpNeighbor(chunks[up_neighbor].getBlocks())
	# 		if chunks.ContainsKey(down_neighbor):
	# 			mesh.setDownNeighbor(chunks[down_neighbor].getBlocks())
	# 		mesh.CalculateMesh()

	# 		lock locker:
	# 			chunk.setFlagMesh(false)
	# 			# TO DO: do not push this chunk out if it has already
	# 			# exceeded the distance metric! (in which case its
	# 			# already been removed in the Update call)
	# 			if LongVector3(coords.x, coords.y, coords.z) in chunks:
	# 				outgoing_queue.Push(["CREATE", chunk])
	# 	except e:
	# 		print "WHOOPS WE HAVE AN ERROR IN MESH: " + e

	# def _noise_worker(chunk as Chunk) as WaitCallback:
	# 	try:
	# 		blocks as BlockData = chunk.getBlocks()
	# 		blocks.CalculateBlocks()
	# 		coords = chunk.getCoords()
	# 		east_neighbor = LongVector3(coords.x + Settings.ChunkSize, coords.y, coords.z)
	# 		west_neighbor = LongVector3(coords.x - Settings.ChunkSize, coords.y, coords.z)
	# 		north_neighbor = LongVector3(coords.x, coords.y, coords.z + Settings.ChunkSize)
	# 		south_neighbor = LongVector3(coords.x, coords.y, coords.z - Settings.ChunkSize)
	# 		up_neighbor = LongVector3(coords.x, coords.y + Settings.ChunkSize, coords.z)
	# 		down_neighbor = LongVector3(coords.x, coords.y - Settings.ChunkSize, coords.z)
			
	# 		lock locker:
	# 			chunk.setFlagNoise(false)
	# 			chunk.setFlagMesh(true)
				
	# 			# # mesh_queue.Push(chunk)
	# 			# if east_neighbor in chunks:
	# 			# 	chunks[east_neighbor].setFlagMesh(true)
	# 			# 	#mesh_queue.Push(chunks[east_neighbor])
	# 			# if west_neighbor in chunks:
	# 			# 	chunks[west_neighbor].setFlagMesh(true)
	# 			# 	#mesh_queue.Push(chunks[west_neighbor])
	# 			# if north_neighbor in chunks:
	# 			# 	chunks[north_neighbor].setFlagMesh(true)
	# 			# 	#mesh_queue.Push(chunks[north_neighbor])
	# 			# if south_neighbor in chunks:
	# 			# 	chunks[south_neighbor].setFlagMesh(true)
	# 			# 	#mesh_queue.Push(chunks[south_neighbor])
	# 			# if up_neighbor in chunks:
	# 			# 	chunks[up_neighbor].setFlagMesh(true)
	# 			# 	#mesh_queue.Push(chunks[up_neighbor])
	# 			# if down_neighbor in chunks:
	# 			# 	chunks[down_neighbor].setFlagMesh(true)
	# 			# 	#mesh_queue.Push(chunks[down_neighbor])

				
	# 	except e:
	# 		print "WHOOPS WE HAVE AN ERROR IN NOISE: " + e


	#
	# uses the distance metric to determine whether to load or unload
	# various chunks.
	#
			
	def SetOrigin(o as Vector3) as void:
		#print 'SetOrigin'
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
		lock chunks:
			for key in chunks.Keys:
				if distance_metric.tooFar(origin_coords, key):
					removal_queue.Push(key)

		# remove all chunks that are too far away
		for key in removal_queue:
			lock outgoing_queue, chunks:
				outgoing_queue.Enqueue(DMMessage("RemoveMesh", chunks[key]))
				chunks.Remove(key)
		
		# determine which chunks need to be added
		creation_queue = []
		for a in range(max_distance*2+1):
			for b in range(Settings.MaxChunksVertical*2+1):
				for c in range(max_distance*2+1):
					x_coord = (a - max_distance)*chunk_size + origin_coords.x
					y_coord = (b - Settings.MaxChunksVertical)*chunk_size
					#y_coord = (b - Settings.MaxChunksVertical)*chunk_size + origin_coords.y
					z_coord = (c - max_distance)*chunk_size + origin_coords.z
					sc = LongVector3(x_coord, y_coord, z_coord)
					lock chunks:
						if not chunks.ContainsKey(sc):
							#print 'Adding Chunk'
							creation_queue.Push(LongVector3(x_coord, y_coord, z_coord))
				c = 0
			c = 0
			b = 0
			

		# sort so that they are from closest to farthest from origin
		creation_queue.Sort() do (left as LongVector3, right as LongVector3):
			return origin.Distance(origin, Vector3(left.x, left.y, left.z)) - origin.Distance(origin, Vector3(right.x, right.y, right.z))

		# add all new chunks
		for item as LongVector3 in creation_queue:
			size = ByteVector3(chunk_size, chunk_size, chunk_size)
			chunk_blocks = BlockData(item, size)
			chunk_mesh = MeshData(chunk_blocks, self)
			chunk_info = Chunk(chunk_blocks, chunk_mesh)
			chunk_info.setFlagNoise(true)
			chunk_info.setFlagMesh(false)
			#print 'Adding Chunk2'
			lock chunks:
				chunks.Add(LongVector3(item.x, item.y, item.z), chunk_info)
			#noise_queue.Push(chunk_info)
			
	#
	# functions to get and set blocks in _global coordinates_
	#

	def convertGlobalToLocal(world as LongVector3):
		pass

	def setBlock(world as LongVector3, block as byte) as void:
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

		lock chunks:
			if chunk_coords in chunks:
				i as Chunk = chunks[chunk_coords]
				c as BlockData = i.getBlocks()
				c.setBlock(block_coords, block)
				m = MeshData(c, self)
				m.CalculateMesh()
				i.setMesh(m)
				SendMessage("RefreshMesh", i)
			else:
				print "Could not find the chunk"			


	# def getBlock(x as long, y as long, z as long):
	# 	pass

	def getBlock(world as LongVector3):
	#def getBlock(x as long, y as long, z as long):
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
		chunk as Chunk
		lock chunks:
			if chunks.TryGetValue(chunk_coords, chunk):
				blocks as BlockData = chunk.getBlocks()
				b = blocks.getBlock(b_x, b_y, b_z)
				return b
			else:
				return 0
		# 	# if b > 0:
		# 	#Log.Log("GET BLOCK: WORLD: $world, CHUNK: $(chunk_coords), LOCAL: $block_coords", LOG_MODULE.CONTACTS)
		# 	return b
		# else:
		# 	print "Could not find the chunk"			
		# 	return 0
		
