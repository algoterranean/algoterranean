namespace Algorithmic.Terrain

import System.Collections.Generic
import System.Threading
import Algorithmic
import UnityEngine
import Algorithmic.Misc


################################################################################
# Utility and Message Passing Stuff
class ChunkInfo():
	_chunk as IChunkBlockData
	_mesh as IChunkMeshData
	_bounds as AABB

	def constructor(chunk as IChunkBlockData, mesh as IChunkMeshData):
		_chunk = chunk
		_mesh = mesh
		coords = chunk.getCoordinates()
		_bounds = AABB(Vector3(coords.x + Settings.ChunkSize/2, coords.y + Settings.ChunkSize/2, coords.z + Settings.ChunkSize/2),
				   Vector3(Settings.ChunkSize/2, Settings.ChunkSize/2, Settings.ChunkSize/2))

	def getChunk() as IChunkBlockData:
		return _chunk

	def getMesh() as IChunkMeshData:
		return _mesh

enum Message:
	REMOVE
	ADD
	BLOCKS_READY
	MESH_READY

class ChunkBallMessage():
	_message as Message
	_data as object

	def constructor(message as Message, data as object):
		_message = message
		_data = data

	def getMessage() as Message:
		return _message

	def getData() as object:
		return _data


struct SweepContact:
	contact_normal as Vector3
	direction as Vector3	
	start_time as single
	end_time as single
	block_aabb as AABB
	offset_vector as Vector3
	surface_area as Vector3

	def constructor(n as Vector3, dir as Vector3, start as single, end as single, a as AABB, sur as Vector3):
		contact_normal = n
		direction = dir
		start_time = start
		end_time = end
		block_aabb = a
		surface_area = sur
		offset_vector = Vector3(n.x * dir.x , n.y * dir.y , n.z * dir.z)
		

	def ToString():
		return "Start: $start_time, End: $end_time, Block: ($(block_aabb.center.x), $(block_aabb.center.y), $(block_aabb.center.z)), Direction: ($(direction.x), $(direction.y), $(direction.z)), Normal: ($(contact_normal.x), $(contact_normal.y), $(contact_normal.z)), Offset: ($(offset_vector.x), $(offset_vector.y), $(offset_vector.z)), Surface Area: ($(surface_area.x), $(surface_area.y), $(surface_area.z))" 
	

