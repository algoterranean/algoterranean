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
	chunks as Dictionary[of WorldBlockCoordinate, Chunk]
	noise_thread as Thread
	mesh_thread as Thread
	outgoing_queue as Queue[of DMMessage]
	metric as ChunkMetric
	chunk_size as byte
	block_generator as BlockGenerator
	mesh_generator as MeshGenerator

	def Awake():
		#def constructor(s as byte, b as BlockGenerator):
		#ThreadPool.SetMaxThreads(5, 5)
		chunk_size = Settings.ChunkSize
		x = BiomeNoiseData()
		#x = SolidNoiseData()
		block_generator = x.getBlock
		mesh_generator = generateMesh
		
		
		chunks = Dictionary[of WorldBlockCoordinate, Chunk]()
		#noise_thread = Thread(ThreadStart(_noise_worker))
		#mesh_thread = Thread(ThreadStart(_mesh_worker))
		outgoing_queue = Queue[of DMMessage]()
		#noise_thread.Start()
		metric = ChunkMetric(Vector3(0, 0, 0),
							 Settings.ChunkSize,
							 Settings.MaxChunks, Settings.MaxChunksVertical, Settings.MaxChunks)
		
		#mesh_thread.Start()

	# def destructor():
	# 	noise_thread.Abort()
	# 	noise_thread.Join()
	# 	# mesh_thread.Abort()
	# 	# mesh_thread.Join()

	def getChunk(coord as WorldBlockCoordinate) as Chunk:
		lock chunks:
			if chunks.ContainsKey(coord):
				return chunks[coord]
		return null

	def setOrigin(o as Vector3):
		metric.Origin = o
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
					ThreadPool.QueueUserWorkItem(_chunk_worker, c)
					
		# for x in chunks:
		# 	print x.Key

	def Update():
		lock outgoing_queue:
			for i in range(len(outgoing_queue)):
				m = outgoing_queue.Dequeue()
				SendMessage(m.function, m.chunk)

	def _chunk_worker(o as object) as WaitCallback:
		c = o cast Chunk
		t1 = DateTime.Now
		c.generateBlocks()
		t2 = DateTime.Now
		c.generateMesh()
		t3 = DateTime.Now
		lock outgoing_queue:
			outgoing_queue.Enqueue(DMMessage("CreateMesh", c))
			print "completed chunk $c, noise in $(t2-t1), mesh in $(t3-t2)"
		

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
		chunk as Chunk
		lock chunks:
			if chunks.TryGetValue(chunk_coords, chunk):
				return chunk.getBlock(b_x, b_y, b_z)
				# blocks as BlockData = chunk.getBlocks()
				# b = blocks.getBlock(b_x, b_y, b_z)
				# return b
			else:
				return 0
		# 	# if b > 0:
		# 	#Log.Log("GET BLOCK: WORLD: $world, CHUNK: $(chunk_coords), LOCAL: $block_coords", LOG_MODULE.CONTACTS)
		# 	return b
		# else:
		# 	print "Could not find the chunk"			
		# 	return 0
		
