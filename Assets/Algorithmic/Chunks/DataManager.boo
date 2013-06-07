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
	argument as duck

	def constructor(f as string, a as duck):
		function = f
		argument = a
		

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

	block_thread as Thread
	block_thread2 as Thread
	block_thread3 as Thread		
	mesh_thread as Thread
	mesh_thread2 as Thread	
	block_queue as Queue[of Chunk]
	mesh_queue as Queue[of Chunk]
	

	def Awake():
		chunk_size = Settings.ChunkSize
		x = BiomeNoiseData2()
		#x = SolidNoiseData()
		block_generator = x.getBlock
		mesh_generator = generateMeshGreedy3
		chunks = Dictionary[of WorldBlockCoordinate, Chunk]()
		outgoing_queue = Queue[of DMMessage]()
		block_queue = Queue[of Chunk]()
		mesh_queue = Queue[of Chunk]()
		origin = Vector3(0, 0, 0)
		origin_init = false
		metric = ChunkMetric(origin,
							 Settings.ChunkSize,
							 Settings.MaxChunks, Settings.MaxChunksVertical, Settings.MaxChunks)

		block_thread = Thread(ThreadStart(_block_thread))
		block_thread.Start()
		# block_thread2 = Thread(ThreadStart(_block_thread))
		# block_thread2.Start()
		# block_thread3 = Thread(ThreadStart(_block_thread))
		# block_thread3.Start()		
		mesh_thread = Thread(ThreadStart(_mesh_thread))
		mesh_thread.Start()
		# mesh_thread2 = Thread(ThreadStart(_mesh_thread))
		# mesh_thread2.Start()

		SendMessage("PerfMaxChunks", Math.Pow(Settings.MaxChunks * 2 + 1, 2) * (Settings.MaxChunksVertical * 2 + 1))
		



	def areNeighborsReady(chunk as Chunk) as bool:
		c = chunk.getCoords()
		size = Settings.ChunkSize
		e = WorldBlockCoordinate(c.x + size, c.y, c.z)
		w = WorldBlockCoordinate(c.x - size, c.y, c.z)
		n = WorldBlockCoordinate(c.x, c.y, c.z + size)
		s = WorldBlockCoordinate(c.x, c.y, c.z - size)
		u = WorldBlockCoordinate(c.x, c.y + size, c.z)
		d = WorldBlockCoordinate(c.x, c.y - size, c.z)
		lock chunks:
			if e in chunks and not chunks[e].GenerateBlocks and \
				w in chunks and not chunks[w].GenerateBlocks and \
				n in chunks and not chunks[n].GenerateBlocks and \
				s in chunks and not chunks[s].GenerateBlocks and \
				u in chunks and not chunks[u].GenerateBlocks and \
				d in chunks and not chunks[d].GenerateBlocks:
				return true
			return false

		
	def _block_thread():
		chunk as Chunk
		while true:
			found = false
			lock block_queue:
				if block_queue.Count > 0:
					chunk = block_queue.Dequeue()
					found = true
				else:
					found = false

			if found:
				if chunk.GenerateBlocks:
					chunk.GenerateBlocks = false
					t1 = System.DateTime.Now
					chunk.generateBlocks()
					t2 = System.DateTime.Now
					chunk.GenerateMesh = true
					lock mesh_queue:
						mesh_queue.Enqueue(chunk)
					lock outgoing_queue:
						outgoing_queue.Enqueue(DMMessage("PerfBlockCreation", (t2 - t1).TotalMilliseconds))


	def _mesh_thread():
		chunk as Chunk
		while true:
			found = false
			lock mesh_queue:
				if mesh_queue.Count > 0:
					chunk = mesh_queue.Dequeue()
					if chunk.GenerateMesh: #and areNeighborsReady(chunk):
						found = true
					else:
						mesh_queue.Enqueue(chunk)
			if found:
				chunk.GenerateMesh = false
				t1 = System.DateTime.Now
				chunk.generateMesh()
				t2 = System.DateTime.Now
				lock outgoing_queue:
					outgoing_queue.Enqueue(DMMessage("CreateMesh", chunk))
					outgoing_queue.Enqueue(DMMessage("PerfMeshCreation", (t2 - t1).TotalMilliseconds))



	def OnApplicationQuit():
		block_thread.Abort()
		# block_thread2.Abort()
		# block_thread3.Abort()
		mesh_thread.Abort()
		# mesh_thread2.Abort()		
		

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
			to_remove = [coord for coord in chunks.Keys if coord not in in_range]
						 # metric.isChunkTooFar(coord)]
			to_add = [coord for coord in in_range if not chunks.ContainsKey(coord)]

			lock outgoing_queue:			
				for coord in to_remove:
					outgoing_queue.Enqueue(DMMessage("RemoveMesh", chunks[coord]))
					chunks.Remove(coord)

			tmp_queue = Queue[of Chunk]()
			tmp_queue2 = Queue[of Chunk]()
			for coord in in_range:
			# for coord in to_add:
				if coord not in chunks.Keys:
					c = Chunk(coord, chunk_size, BiomeNoiseData2().getBlock, mesh_generator)
					chunks.Add(coord, c)

			l = []
			l2 = []
			for coord in chunks.Keys:
				if chunks[coord].GenerateBlocks:
					l.Push(coord)
				if chunks[coord].GenerateMesh:
					l2.Push(coord)
			l = l.Sort() do (left as WorldBlockCoordinate, right as WorldBlockCoordinate):
				d1 = Math.Sqrt(Math.Pow(origin.x - left.x, 2) + Math.Pow(origin.y - left.y, 2) + Math.Pow(origin.z - left.z, 2))
				d2 = Math.Sqrt(Math.Pow(origin.x - right.x, 2) + Math.Pow(origin.y - right.y, 2) + Math.Pow(origin.z - right.z, 2))
				if d1 < d2:
					return -1
				elif d1 > d2:
					return 1
				else:
					return 0
				
			l2 = l2.Sort() do (left as WorldBlockCoordinate, right as WorldBlockCoordinate):
				d1 = Math.Sqrt(Math.Pow(origin.x - left.x, 2) + Math.Pow(origin.y - left.y, 2) + Math.Pow(origin.z - left.z, 2))
				d2 = Math.Sqrt(Math.Pow(origin.x - right.x, 2) + Math.Pow(origin.y - right.y, 2) + Math.Pow(origin.z - right.z, 2))
				if d1 < d2:
					return -1
				elif d1 > d2:
					return 1
				else:
					return 0

			for coord in l:
				tmp_queue.Enqueue(chunks[coord])
			for coord in l2:
				tmp_queue2.Enqueue(chunks[coord])

		# lock mesh_queue:
		# 	mesh_queue = tmp_queue2
		lock block_queue:
			block_queue = tmp_queue

					

	def Update():
		lock outgoing_queue:
			for i in range(len(outgoing_queue)):
				m = outgoing_queue.Dequeue()
				SendMessage(m.function, m.argument)

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