################################################################################
# Main ChunkBall class
class ChunkBall (IChunkBall, IObservable):
	_locker = object()
	_origin as Vector3
	_min_distance as byte
	_max_distance as byte
	_chunk_size as byte
	_observers = []
	_outgoing_queue = []
	_chunks as Dictionary[of LongVector3, ChunkInfo]
	_threshold = 10.0
	_mesh_waiting_queue as Dictionary[of LongVector3, ChunkInfo]


	def Update():
		notifyObservers()

		# check if new meshes are ready
		ready_mesh_key as duck
		lock _locker:
			for item in _mesh_waiting_queue:
				chunk_info as ChunkInfo = item.Value
				chunk_mesh as ChunkMeshData = chunk_info.getMesh()
				if chunk_mesh.areNeighborsReady():
					ThreadPool.QueueUserWorkItem(_mesh_worker, chunk_info)
					ready_mesh_key = item.Key
					#print "FOUND MESH: $item.key. Length of remaining queue: $(len(_mesh_waiting_queue))"
					break

			if ready_mesh_key != null:
				_mesh_waiting_queue.Remove(ready_mesh_key)


	def registerObserver(o as object) as void:
		if _observers.Contains(o):
			pass
		else:
			lock _locker:
				_observers.Push(o)

	def removeObserver(o as object) as void:
		if _observers.Contains(o):
			lock _locker:
				_observers.Remove(o)

	def notifyObservers() as void:
		lock _locker:
			for x as IObserver in _observers:
				for y in _outgoing_queue:
					x.updateObserver(y)
			_outgoing_queue = []

	def constructor(min_distance, max_distance, chunk_size):
		setMinChunkDistance(min_distance)
		setMaxChunkDistance(max_distance)
		_chunk_size = chunk_size
		_chunks = Dictionary[of LongVector3, ChunkInfo]()
		_mesh_waiting_queue = Dictionary[of LongVector3, ChunkInfo]()
		_origin = Vector3(10000, 10000, 10000)


	def setMinChunkDistance(min_distance as byte) as void:
		_min_distance = min_distance

	def getMinChunkDistance() as byte:
		return _min_distance

	def setMaxChunkDistance(max_distance as byte) as void:
		_max_distance = max_distance

	def getMaxChunkDistance() as byte:
		return _max_distance

	def _add_dchunk():
		pass

	def _remove_chunk():
		pass

	def _mesh_worker(chunk_info as ChunkInfo) as WaitCallback:
		try:
			mesh as ChunkMeshData = chunk_info.getMesh()
			chunk as ChunkBlockData = chunk_info.getChunk()
			mesh.CalculateMesh()
			#print "Mesh Calculated: $(chunk.getCoordinates())"
			lock _locker:
				_outgoing_queue.Push(ChunkBallMessage(Message.MESH_READY, chunk_info))
		except e:
			print "WHOOPS WE HAVE AN ERROR IN MESH: " + e

	def _noise_worker(chunk_info as ChunkInfo) as WaitCallback:
		try:
			chunk as ChunkBlockData = chunk_info.getChunk()
			chunk.CalculateBlocks()
			lock _locker:
				_mesh_waiting_queue[chunk.getCoordinates()] = chunk_info
		except e:
			print "WHOOPS WE HAVE AN ERROR IN NOISE: " + e

	def getMaxHeight(location as Vector3) as int:
		chunk_coords = Utils.whichChunk(location) # LongVector3
		if chunk_coords in _chunks:
			pass
		else:
			return 300  # TO DO: this should be able to return a failure state if the chunk doesn't exist




	def SetOrigin(origin as Vector3) as void:
		# only do something if the distance since the
		# last update is greater than some threshold
		a = _origin.x - origin.x
		b = _origin.y - origin.y
		c = _origin.z - origin.z
		if Math.Sqrt(a*a + b*b + c*c) < _threshold:
			return
		_origin = origin


		#############################################
		# determine which chunks are now too far away
		current_chunk_coords = Utils.whichChunk(_origin)
		removal_queue = []
		lock _locker:
			for item in _chunks:
				chunk_info = item.Value
				chunk_blocks = chunk_info.getChunk()
				chunk_mesh  = chunk_info.getMesh()
				chunk_coords = chunk_blocks.getCoordinates()

				if (current_chunk_coords.x - chunk_coords.x)/_chunk_size > _max_distance or \
					(current_chunk_coords.y - chunk_coords.y)/_chunk_size > _max_distance or \
					(current_chunk_coords.z - chunk_coords.z)/_chunk_size > _max_distance:
					removal_queue.Push(item.Key)

		# remove all chunks that are too far away
		for key in removal_queue:
			lock _locker:
				_outgoing_queue.Push(ChunkBallMessage(Message.REMOVE, _chunks[key]))
			_chunks.Remove(key)

		###########################################
		# determine which chunks need to be added
		creation_queue = []
		for a in range(_max_distance*2+1):
			for b in range(_max_distance*2+1):
				for c in range(_max_distance*2+1):
					x_coord = (a - _max_distance)*_chunk_size + current_chunk_coords.x
					y_coord = (b - _max_distance)*_chunk_size + current_chunk_coords.y
					z_coord = (c - _max_distance)*_chunk_size + current_chunk_coords.z
					if not _chunks.ContainsKey(LongVector3(x_coord, y_coord, z_coord)):
						creation_queue.Push(LongVector3(x_coord, y_coord, z_coord))
				c = 0
			c = 0
			b = 0

		# sort so that they are from closest to farthest from origin
		creation_queue.Sort() do (left as LongVector3, right as LongVector3):
			return _origin.Distance(_origin, Vector3(right.x, right.y, right.z)) - _origin.Distance(_origin, Vector3(left.x, left.y, left.z))

		# add all new chunks
		for item as LongVector3 in creation_queue:
			size = ByteVector3(_chunk_size, _chunk_size, _chunk_size)
			chunk_blocks = ChunkBlockData(item, size)
			chunk_mesh = ChunkMeshData(chunk_blocks)
			chunk_info = ChunkInfo(chunk_blocks, chunk_mesh)
			_chunks.Add(item, chunk_info)
			ThreadPool.QueueUserWorkItem(_noise_worker, chunk_info)
			#_outgoing_queue.Push(ChunkBallMessage(Message.ADD, chunk_info))
			#coords = chunk_blocks.getCoordinates()
		#notifyObservers()

		# for all chunks, update neighbors
		for item in _chunks:
			chunk_info = item.Value
			chunk_blocks = chunk_info.getChunk()
			chunk_mesh = chunk_info.getMesh()
			chunk_coords = chunk_blocks.getCoordinates()

			west_coords = LongVector3(chunk_coords.x - Settings.ChunkSize, chunk_coords.y, chunk_coords.z)
			east_coords = LongVector3(chunk_coords.x + Settings.ChunkSize, chunk_coords.y, chunk_coords.z)
			south_coords = LongVector3(chunk_coords.x, chunk_coords.y, chunk_coords.z - Settings.ChunkSize)
			north_coords = LongVector3(chunk_coords.x, chunk_coords.y, chunk_coords.z + Settings.ChunkSize)
			down_coords = LongVector3(chunk_coords.x, chunk_coords.y - Settings.ChunkSize, chunk_coords.z)
			up_coords = LongVector3(chunk_coords.x, chunk_coords.y + Settings.ChunkSize, chunk_coords.z)

			if _chunks.ContainsKey(west_coords):
				chunk_mesh.setWestNeighbor(_chunks[west_coords].getChunk())
			if _chunks.ContainsKey(east_coords):
				chunk_mesh.setEastNeighbor(_chunks[east_coords].getChunk())
			if _chunks.ContainsKey(south_coords):
				chunk_mesh.setSouthNeighbor(_chunks[south_coords].getChunk())
			if _chunks.ContainsKey(north_coords):
				chunk_mesh.setNorthNeighbor(_chunks[north_coords].getChunk())
			if _chunks.ContainsKey(down_coords):
				chunk_mesh.setDownNeighbor(_chunks[down_coords].getChunk())
			if _chunks.ContainsKey(up_coords):
				chunk_mesh.setUpNeighbor(_chunks[up_coords].getChunk())


	def getBlock(world as LongVector3):
		size = Settings.ChunkSize
		x = world.x
		y = world.y
		z = world.z
		# c_x = world.x/size - (1 if world.x < 0 else 0)
		# c_y = world.y/size - (1 if world.y < 0 else 0)
		# c_z = world.z/size - (1 if world.z < 0 else 0)

		# b_x = world.x % size + (size - 1 if world.x < 0 else 0)
		# b_y = world.y % size + (size - 1 if world.y < 0 else 0)
		# b_z = world.z % size + (size - 1 if world.z < 0 else 0)
		if x < 0:
			new_x = x + 1
		else:
			new_x = x
		c_x = new_x / size - (1 if x < 0 else 0)
		start_x = c_x * size
		end_x = start_x + size - 1
		b_x = x - start_x

		if y < 0:
			new_y = y + 1
		else:
			new_y = y
		c_y = new_y / size - (1 if y < 0 else 0)
		start_y = c_y * size
		end_y = start_y + size - 1
		b_y = y - start_y

		if z < 0:
			new_z = z + 1
		else:
			new_z = z
		c_z = new_z / size - (1 if z < 0 else 0)
		start_z = c_z * size
		end_z = start_z + size - 1
		b_z = z - start_z


		
		chunk_coords = LongVector3(c_x * size, c_y * size, c_z * size)
		block_coords = ByteVector3(b_x, b_y, b_z)
		#print "GetBlock: $world, $chunk_coords, $block_coords"
	
		if chunk_coords in _chunks:
			#print "Found Chunk"
			i as ChunkInfo = _chunks[chunk_coords]
			c as ChunkBlockData = i.getChunk()
			b = c.getBlock(block_coords)
			if b > 0:
				Log.Log("GET BLOCK: WORLD: $world, CHUNK: $(chunk_coords), LOCAL: $block_coords", LOG_MODULE.CONTACTS)

			return b
			#print "Found Block: $b"
		else:
			print "Could not find the chunk"			
			return 0
			

					   
		#print "Chunk ($chunk_x, $chunk_y, $chunk_z), Block: ($block_x, $block_y, $block_z)"

	def _generate_possible_collisions(obj as AABB, obj_prev as AABB):
		# generate possible collisions
		r = Vector3(0.5, 0.5, 0.5)

		if obj.center.x <= obj_prev.center.x:
			left = obj.center.x - obj.radius.x
			right = obj_prev.center.x + obj_prev.radius.x
		elif obj.center.x > obj_prev.center.x:
			left = obj_prev.center.x - obj_prev.radius.x
			right = obj.center.x + obj.radius.x
		# else:
		# 	left = obj.center.x - obj.radius.x
		# 	right = obj.center.x + obj.radius.x

		if obj.center.y <= obj_prev.center.y:
			bottom = obj.center.y - obj.radius.y
			top = obj_prev.center.y + obj_prev.radius.y
		elif obj.center.y > obj_prev.center.y:
			bottom = obj_prev.center.y - obj_prev.radius.y
			top = obj.center.y + obj.radius.y
		# else:
		# 	bottom = obj.center.y - obj.radius.y
		# 	top = obj.center.y + obj.radius.y

		if obj.center.z <= obj_prev.center.z: # towards user
			front = obj.center.z - obj.radius.z
			back = obj_prev.center.z + obj_prev.radius.z
		elif obj.center.z > obj_prev.center.z:
			front = obj_prev.center.z - obj_prev.radius.z
			back = obj.center.z + obj.radius.z
		# else:
		# 	front = obj.center.z - obj.radius.z
		# 	back = obj.center.z + obj.radius.z

		# b_left = Math.Floor(left)
		# b_right = Math.Ceiling(right) - 1
		# b_top = Math.Ceiling(top)
		# b_bottom = Math.Floor(bottom) - 1
		# b_front = Math.Floor(front)
		# b_back = Math.Ceiling(back) - 1
		b_left = Math.Floor(left)
		b_right = Math.Floor(right)
		if b_right == right:
			b_right = b_right - 1
		b_top = Math.Floor(top)
		# if b_top == top:
		# 	b_top = b_top - 1
		b_bottom = Math.Floor(bottom)
		b_front = Math.Floor(front)
		b_back = Math.Floor(back)
		if b_back == back:
			b_back = b_back - 1

		possible_collisions = []
		Log.Log("Checking collision range x: $b_left, $b_right, y: $b_top, $b_bottom, z: $b_front, $b_back", LOG_MODULE.PHYSICS)
		for x in range(b_left, b_right+1):
			for y in range(b_bottom, b_top+1):
				for z in range(b_front, b_back+1):
					b = self.getBlock(LongVector3(x, y, z))
					if b > 0:
						possible_collisions.Push(AABB(Vector3(x + r.x, y + r.y, z + r.z), r))
						# possible_collisions.Push(AABB(Vector3(x + r.x, y + r.y, z + r.z), r))

		return possible_collisions

	def _sweep_test(a as AABB, b as AABB, va as Vector3, vb as Vector3): # e.g., a=player, b=block
		# if a.Test(a, b):
		# 	return [0, 1, true, Vector3(0, 0, 0), Vector3(0, 0, 0)]
		
		t_first = 0.0
		t_last = 1.0
		v = vb - va
		print "VEL CHECK: ($(v.x), $(v.y), $(v.z))"
		#overlap_time = Vector3(0, 0, 0)
		contact_normal = Vector3(0, 0, 0)
		movement_dir = va - vb
		surface_area = Vector3(0, 0, 0)

		
		overlap_time = 0
		overlap_axis = "none"
		for y as duck in [[v.x, a.min.x, a.max.x, b.min.x, b.max.x, "x"],
						  [v.y, a.min.y, a.max.y, b.min.y, b.max.y, "y"],
						  [v.z, a.min.z, a.max.z, b.min.z, b.max.z, "z"]]:
			velocity = y[0]
			a_min = y[1]
			a_max = y[2]
			b_min = y[3]
			b_max = y[4]

			if velocity < 0:
				if b_max < a_min:
					return [t_first, t_last, false, contact_normal, movement_dir]
				if a_max < b_min:
					overlap = (a_max - b_min)/velocity
					t_first = Max(overlap, t_first)
					if overlap > overlap_time:
						overlap_time = overlap
						overlap_axis = y[5]
				if b_max > a_min:
					overlap = (a_min - b_max)/velocity
					t_last = Min(overlap, t_last)
					
			elif velocity > 0:
				if b_min > a_max:
					return [t_first, t_last, false, contact_normal, movement_dir]
				if b_max < a_min:
					overlap = (a_min - b_max)/velocity
					t_first = Max(overlap, t_first)
					print "OVERLAP CHECK: $overlap, $overlap_time, $(y[5])"
					if overlap > overlap_time:
						overlap_time = overlap
						overlap_axis = y[5]
						
				if a_max > b_min:
					print 'hi2'
					overlap = (a_max - b_min)/velocity
					t_last = Min(overlap, t_last)
				print 'hi3'

		# surface_area.x = a.max.x - b.min.x
		# surface_area.y = a.max.y - b.min.y
		# surface_area.z = a.max.z - b.min.z
		surface_area_x = (Min(a.max.y, b.max.y) - Max(a.min.y, b.min.y)) * (Min(a.max.z, b.max.z) - Max(a.min.z, b.min.z))
		surface_area_y = (Min(a.max.x, b.max.x) - Max(a.min.x, b.min.x)) * (Min(a.max.z, b.max.z) - Max(a.min.z, b.min.z))
		surface_area_z = (Min(a.max.y, b.max.y) - Max(a.min.y, b.min.y)) * (Min(a.max.x, b.max.x) - Max(a.min.x, b.min.x))
		surface_area = Vector3(surface_area_x, surface_area_y, surface_area_z)
		print "AXIS CHECK: $overlap_axis"
		if overlap_axis == "x":
			contact_normal = Vector3(Mathf.Sign(v.x), 0, 0)
		if overlap_axis == "y":
			contact_normal = Vector3(0, Mathf.Sign(v.y), 0)
		if overlap_axis == "z":
			contact_normal = Vector3(0, 0, Mathf.Sign(v.z))


		FP_ERROR = 0.0001
		if contact_normal == Vector3(0, 0, 0):
			# generate contact normal for resting particles
			if b.max.y <= a.min.y: #+ FP_ERROR: #and v.y <= 0:
				contact_normal = Vector3(0, 1, 0)
			elif b.min.y >= a.max.y: #- FP_ERROR: #and v.y >= 0:
				contact_normal = Vector3(0, -1, 0)

			elif b.max.x <= a.min.x: #+ FP_ERROR: #and v.x <= 0:
				contact_normal = Vector3(1, 0, 0)
			elif b.min.x >= a.max.x: #- FP_ERROR: #and v.x >= 0:
				contact_normal = Vector3(-1, 0, 0)

			elif b.max.z <= a.min.z: #+ FP_ERROR: #and v.z <= 0:
				contact_normal = Vector3(0, 0, 1)
			elif b.min.z >= a.max.z: #- FP_ERROR: #and v.z >= 0:
				contact_normal = Vector3(0, 0, -1)


			
		if t_first > t_last:
			return [t_first, t_last, false, contact_normal, movement_dir, surface_area]

		#print "Contact Normal: ($(contact_normal.x), $(contact_normal.y), $(contact_normal.z))"
		return [t_first, t_last, true, contact_normal, movement_dir, surface_area]

	

	def CheckCollisionsSweep(obj as AABB, obj_prev as AABB) as List[of SweepContact]:
		c = _generate_possible_collisions(obj, obj_prev) # will be empty if the player hasn't moved
		
		#print "Possible Collisions: $c"
		#b = [] #List[of SweepContact]()
		b = List[of SweepContact]()
		for block_aabb in c:
			possible_c as duck = _sweep_test(obj_prev, block_aabb, obj.center - obj_prev.center, Vector3(0, 0, 0))
			#print "POSSIBLE: $possible_c, $block_aabb"
			if possible_c[2]:
				contact = SweepContact(possible_c[3],
									   possible_c[4],
									   possible_c[0],
									   possible_c[1],
									   block_aabb,
									   possible_c[5])
				print "POSSIBLE: $contact"
				b.Add(contact)
			#b.Push([block_aabb, ])
		#print "BEFORE SORT: $b"
		b.Sort() do (x as SweepContact, y as SweepContact):
			if x.start_time < y.start_time:
				return -1
			elif x.start_time > y.start_time:
				return 1
			else:
				return 0
			
		#print "AFTER SORT: $b"
		
		# Log.Log("COLLISION CHECK:", LOG_MODULE.CONTACTS)
		# for x in b:
		# 	Log.Log("    $x", LOG_MODULE.CONTACTS)
		return b
		
		#print "Possible Collisions: $possible_collisions"
		#print "AABBs: $obj Prev: $obj_prev"
	

	def CheckCollisions(_object_to_check as AABB, _object_to_check_previous as AABB):
		collisions = []

		for item in _chunks:
			chunk_info = item.Value
			chunk = chunk_info.getChunk()
			chunk_mesh = chunk_info.getMesh()

			tree as BoundingVolumeTree = chunk_mesh.getTree()
			if tree != null: # would be null in the case of checking chunks that
				             # don't exist (i.e., near player because they're way up in the air)
				node as Node = tree.getTree()
				c = tree.checkCollisionDiscrete(chunk, _object_to_check, _object_to_check_previous)
				if len(c) > 0:
					for x in c:
						collisions.Push(x)

		if len(collisions) > 0:
			furthest_penetration as duck = collisions[0]
			for x as duck in c:
				if x[0].y > furthest_penetration[0].y:
					furthest_penetration = x
			collisions = [furthest_penetration]

		return collisions












