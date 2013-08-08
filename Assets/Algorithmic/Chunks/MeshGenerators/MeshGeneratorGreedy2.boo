namespace Algorithmic.Chunks

def generateMeshGreedy2(chunk as Chunk,
						neighbors as System.Collections.Generic.Dictionary[of ChunkCoordinate, Chunk],
						water as bool) as MeshData:
	blocks = chunk.Blocks
	chunk_size = Settings.Chunks.Size
	vertices = List[of Vector3]()
	uvs = List[of Vector2]()
	normals = List[of Vector3]()
	triangles = List[of int]()
	lights = List[of Color]()

	def _add_uvs(x as single, y as single):
		# give x, y coordinates in (0-9) by (0-9)
		uvs.Push(Vector2(x + 0.01, 1.0 - y - 0.1 + 0.01))
		uvs.Push(Vector2(x + 0.01, 1.0 - y - 0.01))
		uvs.Push(Vector2(x - 0.01 + 0.1, 1.0 - y - 0.01))
		uvs.Push(Vector2(x - 0.01 + 0.1, 1.0 - y - 0.1 + 0.01))

	coords = chunk.getCoords()
	# offset = Settings.Chunks.Size * Settings.Chunks.Scale
	offset = 1
	w = ChunkCoordinate(coords.x - offset, coords.y, coords.z)
	e = ChunkCoordinate(coords.x + offset, coords.y, coords.z)
	n = ChunkCoordinate(coords.x, coords.y, coords.z + offset)
	s = ChunkCoordinate(coords.x, coords.y, coords.z - offset)
	u = ChunkCoordinate(coords.x, coords.y + offset, coords.z)
	d = ChunkCoordinate(coords.x, coords.y - offset, coords.z)
	n_w = neighbors[w]
	n_e = neighbors[e]
	n_n = neighbors[n]
	n_s = neighbors[s]
	n_u = neighbors[u]
	n_d = neighbors[d]



	# do the west and east pass
	vertice_count = 0
	for x as byte in range(chunk_size):
		west_mask = matrix(bool, chunk_size, chunk_size)
		east_mask = matrix(bool, chunk_size, chunk_size)
		for y as byte in range(chunk_size):
			for z as byte in range(chunk_size):
				block = blocks[x, y, z]
				if x == 0:
					block_west = n_w.getBlock(chunk_size-1, y, z)					
					#block_west = BLOCK.AIR
				else:
					block_west = blocks[x - 1, y, z]
				if x == chunk_size - 1:
					block_east = n_e.getBlock(0, y, z)					
					#block_east = BLOCK.AIR
				else:
					block_east = blocks[x + 1, y, z]

				if not water:
					if block != 0 and block != 200 and not block_west:
						west_mask[y, z] = true
					else:
						west_mask[y, z] = false
					if block != 0 and block != 200 and not block_east:
						east_mask[y, z] = true
					else:
						east_mask[y, z] = false
				else:
					if block == 200 and block_west != 200:
						west_mask[y, z] = true
					else:
						west_mask[y, z] = false
					if block == 200 and block_east != 200:
						east_mask[y, z] = true
					else:
						east_mask[y, z] = false
					

		for y as byte in range(chunk_size):
			building = false
			for z as byte in range(chunk_size):
				if west_mask[y, z] and not building:
					building = true
					i = z
				if (not west_mask[y, z] and building) or (z == chunk_size-1 and building):
					if (not west_mask[y, z] and building):
						j = z - 1
					else:
						j = z
					building = false
					done = false
					h = 1
					for y2 in range(y+1, chunk_size):
						for z2 in range(i, j+1):
							if not west_mask[y2, z2]:
								done = true
								break
						if done:
							break
						h += 1
					# y = starting height
					# y + h = ending hight
					# i = starting width
					# j = ending width
					vertices.Push(Vector3(x, y+h, i))					
					vertices.Push(Vector3(x, y, i))
					vertices.Push(Vector3(x, y, j+1))
					vertices.Push(Vector3(x, y+h, j+1))					
					vertice_count += 4
					triangles.Push(vertice_count-4)
					triangles.Push(vertice_count-3)
					triangles.Push(vertice_count-2)
					triangles.Push(vertice_count-2)
					triangles.Push(vertice_count-1)
					triangles.Push(vertice_count-4)
					# normals.Push(Vector3(1, 0, 0))
					# normals.Push(Vector3(1, 0, 0))
					# normals.Push(Vector3(1, 0, 0))
					# normals.Push(Vector3(1, 0, 0))
					# _add_uvs(0.6, 0)


					for y3 in range(y, h+y):
						for z3 in range(i, j+1):
							west_mask[y3, z3] = false

							
		for y as byte in range(chunk_size):
			building = false
			for z as byte in range(chunk_size):
				if east_mask[y, z] and not building:
					building = true
					i = z
				if (not east_mask[y, z] and building) or (z == chunk_size-1 and building):
					if (not east_mask[y, z] and building):
						j = z - 1
					else:
						j = z
					building = false
					done = false
					h = 1
					for y2 in range(y+1, chunk_size):
						for z2 in range(i, j+1):
							if not east_mask[y2, z2]:
								done = true
								break
						if done:
							break
						h += 1
					# y = starting height
					# y + h = ending hight
					# i = starting width
					# j = ending width
					vertices.Push(Vector3(x+1, y+h, j+1))
					vertices.Push(Vector3(x+1, y, j+1))					
					vertices.Push(Vector3(x+1, y, i))
					vertices.Push(Vector3(x+1, y+h, i))										


					vertice_count += 4
					triangles.Push(vertice_count-4)
					triangles.Push(vertice_count-3)
					triangles.Push(vertice_count-2)
					triangles.Push(vertice_count-2)
					triangles.Push(vertice_count-1)
					triangles.Push(vertice_count-4)
					# normals.Push(Vector3(-1, 0, 0))
					# normals.Push(Vector3(-1, 0, 0))
					# normals.Push(Vector3(-1, 0, 0))
					# normals.Push(Vector3(-1, 0, 0))
					# _add_uvs(0.6, 0)


					for y3 in range(y, h+y):
						for z3 in range(i, j+1):
							east_mask[y3, z3] = false

	# do the north and south pass
	#vertice_count = 0
	for z as byte in range(chunk_size):
		north_mask = matrix(bool, chunk_size, chunk_size)
		south_mask = matrix(bool, chunk_size, chunk_size)
		
		for y as byte in range(chunk_size):
			for x as byte in range(chunk_size):
				block = blocks[x, y, z]
				if z == 0:
					block_south = n_s.getBlock(x, y, chunk_size-1)					
					#block_south = BLOCK.AIR
				else:
					block_south = blocks[x, y, z-1]
				if z == chunk_size - 1:
					block_north = n_n.getBlock(x, y, 0)					
					#block_north = BLOCK.AIR
				else:
					block_north = blocks[x, y, z+1]

				if not water:
					if block != 0 and block != 200 and not block_north:
						north_mask[y, x] = true
					else:
						north_mask[y, x] = false
					if block != 0 and block != 200 and not block_south:
						south_mask[y, x] = true
					else:
						south_mask[y, x] = false
				else:
					if block == 200 and block_north != 200:
						north_mask[y, x] = true
					else:
						north_mask[y, x] = false
					if block == 200 and block_south != 200:
						south_mask[y, x] = true
					else:
						south_mask[y, x] = false
					
					
		for y as byte in range(chunk_size):
			building = false
			for x as byte in range(chunk_size):
				if south_mask[y, x] and not building:
					building = true
					i = x
				if (not south_mask[y, x] and building) or (x == chunk_size-1 and building):
					if (not south_mask[y, x] and building):
						j = x - 1
					else:
						j = x
					building = false
					done = false
					h = 1
					for y2 in range(y+1, chunk_size):
						for x2 in range(i, j+1):
							if not south_mask[y2, x2]:
								done = true
								break
						if done:
							break
						h += 1
					# y = starting height
					# y + h = ending hight
					# i = starting width
					# j = ending width
					vertices.Push(Vector3(j+1, y+h, z))
					vertices.Push(Vector3(j+1, y, z))					
					vertices.Push(Vector3(i, y, z))
					vertices.Push(Vector3(i, y+h, z))

					vertice_count += 4
					triangles.Push(vertice_count-4)
					triangles.Push(vertice_count-3)
					triangles.Push(vertice_count-2)
					triangles.Push(vertice_count-2)
					triangles.Push(vertice_count-1)
					triangles.Push(vertice_count-4)
					# normals.Push(Vector3(0, 0, -1))
					# normals.Push(Vector3(0, 0, -1))
					# normals.Push(Vector3(0, 0, -1))
					# normals.Push(Vector3(0, 0, -1))
					# _add_uvs(0.6, 0)


					for y3 in range(y, h+y):
						for x3 in range(i, j+1):
							south_mask[y3, x3] = false

		for y as byte in range(chunk_size):
			building = false
			for x as byte in range(chunk_size):
				if north_mask[y, x] and not building:
					building = true
					i = x
				if (not north_mask[y, x] and building) or (x == chunk_size-1 and building):
					if (not north_mask[y, x] and building):
						j = x - 1
					else:
						j = x
					building = false
					done = false
					h = 1
					for y2 in range(y+1, chunk_size):
						for x2 in range(i, j+1):
							if not north_mask[y2, x2]:
								done = true
								break
						if done:
							break
						h += 1
					# y = starting height
					# y + h = ending hight
					# i = starting width
					# j = ending width

					vertices.Push(Vector3(j+1, y, z+1))
					vertices.Push(Vector3(j+1, y+h, z+1))					
					vertices.Push(Vector3(i, y+h, z+1))
					vertices.Push(Vector3(i, y, z+1))					

					vertice_count += 4
					triangles.Push(vertice_count-4)
					triangles.Push(vertice_count-3)
					triangles.Push(vertice_count-2)
					triangles.Push(vertice_count-2)
					triangles.Push(vertice_count-1)
					triangles.Push(vertice_count-4)
					# normals.Push(Vector3(0, 0, 1))
					# normals.Push(Vector3(0, 0, 1))
					# normals.Push(Vector3(0, 0, 1))
					# normals.Push(Vector3(0, 0, 1))
					# _add_uvs(0.6, 0)


					for y3 in range(y, h+y):
						for x3 in range(i, j+1):
							north_mask[y3, x3] = false
							
	# do the up and down pass
	#vertice_count = 0
	for y as byte in range(chunk_size):
		up_mask = matrix(bool, chunk_size, chunk_size)
		down_mask = matrix(bool, chunk_size, chunk_size)
		
		for x as byte in range(chunk_size):
			for z as byte in range(chunk_size):
				block = blocks[x, y, z]
				if y == 0:
					block_down = n_d.getBlock(x, chunk_size-1, z)
					#block_down = BLOCK.AIR
				else:
					block_down = blocks[x, y-1, z]
				if y == chunk_size - 1:
					block_up = n_u.getBlock(x, 0, z)
					#block_up = BLOCK.AIR
				else:
					block_up = blocks[x, y+1, z]

				if not water:
					if block != 0 and block != 200 and not block_down:
						up_mask[x, z] = true
					else:
						up_mask[x, z] = false
					if block != 0 and block != 200 and not block_up:
						down_mask[x, z] = true
					else:
						down_mask[x, z] = false
				else:
					if block == 200 and block_down != 200:
						up_mask[x, z] = true
					else:
						up_mask[x, z] = false
					if block == 200 and block_up != 200:
						down_mask[x, z] = true
					else:
						down_mask[x, z] = false
					

		for x as byte in range(chunk_size):
			building = false
			for z as byte in range(chunk_size):
				if down_mask[x, z] and not building:
					building = true
					i = z
				if (not down_mask[x, z] and building) or (z == chunk_size-1 and building):
					if (not down_mask[x, z] and building):
						j = z - 1
					else:
						j = z
					building = false
					done = false
					h = 1
					for x2 in range(x+1, chunk_size):
						for z2 in range(i, j+1):
							if not down_mask[x2, z2]:
								done = true
								break
						if done:
							break
						h += 1
					# y = starting height
					# y + h = ending hight
					# i = starting width
					# j = ending width
					vertices.Push(Vector3(x+h, y+1, i))
					vertices.Push(Vector3(x, y+1, i))
					vertices.Push(Vector3(x, y+1, j+1))
					vertices.Push(Vector3(x+h, y+1, j+1))

					vertice_count += 4
					triangles.Push(vertice_count-4)
					triangles.Push(vertice_count-3)
					triangles.Push(vertice_count-2)
					triangles.Push(vertice_count-2)
					triangles.Push(vertice_count-1)
					triangles.Push(vertice_count-4)
					# normals.Push(Vector3(0, 1, 0))
					# normals.Push(Vector3(0, 1, 0))
					# normals.Push(Vector3(0, 1, 0))
					# normals.Push(Vector3(0, 1, 0))
					# _add_uvs(0.6, 0)

					for x3 in range(x, x+h):
						for z3 in range(i, j+1):
							down_mask[x3, z3] = false

		for x as byte in range(chunk_size):
			building = false
			for z as byte in range(chunk_size):
				if up_mask[x, z] and not building:
					building = true
					i = z
				if (not up_mask[x, z] and building) or (z == chunk_size-1 and building):
					if (not up_mask[x, z] and building):
						j = z - 1
					else:
						j = z
					building = false
					done = false
					h = 1
					for x2 in range(x+1, chunk_size):
						for z2 in range(i, j+1):
							if not up_mask[x2, z2]:
								done = true
								break
						if done:
							break
						h += 1
					# y = starting height
					# y + h = ending hight
					# i = starting width
					# j = ending width
					vertices.Push(Vector3(x+h, y, j+1))						
					vertices.Push(Vector3(x, y, j+1))
					vertices.Push(Vector3(x, y, i))
					vertices.Push(Vector3(x+h, y, i))

					vertice_count += 4
					triangles.Push(vertice_count-4)
					triangles.Push(vertice_count-3)
					triangles.Push(vertice_count-2)
					triangles.Push(vertice_count-2)
					triangles.Push(vertice_count-1)
					triangles.Push(vertice_count-4)
					# normals.Push(Vector3(0, -1, 0))
					# normals.Push(Vector3(0, -1, 0))
					# normals.Push(Vector3(0, -1, 0))
					# normals.Push(Vector3(0, -1, 0))
					# _add_uvs(0.6, 0)

					for x3 in range(x, x+h):
						for z3 in range(i, j+1):
							up_mask[x3, z3] = false
							
					
							
							

			
	m = MeshData(uvs.ToArray(),
				 vertices.ToArray(),
				 normals.ToArray(),
				 triangles.ToArray(),
				 lights.ToArray())
	return m

	
