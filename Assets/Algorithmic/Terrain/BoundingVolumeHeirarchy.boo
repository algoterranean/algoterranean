namespace Algorithmic.Terrain


# struct Node:
# 	bounding_volume as AABB
# 	children as (Node)     # eight children nodes
# 	#object_list as List    # all objects at this node

# 	def constructor(_aabb as AABB):
# 		bounding_volume = _aabb
# 		children = array(Node, 8)
# 		#object_list = []

# 	def ToString():
# 		s = "NODE: $bounding_volume"
# 		for x in range(len(children)):
# 			s += "\n\t$(children[x])"
# 		return s





struct Node:
	center as Vector3
	radius as Vector3
	children as (Node)
	def constructor(c as Vector3, r as Vector3):
		center = c
		radius = r
		children = array(Node, 8)

class BoundingVolumeTree:
	_tree as Node
	_chunk as IChunkBlockData

	def getTree():
		return _tree
	
	def checkCollision(_aabb as AABB):
		# recursive tree walker
		def _check(tree as Node, aabb as AABB, running_list as List) as void:
			def test(c1 as Vector3, r1 as Vector3,
					 c2 as Vector3, r2 as Vector3):
				if Math.Abs(c1.y - c2.y) > (r1.y + r2.y):
					return false
				if Math.Abs(c1.x - c2.x) > (r1.x + r2.x):
					return false
				if Math.Abs(c1.z - c2.z) > (r1.z + r2.z):
					return false
				return true

			def getCollision(c1 as Vector3, r1 as Vector3,
							 c2 as Vector3, r2 as Vector3):
				x = 0.0
				y = 0.0
				z = 0.0
				if Math.Abs(c1.y - c2.y) <= (r1.y + r2.y):
					y = (c1.y - c2.y) #- (r1.y + r2.y)
				
				return Vector3(x, y, z)

			if test(tree.center, tree.radius, aabb.center, aabb.radius):
				if (tree.radius.x == 0.5 and
					tree.radius.y == 0.5 and
					tree.radius.z == 0.5):
					
					pos = ByteVector3(Math.Abs(tree.center.x % Settings.ChunkSize),
									  Math.Abs(tree.center.y % Settings.ChunkSize),
									  Math.Abs(tree.center.z % Settings.ChunkSize))
					block = _chunk.getBlock(pos)
					if block:
						running_list.Push([getCollision(tree.center, tree.radius,
														aabb.center, aabb.radius), pos])
				for x in range(len(tree.children)):
					_check(tree.children[x], aabb, running_list)
		l = []
		_check(_tree, _aabb, l)
		return l
						
					
			# if test(tree.center, tree.radius, aabb.center, aabb.radius):
			# 	#v = tree.bounding_volume.getCollision(tree.bounding_volume, aabb)
			# 	if (tree.radius.x == 0.5 and
			# 		tree.radius.y == 0.5 and
			# 		tree.radius.z == 0.5):
			# 		pos = ByteVector3(Math.Abs(coords.x % Settings.ChunkSize),
			# 						  Math.Abs(coords.y % Settings.ChunkSize),
			# 			Math.Abs(coords.z % Settings.ChunkSize))
			# 		block = _chunk.getBlock(pos)

			# 		if block:
			# 			running_list.Push([v, pos])

			# 	for x in range(len(tree.children)):
			# 		_check(tree.children[x], aabb, running_list)

		# l = []
		# _check(_tree, _aabb, l)
		# return l	

	def constructor(chunk as ChunkBlockData):
		_chunk = chunk
		size = chunk.getSize()
		coords = chunk.getCoordinates()
		
		if chunk.areBlocksCalculated():
			def _build_tree(root_node as Node, depth as int) as void:
				center = root_node.center
				radius = root_node.radius
				if depth > 0:
					r_half_x = radius.x/2
					r_half_y = radius.y/2
					r_half_z = radius.z/2
					new_radius = Vector3(r_half_x,
										 r_half_y,
										 r_half_z)
					new_center = Vector3(center.x + r_half_x,
										 center.y - r_half_y,
										 center.z - r_half_z)
					root_node.children[0] = Node(new_center, new_radius)

					new_center = Vector3(center.x + r_half_x,
										 center.y + r_half_y,
										 center.z - r_half_z)
					root_node.children[1] = Node(new_center, new_radius)

					new_center = Vector3(center.x + r_half_x,
										 center.y + r_half_y,
										 center.z + r_half_z)
					root_node.children[2] = Node(new_center, new_radius)

					new_center = Vector3(center.x + r_half_x,
										 center.y - r_half_y,
										 center.z + r_half_z)
					root_node.children[3] = Node(new_center, new_radius)

					new_center = Vector3(center.x - r_half_x,
										 center.y - r_half_y,
										 center.z - r_half_z)
					root_node.children[4] = Node(new_center, new_radius)

					new_center = Vector3(center.x - r_half_x,
										 center.y + r_half_y,
										 center.z - r_half_z)
					root_node.children[5] = Node(new_center, new_radius)

					new_center = Vector3(center.x - r_half_x,
										 center.y + r_half_y,
										 center.z + r_half_z)
					root_node.children[6] = Node(new_center, new_radius)

					new_center = Vector3(center.x - r_half_x,
										 center.y - r_half_y,
										 center.z + r_half_z)
					root_node.children[7] = Node(new_center, new_radius)
					#total_count += 8


					for x in  range(len(root_node.children)):
						_build_tree(root_node.children[x], depth - 1)

			coords = chunk.getCoordinates()
			size = chunk.getSize()
			center = Vector3(coords.x + size.x/2,
							 coords.y + size.y/2,
							 coords.z + size.z/2)
			radius = Vector3(size.x/2,
							 size.y/2,
							 size.z/2)

			_tree = Node(center, radius)
			_build_tree(_tree, 5)
					

			
		



