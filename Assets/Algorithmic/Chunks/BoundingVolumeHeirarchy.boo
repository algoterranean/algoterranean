namespace Algorithmic.Chunks
import Algorithmic.Misc
import System


class Node:
	public center as Vector3
	public radius as Vector3
	public children as (Node)

	def constructor(c as Vector3, r as Vector3, child_size as int):
		center = c
		radius = r
		children = array(Node, child_size)




def SweepTest(a as AABB, b as AABB, va as Vector3, vb as Vector3):
	if a.Test(a, b):
		return [0.0, 0.0, true]

	v = vb - va
	t_first = 0.0
	t_last = 1.0

	b_max_x = b.center.x + b.radius.x
	b_min_x = b.center.x - b.radius.x
	a_max_x = a.center.x + a.radius.x
	a_min_x = a.center.x - a.radius.x
	
	b_max_y = b.center.y + b.radius.y
	b_min_y = b.center.y - b.radius.y
	a_max_y = a.center.y + a.radius.y
	a_min_y = a.center.y - a.radius.y
	
	b_max_z = b.center.z + b.radius.z
	b_min_z = b.center.z - b.radius.z
	a_max_z = a.center.z + a.radius.z
	a_min_z = a.center.z - a.radius.z


	if v.x < 0.0:
		if b_max_x < a_min_x:
			return [t_first, t_last, false]
		elif a_max_x < b_min_x:
			t_first = Max((a_max_x - b_min_x)/v.x, t_first)
		elif b_max_x > a_min_x:
			t_last = Min((a_min_x - b_max_x)/v.x, t_last)
	if v.x > 0.0:
		if b_min_x > a_max_x:
			return [t_first, t_last, false]
		elif b_max_x < a_min_x:
			t_first = Max((a_min_x - b_max_x)/v.x, t_first)
		elif a_max_x > b_min_x:
			t_last = Min((a_max_x - b_min_x)/v.x, t_last)

	if v.y < 0.0:
		if b_max_y < a_min_y:
			return [t_first, t_last, false]
		elif a_max_y < b_min_y:
			t_first = Max((a_max_y - b_min_y)/v.y, t_first)
		elif b_max_y > a_min_y:
			t_last = Min((a_min_y - b_max_y)/v.y, t_last)
	if v.y > 0.0:
		if b_min_y > a_max_y:
			return [t_first, t_last, false]
		elif b_max_y < a_min_y:
			t_first = Max((a_min_y - b_max_y)/v.y, t_first)
		elif a_max_y > b_min_y:
			t_last = Min((a_max_y - b_min_y)/v.y, t_last)

	if v.z < 0.0:
		if b_max_z < a_min_z:
			return [t_first, t_last, false]
		elif a_max_z < b_min_z:
			t_first = Max((a_max_z - b_min_z)/v.z, t_first)
		elif b_max_z > a_min_z:
			t_last = Min((a_min_z - b_max_z)/v.z, t_last)
	if v.z > 0.0:
		if b_min_z > a_max_z:
			return [t_first, t_last, false]
		elif b_max_z < a_min_z:
			t_first = Max((a_min_z - b_max_z)/v.z, t_first)
		elif a_max_z > b_min_z:
			t_last = Min((a_max_z - b_min_z)/v.z, t_last)			

	if t_first > t_last:
		return [t_first, t_last, false]
	return [t_first, t_last, true]




