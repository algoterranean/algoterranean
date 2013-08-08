namespace Algorithmic.Chunks
import System.Collections.Generic
import Algorithmic

# "naive" method for generating a mesh. this will generate 2 triangles (1 square)
# for each face on a block where there is AIR in the direction of that face.
# this algorithm will take into account the neighboring chunks for efficiency purposes.
def generateMesh(chunk as Chunk,
				 neighbors as Dictionary[of ChunkCoordinate, Chunk],
				 water as bool) as MeshData:

	blocks = chunk.Blocks
	block_lights = chunk.Lights
	chunk_size = Settings.Chunks.Size #len(blocks, 0)
	vertice_size = 0
	triangle_size = 0
	uv_size = 0
	aabb_size = 0


	# use Lists so that we can dynamically add items to them efficiently
	vertices = List[of Vector3]()
	uvs = List[of Vector2]()
	normals = List[of Vector3]()
	triangles = List[of int]()
	lights = List[of Color]()
	vertice_count = 0
	
	# local convenience functions to handle UVs, Triangles, and Normals
	def _add_uvs(x as single, y as single):
		# give x, y coordinates in (0-9) by (0-9)
		uvs.Add(Vector2(x + 0.01, 1.0 - y - 0.1 + 0.01))
		uvs.Add(Vector2(x + 0.01, 1.0 - y - 0.01))
		uvs.Add(Vector2(x - 0.01 + 0.1, 1.0 - y - 0.01))
		uvs.Add(Vector2(x - 0.01 + 0.1, 1.0 - y - 0.1 + 0.01))
		
		# for v as Vector2 in [Vector2(x + 0.01, 1.0 - y - 0.1 + 0.01),
		# 					 Vector2(x + 0.01, 1.0 - y - 0.01),
		# 					 Vector2(x - 0.01 + 0.1, 1.0 - y - 0.01),
		# 					 Vector2(x - 0.01 + 0.1, 1.0 - y - 0.1 + 0.01)]:
		# 	uvs.Add(v)
							 
	def _add_triangles():
		# clockwise order
		triangles.Add(vertice_count - 4)
		triangles.Add(vertice_count - 3)
		triangles.Add(vertice_count - 2)
		triangles.Add(vertice_count - 2)
		triangles.Add(vertice_count - 1)
		triangles.Add(vertice_count - 4)		
		# for i as int in [4, 3, 2, 2, 1, 4]:
		# 	triangles.Add(vertice_count - i)

	def _add_normals(n as Vector3):
		# normals for the 4 corners of a square always
		# point in the same direction
		normals.Add(n)
		normals.Add(n)
		normals.Add(n)
		normals.Add(n)		
		# for i in range(4):
		# 	normals.Add(n)

	# a   b | b   c | c   d |
	#   A   |   B   |   C   |
	# e   f | f   g | g   h |
	#   D   |   E   |   F   |
	# i   j | j   k | k   l |
	#   G   |   H   |   I   |
	# m   n | n   o | o   p |




	def _add_east_west_lights(x as byte, y as byte, z as byte, direction as string, color as Color):
		light_chunk = ChunkCoordinate(0, 0, 0)
		coords = chunk.getCoords()
		scale = Settings.Chunks.Scale
		# offset as int = chunk_size * scale
		offset = 1

		# if everything fits within this block, use the linear method
		if x > 0 and x < chunk_size - 1 and y > 0 and y < chunk_size - 1 and z > 0 and z < chunk_size - 1:
			if direction == 'WEST':
				x_offset = -1
			elif direction == 'EAST':
				x_offset = 1
				
			light_a = block_lights[x + x_offset, y + 1, z + 1]
			light_b = block_lights[x + x_offset, y + 1, z]
			light_c = block_lights[x + x_offset, y + 1, z - 1]
							 
			light_d = block_lights[x + x_offset, y, z + 1]
			light_e = block_lights[x + x_offset, y, z]
			light_f = block_lights[x + x_offset, y, z - 1]

			light_g = block_lights[x + x_offset, y-1, z + 1]
			light_h = block_lights[x + x_offset, y-1, z]
			light_i = block_lights[x + x_offset, y-1, z - 1]

		# something doesn't fit nearby so use the slow lookup of neighbors method
		# TO DO: create a look-up table for these neighborly blocks by reference
		# (32 x 32 x 6 = 6144)
		else:
			if direction == 'WEST':
				if x == 0:
					light_chunk.x = coords.x - offset
					l_x = chunk_size - 1
				else:
					light_chunk.x = coords.x
					l_x = x - 1
			elif direction == 'EAST':
				if x == chunk_size - 1:
					light_chunk.x = coords.x + offset
					l_x = 0
				else:
					light_chunk.x = coords.x
					l_x = x + 1

			# ROW 1

			if y == chunk_size - 1:
				light_chunk.y = coords.y + offset
				l_y = 0
			else:
				light_chunk.y = coords.y
				l_y = y + 1

			if z == 0:
				light_chunk.z = coords.z - offset
				l_z = chunk_size - 1
			else:
				light_chunk.z = coords.z
				l_z = z - 1

			light_chunk.UpdateHash()
			# print "LIGHT CHECK: $light_chunk, z: $z, local: $l_x, $l_y, $l_z, coords: $coords"
			# if direction == 'WEST':
			# 	light_a = neighbors[light_chunk].getLight(l_x, l_y, l_z)
			# else:
			light_c = neighbors[light_chunk].getLight(l_x, l_y, l_z)
				


			light_chunk.z = coords.z
			l_z = z
			light_chunk.UpdateHash()
			light_b = neighbors[light_chunk].getLight(l_x, l_y, l_z)


			if z == chunk_size - 1:
				light_chunk.z = coords.z + offset
				l_z = 0
			else:
				light_chunk.z = coords.z
				l_z = z + 1
			light_chunk.UpdateHash()
			# if direction == 'WEST':
			# 	light_c = neighbors[light_chunk].getLight(l_x, l_y, l_z)
			# else:
			light_a = neighbors[light_chunk].getLight(l_x, l_y, l_z)


			# ROW 2
			# light_chunk.z = coords.z
			# l_z = z
			light_chunk.y = coords.y
			l_y = y
			# if z == 0:
			# 	light_chunk.z = coords.z - offset
			# 	l_z = chunk_size - 1
			# else:
			# 	light_chunk.z = coords.z
			# 	l_z = z - 1

			light_chunk.UpdateHash()
			# if direction == 'WEST':
			# 	light_f = neighbors[light_chunk].getLight(l_x, l_y, l_z)
			# else:
			light_d = neighbors[light_chunk].getLight(l_x, l_y, l_z)

			light_chunk.z = coords.z
			l_z = z
			light_chunk.UpdateHash()
			light_e = neighbors[light_chunk].getLight(l_x, l_y, l_z)


			if z == 0:
				light_chunk.z = coords.z - offset
				l_z = chunk_size - 1
			else:
				light_chunk.z = coords.z
				l_z = z - 1
			light_chunk.UpdateHash()
			# if direction == 'WEST':
			# 	light_d = neighbors[light_chunk].getLight(l_x, l_y, l_z)
			# else:
			light_f = neighbors[light_chunk].getLight(l_x, l_y, l_z)


			# ROW 3
			if y == 0:
				light_chunk.y = coords.y - offset
				l_y = chunk_size - 1
			else:
				light_chunk.y = coords.y
				l_y = y - 1
			light_chunk.UpdateHash()
			# if direction == 'WEST':
			# 	light_g = neighbors[light_chunk].getLight(l_x, l_y, l_z)
			# else:
			light_i = neighbors[light_chunk].getLight(l_x, l_y, l_z)


			light_chunk.z = coords.z
			l_z = z
			light_chunk.UpdateHash()
			light_h = neighbors[light_chunk].getLight(l_x, l_y, l_z)


			if z == chunk_size - 1:
				light_chunk.z = coords.z + offset
				l_z = 0
			else:
				light_chunk.z = coords.z
				l_z = z + 1
			light_chunk.UpdateHash()
			# if direction == 'WEST':
			# 	light_i = neighbors[light_chunk].getLight(l_x, l_y, l_z)
			# else:
			light_g = neighbors[light_chunk].getLight(l_x, l_y, l_z)
				

		point_k = (light_e + light_f + light_h + light_i) / 4.0 / 255.0
		point_j = (light_e + light_d + light_h + light_g) / 4.0 / 255.0
		point_f = (light_a + light_b + light_d + light_e) / 4.0 / 255.0
		point_g = (light_e + light_b + light_c + light_f) / 4.0 / 255.0
		# print "LIGHT: ($x, $y, $z) ($point_k, $point_j, $point_f, $point_g)"

		if direction == 'WEST':
			lights.Add(Color(point_k, point_k, point_k, 1.0) * color)
			lights.Add(Color(point_j, point_j, point_j, 1.0) * color)															
			lights.Add(Color(point_f, point_f, point_f, 1.0) * color)
			lights.Add(Color(point_g, point_g, point_g, 1.0) * color)			
		if direction == 'EAST':
			lights.Add(Color(point_j, point_j, point_j, 1.0) * color)
			lights.Add(Color(point_k, point_k, point_k, 1.0) * color)
			lights.Add(Color(point_g, point_g, point_g, 1.0) * color)						
			lights.Add(Color(point_f, point_f, point_f, 1.0) * color)			



	def _add_north_south_lights(x as byte, y as byte, z as byte, direction as string, color as Color):
		light_chunk = ChunkCoordinate(0, 0, 0)
		coords = chunk.getCoords()
		scale = Settings.Chunks.Scale
		offset = 1
		
		# if everything fits within this block, use the linear method
		if x > 0 and x < chunk_size - 1 and y > 0 and y < chunk_size - 1 and z > 0 and z < chunk_size - 1:
			if direction == 'NORTH':
				z_offset = 1
			elif direction == 'SOUTH':
				z_offset = -1
			light_a = block_lights[x+1, y + 1, z + z_offset]
			light_b = block_lights[x, y + 1, z + z_offset]
			light_c = block_lights[x-1, y + 1, z + z_offset]
							 
			light_d = block_lights[x+1, y, z + z_offset]
			light_e = block_lights[x, y, z + z_offset]
			light_f = block_lights[x-1, y, z + z_offset]

			light_g = block_lights[x+1, y-1, z + z_offset]
			light_h = block_lights[x, y-1, z + z_offset]
			light_i = block_lights[x-1, y-1, z + z_offset]
		else:
			if direction == 'SOUTH':
				if z == 0:
					light_chunk.z = coords.z - offset
					l_z = chunk_size - 1
				else:
					light_chunk.z = coords.z
					l_z = z - 1
			elif direction == 'NORTH':
				if z == chunk_size - 1:
					light_chunk.z = coords.z + offset
					l_z = 0
				else:
					light_chunk.z = coords.z
					l_z = z + 1

			# ROW 1
			if y == chunk_size - 1:
				light_chunk.y = coords.y + offset
				l_y = 0
			else:
				light_chunk.y = coords.y
				l_y = y + 1

			if x == 0:
				light_chunk.x = coords.x - offset
				l_x = chunk_size - 1
			else:
				light_chunk.x = coords.x
				l_x = x - 1
			light_chunk.UpdateHash()
			# print "LIGHT CHECK: $light_chunk, z: $z, local: $l_x, $l_y, $l_z, coords: $coords"
			# if direction == 'NORTH':
			# 	light_a = neighbors[light_chunk].getLight(l_x, l_y, l_z)
			# else:
			light_c = neighbors[light_chunk].getLight(l_x, l_y, l_z)

			light_chunk.x = coords.x
			l_x = x
			light_chunk.UpdateHash()
			light_b = neighbors[light_chunk].getLight(l_x, l_y, l_z)

			if x == chunk_size - 1:
				light_chunk.x = coords.x + offset
				l_x = 0
			else:
				light_chunk.x = coords.x
				l_x = x + 1
			light_chunk.UpdateHash()
			# if direction == 'NORTH':
			# 	light_c = neighbors[light_chunk].getLight(l_x, l_y, l_z)
			# else:
			light_a = neighbors[light_chunk].getLight(l_x, l_y, l_z)

			# ROW 2
			light_chunk.y = coords.y
			l_y = y
			light_chunk.UpdateHash()
			# if direction == 'NORTH':
			# 	light_f = neighbors[light_chunk].getLight(l_x, l_y, l_z)
			# else:
			light_d = neighbors[light_chunk].getLight(l_x, l_y, l_z)

			light_chunk.x = coords.x
			l_x = x
			light_chunk.UpdateHash()
			light_e = neighbors[light_chunk].getLight(l_x, l_y, l_z)


			if x == 0:
				light_chunk.x = coords.x - offset
				l_x = chunk_size - 1
			else:
				light_chunk.x = coords.x
				l_x = x - 1
			light_chunk.UpdateHash()
			# if direction == 'NORTH':
			# 	light_d = neighbors[light_chunk].getLight(l_x, l_y, l_z)
			# else:
			light_f = neighbors[light_chunk].getLight(l_x, l_y, l_z)

			# ROW 3
			if y == 0:
				light_chunk.y = coords.y - offset
				l_y = chunk_size - 1
			else:
				light_chunk.y = coords.y
				l_y = y - 1
			light_chunk.UpdateHash()
			# if direction == 'NORTH':
			# 	light_g = neighbors[light_chunk].getLight(l_x, l_y, l_z)
			# else:
			light_i = neighbors[light_chunk].getLight(l_x, l_y, l_z)
				
			light_chunk.x = coords.x
			l_x = x
			light_chunk.UpdateHash()
			light_h = neighbors[light_chunk].getLight(l_x, l_y, l_z)


			if x == chunk_size - 1:
				light_chunk.x = coords.x + offset
				l_x = 0
			else:
				light_chunk.x = coords.x
				l_x = x + 1
			light_chunk.UpdateHash()
			# if direction == 'NORTH':
			# 	light_i = neighbors[light_chunk].getLight(l_x, l_y, l_z)
			# else:
			light_g = neighbors[light_chunk].getLight(l_x, l_y, l_z)

		point_k = (light_e + light_f + light_h + light_i) / 4.0 / 255.0
		point_j = (light_e + light_d + light_h + light_g) / 4.0 / 255.0
		point_f = (light_a + light_b + light_d + light_e) / 4.0 / 255.0
		point_g = (light_e + light_b + light_c + light_f) / 4.0 / 255.0

		
		if direction == 'NORTH':
			lights.Add(Color(point_k, point_k, point_k, 1.0) * color)
			lights.Add(Color(point_j, point_j, point_j, 1.0) * color)			
			lights.Add(Color(point_f, point_f, point_f, 1.0) * color)
			lights.Add(Color(point_g, point_g, point_g, 1.0) * color)			
		elif direction == 'SOUTH':
			lights.Add(Color(point_j, point_j, point_j, 1.0) * color)
			lights.Add(Color(point_k, point_k, point_k, 1.0) * color)
			lights.Add(Color(point_g, point_g, point_g, 1.0) * color)
			lights.Add(Color(point_f, point_f, point_f, 1.0) * color)			
			

	def _add_up_down_lights(x as byte, y as byte, z as byte, direction as string, color as Color):
		light_chunk = ChunkCoordinate(0, 0, 0)
		coords = chunk.getCoords()
		scale = Settings.Chunks.Scale
		# offset as int = chunk_size * scale
		offset = 1
		

		# if everything fits within this block, use the linear method
		if x > 0 and x < chunk_size - 1 and y > 0 and y < chunk_size - 1 and z > 0 and z < chunk_size - 1:
			if direction == 'UP':
				y_offset = 1
			elif direction == 'DOWN':
				y_offset = -1

			light_a = block_lights[x-1, y + y_offset, z+1]
			light_b = block_lights[x, y + y_offset, z+1]
			light_c = block_lights[x+1, y + y_offset, z+1]
							 
			light_d = block_lights[x-1, y + y_offset, z]
			light_e = block_lights[x, y + y_offset, z]
			light_f = block_lights[x+1, y + y_offset, z]

			light_g = block_lights[x-1, y + y_offset, z-1]
			light_h = block_lights[x, y + y_offset, z-1]
			light_i = block_lights[x+1, y + y_offset, z-1]
		else:
			if direction == 'DOWN':
				if y == 0:
					light_chunk.y = coords.y - offset
					l_y = chunk_size - 1
				else:
					light_chunk.y = coords.y
					l_y = y - 1
			elif direction == 'UP':
				if y == chunk_size - 1:
					light_chunk.y = coords.y + offset
					l_y = 0
				else:
					light_chunk.y = coords.y
					l_y = y + 1

			# ROW 1

			if z == chunk_size - 1:
				light_chunk.z = coords.z + offset
				l_z = 0
			else:
				light_chunk.z = coords.z
				l_z = z + 1

			if x == 0:
				light_chunk.x = coords.x - offset
				l_x = chunk_size - 1
			else:
				light_chunk.x = coords.x
				l_x = x - 1

			light_chunk.UpdateHash()
			# print "LIGHT CHECK: $light_chunk, z: $z, local: $l_x, $l_y, $l_z, coords: $coords"
			if direction == 'UP':
				light_a = neighbors[light_chunk].getLight(l_x, l_y, l_z)
			else:
				light_c = neighbors[light_chunk].getLight(l_x, l_y, l_z)



			light_chunk.x = coords.x
			l_x = x
			light_chunk.UpdateHash()
			light_b = neighbors[light_chunk].getLight(l_x, l_y, l_z)


			if x == chunk_size - 1:
				light_chunk.x = coords.x + offset
				l_x = 0
			else:
				light_chunk.x = coords.x
				l_x = x + 1
			light_chunk.UpdateHash()
			if direction == 'UP':
				light_c = neighbors[light_chunk].getLight(l_x, l_y, l_z)
			else:
				light_a = neighbors[light_chunk].getLight(l_x, l_y, l_z)


			# ROW 2
			# light_chunk.z = coords.z
			# l_z = z
			light_chunk.z = coords.z
			l_z = z
			# if z == 0:
			# 	light_chunk.z = coords.z - offset
			# 	l_z = chunk_size - 1
			# else:
			# 	light_chunk.z = coords.z
			# 	l_z = z - 1

			light_chunk.UpdateHash()
			if direction == 'UP':
				light_f = neighbors[light_chunk].getLight(l_x, l_y, l_z)
			else:
				light_d = neighbors[light_chunk].getLight(l_x, l_y, l_z)

			light_chunk.x = coords.x
			l_x = x
			light_chunk.UpdateHash()
			light_e = neighbors[light_chunk].getLight(l_x, l_y, l_z)


			if x == 0:
				light_chunk.x = coords.x - offset
				l_x = chunk_size - 1
			else:
				light_chunk.x = coords.x
				l_x = x - 1
			light_chunk.UpdateHash()
			if direction == 'UP':
				light_d = neighbors[light_chunk].getLight(l_x, l_y, l_z)
			else:
				light_f = neighbors[light_chunk].getLight(l_x, l_y, l_z)


			# ROW 3
			if z == 0:
				light_chunk.z = coords.z - offset
				l_z = chunk_size - 1
			else:
				light_chunk.z = coords.z
				l_z = z - 1
			light_chunk.UpdateHash()
			if direction == 'UP':
				light_g = neighbors[light_chunk].getLight(l_x, l_y, l_z)
			else:
				light_i = neighbors[light_chunk].getLight(l_x, l_y, l_z)


			light_chunk.x = coords.x
			l_x = x
			light_chunk.UpdateHash()
			light_h = neighbors[light_chunk].getLight(l_x, l_y, l_z)


			if x == chunk_size - 1:
				light_chunk.x = coords.x + offset
				l_x = 0
			else:
				light_chunk.x = coords.x
				l_x = x + 1
			light_chunk.UpdateHash()
			if direction == 'UP':
				light_i = neighbors[light_chunk].getLight(l_x, l_y, l_z)
			else:
				light_g = neighbors[light_chunk].getLight(l_x, l_y, l_z)


		point_k = (light_e + light_f + light_h + light_i) / 4.0 / 255.0
		point_j = (light_e + light_d + light_h + light_g) / 4.0 / 255.0
		point_f = (light_a + light_b + light_d + light_e) / 4.0 / 255.0
		point_g = (light_e + light_b + light_c + light_f) / 4.0 / 255.0


		if direction == 'UP':
			lights.Add(Color(point_k, point_k, point_k, 1.0) * color)			
			lights.Add(Color(point_j, point_j, point_j, 1.0) * color)
			lights.Add(Color(point_f, point_f, point_f, 1.0) * color)
			lights.Add(Color(point_g, point_g, point_g, 1.0) * color)
		elif direction == 'DOWN':
			lights.Add(Color(point_g, point_g, point_g, 1.0) * color)
			lights.Add(Color(point_f, point_f, point_f, 1.0) * color)			
			lights.Add(Color(point_j, point_j, point_j, 1.0) * color)
			lights.Add(Color(point_k, point_k, point_k, 1.0) * color)

		
	# begin generating the mesh
	t1 = DateTime.Now

	coords = chunk.getCoords()
	# offset = Settings.Chunks.Size * Settings.Chunks.Scale
	offset = 1
	
	w = ChunkCoordinate(coords.x - 1, coords.y, coords.z)
	e = ChunkCoordinate(coords.x + 1, coords.y, coords.z)
	n = ChunkCoordinate(coords.x, coords.y, coords.z + 1)
	s = ChunkCoordinate(coords.x, coords.y, coords.z - 1)
	u = ChunkCoordinate(coords.x, coords.y + 1, coords.z)
	d = ChunkCoordinate(coords.x, coords.y - 1, coords.z)
	# print "MESH GENERATOR: ", w, e, n, s, u, d
	# for x in neighbors.Keys:
	# 	print x

	n_w = neighbors[w]
	n_e = neighbors[e]
	n_n = neighbors[n]
	n_s = neighbors[s]
	n_u = neighbors[u]
	n_d = neighbors[d]

	def do_west(x as int, y as int, z as int, block as byte):
		vertices.Add(Vector3(x, y, z))
		vertices.Add(Vector3(x, y, z+1))
		vertices.Add(Vector3(x, y+1, z+1))
		vertices.Add(Vector3(x, y+1, z))
		vertice_count += 4
		_add_triangles()
		_add_normals(Vector3(-1, 0, 0))
		# for i in range(4):
		# 	lights.Add(Color(1, 1, 1, 1))	
							
		_add_east_west_lights(x, y, z, "WEST", Blocks.block_def[block].color)
		# _add_uvs(Blocks.block_def[block].uv_x, Blocks.block_def[block].uv_y)

	def do_east(x as int, y as int, z as int, block as byte):
		vertices.Add(Vector3(x+1, y, z+1))
		vertices.Add(Vector3(x+1, y, z))
		vertices.Add(Vector3(x+1, y+1, z))
		vertices.Add(Vector3(x+1, y+1, z+1))
		vertice_count += 4
		_add_triangles()
		_add_normals(Vector3(1, 0, 0))
		# for i in range(4):
		# 	lights.Add(Color(1, 1, 1, 1))
		_add_east_west_lights(x, y, z, "EAST", Blocks.block_def[block].color)
		# _add_uvs(Blocks.block_def[block].uv_x, Blocks.block_def[block].uv_y)

	def do_south(x as int, y as int, z as int, block as byte):
		vertices.Add(Vector3(x+1, y, z))
		vertices.Add(Vector3(x, y, z))
		vertices.Add(Vector3(x, y+1, z))
		vertices.Add(Vector3(x+1, y+1, z))
		vertice_count += 4
		_add_triangles()
		# for i in range(4):
		# 	lights.Add(Color(1, 1, 1, 1))
		_add_north_south_lights(x, y, z, "SOUTH", Blocks.block_def[block].color)
		_add_normals(Vector3(0, 0, -1))
		# _add_uvs(Blocks.block_def[block].uv_x, Blocks.block_def[block].uv_y)

	def do_north(x as int, y as int, z as int, block as byte):
		vertices.Add(Vector3(x, y, z+1))
		vertices.Add(Vector3(x+1, y, z+1))
		vertices.Add(Vector3(x+1, y+1, z+1))
		vertices.Add(Vector3(x, y+1, z+1))
		vertice_count += 4
		_add_triangles()
		_add_normals(Vector3(0, 0, 1))
		# for i in range(4):
		# 	lights.Add(Color(1, 1, 1, 1))
		_add_north_south_lights(x, y, z, "NORTH", Blocks.block_def[block].color)
		
		# _add_uvs(Blocks.block_def[block].uv_x, Blocks.block_def[block].uv_y)

	def do_down(x as int, y as int, z as int, block as byte):
		vertices.Add(Vector3(x+1, y, z+1))
		vertices.Add(Vector3(x, y, z+1))
		vertices.Add(Vector3(x, y, z))
		vertices.Add(Vector3(x+1, y, z))
		vertice_count += 4
		_add_triangles()
		_add_normals(Vector3(0, -1, 0))
		# for i in range(4):
		# 	lights.Add(Color(1, 1, 1, 1))
		_add_up_down_lights(x, y, z, "DOWN", Blocks.block_def[block].color)
		# _add_uvs(Blocks.block_def[block].uv_x, Blocks.block_def[block].uv_y)

	def do_up(x as int, y as int, z as int, block as byte):
		vertices.Add(Vector3(x+1, y+1, z))
		vertices.Add(Vector3(x, y+1, z))
		vertices.Add(Vector3(x, y+1, z+1))
		vertices.Add(Vector3(x+1, y+1, z+1))
		vertice_count += 4
		_add_triangles()
		_add_normals(Vector3(0, 1, 0))
		# for i in range(4):
		# 	lights.Add(Color(1, 1, 1, 1))
		_add_up_down_lights(x, y, z, "UP", Blocks.block_def[block].color)
		# _add_uvs(Blocks.block_def[block].uv_x, Blocks.block_def[block].uv_y)
		
		
	
	for x as byte in range(chunk_size):
		for y as byte in range(chunk_size):
			for z as byte in range(chunk_size):
				# get this block and all the neighbor block values, taking into account
				# if the neighbor block is actually in a neighboring chunk
				block = blocks[x, y, z]

				
				block_west = (n_w.getBlock(chunk_size-1, y, z) if x == 0 else blocks[x-1, y, z])
				block_east = (n_e.getBlock(0, y, z) if x == chunk_size - 1 else blocks[x+1, y, z])
				block_south = (n_s.getBlock(x, y, chunk_size-1) if z == 0 else blocks[x, y, z-1])
				block_north = (n_n.getBlock(x, y, 0) if z == chunk_size - 1 else blocks[x, y, z+1])
				block_down = (n_d.getBlock(x, chunk_size-1, z) if y == 0 else blocks[x, y-1, z])
				block_up = (n_u.getBlock(x, 0, z) if y == chunk_size - 1 else blocks[x, y+1, z])
				
				# if this block is solid and the neighboring block is not, generate a face
				if not water and block != 200 and block != 0:
					if block_west == 0 or block_west == 200:
						do_west(x, y, z, block)
					if block_east == 0 or block_east == 200:
						do_east(x, y, z, block)
					if block_south == 0 or block_south == 200:
						do_south(x, y, z, block)
					if block_north == 0 or block_north == 200:
						do_north(x, y, z, block)
					if block_down == 0 or block_down == 200:
						do_down(x, y, z, block)
					if block_up == 0 or block_up == 200:
						do_up(x, y, z, block)

				elif water and block == 200:
					if block_west != 200:
						do_west(x, y, z, block)
					if block_east != 200:
						do_east(x, y, z, block)
					if block_south != 200:
						do_south(x, y, z, block)
					if block_north != 200:
						do_north(x, y, z, block)
					if block_down != 200:
						do_down(x, y, z, block)
					if block_up != 200:
						do_up(x, y, z, block)
					

	# convert all of the Lists to arrays since this is what Unity's Mesh will be expecting.
	# ToArray is highly optimized in Mono.
	t2 = DateTime.Now
	m = MeshData(uvs.ToArray(),
				 vertices.ToArray(),
				 normals.ToArray(),
				 triangles.ToArray(),
				 lights.ToArray())
	t3 = DateTime.Now

	return m

