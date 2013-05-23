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
	function as string
	chunk as Chunk

	def constructor(f as string, c as Chunk):
		function = f
		chunk = c

struct MeshData2:
	uvs as (Vector2)
	vertices as (Vector3)
	normals as (Vector3)
	triangles as (int)

	def constructor(u as (Vector2), v as (Vector3), n as (Vector3), t as (int)):
		uvs = u
		vertices = v
		normals = n
		triangles = t
		

callable BlockGenerator(world_x as long, world_y as long, world_z as long) as byte
callable MeshGenerator(blocks as (byte, 3)) as MeshData2

def b1 (x as long, y as long, z as long) as byte:
	return 1
# def m1 (blocks as (byte, 3)) as MeshData2:
# 	return MeshData2(0)

class DataManager (MonoBehaviour, IChunkGenerator):
	origin as Vector3
	origin_lock as object
	chunks as Dictionary[of WorldBlockCoordinate, Chunk]
	outgoing_queue as Queue[of DMMessage]
	metric as ChunkMetric
	chunk_size as byte
	block_generator as BlockGenerator
	mesh_generator as MeshGenerator
	worker_thread as Thread
	# worker_thread2 as Thread
	# worker_thread3 as Thread	
	ordered_chunk_list as List[of WorldBlockCoordinate]

	def Awake():
		chunk_size = Settings.ChunkSize
		x = BiomeNoiseData()
		#x = SolidNoiseData()
		block_generator = x.getBlock
		mesh_generator = generateMesh
		
		ordered_chunk_list = List[of WorldBlockCoordinate]()
		chunks = Dictionary[of WorldBlockCoordinate, Chunk]()
		outgoing_queue = Queue[of DMMessage]()
		origin_lock = object()
		origin = Vector3(0, 0, 0)
		metric = ChunkMetric(origin,
							 Settings.ChunkSize,
							 Settings.MaxChunks, Settings.MaxChunksVertical, Settings.MaxChunks)
		ordered_chunk_list = metric.getOrderedChunksInRange()
		worker_thread = Thread(ThreadStart(_worker_thread))
		worker_thread2 = Thread(ThreadStart(_worker_thread))
		worker_thread3 = Thread(ThreadStart(_worker_thread))		
		worker_thread.Start()
		# worker_thread2.Start()
		# worker_thread3.Start()		
		


	def _worker_thread():
		:start
		try:
			while true:
				for c in ordered_chunk_list:
					found = false					
					lock origin_lock:
						converted = WorldBlockCoordinate(origin.x/chunk_size + (c.x * chunk_size),
														  origin.y/chunk_size + (c.y * chunk_size),
														  origin.z/chunk_size + (c.z * chunk_size))
					lock chunks:
						if converted in chunks and chunks[converted].FlagGenBlocks:
							chunk = chunks[converted]
							chunk.FlagGenBlocks = false
							found = true
					if found:
						chunk.generateBlocks()
						chunk.generateMesh()
						lock outgoing_queue:
							outgoing_queue.Enqueue(DMMessage("CreateMesh", chunk))

		except e as ThreadAbortException:
			if e.ExceptionState == "reset":
				Thread.ResetAbort()
				goto start
		
	def getChunk(coord as WorldBlockCoordinate) as Chunk:
		lock chunks:
			if chunks.ContainsKey(coord):
				return chunks[coord]
		return null

	def setOrigin(o as Vector3):
		lock origin_lock:
			origin = o
		metric.Origin = origin
		in_range = metric.getChunksInRange()

		lock chunks:
			to_remove = [coord for coord in chunks.Keys if metric.isChunkTooFar(coord)]
			to_add = [coord for coord in in_range if not chunks.ContainsKey(coord)]
			for coord in to_remove:
				chunks.Remove(coord)
			for coord in to_add:
				if not chunks.ContainsKey(coord):
					c = Chunk(coord, chunk_size, block_generator, mesh_generator)
					chunks.Add(coord, c)
			worker_thread.Abort("reset")
			# worker_thread2.Abort("reset")
			# worker_thread3.Abort("reset")

	def Update():
		lock outgoing_queue:
			for i in range(len(outgoing_queue)):
				m = outgoing_queue.Dequeue()
				SendMessage(m.function, m.chunk)


	# def setBlock(world as WorldBlockCoordinate, block as byte) as void:
	# 	size = Settings.ChunkSize
	# 	x = world.x
	# 	y = world.y
	# 	z = world.z
		
	# 	if x < 0:
	# 		new_x = x + 1
	# 	else:
	# 		new_x = x
	# 	c_x = new_x / size - (1 if x < 0 else 0)
	# 	start_x = c_x * size
	# 	#end_x = start_x + size - 1
	# 	b_x = x - start_x

	# 	if y < 0:
	# 		new_y = y + 1
	# 	else:
	# 		new_y = y
	# 	c_y = new_y / size - (1 if y < 0 else 0)
	# 	start_y = c_y * size
	# 	#end_y = start_y + size - 1
	# 	b_y = y - start_y

	# 	if z < 0:
	# 		new_z = z + 1
	# 	else:
	# 		new_z = z
	# 	c_z = new_z / size - (1 if z < 0 else 0)
	# 	start_z = c_z * size
	# 	#end_z = start_z + size - 1
	# 	b_z = z - start_z

	# 	chunk_coords = WorldBlockCoordinate(c_x * size, c_y * size, c_z * size)
	# 	#chunk_coords = "$(c_x*size),$(c_y*size),$(c_z*size)"
	# 	block_coords = ByteVector3(b_x, b_y, b_z)
	# 	#print "GetBlock: $world, $chunk_coords, $block_coords"

	# 	lock chunks:
	# 		if chunk_coords in chunks:
	# 			i as Chunk = chunks[chunk_coords]
	# 			c as BlockData = i.getBlocks()
	# 			c.setBlock(block_coords, block)
	# 			m = MeshData(c, self)
	# 			m.CalculateMesh()
	# 			i.setMesh(m)
	# 			SendMessage("RefreshMesh", i)
	# 		else:
	# 			print "Could not find the chunk"			


	# # def getBlock(x as long, y as long, z as long):
	# # 	pass

	def getBlock(world as WorldBlockCoordinate):
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



		chunk_coords = WorldBlockCoordinate(c_x * size, c_y * size, c_z * size)
		
		#return 0
	
		chunk as Chunk
		if chunks.TryGetValue(chunk_coords, chunk):
			if not chunk.FlagGenBlocks:
				return chunk.getBlock(b_x, b_y, b_z)
		return 0
		# lock chunks:
		# 	if chunk_coords in chunks and not chunks[chunk_coords].FlagGenBlocks:
			#if chunks.TryGetValue(chunk_coords, chunk):
			# return chunks[chunk_coords].getBlock(b_x, b_y, b_z)
			# else:
			# 	return 0
		