class BoundingVolumeTree:
	_tree as Node
	#_chunk as IChunkBlockData

	def getTree():
		return _tree


	def checkCollisionSwept(chunk as IChunkBlockData, _aabb as AABB) as List:
		l = []
		def _check(chunk as IChunkBlockData,
				   tree as Node, aabb as AABB, running_list as List) as void:

			pass
		_check(chunk, _tree, _aabb, l)
		return l


	# discrete collision detection
	def checkCollisionDiscrete(chunk as IChunkBlockData, _aabb as AABB, _aabb_previous as AABB) as List:
		# recursive tree walker
		def _check(chunk as IChunkBlockData,
				   tree as Node, aabb as AABB, aabb_previous as AABB, running_list as List) as void:

			def test(c1 as Vector3, r1 as Vector3,
					 c2 as Vector3, r2 as Vector3):
				if Math.Abs(c1.y - c2.y) >= (r1.y + r2.y):
					return false
				if Math.Abs(c1.x - c2.x) >= (r1.x + r2.x):
					return false
				if Math.Abs(c1.z - c2.z) >= (r1.z + r2.z):
					return false
				return true

			def getCollision(c1 as Vector3, r1 as Vector3,  # terrain
							 c2 as Vector3, r2 as Vector3,  # player
							 c3 as Vector3, r3 as Vector3): # player previously

				penetration = Vector3(0, 0, 0)
				contact_normal = Vector3(0, 0, 0)
				pos_diff = c2 - c3

				
				if Math.Abs(c1.y - c2.y) < (r1.y + r2.y):
					if pos_diff.y < 0: # down, so impacts top face
						penetration.y = (c1.y + r1.y) - (c2.y - r2.y)
						contact_normal.y = 1
					elif pos_diff.y > 0: # up, so impacts bottom face
						penetration.y = -((c1.y - r1.y) - (c2.y + r2.y))
						contact_normal.y = -1
				
				elif Math.Abs(c1.x - c2.x) < (r1.x + r2.x):
					if pos_diff.x < 0: # left, so right face
						penetration.x = (c1.x + r1.x) - (c2.x - r2.x)
						contact_normal.x = 1
					elif pos_diff.x > 0: # right, so left face
						penetration.x = -((c1.x - r1.x) - (c2.x + r2.x))
						contact_normal.x = -1
					
				# Log.Log("\tgetCollision")
				# Log.Log("\t\tPos Diff: ($(pos_diff.x), $(pos_diff.y), $(pos_diff.z)) Penetration: ($(penetration.x), $(penetration.y), $(penetration.z)) Normal: ($(contact_normal.x), $(contact_normal.y), $(contact_normal.z))", Log.PHYSICS)
				#Log.Log("\tFLOATING POINT CHECK on POS_DIFF ($(pos_diff.x), $(pos_diff.y), $(pos_diff.z))")
				# if Math.Abs(c1.x - c2.x) < (r1.x + r2.x):
				# 	x = (c1.x + r1.x) - (c2.x - r2.x)
					
				# if Math.Abs(c1.z - c2.z) < (r1.z + r2.z):
				# 	z = (c1.z + r1.z) - (c2.z - r2.z)

				return [penetration, contact_normal]
			

			if test(tree.center, tree.radius, aabb.center, aabb.radius):
				if (tree.radius.x == 0.5 and
					tree.radius.y == 0.5 and
					tree.radius.z == 0.5):

					pos = ByteVector3(Math.Abs(tree.center.x - 0.5) % Settings.ChunkSize,
									  Math.Abs(tree.center.y - 0.5) % Settings.ChunkSize,
									  Math.Abs(tree.center.z - 0.5) % Settings.ChunkSize)
					block = chunk.getBlock(pos)
					if block:
						# Log.Log("_check")
						# Log.Log("\tTested $(tree.center) with $(aabb.center)")
						# Log.Log("\tBlock: $block, Block Position: $pos")
						running_list.Push(getCollision(tree.center, tree.radius,
													   aabb.center, aabb.radius,
													   aabb_previous.center, aabb_previous.radius))

				for x in range(len(tree.children)):
					_check(chunk, tree.children[x], aabb, aabb_previous, running_list)
		l = []
		_check(chunk, _tree, _aabb, _aabb_previous, l)
		return l



	def constructor(chunk_size as ByteVector3, chunk_coordinates as LongVector3):
		#_chunk = chunk
		size = chunk_size
		coords = chunk_coordinates

		#if chunk.areBlocksCalculated():
		def _build_tree(root_node as Node, depth as int) as void:
			center = root_node.center
			radius = root_node.radius
			if depth > 0:
				r_half_x = radius.x/2
				r_half_y = radius.y/2
				r_half_z = radius.z/2

				if depth > 1:         # if the child nodes will be the final step in recursion, they don't need children nodes themselves
					child_size = 8
				else:
					child_size = 0

				new_radius = Vector3(r_half_x,
									 r_half_y,
									 r_half_z)
				new_center = Vector3(center.x + r_half_x,
									 center.y - r_half_y,
									 center.z - r_half_z)
				root_node.children[0] = Node(new_center, new_radius, child_size)

				new_center = Vector3(center.x + r_half_x,
									 center.y + r_half_y,
									 center.z - r_half_z)
				root_node.children[1] = Node(new_center, new_radius, child_size)

				new_center = Vector3(center.x + r_half_x,
									 center.y + r_half_y,
									 center.z + r_half_z)
				root_node.children[2] = Node(new_center, new_radius, child_size)

				new_center = Vector3(center.x + r_half_x,
									 center.y - r_half_y,
									 center.z + r_half_z)
				root_node.children[3] = Node(new_center, new_radius, child_size)

				new_center = Vector3(center.x - r_half_x,
									 center.y - r_half_y,
									 center.z - r_half_z)
				root_node.children[4] = Node(new_center, new_radius, child_size)

				new_center = Vector3(center.x - r_half_x,
									 center.y + r_half_y,
									 center.z - r_half_z)
				root_node.children[5] = Node(new_center, new_radius, child_size)

				new_center = Vector3(center.x - r_half_x,
									 center.y + r_half_y,
									 center.z + r_half_z)
				root_node.children[6] = Node(new_center, new_radius, child_size)

				new_center = Vector3(center.x - r_half_x,
									 center.y - r_half_y,
									 center.z + r_half_z)
				root_node.children[7] = Node(new_center, new_radius, child_size)
				#total_count += 8

				for x in range(len(root_node.children)):
					_build_tree(root_node.children[x], depth - 1)

		coords = chunk_coordinates
		size = chunk_size
		center = Vector3(coords.x + size.x/2,
						 coords.y + size.y/2,
						 coords.z + size.z/2)
		radius = Vector3(size.x/2,
						 size.y/2,
						 size.z/2)

		_tree = Node(center, radius, 8)
		_build_tree(_tree, 5)








