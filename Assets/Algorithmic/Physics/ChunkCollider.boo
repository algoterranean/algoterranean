namespace Algorithmic.Physics

import UnityEngine
import Algorithmic.Chunks




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


class ChunkCollider ():
	chunk_ball as IChunkGenerator

	def constructor(cb as IChunkGenerator):
		chunk_ball = cb
		
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
		Algorithmic.Misc.Log.Log("Checking collision range x: $b_left, $b_right, y: $b_top, $b_bottom, z: $b_front, $b_back", LOG_MODULE.PHYSICS)
		for x in range(b_left, b_right+1):
			for y in range(b_bottom, b_top+1):
				for z in range(b_front, b_back+1):
					b = chunk_ball.getBlock(LongVector3(x, y, z))
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
		#print "VEL CHECK: ($(v.x), $(v.y), $(v.z))"
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
					#print "OVERLAP CHECK: $overlap, $overlap_time, $(y[5])"
					if overlap > overlap_time:
						overlap_time = overlap
						overlap_axis = y[5]
						
				if a_max > b_min:
					#print 'hi2'
					overlap = (a_max - b_min)/velocity
					t_last = Min(overlap, t_last)
				#print 'hi3'

		# surface_area.x = a.max.x - b.min.x
		# surface_area.y = a.max.y - b.min.y
		# surface_area.z = a.max.z - b.min.z
		surface_area_x = (Min(a.max.y, b.max.y) - Max(a.min.y, b.min.y)) * (Min(a.max.z, b.max.z) - Max(a.min.z, b.min.z))
		surface_area_y = (Min(a.max.x, b.max.x) - Max(a.min.x, b.min.x)) * (Min(a.max.z, b.max.z) - Max(a.min.z, b.min.z))
		surface_area_z = (Min(a.max.y, b.max.y) - Max(a.min.y, b.min.y)) * (Min(a.max.x, b.max.x) - Max(a.min.x, b.min.x))
		surface_area = Vector3(surface_area_x, surface_area_y, surface_area_z)
		#print "AXIS CHECK: $overlap_axis"
		if overlap_axis == "x":
			contact_normal = Vector3(Mathf.Sign(v.x), 0, 0)
		if overlap_axis == "y":
			contact_normal = Vector3(0, Mathf.Sign(v.y), 0)
		if overlap_axis == "z":
			contact_normal = Vector3(0, 0, Mathf.Sign(v.z))


		#FP_ERROR = 0.0001
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
				#print "POSSIBLE: $contact"
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
	


	# old code when I used a BoundingVolumeHeirarchy
	# def CheckCollisions(_object_to_check as AABB, _object_to_check_previous as AABB):
	# 	collisions = []

	# 	for item in chunks:
	# 		chunk_info = item.Value
	# 		chunk = chunk_info.getChunk()
	# 		chunk_mesh = chunk_info.getMesh()

	# 		tree as BoundingVolumeTree = chunk_mesh.getTree()
	# 		if tree != null: # would be null in the case of checking chunks that
	# 			             # don't exist (i.e., near player because they're way up in the air)
	# 			node as Node = tree.getTree()
	# 			c = tree.checkCollisionDiscrete(chunk, _object_to_check, _object_to_check_previous)
	# 			if len(c) > 0:
	# 				for x in c:
	# 					collisions.Push(x)

	# 	if len(collisions) > 0:
	# 		furthest_penetration as duck = collisions[0]
	# 		for x as duck in c:
	# 			if x[0].y > furthest_penetration[0].y:
	# 				furthest_penetration = x
	# 		collisions = [furthest_penetration]

	# 	return collisions




