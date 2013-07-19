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


# used to efficiently pass data from the work threads to the
# outgoing queue and from there on to any listening objects
struct DMMessage:
	
	function as string
	argument as duck

	def constructor(f as string, a as duck):
		function = f
		argument = a

# gathers up all of the data generated by a mesh algorithm
# so that it can be passed to DisplayManager or any other
# listener that needs to generate a mesh. the members of this
# struct are typed specifically to be used by Unity's Mesh object
class MeshData:
	
	public uvs as (Vector2)
	public vertices as (Vector3)
	public normals as (Vector3)
	public triangles as (int)
	public lights as (Color)

	def constructor(u as (Vector2), v as (Vector3), n as (Vector3), t as (int), l as (Color)):
		uvs = u
		vertices = v
		normals = n
		triangles = t
		lights = l

# block and mesh generator function signatures
callable BlockGenerator(world_x as long, world_y as long, world_z as long) as byte
callable MeshGenerator(chunk as Chunk, neighbors as Dictionary[of WorldBlockCoordinate, Chunk]) as MeshData



# main workhorse that handles all chunk generating, updating, etc. 
# the player informs the DataManager via setOrigin of where they currently
# are and the DataManager responds by queueing up chunks to be generated
# depending on how far from the player they are (i.e., closest gets worked first)
# the work is all performed multi-threaded. when chunks have been fully
# generated or updated (i.e., via digging) the DataManager will send out
# notices to whichever objects are listening.
class DataManager (MonoBehaviour):
	
	# reference to display manager for performance reasons. this is used
	# to inform the DisplayManager of any changes to chunks so they can
	# be drawn, refreshed, removed, etc. 
	display_manager as DisplayManager
	
	# keeps track of what the current origin is and the distance
	# for when the origin should be updated (and thus when the
	# work queues for chunks are updated)
	origin as Vector3
	origin_init as bool
	origin_trigger_distance as single
	
	# main chunk storage and a distance metric that determines
	# which chunks should be displayed and which should be removed
	chunk_size as byte
	chunks as Dictionary[of WorldBlockCoordinate, Chunk]
	metric as ChunkMetric
	
	# the block, mesh, and light algorithms that we will use
	block_generator as callable
	# block_generator as BlockGenerator	
	mesh_generator as MeshGenerator
	mesh_physx_generator as MeshGenerator
	
	# work queues. shared between the main thread and the work threads.
	outgoing_queue as Queue[of DMMessage]
	block_queue as Queue[of Chunk]
	mesh_queue as Queue[of Chunk]
	
	# work threads
	thread_list as List[of Thread]	
	

	def Awake():
		display_manager = gameObject.Find("Engine/ChunkManager").GetComponent("DisplayManager")

		origin = Vector3(0, 0, 0)
		origin_init = false
		origin_trigger_distance = 10.0 * Settings.Chunks.Scale

		chunk_size = Settings.Chunks.Size
		chunks = Dictionary[of WorldBlockCoordinate, Chunk]()
		metric = ChunkMetric(origin,
							 Settings.Chunks.Size,
							 Settings.Chunks.MaxHorizontal,
							 Settings.Chunks.MaxVertical,
							 Settings.Chunks.MaxHorizontal)

		# block_generator = FormFlatNoiseData
		mesh_generator = generateMesh
		mesh_physx_generator = generateMeshGreedy2

		outgoing_queue = Queue[of DMMessage]()
		block_queue = Queue[of Chunk]()
		mesh_queue = Queue[of Chunk]()

		thread_list = List[of Thread]()
		thread_list.Add(Thread(ThreadStart(_origin_thread)))
		thread_list.Add(Thread(ThreadStart(_block_thread)))
		thread_list.Add(Thread(ThreadStart(_block_thread)))
		thread_list.Add(Thread(ThreadStart(_mesh_thread)))
		thread_list.Add(Thread(ThreadStart(_mesh_thread)))		
		
		# thread_list = List[of Thread]([,
		# 			   Thread(ThreadStart(_block_thread)), Thread(ThreadStart(_block_thread)),
		# 			   Thread(ThreadStart(_mesh_thread)), Thread(ThreadStart(_mesh_thread))])
		_start_threads()

		SendMessage("PerfMaxChunks", Math.Pow(Settings.Chunks.MaxHorizontal * 2 + 1, 2) * (Settings.Chunks.MaxVertical * 2 + 1))


	def Update():
		# check the outgoing message queue to see if any listeners need to
		# be informed of recent changes. the DisplayManager is informed directly
		# for the messages it cares about (since SendMessage is slow) and any
		# other messages are passed up the chain to any siblings via SendMessage
		# (for purposes of easy expandability in the future)
		lock outgoing_queue:
			# completely clear out this queue in one Update
			for i in range(outgoing_queue.Count): 
				m = outgoing_queue.Dequeue()
				if m.function == "CreateMesh":
					display_manager.CreateMesh(m.argument)
				elif m.function == "RefreshMesh":
					display_manager.RefreshMesh(m.argument)
				else:
					SendMessage(m.function, m.argument)

		# _mesh_thread()

	def OnApplicationQuit():
		_stop_threads()		


	def _start_threads():
		for x in thread_list:
			x.IsBackground = true
			x.Start()


	def _stop_threads():
		for x in thread_list:
			x.Abort()
			x.Join()

		
	def _block_thread():
		chunk as Chunk
		while true:
			found = false
			lock block_queue:
				# check if there are any chunks that need their basic data generated
				if block_queue.Count > 0:
					chunk = block_queue.Dequeue()
					found = true
				else:
					found = false

			if found:
				if chunk.GenerateBlocks:
					t1 = System.DateTime.Now
					try:
						# generate all of the blocks for this chunk and then fill in
						# the initial lighting data so that we can flood-fill later
						# when the neighbors are ready
						chunk.GenerateBlocks = false
						chunk.generateBlocks()
						chunk.initializeLights()
						chunk.GenerateMesh = true
						t2 = System.DateTime.Now

						# this chunk is now ready to have its meshes generated
						# once its neighbors are likewise ready
						lock mesh_queue:
							mesh_queue.Enqueue(chunk)
						# inform any performance listeners of how long this took
						lock outgoing_queue:
							outgoing_queue.Enqueue(DMMessage("PerfBlockCreation", (t2 - t1).TotalMilliseconds))
					except e:
						print "THREAD ERROR $e"
			else:
				Thread.Sleep(50)


	def _mesh_thread():
		chunk as Chunk
		# neighbors will be passed in by ref to areNeighborsReady
		# neighbors = List[of Chunk]()
		# for i in range(6):
		# 	neighbors.Add(null)
			
		while true:
			found = false
			lock mesh_queue:
				if mesh_queue.Count > 0:
					chunk = mesh_queue.Dequeue()
					# only proceed with this chunk if it needs a mesh generated
					# and its neighbors have all their basic data already generated
					neighbors = Dictionary[of WorldBlockCoordinate, Chunk]()					
					if chunk.GenerateMesh and _areNeighborsReady(chunk, neighbors):
						found = true
					else:
						# if the neighbors aren't ready yet, put it back in the queue
						# to be worked later
						mesh_queue.Enqueue(chunk)
			if found:
				try:
					# update the lights ala flood-fill for smooth lighting
					# and then generate the 2 meshes (physics and visual)
					chunk.GenerateMesh = false
					t1 = System.DateTime.Now
					#chunk.generateLights(neighbors)
					chunk.generateMesh(neighbors)
					t2 = System.DateTime.Now

					# inform any listeners that the mesh has been created
					lock outgoing_queue:
						outgoing_queue.Enqueue(DMMessage("CreateMesh", chunk))
						outgoing_queue.Enqueue(DMMessage("PerfMeshCreation", (t2 - t1).TotalMilliseconds))
				except e:
					print "THREAD ERROR $e"

			# nothing to do so take a brief nap so as not to consume 100% of the CPU in this loop
			else: 
				Thread.Sleep(10)


	def _origin_thread():
		local_origin = Vector3(99, 99, 99)
		
		while true:
			# only run if the origin has changed
			if local_origin != origin:
				local_origin = origin
				# get all of the chunks that are in range
				in_range = metric.getChunksInRange()
				lock chunks:
					for coord in in_range.Keys:
						if coord not in chunks:
							# add all chunks to our master dictionary that are
							# in range but haven't been added yet
							chunks.Add(coord, Chunk(coord,
													chunk_size,
													FormFlatNoiseData().getBlock,
													mesh_generator,
													mesh_physx_generator))

					# "mark" all chunks that are no longer in range as needing to be removed
					to_remove = List[of WorldBlockCoordinate]()
					for coord in chunks.Keys:
						if coord not in in_range:
							to_remove.Add(coord)

					# remove the chunks from our master dictionary and inform the listeners
					# that the chunk has been removed
					lock outgoing_queue:
						for coord in to_remove:
							outgoing_queue.Enqueue(DMMessage("RemoveMesh", chunks[coord]))
							chunks.Remove(coord)


					# generate an ordered list of all the chunks that need work done
					# so that these chunks are worked in order of the distance from the origin
					tmp_queue = Queue[of Chunk]()
					l = List[of WorldBlockCoordinate]()
					
					for coord in chunks.Keys:
						if chunks[coord].GenerateBlocks:
							l.Add(coord)
							
					l.Sort() do (left as WorldBlockCoordinate, right as WorldBlockCoordinate):
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

					# update the working queue for the block threads
					lock block_queue:
						block_queue = tmp_queue
			else:
				Thread.Sleep(10)


	def _getNeighbors(chunk as Chunk) as Dictionary[of WorldBlockCoordinate, Chunk]:
		size as int = Settings.Chunks.Size * Settings.Chunks.Scale
		neighbors = Dictionary[of WorldBlockCoordinate, Chunk]()
		c = chunk.getCoords()

		# the coordinates for all (including diagonals)
		# TODO: rewrite this so it isn't so shitty (laborious)
		e = WorldBlockCoordinate(c.x + size, c.y, c.z)
		w = WorldBlockCoordinate(c.x - size, c.y, c.z)
		n = WorldBlockCoordinate(c.x, c.y, c.z + size)
		s = WorldBlockCoordinate(c.x, c.y, c.z - size)
		u = WorldBlockCoordinate(c.x, c.y + size, c.z)
		d = WorldBlockCoordinate(c.x, c.y - size, c.z)

		ne = WorldBlockCoordinate(c.x + size, c.y, c.z + size)
		nw = WorldBlockCoordinate(c.x - size, c.y, c.z + size)
		se = WorldBlockCoordinate(c.x + size, c.y, c.z - size)
		sw = WorldBlockCoordinate(c.x - size, c.y, c.z - size)

		ue = WorldBlockCoordinate(c.x + size, c.y + size, c.z)
		uw = WorldBlockCoordinate(c.x - size, c.y + size, c.z)
		un = WorldBlockCoordinate(c.x, c.y + size, c.z + size)
		us = WorldBlockCoordinate(c.x, c.y + size, c.z - size)
		une = WorldBlockCoordinate(c.x + size, c.y + size, c.z + size)
		unw = WorldBlockCoordinate(c.x - size, c.y + size, c.z + size)
		use = WorldBlockCoordinate(c.x + size, c.y + size, c.z - size)
		usw = WorldBlockCoordinate(c.x - size, c.y + size, c.z - size)

		de = WorldBlockCoordinate(c.x + size, c.y - size, c.z)
		dw = WorldBlockCoordinate(c.x - size, c.y - size, c.z)
		dn = WorldBlockCoordinate(c.x, c.y - size, c.z + size)
		ds = WorldBlockCoordinate(c.x, c.y - size, c.z - size)
		dne = WorldBlockCoordinate(c.x + size, c.y - size, c.z + size)
		dnw = WorldBlockCoordinate(c.x - size, c.y - size, c.z + size)
		dse = WorldBlockCoordinate(c.x + size, c.y - size, c.z - size)
		dsw = WorldBlockCoordinate(c.x - size, c.y - size, c.z - size)

		neighbors[c] = chunk

		neighbors[e] = (chunks[e] if e in chunks else null)
		neighbors[w] = (chunks[w] if w in chunks else null)
		neighbors[n] = (chunks[n] if n in chunks else null)
		neighbors[s] = (chunks[s] if s in chunks else null)
		neighbors[u] = (chunks[u] if u in chunks else null)		
		neighbors[d] = (chunks[d] if d in chunks else null)

		#print DATA MANAGER: , e, w, n, s, u, d

		neighbors[ne] = (chunks[ne] if ne in chunks else null)
		neighbors[nw] = (chunks[nw] if nw in chunks else null)
		neighbors[se] = (chunks[se] if se in chunks else null)
		neighbors[sw] = (chunks[sw] if sw in chunks else null)

		neighbors[ue] = (chunks[ue] if ue in chunks else null)
		neighbors[uw] = (chunks[uw] if uw in chunks else null)
		neighbors[un] = (chunks[un] if un in chunks else null)
		neighbors[us] = (chunks[us] if us in chunks else null)
		neighbors[une] = (chunks[une] if une in chunks else null)
		neighbors[unw] = (chunks[unw] if unw in chunks else null)
		neighbors[use] = (chunks[use] if use in chunks else null)
		neighbors[usw] = (chunks[usw] if usw in chunks else null)

		neighbors[de] = (chunks[de] if de in chunks else null)
		neighbors[dw] = (chunks[dw] if dw in chunks else null)
		neighbors[dn] = (chunks[dn] if dn in chunks else null)
		neighbors[ds] = (chunks[ds] if ds in chunks else null)
		neighbors[dne] = (chunks[dne] if dne in chunks else null)
		neighbors[dnw] = (chunks[dnw] if dnw in chunks else null)
		neighbors[dse] = (chunks[dse] if dse in chunks else null)
		neighbors[dsw] = (chunks[dsw] if dsw in chunks else null)
		
		return neighbors


	def _areNeighborsReady(chunk as Chunk, ref neighbors as Dictionary[of WorldBlockCoordinate, Chunk]) as bool:
		n = _getNeighbors(chunk)
		# set the neighbors List that was passed in to the values we just found
		# so that looking up the chunks doesn"t have to happen a 2nd time
		for x in n.Keys:
			neighbors[x] = n[x]
		# for i in range(6):
		# 	neighbors[i] = n[i]

		# if any of the neighbors doesn"t exist or they haven't generated their
		# basic data yet, then they are not ready
		for x in n.Keys:
			if neighbors[x] == null or neighbors[x].GenerateBlocks:
				return false
		# for i in range(6):
		# 	if neighbors[i] == null or neighbors[i].GenerateBlocks:
		# 		return false
		return true
		
		
	def setOrigin(o as Vector3):
		if origin_init:
			# only update the origin if it has changed sufficiently
			if Vector3.Distance(o, origin) < origin_trigger_distance:
				return

		# triggers if the distance between the old and new origin
		# is sufficiently large OR the origin has never been set
		origin_init = true
		origin = o
		metric.Origin = origin
								

	def setBlock(world as WorldBlockCoordinate, block as byte) as void:
		chunk_coord as WorldBlockCoordinate, local_coord as ChunkBlockCoordinate = decomposeCoordinates(world)
		
		lock chunks:
			if chunk_coord in chunks:
				c as Chunk = chunks[chunk_coord]
				c.setBlock(local_coord.x, local_coord.y, local_coord.z, block)
				# c.generateMesh(_getNeighbors(c))
				
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
							# TO DO: add neighbors to this list if a border block is affected
							
		# for k in chunks_to_update.Keys:
		# 	c = chunks_to_update[k]
		# 	c.generateMesh(_getNeighbors(c))
		# 	lock outgoing_queue:
		# 		outgoing_queue.Enqueue(DMMessage("RefreshMesh", c))


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

		# for k in chunks_to_update.Keys:
		# 	c = chunks_to_update[k]
		# 	c.generateMesh(_getNeighbors(c))
		# 	lock outgoing_queue:
		# 		outgoing_queue.Enqueue(DMMessage("RefreshMesh", c))


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



