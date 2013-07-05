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
import Algorithmic.Utils


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


class DataManager (MonoBehaviour):
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

	origin_thread as Thread
	block_thread as Thread
	block_thread2 as Thread
	block_thread3 as Thread		
	mesh_thread as Thread
	mesh_thread2 as Thread	
	block_queue as Queue[of Chunk]
	mesh_queue as Queue[of Chunk]
	display_manager as DisplayManager
	

	def Awake():
		display_manager = gameObject.Find("Engine/ChunkManager").GetComponent("DisplayManager")
		chunk_size = Settings.Chunks.Size
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
							 Settings.Chunks.Size,
							 Settings.Chunks.MaxHorizontal, Settings.Chunks.MaxVertical, Settings.Chunks.MaxHorizontal)

		origin_thread = Thread(ThreadStart(_origin_thread))
		origin_thread.Start()
		block_thread = Thread(ThreadStart(_block_thread))
		block_thread.IsBackground = true
		block_thread.Start()
		block_thread2 = Thread(ThreadStart(_block_thread))
		block_thread2.IsBackground = true
		block_thread2.Start()
		
		
		
		# block_thread3 = Thread(ThreadStart(_block_thread))
		# block_thread3.Start()		
		mesh_thread = Thread(ThreadStart(_mesh_thread))
		mesh_thread.Start()
		mesh_thread2 = Thread(ThreadStart(_mesh_thread))
		mesh_thread2.Start()

		SendMessage("PerfMaxChunks", Math.Pow(Settings.Chunks.MaxHorizontal * 2 + 1, 2) * (Settings.Chunks.MaxVertical * 2 + 1))
		



	def areNeighborsReady(chunk as Chunk) as bool:
		c = chunk.getCoords()
		size as int = Settings.Chunks.Size * Settings.Chunks.Scale
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

					t1 = System.DateTime.Now
					try:
						chunk.generateBlocks()
						chunk.GenerateBlocks = false
						chunk.GenerateMesh = true
					except e:
						print "THREAD ERROR $e"
						
					t2 = System.DateTime.Now
					lock mesh_queue:
						mesh_queue.Enqueue(chunk)
					lock outgoing_queue:
						outgoing_queue.Enqueue(DMMessage("PerfBlockCreation", (t2 - t1).TotalMilliseconds))
			else:
				Thread.Sleep(50)


	def _mesh_thread():
		chunk as Chunk
		while true:
			found = false
			lock mesh_queue:
				if mesh_queue.Count > 0:
					chunk = mesh_queue.Dequeue()
					if chunk.GenerateMesh and areNeighborsReady(chunk):
						found = true
					else:
						mesh_queue.Enqueue(chunk)
			if found:
				chunk.GenerateMesh = false
				t1 = System.DateTime.Now
				chunk.generateMesh()
				t2 = System.DateTime.Now
				print "CREATING $chunk"
				lock outgoing_queue:
					outgoing_queue.Enqueue(DMMessage("CreateMesh", chunk))
					outgoing_queue.Enqueue(DMMessage("PerfMeshCreation", (t2 - t1).TotalMilliseconds))
			else:
				Thread.Sleep(10)



	def OnApplicationQuit():
		block_thread.Abort()
		block_thread.Join()
		block_thread2.Abort()
		block_thread2.Join()
		
		mesh_thread.Abort()
		mesh_thread.Join()
		mesh_thread2.Abort()
		mesh_thread2.Join()
		
		origin_thread.Abort()
		origin_thread.Join()


	def _origin_thread():
		local_origin = Vector3(99, 99, 99)
		#run = true
		#while run:
		while true:
			# gen = false
			# x1 = Math.Abs(local_origin.x - origin.x)
			# y1 = Math.Abs(local_origin.y - origin.y)
			# z1 = Math.Abs(local_origin.z - origin.z)
			# if Math.Sqrt(x1 * x1 + y1 * y1 + z1 * z1) < 10: #* Settings.ChunkScale:
			# 	gen = false
			# else:
			# 	local_origin = origin
			# 	gen = true
			# 	#metric.Origin = local_origin
			# 	#run = false

			if local_origin != origin:
				local_origin = origin
				in_range = metric.getChunksInRange()
				lock chunks:
					for coord in in_range.Keys:
						#print coord
						if coord not in chunks:
							#chunks.Add(coord, Chunk(coord, chunk_size, BiomeNoiseData2().getBlock, mesh_generator))
							chunks.Add(coord, Chunk(coord, chunk_size, FormFlatNoiseData().getBlock, mesh_generator))

					to_remove = List[of WorldBlockCoordinate]()
					for coord in chunks.Keys:
						if coord not in in_range:
							to_remove.Add(coord)

					lock outgoing_queue:
						for coord in to_remove:
							outgoing_queue.Enqueue(DMMessage("RemoveMesh", chunks[coord]))
							chunks.Remove(coord)


					tmp_queue = Queue[of Chunk]()
					l = List[of WorldBlockCoordinate]()
					# l2 = List[of WorldBlockCoordinate]()
					for coord in chunks.Keys:
						if chunks[coord].GenerateBlocks:
							l.Add(coord)
						# if chunks[coord].GenerateMesh:
						# 	l2.Add(coord)
					l.Sort() do (left as WorldBlockCoordinate, right as WorldBlockCoordinate):
						d1 = Math.Sqrt(Math.Pow(origin.x - left.x, 2) + Math.Pow(origin.y - left.y, 2) + Math.Pow(origin.z - left.z, 2))
						d2 = Math.Sqrt(Math.Pow(origin.x - right.x, 2) + Math.Pow(origin.y - right.y, 2) + Math.Pow(origin.z - right.z, 2))
						if d1 < d2:
							return -1
						elif d1 > d2:
							return 1
						else:
							return 0
				
					# l2.Sort() do (left as WorldBlockCoordinate, right as WorldBlockCoordinate):
					# 	d1 = Math.Sqrt(Math.Pow(origin.x - left.x, 2) + Math.Pow(origin.y - left.y, 2) + Math.Pow(origin.z - left.z, 2))
					# 	d2 = Math.Sqrt(Math.Pow(origin.x - right.x, 2) + Math.Pow(origin.y - right.y, 2) + Math.Pow(origin.z - right.z, 2))
					# 	if d1 < d2:
					# 		return -1
					# 	elif d1 > d2:
					# 		return 1
					# 	else:
					# 		return 0

					for coord in l:
						tmp_queue.Enqueue(chunks[coord])
					lock block_queue:
						block_queue = tmp_queue
					# for coord in l2:
					# 	tmp_queue2.Enqueue(chunks[coord])
			else:
				Thread.Sleep(10)
		
		


	# this is way too slow. maybe this should be done in another thread?
	def setOrigin(o as Vector3):
		if origin_init:
			x1 = Math.Abs(o.x - origin.x)
			y1 = Math.Abs(o.y - origin.y)
			z1 = Math.Abs(o.z - origin.z)
			if Math.Sqrt(x1 * x1 + y1 * y1 + z1 * z1) < 10 * Settings.Chunks.Scale:
				return

		origin_init = true
		origin = o
		metric.Origin = origin

		#_origin_thread()
		

	def Update():
		lock outgoing_queue:
			for i in range(outgoing_queue.Count):
				m = outgoing_queue.Dequeue()
				
				#print "SENDING $(m.function) -> $(m.argument)"
				if m.function == "CreateMesh":
					display_manager.CreateMesh(m.argument)
				elif m.function == "RefreshMesh":
					display_manager.RefreshMesh(m.argument)
				else:
					SendMessage(m.function, m.argument)
				

	def setBlock(world as WorldBlockCoordinate, block as byte) as void:
		chunk_coord as WorldBlockCoordinate, local_coord as ChunkBlockCoordinate = decomposeCoordinates(world)
		
		lock chunks:
			if chunk_coord in chunks:
				c as Chunk = chunks[chunk_coord]
				c.setBlock(local_coord.x, local_coord.y, local_coord.z, block)
				c.generateMesh()
				lock outgoing_queue:
					outgoing_queue.Enqueue(DMMessage("RefreshMesh",c))
			else:
				print "Could not find the chunk"

	def setBlocks(world as WorldBlockCoordinate, size as byte, block as byte):
		chunks_to_update = {}
		for x in range(size):
			for y in range(size):
				for z in range(size):
					chunk_coord as WorldBlockCoordinate, local_coord as ChunkBlockCoordinate = decomposeCoordinates(WorldBlockCoordinate(world.x + x, world.y + y, world.z + z))
		
					lock chunks:
						if chunk_coord in chunks:
							c as Chunk = chunks[chunk_coord]
							c.setBlock(local_coord.x, local_coord.y, local_coord.z, block)
							chunks_to_update["$c"] = c

		for k in chunks_to_update.Keys:
			c = chunks_to_update[k]
			c.generateMesh()
			lock outgoing_queue:
				outgoing_queue.Enqueue(DMMessage("RefreshMesh", c))


	def setBlocks(world as WorldBlockCoordinate, size as byte, direction as Vector3, block as byte):
		chunks_to_update = {}
		for x in range(size):
			for y in range(size):
				for z in range(size):
					w = WorldBlockCoordinate(world.x + x, world.y + y, world.z + z)
					if direction.x < 0:
						w.x -= (size - 1)
					if direction.y < 0:
						w.y -= (size - 1)
					if direction.z < 0:
						w.z -= (size - 1)
					
					chunk_coord as WorldBlockCoordinate, local_coord as ChunkBlockCoordinate = decomposeCoordinates(w)
		
					lock chunks:
						if chunk_coord in chunks:
							c as Chunk = chunks[chunk_coord]
							c.setBlock(local_coord.x, local_coord.y, local_coord.z, block)
							chunks_to_update["$c"] = c

		for k in chunks_to_update.Keys:
			c = chunks_to_update[k]
			c.generateMesh()
			lock outgoing_queue:
				outgoing_queue.Enqueue(DMMessage("RefreshMesh", c))
				
				


	def getBlock(world as WorldBlockCoordinate) as byte:
		chunk_coord as WorldBlockCoordinate, local_coord as ChunkBlockCoordinate = decomposeCoordinates(world)
		
		# lock chunks:
		if chunk_coord in chunks:
			c as Chunk = chunks[chunk_coord]
			return c.getBlock(local_coord.x, local_coord.y, local_coord.z)
		else:
			print "Could not find the chunk"			
			return 0
		

	def getBlocks(world as WorldBlockCoordinate, size as byte) as (byte, 3):
		blocks = matrix(byte, size, size, size)
		for x in range(size):
			for y in range(size):
				for z in range(size):
					blocks[x, y, z] = getBlock(WorldBlockCoordinate(world.x + x, world.y + y, world.z + z))
		return blocks

	def getBlocks(world as WorldBlockCoordinate, size as byte, direction as Vector3) as (byte, 3):
		blocks = matrix(byte, size, size, size)
		
		for x in range(size):
			for y in range(size):
				for z in range(size):
					w = WorldBlockCoordinate(world.x + x, world.y + y, world.z + z)
					if direction.x < 0:
						w.x -= (size - 1)
					if direction.y < 0:
						w.y -= (size - 1)
					if direction.z < 0:
						w.z -= (size - 1)
					blocks[x, y, z] = getBlock(w)
		return blocks



