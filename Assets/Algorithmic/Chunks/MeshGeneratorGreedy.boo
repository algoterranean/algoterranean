namespace Algorithmic.Chunks


def generateMeshGreedy(blocks as (byte, 3)) as MeshData2:
	chunk_size = Settings.ChunkSize
	vertices = List[of Vector3]()
	uvs = List[of Vector2]()
	normals = List[of Vector3]()
	triangles = List[of int]()

	def _add_uvs(x as single, y as single):
		# give x, y coordinates in (0-9) by (0-9)
		uvs.Push(Vector2(x + 0.01, 1.0 - y - 0.1 + 0.01))
		uvs.Push(Vector2(x + 0.01, 1.0 - y - 0.01))
		uvs.Push(Vector2(x - 0.01 + 0.1, 1.0 - y - 0.01))
		uvs.Push(Vector2(x - 0.01 + 0.1, 1.0 - y - 0.1 + 0.01))


	# do the west and east pass
	vertice_count = 0
	for x as byte in range(chunk_size):
		west_mask = matrix(bool, chunk_size, chunk_size)
		east_mask = matrix(bool, chunk_size, chunk_size)
		for y as byte in range(chunk_size):
			for z as byte in range(chunk_size):
				block = blocks[x, y, z]
				if x == 0:
					block_west = BLOCK.AIR
				else:
					block_west = blocks[x - 1, y, z]
				if x == chunk_size - 1:
					block_east = BLOCK.AIR
				else:
					block_east = blocks[x + 1, y, z]
				
				if block and not block_west:
					west_mask[y, z] = true
				else:
					west_mask[y, z] = false
				if block and not block_east:
					east_mask[y, z] = true
				else:
					east_mask[y, z] = false

					
		for y as byte in range(chunk_size):
			building = false
			for z as byte in range(chunk_size):
				block = blocks[x, y, z]
				if west_mask[y, z] and not building:
					# start new block					
					vertices.Push(Vector3(x, y+1, z))
					vertices.Push(Vector3(x, y, z))
					vertice_count += 2
					building = true
				if (not west_mask[y, z] and building) or (z == chunk_size - 1 and building):
					# finish old block
					if z == chunk_size - 1 and west_mask[y, z]:
						vertices.Push(Vector3(x, y, z+1))						
						vertices.Push(Vector3(x, y+1, z+1))
					else:
						vertices.Push(Vector3(x, y, z))
						vertices.Push(Vector3(x, y+1, z))
					vertice_count += 2
					triangles.Push(vertice_count-4)
					triangles.Push(vertice_count-3)
					triangles.Push(vertice_count-2)
					triangles.Push(vertice_count-2)
					triangles.Push(vertice_count-1)
					triangles.Push(vertice_count-4)
					normals.Push(Vector3(1, 0, 0))
					normals.Push(Vector3(1, 0, 0))
					normals.Push(Vector3(1, 0, 0))
					normals.Push(Vector3(1, 0, 0))
					_add_uvs(0.6, 0)
					#_add_uvs(Blocks.block_def[block].uv_x, Blocks.block_def[block].uv_y)
					building = false

			building = false
			for z as byte in range(chunk_size):
				block = blocks[x, y, z]
				if east_mask[y, z] and not building:
					# start new block
					vertices.Push(Vector3(x+1, y, z))
					vertices.Push(Vector3(x+1, y+1, z))					
					vertice_count += 2
					building = true
				if (not east_mask[y, z] and building) or (z == chunk_size - 1 and building):
					# finish old block
					if z == chunk_size - 1 and east_mask[y, x]:
						vertices.Push(Vector3(x+1, y+1, z+1))
						vertices.Push(Vector3(x+1, y, z+1))						
					else:
						vertices.Push(Vector3(x+1, y+1, z))
						vertices.Push(Vector3(x+1, y, z))
					vertice_count += 2
					triangles.Push(vertice_count-4)
					triangles.Push(vertice_count-3)
					triangles.Push(vertice_count-2)
					triangles.Push(vertice_count-2)
					triangles.Push(vertice_count-1)
					triangles.Push(vertice_count-4)
					normals.Push(Vector3(-1, 0, 0))
					normals.Push(Vector3(-1, 0, 0))
					normals.Push(Vector3(-1, 0, 0))
					normals.Push(Vector3(-1, 0, 0))
					_add_uvs(0.6, 0)					
					#_add_uvs(Blocks.block_def[block].uv_x, Blocks.block_def[block].uv_y)
					building = false


	# do the north and south pass
	#vertice_count = 0
	for z as byte in range(chunk_size):
		north_mask = matrix(bool, chunk_size, chunk_size)
		south_mask = matrix(bool, chunk_size, chunk_size)
		
		for y as byte in range(chunk_size):
			for x as byte in range(chunk_size):
				block = blocks[x, y, z]
				if z == 0:
					block_south = BLOCK.AIR
				else:
					block_south = blocks[x, y, z-1]
				if z == chunk_size - 1:
					block_north = BLOCK.AIR
				else:
					block_north = blocks[x, y, z+1]
				
				if block and not block_north:
					north_mask[y, x] = true
				else:
					north_mask[y, x] = false
				if block and not block_south:
					south_mask[y, x] = true
				else:
					south_mask[y, x] = false

					
		for y as byte in range(chunk_size):
			building = false
			for x as byte in range(chunk_size):
				block = blocks[x, y, z]
				if south_mask[y, x] and not building:
					# start new block
					vertices.Push(Vector3(x, y, z))
					vertices.Push(Vector3(x, y+1, z))
					vertice_count += 2
					building = true
				if (not south_mask[y, x] and building) or (x == chunk_size - 1 and building):
					# finish old block
					if x == chunk_size - 1 and south_mask[y, x]:
						vertices.Push(Vector3(x+1, y+1, z))
						vertices.Push(Vector3(x+1, y, z))
					else:
						vertices.Push(Vector3(x, y+1, z))
						vertices.Push(Vector3(x, y, z))
					vertice_count += 2
					triangles.Push(vertice_count-4)
					triangles.Push(vertice_count-3)
					triangles.Push(vertice_count-2)
					triangles.Push(vertice_count-2)
					triangles.Push(vertice_count-1)
					triangles.Push(vertice_count-4)
					normals.Push(Vector3(0, 0, -1))
					normals.Push(Vector3(0, 0, -1))
					normals.Push(Vector3(0, 0, -1))
					normals.Push(Vector3(0, 0, -1))
					_add_uvs(0.6, 0)
					#_add_uvs(Blocks.block_def[block].uv_x, Blocks.block_def[block].uv_y)
					building = false

			building = false
			for x as byte in range(chunk_size):
				block = blocks[x, y, z]
				if north_mask[y, x] and not building:
					# start new block
					vertices.Push(Vector3(x, y+1, z+1))
					vertices.Push(Vector3(x, y, z+1))				
					vertice_count += 2
					building = true
				if (not north_mask[y, x] and building) or (x == chunk_size - 1 and building):
					# finish old block
					if x == chunk_size - 1 and north_mask[y, x]:
						vertices.Push(Vector3(x+1, y, z+1))						
						vertices.Push(Vector3(x+1, y+1, z+1))
					else:
						vertices.Push(Vector3(x, y, z+1))
						vertices.Push(Vector3(x, y+1, z+1))
					vertice_count += 2
					triangles.Push(vertice_count-4)
					triangles.Push(vertice_count-3)
					triangles.Push(vertice_count-2)
					triangles.Push(vertice_count-2)
					triangles.Push(vertice_count-1)
					triangles.Push(vertice_count-4)
					normals.Push(Vector3(0, 0, 1))
					normals.Push(Vector3(0, 0, 1))
					normals.Push(Vector3(0, 0, 1))
					normals.Push(Vector3(0, 0, 1))
					_add_uvs(0.6, 0)					
					#_add_uvs(Blocks.block_def[block].uv_x, Blocks.block_def[block].uv_y)
					building = false					



	# do the up and down pass
	#vertice_count = 0
	for y as byte in range(chunk_size):
		up_mask = matrix(bool, chunk_size, chunk_size)
		down_mask = matrix(bool, chunk_size, chunk_size)
		
		for x as byte in range(chunk_size):
			for z as byte in range(chunk_size):
				block = blocks[x, y, z]
				if y == 0:
					block_down = BLOCK.AIR
				else:
					block_down = blocks[x, y-1, z]
				if y == chunk_size - 1:
					block_up = BLOCK.AIR
				else:
					block_up = blocks[x, y+1, z]
				
				if block and not block_down:
					up_mask[x, z] = true
				else:
					up_mask[x, z] = false
				if block and not block_up:
					down_mask[x, z] = true
				else:
					down_mask[x, z] = false

					
		for x as byte in range(chunk_size):
			building = false
			for z as byte in range(chunk_size):
				block = blocks[x, y, z]
				if down_mask[x, z] and not building:
					# start new block
					vertices.Push(Vector3(x+1, y+1, z))
					vertices.Push(Vector3(x, y+1, z))					
					vertice_count += 2
					building = true
				if (not down_mask[x, z] and building) or (z == chunk_size - 1 and building):
					# finish old block
					if z == chunk_size - 1 and down_mask[x, z]:
						vertices.Push(Vector3(x, y+1, z+1))
						vertices.Push(Vector3(x+1, y+1, z+1))
					else:
						vertices.Push(Vector3(x, y+1, z))
						vertices.Push(Vector3(x+1, y+1, z))
					vertice_count += 2
					triangles.Push(vertice_count-4)
					triangles.Push(vertice_count-3)
					triangles.Push(vertice_count-2)
					triangles.Push(vertice_count-2)
					triangles.Push(vertice_count-1)
					triangles.Push(vertice_count-4)
					normals.Push(Vector3(0, 1, 0))
					normals.Push(Vector3(0, 1, 0))
					normals.Push(Vector3(0, 1, 0))
					normals.Push(Vector3(0, 1, 0))
					_add_uvs(0.6, 0)					
					#_add_uvs(Blocks.block_def[block].uv_x, Blocks.block_def[block].uv_y)
					building = false

		for x as byte in range(chunk_size):
			building = false
			for z as byte in range(chunk_size):
				block = blocks[x, y, z]
				if up_mask[x, z] and not building:
					# start new block
					vertices.Push(Vector3(x, y, z))
					vertices.Push(Vector3(x+1, y, z))					
					vertice_count += 2
					building = true
				if (not up_mask[x, z] and building) or (z == chunk_size - 1 and building):
					# finish old block
					if z == chunk_size - 1 and up_mask[x, z]:
						vertices.Push(Vector3(x+1, y, z+1))
						vertices.Push(Vector3(x, y, z+1))
					else:
						vertices.Push(Vector3(x+1, y, z))
						vertices.Push(Vector3(x, y, z))					
						

					vertice_count += 2
					triangles.Push(vertice_count-4)
					triangles.Push(vertice_count-3)
					triangles.Push(vertice_count-2)
					triangles.Push(vertice_count-2)
					triangles.Push(vertice_count-1)
					triangles.Push(vertice_count-4)
					normals.Push(Vector3(0, -1, 0))
					normals.Push(Vector3(0, -1, 0))
					normals.Push(Vector3(0, -1, 0))
					normals.Push(Vector3(0, -1, 0))
					_add_uvs(0.6, 0)					
					#_add_uvs(Blocks.block_def[block].uv_x, Blocks.block_def[block].uv_y)
					building = false
					


					
					
				
	# print "Vert LEN: $(len(vertices))"
	# print "Uvs LEN: $(len(uvs))"
	# print "Normals LEN: $(len(normals))"		
	m = MeshData2(uvs.ToArray(),
				  vertices.ToArray(),
				  normals.ToArray(),
				  triangles.ToArray())
	return m
					
				
