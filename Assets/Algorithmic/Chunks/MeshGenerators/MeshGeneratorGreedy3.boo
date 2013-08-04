namespace Algorithmic.Chunks

def generateMeshGreedy3(chunk as Chunk,
						neighbors as System.Collections.Generic.List[of Chunk],
						include_water as bool) as MeshData:

	blocks = chunk.Blocks
	chunk_size = Settings.Chunks.Size
	vertices = List[of Vector3]()
	uvs = List[of Vector2]()
	normals = List[of Vector3]()
	triangles = List[of int]()
	lights = List[of Color]()

	n_b_e = neighbors[0].getBlock

	def _add_uvs(x as single, y as single):
		# give x, y coordinates in (0-9) by (0-9)
		uvs.Push(Vector2(x + 0.01, 1.0 - y - 0.1 + 0.01))
		uvs.Push(Vector2(x + 0.01, 1.0 - y - 0.01))
		uvs.Push(Vector2(x - 0.01 + 0.1, 1.0 - y - 0.01))
		uvs.Push(Vector2(x - 0.01 + 0.1, 1.0 - y - 0.1 + 0.01))

	# do the west and east pass
	vertice_count = 0
	for x as byte in range(chunk_size):
		west_mask = matrix(byte, chunk_size, chunk_size)
		east_mask = matrix(byte, chunk_size, chunk_size)
		for y as byte in range(chunk_size):
			for z as byte in range(chunk_size):
				block = blocks[x, y, z]
				if x == 0:
					block_west = neighbors[1].getBlock(chunk_size-1, y, z)
					# block_west = BLOCK.AIR
				else:
					block_west = blocks[x - 1, y, z]
				if x == chunk_size - 1:
					block_east = neighbors[0].getBlock(0, y, z)
					# block_east = BLOCK.AIR
				else:
					block_east = blocks[x + 1, y, z]
				
				if block and not block_west:
					west_mask[y, z] = block
				else:
					west_mask[y, z] = 0
				if block and not block_east:
					east_mask[y, z] = block
				else:
					east_mask[y, z] = 0

		for y as byte in range(chunk_size):
			building = false
			mask_block = 0			
			for z as byte in range(chunk_size):
				:west_last_block
				if west_mask[y, z] and not building:
					building = true
					mask_block = west_mask[y, z]
					i = z

				# if (west_mask[y, z] != mask_block and building):
				# 	pass
				# elif (z == chunk_size - 1 and building):
				# 	if west_mask[y, z] != mask_block:
				# 		pass
				# 	else:
				# 		pass

					
					
				if (west_mask[y, z] != mask_block and building) or (z == chunk_size-1 and building):
					if (west_mask[y, z] != mask_block and building) and west_mask[y, z]:
						j = z - 1
					elif (z == chunk_size-1 and building and west_mask[y, z]):
						j = z
					else:
						j = z - 1
						
					building = false
					done = false
					h = 1
					for y2 in range(y+1, chunk_size):
						for z2 in range(i, j+1):
							if west_mask[y2, z2] != mask_block:
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
					normals.Push(Vector3(1, 0, 0))
					normals.Push(Vector3(1, 0, 0))
					normals.Push(Vector3(1, 0, 0))
					normals.Push(Vector3(1, 0, 0))
					_add_uvs(Blocks.block_def[mask_block].uv_x, Blocks.block_def[mask_block].uv_y)


					for y3 in range(y, h+y):
						for z3 in range(i, j+1):
							west_mask[y3, z3] = 0

					if west_mask[y, z]:
						goto west_last_block
						# building = true
						# mask_block = west_mask[y, z]
						# i = z


							
		for y as byte in range(chunk_size):
			building = false
			mask_block = 0
			for z as byte in range(chunk_size):
				:east_last_block
				if east_mask[y, z] and not building:
					building = true
					mask_block = east_mask[y, z]
					i = z
				if (east_mask[y, z] != mask_block and building) or (z == chunk_size-1 and building):
					if (east_mask[y, z] != mask_block and building) and east_mask[y, z]:
						j = z - 1
					elif (z == chunk_size - 1 and building and east_mask[y, z]):
						j = z
					else:
						j = z - 1
					building = false
					done = false
					h = 1
					for y2 in range(y+1, chunk_size):
						for z2 in range(i, j+1):
							if east_mask[y2, z2] != mask_block:
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
					normals.Push(Vector3(-1, 0, 0))
					normals.Push(Vector3(-1, 0, 0))
					normals.Push(Vector3(-1, 0, 0))
					normals.Push(Vector3(-1, 0, 0))
					_add_uvs(Blocks.block_def[mask_block].uv_x, Blocks.block_def[mask_block].uv_y)					
					#_add_uvs(0.6, 0)


					for y3 in range(y, h+y):
						for z3 in range(i, j+1):
							east_mask[y3, z3] = 0

					if east_mask[y, z]:
						goto east_last_block
						# building = true
						# mask_block = east_mask[y, z]
						# i = z
							

	# do the north and south pass
	#vertice_count = 0
	for z as byte in range(chunk_size):
		north_mask = matrix(byte, chunk_size, chunk_size)
		south_mask = matrix(byte, chunk_size, chunk_size)
		
		for y as byte in range(chunk_size):
			for x as byte in range(chunk_size):
				block = blocks[x, y, z]
				if z == 0:
					block_south = neighbors[3].getBlock(x, y, chunk_size-1)
					#block_south = BLOCK.AIR
				else:
					block_south = blocks[x, y, z-1]
				if z == chunk_size - 1:
					block_north = neighbors[2].getBlock(x, y, 0)
					#block_north = BLOCK.AIR
				else:
					block_north = blocks[x, y, z+1]
				
				if block and not block_north:
					north_mask[y, x] = block
				else:
					north_mask[y, x] = 0
				if block and not block_south:
					south_mask[y, x] = block
				else:
					south_mask[y, x] = 0
					
		for y as byte in range(chunk_size):
			building = false
			mask_block = 0
			for x as byte in range(chunk_size):
				:south_last_block
				if south_mask[y, x] and not building:
					building = true
					mask_block = south_mask[y, x]
					i = x
				if (south_mask[y, x] != mask_block and building) or (x == chunk_size-1 and building):
					if (south_mask[y, x] != mask_block and building) and south_mask[y, x]:
						j = x - 1
					elif (x == chunk_size - 1 and building and south_mask[y, x]):
						j = x
					else:
						j = x - 1
					building = false
					done = false
					h = 1
					for y2 in range(y+1, chunk_size):
						for x2 in range(i, j+1):
							if south_mask[y2, x2] != mask_block:
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
					normals.Push(Vector3(0, 0, -1))
					normals.Push(Vector3(0, 0, -1))
					normals.Push(Vector3(0, 0, -1))
					normals.Push(Vector3(0, 0, -1))
					_add_uvs(Blocks.block_def[mask_block].uv_x, Blocks.block_def[mask_block].uv_y)
					#_add_uvs(0.6, 0)


					for y3 in range(y, h+y):
						for x3 in range(i, j+1):
							south_mask[y3, x3] = 0

					if south_mask[y, x]:
						goto south_last_block
						# building = true
						# mask_block = south_mask[y, x]
						# i = x
							

		for y as byte in range(chunk_size):
			building = false
			mask_block = 0
			for x as byte in range(chunk_size):
				:north_last_block
				if north_mask[y, x] and not building:
					building = true
					mask_block = north_mask[y, x]
					i = x
				if (north_mask[y, x] != mask_block and building) or (x == chunk_size-1 and building):
					if (north_mask[y, x] != mask_block and building) and north_mask[y, z]:
						j = x - 1
					elif (x == chunk_size - 1 and building and north_mask[y, x]):
						j = x
					else:
						j = x - 1
					building = false
					done = false
					h = 1
					for y2 in range(y+1, chunk_size):
						for x2 in range(i, j+1):
							if north_mask[y2, x2] != mask_block:
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
					normals.Push(Vector3(0, 0, 1))
					normals.Push(Vector3(0, 0, 1))
					normals.Push(Vector3(0, 0, 1))
					normals.Push(Vector3(0, 0, 1))
					_add_uvs(Blocks.block_def[mask_block].uv_x, Blocks.block_def[mask_block].uv_y)					
					#_add_uvs(0.6, 0)


					for y3 in range(y, h+y):
						for x3 in range(i, j+1):
							north_mask[y3, x3] = 0

					if north_mask[y, x]:
						goto north_last_block
						# building = true
						# mask_block = north_mask[y, x]
						# i = x
							
							
	# do the up and down pass
	#vertice_count = 0
	for y as byte in range(chunk_size):
		up_mask = matrix(byte, chunk_size, chunk_size)
		down_mask = matrix(byte, chunk_size, chunk_size)
		
		for x as byte in range(chunk_size):
			for z as byte in range(chunk_size):
				block = blocks[x, y, z]
				if y == 0:
					block_down = neighbors[5].getBlock(x, chunk_size-1, z)
					#block_down = BLOCK.AIR
				else:
					block_down = blocks[x, y-1, z]
				if y == chunk_size - 1:
					block_up = neighbors[4].getBlock(x, 0, z)					
					#block_up = BLOCK.AIR
				else:
					block_up = blocks[x, y+1, z]
				
				if block and not block_down:
					up_mask[x, z] = block
				else:
					up_mask[x, z] = 0
				if block and not block_up:
					down_mask[x, z] = block
				else:
					down_mask[x, z] = 0

		for x as byte in range(chunk_size):
			building = false
			mask_block = 0
			for z as byte in range(chunk_size):
				:down_last_block
				if down_mask[x, z] and not building:
					building = true
					mask_block = down_mask[x, z]
					i = z
				if (down_mask[x, z] != mask_block and building) or (z == chunk_size-1 and building):
					if (down_mask[x, z] != mask_block and building) and down_mask[x, z]:
						j = z - 1
					elif (z == chunk_size-1 and building) and down_mask[x, z]:
						j = z
					else:
						j = z - 1
						
					building = false
					done = false
					h = 1
					for x2 in range(x+1, chunk_size):
						for z2 in range(i, j+1):
							if down_mask[x2, z2] != mask_block:
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
					normals.Push(Vector3(0, 1, 0))
					normals.Push(Vector3(0, 1, 0))
					normals.Push(Vector3(0, 1, 0))
					normals.Push(Vector3(0, 1, 0))
					_add_uvs(Blocks.block_def[mask_block].uv_x, Blocks.block_def[mask_block].uv_y)					
					#_add_uvs(0.6, 0)

					for x3 in range(x, x+h):
						for z3 in range(i, j+1):
							down_mask[x3, z3] = 0

					if down_mask[x, z]:
						goto down_last_block
						

		for x as byte in range(chunk_size):
			building = false
			mask_block = 0
			for z as byte in range(chunk_size):
				:up_last_block
				if up_mask[x, z] and not building:
					building = true
					mask_block = up_mask[x, z]
					i = z
				if (up_mask[x, z] != mask_block and building) or (z == chunk_size-1 and building):
					if (up_mask[x, z] != mask_block and building) and up_mask[x, z]:
						j = z - 1
					elif (z == chunk_size - 1 and building and up_mask[x, z]):
						j = z
					else:
						j = z - 1
					building = false
					done = false
					h = 1
					for x2 in range(x+1, chunk_size):
						for z2 in range(i, j+1):
							if up_mask[x2, z2] != mask_block:
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
					normals.Push(Vector3(0, -1, 0))
					normals.Push(Vector3(0, -1, 0))
					normals.Push(Vector3(0, -1, 0))
					normals.Push(Vector3(0, -1, 0))
					_add_uvs(Blocks.block_def[mask_block].uv_x, Blocks.block_def[mask_block].uv_y)					
					#_add_uvs(0.6, 0)

					for x3 in range(x, x+h):
						for z3 in range(i, j+1):
							up_mask[x3, z3] = 0
					if up_mask[x, z]:
						goto up_last_block
						# building = true
						# mask_block = up_mask[x, z]
						# i = z
							
					
							
							

			
	m = MeshData(uvs.ToArray(),
				 vertices.ToArray(),
				 normals.ToArray(),
				 triangles.ToArray(),
				 lights.ToArray())
	return m

	
