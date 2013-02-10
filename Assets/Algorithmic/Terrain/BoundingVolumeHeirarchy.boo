namespace Algorithmic.Terrain


struct Node:
	bounding_volume as AABB
	children as List   # eight children nodes
	object_list as List    # all objects at this node

	def constructor(_aabb as AABB):
		bounding_volume = _aabb
		children = [] #array(Node, 8)
		object_list = []

	def ToString():
		s = "NODE: $bounding_volume"
		for x in range(len(children)):
			s += "\n\t$(children[x])"
		return s
	
	


class BoundingVolumeTree:
	_tree as Node
	_chunk as IChunkBlockData

	def getTree():
		return _tree

	def checkCollision(_aabb as AABB):
		# recursive tree walker
		def _check(tree as Node, aabb as AABB, running_list as List):
			if tree.bounding_volume.Test(tree.bounding_volume, aabb):
				v = tree.bounding_volume.getCollision(tree.bounding_volume, aabb)
				coords = tree.bounding_volume.center
				radius = tree.bounding_volume.radius
				if (radius.x == 0.5 and
				    radius.y == 0.5 and
					radius.z == 0.5):
					pos = ByteVector3(Math.Abs(coords.x % Settings.ChunkSize),
									  Math.Abs(coords.y % Settings.ChunkSize),
						Math.Abs(coords.z % Settings.ChunkSize))
					block = _chunk.getBlock(pos)
					
					if block:
						running_list.Push([v, pos])
						
				for x in range(len(tree.children)):
					_check(tree.children[x], aabb, running_list)
					
		l = []
		_check(_tree, _aabb, l)
		# if len(l) > 0:
		# 	item as List = l[0]
		# 	max_v as Vector3 = item[0]
		# 	max_p as ByteVector3 = item[1]
			
		# 	for x as List in l:
		# 		v as Vector3 = x[0]
		# 		p as ByteVector3 = x[1]
		# 		if p.y > max_p.y:
		# 			max_p = p
		# 			max_v = v
		# 	return [[max_v, max_p]]
		
		return l



	def constructor(chunk as ChunkBlockData):
		_chunk = chunk
		size = chunk.getSize()
		coords = chunk.getCoordinates()

		if chunk.areBlocksCalculated():
			def _build_tree(root_node as Node, depth as int) as void:
				_aabb = root_node.bounding_volume
				center = _aabb.center
				radius = _aabb.radius
				if depth > 0:
					new_radius = Vector3(radius.x/2, radius.y/2, radius.z/2)
					new_center = Vector3(center.x + radius.x/2, center.y - radius.y/2, center.z - radius.z/2)
					root_node.children.Push(Node(AABB(new_center, new_radius)))
					
					new_center = Vector3(center.x + radius.x/2, center.y + radius.y/2, center.z - radius.z/2)
					root_node.children.Push(Node(AABB(new_center, new_radius)))

					new_center = Vector3(center.x + radius.x/2, center.y + radius.y/2, center.z + radius.z/2)
					root_node.children.Push(Node(AABB(new_center, new_radius)))
				
					new_center = Vector3(center.x + radius.x/2, center.y - radius.y/2, center.z + radius.z/2)
					root_node.children.Push(Node(AABB(new_center, new_radius)))
					
					new_center = Vector3(center.x - radius.x/2, center.y - radius.y/2, center.z - radius.z/2)
					root_node.children.Push(Node(AABB(new_center, new_radius)))

					new_center = Vector3(center.x - radius.x/2, center.y + radius.y/2, center.z - radius.z/2)
					root_node.children.Push(Node(AABB(new_center, new_radius)))

					new_center = Vector3(center.x - radius.x/2, center.y + radius.y/2, center.z + radius.z/2)
					root_node.children.Push(Node(AABB(new_center, new_radius)))
					
					new_center = Vector3(center.x - radius.x/2, center.y - radius.y/2, center.z + radius.z/2)
					root_node.children.Push(Node(AABB(new_center, new_radius)))

					for x in range(len(root_node.children)):
						_build_tree(root_node.children[x], depth - 1)
				#return root_node

			coords = chunk.getCoordinates()
			size = chunk.getSize()
			center = Vector3(coords.x + size.x/2, coords.y + size.y/2, coords.z + size.z/2)
			radius = Vector3(size.x/2, size.y/2, size.z/2)
			_tree = Node(AABB(center, radius))
			_build_tree(_tree, 5)

					
				
				
		
		
