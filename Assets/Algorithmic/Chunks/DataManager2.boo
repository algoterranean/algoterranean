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


class DataManager2 (MonoBehaviour, IChunkGenerator):
	
	chunks = Dictionary[of LongVector3, Chunk]()
	outgoing_queue = []
	# metric stuff
	origin as Vector3
	origin_initialized = false	
	max_distance as byte
	distance_metric as Metric
	threshold = 10.0


	def Awake():
		max_distance = Settings.MaxChunks
		distance_metric = Metric(Settings.ChunkSize * Settings.MaxChunks)
		Thread(ThreadStart(_mesh_thread)).Start()
		Thread(ThreadStart(_noise_thread)).Start()

		
	def Update():
		# send updates for any previously queued up items
		lock outgoing_queue:
			for x in outgoing_queue:
				SendMessage(x[0], x[1])
			outgoing_queue = []
				
	#
	# helper functions for calculating the block data and mesh data
	# off in the ThreadPool
	#
			
	def _mesh_thread():
		while true:
			try:
				m_list = []
				lock chunks:
					keys = chunks.Keys
					for k in keys:
						if k in chunks and chunks[k].getFlagMesh():
							m_list.Push(k)
				if len(m_list) > 0:
					chunk = m_list[0]
					coords = chunk.getCoords()
					mesh = chunk.getMesh()
					east, west, north, south, up, down = getNeighbors(coords)
					lock chunks:
						mesh.setEastNeighbor(chunks[east].getBlocks()) if east in chunks
						mesh.setWestNeighbor(chunks[west].getBlocks()) if west in chunks
						mesh.setNorthNeighbor(chunks[north].getBlocks()) if north in chunks
						mesh.setSouthNeighbor(chunks[south].getBlocks()) if south in chunks
						mesh.setUpNeighbor(chunks[up].getBlocks()) if up in chunks
						mesh.setDownNeighbor(chunks[down].getBlocks()) if down in chunks

					chunk.setFlagMesh(false)
					mesh.CalculateMesh()
					if LongVector3(coords.x, coords.y, coords.z) in chunks:
						outgoing_queue.Push(["CreateMesh", chunk])
			except e:
				pass
				

	def _noise_thread():
		while true:
			try:
				n_list = []
				lock chunks:
					keys = chunks.Keys
					for k in keys:
						if k in chunks and chunks[k].getFlagNoise():
							n_list.Push(k)
				if len(n_list) > 0:
					chunk = n_list[0]
					chunk.getBlocks().CalculateBlocks()
					chunk.setFlagNoise(false)
					chunk.setFlagMesh(true)
					lock chunks:					
						for neighbor in getNeighbors(chunk.getCoords()):
							if neighbor in chunks:
								chunks[neighbor].setFlagMesh(true)
			except e:
				pass


	#
	# uses the distance metric to determine whether to load or unload
	# various chunks.
	#
			
	def SetOrigin(o as Vector3) as void:
		# only do something if the distance since the last update is greater than some threshold
		if origin_initialized:
			a, b, c = origin.x - o.x, origin.y - o.y, origin.z - o.z
			if Math.Sqrt(a*a + b*b + c*c) < threshold:
				return
			origin = o
		else:
			origin_initialized = true
			origin = o

		# determine which chunks are now too far away and remove them
		origin_coords = Utils.whichChunk(origin)
		# lock chunks:		
		# 	for k in chunks.Keys:
		# 		if k in chunks and distance_metric.tooFar(origin_coords, k):
		# 			lock outgoing_queue:
		# 				outgoing_queue.Push(["RemoveMesh", chunks[k]])
		# 			chunks.Remove(k)
		
		# determine which chunks need to be added
		size_vector = ByteVector3(Settings.ChunkSize, Settings.ChunkSize, Settings.ChunkSize)
		
		for a in range(max_distance*2+1):
			for b in range(Settings.MaxChunksVertical*2+1):
				for c in range(max_distance*2+1):
					
					x_coord = (a - max_distance)*Settings.ChunkSize + origin_coords.x
					y_coord = (b - Settings.MaxChunksVertical)*Settings.ChunkSize + origin_coords.y
					z_coord = (c - max_distance)*Settings.ChunkSize + origin_coords.z
					sc = LongVector3(x_coord, y_coord, z_coord)
					lock chunks:
						if sc not in chunks:
							blocks = BlockData(sc, size_vector)
							chunks.Add(sc, Chunk(blocks, MeshData(blocks)))
				c = 0
			c = 0
			b = 0

	#
	# functions to get and set blocks in _global coordinates_
	#

	def getNeighbors(coords as LongVector3):
		east = LongVector3(coords.x + Settings.ChunkSize, coords.y, coords.z)
		west = LongVector3(coords.x - Settings.ChunkSize, coords.y, coords.z)
		north = LongVector3(coords.x, coords.y, coords.z + Settings.ChunkSize)
		south = LongVector3(coords.x, coords.y, coords.z - Settings.ChunkSize)
		up = LongVector3(coords.x, coords.y + Settings.ChunkSize, coords.z)
		down = LongVector3(coords.x, coords.y - Settings.ChunkSize, coords.z)
		return east, west, north, south, up, down

		
	def globalToLocal(world as LongVector3):
		# c_coords, b_coords = array(long, 3), array(byte, 3)
		# w_coords = (world.x, world.y, world.z)
		
		# for i in range(3):
		# 	new_a = (w_coords[i] + 1 if w_coords[i] < 0 else w_coords[i])
		# 	c_a = new_a / Settings.ChunkSize - (1 if w_coords[i] < 0 else 0)
		# 	start_a = c_a * Settings.ChunkSize
		# 	c_coords[i] = start_a
		# 	b_coords[i] = (w_coords[i] - start_a) cast byte

		# chunk_coords = LongVector3(c_coords[0], c_coords[1], c_coords[2])
		# block_coords = ByteVector3(b_coords[0], b_coords[1], b_coords[2])

		x = world.x
		y = world.y
		z = world.z
		size = Settings.ChunkSize
		
		if x < 0:
			new_x = x + 1
		else:
			new_x = x
		c_x = new_x / size - (1 if x < 0 else 0)
		start_x = c_x * size
		b_x = x - start_x

		if y < 0:
			new_y = y + 1
		else:
			new_y = y
		c_y = new_y / size - (1 if y < 0 else 0)
		start_y = c_y * size
		b_y = y - start_y

		if z < 0:
			new_z = z + 1
		else:
			new_z = z
		c_z = new_z / size - (1 if z < 0 else 0)
		start_z = c_z * size
		b_z = z - start_z

		chunk_coords = LongVector3(c_x * size, c_y * size, c_z * size)
		block_coords = ByteVector3(b_x, b_y, b_z)
	
		return chunk_coords, block_coords

		
	def setBlock(world as LongVector3, block as byte):
		chunk_coords, block_coords = globalToLocal(world)

		lock chunks:
			if chunk_coords in chunks:
				chunk = chunks[chunk_coords]
				chunk.getBlocks().setBlock(block_coords, block)
				chunk.getMesh().CalculateMesh()
				SendMessage("RefreshMesh", chunk)



	def getBlock(world as LongVector3):
		chunk_coords, block_coords = globalToLocal(world)
		
		if chunk_coords in chunks:
			return chunks[chunk_coords].getBlocks().getBlock(block_coords)
		else:
			return 0
