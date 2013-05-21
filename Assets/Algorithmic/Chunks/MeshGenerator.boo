namespace Algorithmic.Chunks

def generateMesh(blocks as (byte, 3)) as MeshData2:
	chunk_size = Settings.ChunkSize
	#size = chunk.getSize()
	vertice_size = 0
	triangle_size = 0
	uv_size = 0
	aabb_size = 0

	#coords = chunk.getCoordinates()
	# en = data_manager.getChunk(WorldBlockCoordinate(coords.x + Settings.ChunkSize, coords.y, coords.z))
	# wn = data_manager.getChunk(WorldBlockCoordinate(coords.x - Settings.ChunkSize, coords.y, coords.z))
	# nn = data_manager.getChunk(WorldBlockCoordinate(coords.x, coords.y, coords.z + Settings.ChunkSize))
	# sn = data_manager.getChunk(WorldBlockCoordinate(coords.x, coords.y, coords.z - Settings.ChunkSize))
	# un = data_manager.getChunk(WorldBlockCoordinate(coords.x, coords.y + Settings.ChunkSize, coords.z))
	# dn = data_manager.getChunk(WorldBlockCoordinate(coords.x, coords.y - Settings.ChunkSize, coords.z))
	# if en != null:
	# 	east_neighbor = en.getBlocks()
	# if wn != null:
	# 	west_neighbor = wn.getBlocks()
	# if nn != null:
	# 	north_neighbor = nn.getBlocks()
	# if sn != null:
	# 	south_neighbor = sn.getBlocks()
	# if un != null:
	# 	up_neighbor = un.getBlocks()
	# if dn != null:
	# 	down_neighbor = dn.getBlocks()

	# vertices = matrix(Vector3, vertice_size)
	# triangles = matrix(int, triangle_size)
	# uvs = matrix(Vector2, uv_size)
	# normals = matrix(Vector3, vertice_size)
	## _bounding_volumes = matrix(AABB, aabb_size)

	# vertice_count = 0
	# triangle_count = 0
	# uv_count = 0
	# normal_count = 0
	#aabb_count = 0

	vertices = List[of Vector3]()
	uvs = List[of Vector2]()
	normals = List[of Vector3]()
	triangles = List[of int]()
	vertice_count = 0
	

	def _add_uvs(x as single, y as single):
		# give x, y coordinates in (0-9) by (0-9)
		uvs.Push(Vector2(x + 0.01, 1.0 - y - 0.1 + 0.01))
		uvs.Push(Vector2(x + 0.01, 1.0 - y - 0.01))
		uvs.Push(Vector2(x - 0.01 + 0.1, 1.0 - y - 0.01))
		uvs.Push(Vector2(x - 0.01 + 0.1, 1.0 - y - 0.1 + 0.01))

	def _calc_triangles():
		triangles.Push(vertice_count-4)
		triangles.Push(vertice_count-3)
		triangles.Push(vertice_count-2)
		triangles.Push(vertice_count-2)
		triangles.Push(vertice_count-1)
		triangles.Push(vertice_count-4)
		# triangles[triangle_count]   = vertice_count-4 # 0
		# triangles[triangle_count+1] = vertice_count-3 # 1
		# triangles[triangle_count+2] = vertice_count-2 # 2
		# triangles[triangle_count+3] = vertice_count-2 # 2
		# triangles[triangle_count+4] = vertice_count-1 # 3
		# triangles[triangle_count+5] = vertice_count-4 # 0
		# triangle_count += 6

	def _add_normals(n as Vector3):
		normals.Push(n)
		normals.Push(n)
		normals.Push(n)
		normals.Push(n)

	t1 = DateTime.Now
	for x as byte in range(chunk_size):
		for y as byte in range(chunk_size):
			for z as byte in range(chunk_size):
				block = blocks[x, y, z] #chunk.getBlock(ByteVector3(x, y, z))

				if x == 0: #and west_neighbor.isNull():
					block_west = BLOCK.AIR
				# elif x == 0 and not west_neighbor.isNull():
				# 	block_west = west_neighbor.getBlock(ByteVector3(chunk_size-1, y, z))
				else:
					block_west = blocks[x-1, y, z] #chunk.getBlock(ByteVector3(x-1, y, z))

				if x == chunk_size -1: #and east_neighbor.isNull():
					block_east = BLOCK.AIR
				# elif x == chunk_size - 1 and not east_neighbor.isNull():
				# 	block_east = east_neighbor.getBlock(ByteVector3(0, y, z))
				else:
					block_east = blocks[x+1, y, z] #chunk.getBlock(ByteVector3(x+1, y ,z))

				if z == 0: #and south_neighbor.isNull():
					block_south = BLOCK.AIR
				# elif z == 0 and not south_neighbor.isNull():
				# 	block_south = south_neighbor.getBlock(ByteVector3(x, y, chunk_size-1))
				else:
					block_south = blocks[x, y, z-1] #chunk.getBlock(ByteVector3(x, y, z-1))

				if z == chunk_size-1: #and north_neighbor.isNull():
					block_north = BLOCK.AIR
				# elif z == chunk_size-1 and not north_neighbor.isNull():
				# 	block_north = north_neighbor.getBlock(ByteVector3(x, y, 0))
				else:
					block_north = blocks[x, y, z+1] #chunk.getBlock(ByteVector3(x, y, z+1))

				if y == 0: #and down_neighbor.isNull():
					block_down = BLOCK.AIR
				# elif y == 0 and not down_neighbor.isNull():
				# 	block_down = down_neighbor.getBlock(ByteVector3(x, chunk_size-1, z))
				else:
					block_down = blocks[x, y-1, z] #chunk.getBlock(ByteVector3(x, y-1, z))

				if y == chunk_size-1: #and up_neighbor.isNull():
					block_up = BLOCK.AIR
				# elif y == chunk_size-1 and not up_neighbor.isNull():
				# 	block_up = up_neighbor.getBlock(ByteVector3(x, 0, z))
				else:
					block_up = blocks[x, y+1, z] #chunk.getBlock(ByteVector3(x, y+1, z))


				if block:
					aabb_test = false
					if not block_west:
						vertices.Push(Vector3(x, y, z))
						vertices.Push(Vector3(x, y, z+1))
						vertices.Push(Vector3(x, y+1, z+1))
						vertices.Push(Vector3(x, y+1, z))
						vertice_count += 4
						_calc_triangles()
						_add_normals(Vector3(-1, 0, 0))
						_add_uvs(Blocks.block_def[block].uv_x, Blocks.block_def[block].uv_y)
						aabb_test = true
					if not block_east:
						vertices.Push(Vector3(x+1, y, z+1))
						vertices.Push(Vector3(x+1, y, z))
						vertices.Push(Vector3(x+1, y+1, z))
						vertices.Push(Vector3(x+1, y+1, z+1))
						vertice_count += 4
						_calc_triangles()
						_add_normals(Vector3(1, 0, 0))
						_add_uvs(Blocks.block_def[block].uv_x, Blocks.block_def[block].uv_y)
						aabb_test = true
					if not block_south:
						vertices.Push(Vector3(x+1, y, z))
						vertices.Push(Vector3(x, y, z))
						vertices.Push(Vector3(x, y+1, z))
						vertices.Push(Vector3(x+1, y+1, z))
						vertice_count += 4
						_calc_triangles()
						_add_normals(Vector3(0, 0, -1))
						_add_uvs(Blocks.block_def[block].uv_x, Blocks.block_def[block].uv_y)
						aabb_test = true
					if not block_north:
						vertices.Push(Vector3(x, y, z+1))
						vertices.Push(Vector3(x+1, y, z+1))
						vertices.Push(Vector3(x+1, y+1, z+1))
						vertices.Push(Vector3(x, y+1, z+1))
						vertice_count += 4
						_calc_triangles()
						_add_normals(Vector3(0, 0, 1))
						_add_uvs(Blocks.block_def[block].uv_x, Blocks.block_def[block].uv_y)
						aabb_test = true
					if not block_down:
						vertices.Push(Vector3(x+1, y, z+1))
						vertices.Push(Vector3(x, y, z+1))
						vertices.Push(Vector3(x, y, z))
						vertices.Push(Vector3(x+1, y, z))
						vertice_count += 4
						_calc_triangles()
						_add_normals(Vector3(0, -1, 0))
						_add_uvs(Blocks.block_def[block].uv_x, Blocks.block_def[block].uv_y)
						aabb_test = true
					if not block_up:
						vertices.Push(Vector3(x+1, y+1, z))
						vertices.Push(Vector3(x, y+1, z))
						vertices.Push(Vector3(x, y+1, z+1))
						vertices.Push(Vector3(x+1, y+1, z+1))
						vertice_count += 4
						_calc_triangles()
						_add_normals(Vector3(0, 1, 0))
						_add_uvs(Blocks.block_def[block].uv_x, Blocks.block_def[block].uv_y)
						aabb_test = true
					## if aabb_test:
					## 	_bounding_volumes[aabb_count] = AABB(Vector3(x + 0.5, y + 0.5, z + 0.5), Vector3(0.5, 0.5, 0.5))
					## 	aabb_count += 1

	t2 = DateTime.Now
	m = MeshData2(uvs.ToArray(),
				  vertices.ToArray(),
				  normals.ToArray(),
				  triangles.ToArray())
	t3 = DateTime.Now
	#print "Finished mesh in $(t2-t1), $(t3-t2)"
	return m
	#bounding_volume_tree = BoundingVolumeTree(chunk.getSize(), chunk.getCoordinates())
