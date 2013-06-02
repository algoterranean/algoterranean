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


class DataManager (MonoBehaviour, IChunkGenerator):
	origin as Vector3
	origin_lock as object
	origin_init as bool
	chunk_cached as Chunk = null
	chunks as Dictionary[of WorldBlockCoordinate, Chunk]
	outgoing_queue as Queue[of DMMessage]
	metric as ChunkMetric
	chunk_size as byte
	block_generator as BlockGenerator
	mesh_generator as MeshGenerator
	worker_thread as Thread
	work_queue as Queue[of Chunk]
	

	def Awake():
		chunk_size = Settings.ChunkSize
		x = BiomeNoiseData()
		#x = SolidNoiseData()
		block_generator = x.getBlock
		mesh_generator = generateMeshGreedy3
		chunks = Dictionary[of WorldBlockCoordinate, Chunk]()
		outgoing_queue = Queue[of DMMessage]()
		work_queue = Queue[of Chunk]()		
		origin = Vector3(0, 0, 0)
		origin_init = false
		metric = ChunkMetric(origin,
							 Settings.ChunkSize,
							 Settings.MaxChunks, Settings.MaxChunksVertical, Settings.MaxChunks)
		worker_thread = Thread(ThreadStart(_worker_thread))
		worker_thread.Start()
		

		
	def _worker_thread():
		chunk as Chunk
		try:
			while true:
				found = false
				lock work_queue:
					if work_queue.Count > 0:
						chunk = work_queue.Dequeue()
						found = true
					else:
						found = false

				if found:
					lock chunk:
						if chunk.NeedsWork:
							chunk.generateBlocks()
							chunk.generateMesh()
							chunk.NeedsWork = false
							
					lock outgoing_queue:
						outgoing_queue.Enqueue(DMMessage("CreateMesh", chunk))
		except e:
			print "THREAD ERROR $e"

	def OnApplicationQuit():
		worker_thread.Abort()
		

	def setOrigin(o as Vector3):
		if origin_init:
			x1 = Math.Abs(o.x - origin.x)
			y1 = Math.Abs(o.y - origin.y)
			z1 = Math.Abs(o.z - origin.z)
			if Math.Sqrt(x1 * x1 + y1 * y1 + z1 * z1) < 10:
				return

		origin_init = true
		origin = o
		metric.Origin = origin
		in_range = metric.getChunksInRange()
		
		
		lock chunks:
			to_remove = [coord for coord in chunks.Keys if metric.isChunkTooFar(coord)]
			to_add = [coord for coord in in_range if not chunks.ContainsKey(coord)]
			lock outgoing_queue:			
				for coord in to_remove:
					outgoing_queue.Enqueue(DMMessage("RemoveMesh", chunks[coord]))
					chunks.Remove(coord)

			tmp_queue = Queue[of Chunk]()
			for coord in to_add:
				if not chunks.ContainsKey(coord):
					c = Chunk(coord, chunk_size, block_generator, mesh_generator)
					chunks.Add(coord, c)

			l = []
			for coord in chunks.Keys:
				if chunks[coord].NeedsWork:
					l.Push(coord)
			l = l.Sort()#  do (left as Chunk, right as Chunk):
			# def p:
			# 	if left.coords
			for coord in l:
				tmp_queue.Enqueue(chunks[coord])

		lock work_queue:
			work_queue = tmp_queue
					

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
		if chunk_cached is not null and chunk_cached.getCoords() == chunk_coords:
			return chunk_cached.getBlock(b_x, b_y, b_z)
		else:
			if chunks.TryGetValue(chunk_coords, chunk_cached):
				return chunk_cached.getBlock(b_x, b_y, b_z)
			else:
				return 0