# class BoundingVolumeTree:
# 	_tree as Node
# 	_chunk as IChunkBlockData

# 	def getTree():
# 		return _tree

# 	def checkCollision(_aabb as AABB):
# 		# recursive tree walker
# 		def _check(tree as Node, aabb as AABB, running_list as List):
# 			if tree.bounding_volume.Test(tree.bounding_volume, aabb):
# 				v = tree.bounding_volume.getCollision(tree.bounding_volume, aabb)
# 				coords = tree.bounding_volume.center
# 				radius = tree.bounding_volume.radius
# 				if (radius.x == 0.5 and
# 					radius.y == 0.5 and
# 					radius.z == 0.5):
# 					pos = ByteVector3(Math.Abs(coords.x % Settings.ChunkSize),
# 									  Math.Abs(coords.y % Settings.ChunkSize),
# 						Math.Abs(coords.z % Settings.ChunkSize))
# 					block = _chunk.getBlock(pos)

# 					if block:
# 						running_list.Push([v, pos])

# 				for x in range(len(tree.children)):
# 					_check(tree.children[x], aabb, running_list)

# 		l = []
# 		_check(_tree, _aabb, l)
# 		return l



# 	def constructor(chunk as ChunkBlockData):
# 		_chunk = chunk
# 		size = chunk.getSize()
# 		coords = chunk.getCoordinates()

# 		if chunk.areBlocksCalculated():
# 			total_count = 1
# 			def _build_tree(root_node as Node, depth as int) as void:
# 				_aabb = root_node.bounding_volume
# 				center = _aabb.center
# 				radius = _aabb.radius
# 				if depth > 0:
# 					r_half_x = radius.x/2
# 					r_half_y = radius.y/2
# 					r_half_z = radius.z/2
# 					new_radius = Vector3(r_half_x,
# 										 r_half_y,
# 										 r_half_z)
# 					new_center = Vector3(center.x + r_half_x,
# 										 center.y - r_half_y,
# 										 center.z - r_half_z)
# 					root_node.children[0] = Node(AABB(new_center, new_radius))

# 					new_center = Vector3(center.x + r_half_x,
# 										 center.y + r_half_y,
# 										 center.z - r_half_z)
# 					root_node.children[1] = Node(AABB(new_center, new_radius))

# 					new_center = Vector3(center.x + r_half_x,
# 										 center.y + r_half_y,
# 										 center.z + r_half_z)
# 					root_node.children[2] = Node(AABB(new_center, new_radius))

# 					new_center = Vector3(center.x + r_half_x,
# 										 center.y - r_half_y,
# 										 center.z + r_half_z)
# 					root_node.children[3] = Node(AABB(new_center, new_radius))

# 					new_center = Vector3(center.x - r_half_x,
# 										 center.y - r_half_y,
# 										 center.z - r_half_z)
# 					root_node.children[4] = Node(AABB(new_center, new_radius))

# 					new_center = Vector3(center.x - r_half_x,
# 										 center.y + r_half_y,
# 										 center.z - r_half_z)
# 					root_node.children[5] = Node(AABB(new_center, new_radius))

# 					new_center = Vector3(center.x - r_half_x,
# 										 center.y + r_half_y,
# 										 center.z + r_half_z)
# 					root_node.children[6] = Node(AABB(new_center, new_radius))

# 					new_center = Vector3(center.x - r_half_x,
# 										 center.y - r_half_y,
# 										 center.z + r_half_z)
# 					root_node.children[7] = Node(AABB(new_center, new_radius))
# 					total_count += 8


# 					for x in  range(len(root_node.children)):
# 						_build_tree(root_node.children[x], depth - 1)
# 				#return root_node

# 			coords = chunk.getCoordinates()
# 			size = chunk.getSize()
# 			center = Vector3(coords.x + size.x/2,
# 							 coords.y + size.y/2,
# 							 coords.z + size.z/2)
# 			radius = Vector3(size.x/2,
# 							 size.y/2,
# 							 size.z/2)

# 			_tree = Node(AABB(center, radius))
# 			_build_tree(_tree, 5)

# 			print "Bounding Volume Count: $total_count"






