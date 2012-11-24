

class Chunk ():
	blocks as (byte, 3)
	noise as VoxelNoiseData
	private vertices as (Vector3)
	private triangles as (int)
	private uvs as (Vector2)
	private colors as (Color32)
	private normals as (Vector3)

	
	def constructor(chunk_x as int, chunk_z as int, chunk_y as int):
		
		blocks = matrix(byte, Settings.ChunkSize, Settings.ChunkSize, Settings.ChunkSize)
		noise = VoxelNoiseData()
		x_width = Settings.ChunkSize
		z_width = Settings.ChunkSize
		y_width = Settings.ChunkSize
		
		for x in range(Settings.ChunkSize):
			for z in range(Settings.ChunkSize):
				for y in range(Settings.ChunkSize):
					blocks[x,z,y] = noise.GetBlock(x + chunk_x, z + chunk_z, y + chunk_y)

		triangle_size = 0
		vertice_size = 0
		uv_size = 0
					
		for x in range(Settings.ChunkSize):
			for z in range(Settings.ChunkSize):
				for y in range(Settings.ChunkSize):
					solid = blocks[x, z, y]
					solid_west = (0 if x == 0 else blocks[x-1, z, y])
					solid_east = (0 if x == x_width-1 else blocks[x+1, z, y])
					solid_south = (0 if z == 0 else blocks[x, z-1, y])
					solid_north = (0 if z == z_width-1 else blocks[x, z+1, y])
					solid_down = (0 if y == 0 else blocks[x, z, y-1])
					solid_up = (0 if y == y_width-1 else blocks[x, z, y+1])

					# if solid:
					# 	pass
					
					# if solid:
					# 	if solid_west:
					# 		pass
					# 	if solid_east:
					# 		pass
					# 	if solid_south:
					# 		pass
					# 	if solid_north:
					# 		pass
					# 	if solid_down:
					# 		pass
					# 	if solid_up:
					# 		pass
					# 	# for side in [solid_west, solid_east, solid_south, solid_north, solid_down, solid_up]:
					# 	# 	if not side:
					# 	# 		vertice_size += 4
					# 	# 		uv_size += 4
					# 	# 		triangle_size += 6
								
					

	def GetBlock(x as int, z as int, y as int):
		return blocks[x, z, y]

	def BuildMesh():
		# while not voxels.IsInitialized():
		# 	yield
			
		x_width = Settings.ChunkSize
		z_width = Settings.ChunkSize
		y_width = Settings.ChunkSize
		
		_vertices = []
		_triangles = []
		_uvs = []
		_colors = []
		_normals = []
		_outline_vertices = []


		triangle_count = 0

		def _calc_uvs(x as int, y as int):
			pass
			# give x, y coordinates in (0-9) by (0-9)
			#_uvs.Push(Vector2(0.1*x, 1.0 - 0.1*y - 0.1))
			#_uvs.Push(Vector2(0.1*x, 1.0 - 0.1*y))
			#_uvs.Push(Vector2(0.1*x + 0.1, 1.0 - 0.1*y))
			#_uvs.Push(Vector2(0.1*x + 0.1, 1.0 - 0.1*y - 0.1))
			
			

		for x in range(x_width):
			for z in range(z_width):
				for y in range(y_width):
					solid = GetBlock(x, z, y)
					# solid_west = voxels.GetWestBlock(x, z, y)
					# solid_east = voxels.GetEastBlock(x, z, y)
					# solid_south = voxels.GetSouthBlock(x, z, y)
					# solid_north = voxels.GetNorthBlock(x, z, y)
					# solid_down = voxels.GetDownBlock(x, z, y)
					# solid_up = voxels.GetUpBlock(x, z, y)
					
					solid_west = (0 if x == 0 else blocks[x-1, z, y])
					solid_east = (0 if x == x_width-1 else blocks[x+1, z, y])
					
					solid_south = (0 if z == 0 else blocks[x, z-1, y])
					solid_north = (0 if z == z_width-1 else blocks[x, z+1, y])
					
					solid_down = (0 if y == 0 else blocks[x, z, y-1])
					solid_up = (0 if y == y_width-1 else blocks[x, z, y+1])

					if solid:
						if not solid_west:
							#_vertices.Push(Vector3(x, y, z))
							#_vertices.Push(Vector3(x, y, z+1))
							#_vertices.Push(Vector3(x, y+1, z+1))
							#_vertices.Push(Vector3(x, y+1, z))
							# _triangles.Push(0+triangle_count*4)
							# _triangles.Push(1+triangle_count*4)
							# _triangles.Push(2+triangle_count*4)
							# _triangles.Push(2+triangle_count*4)
							# _triangles.Push(3+triangle_count*4)
							# _triangles.Push(0+triangle_count*4)
							if solid == 1:
								_calc_uvs(3,0)
							elif solid == 2:
								_calc_uvs(2,0)
							triangle_count += 1
						if not solid_east:
							#_vertices.Push(Vector3(x+1, y, z+1))
							#_vertices.Push(Vector3(x+1, y, z))
							#_vertices.Push(Vector3(x+1, y+1, z))
							#_vertices.Push(Vector3(x+1, y+1, z+1))
							# _triangles.Push(0+triangle_count*4)
							# _triangles.Push(1+triangle_count*4)
							# _triangles.Push(2+triangle_count*4)
							# _triangles.Push(2+triangle_count*4)
							# _triangles.Push(3+triangle_count*4)
							# _triangles.Push(0+triangle_count*4)
							if solid == 1:
								_calc_uvs(3,0)
							elif solid == 2:
								_calc_uvs(2,0)							
							triangle_count += 1							
						if not solid_north:
							#_vertices.Push(Vector3(x, y, z+1))
							#_vertices.Push(Vector3(x+1, y, z+1))
							#_vertices.Push(Vector3(x+1, y+1, z+1))
							#_vertices.Push(Vector3(x, y+1, z+1))
							# _triangles.Push(0+triangle_count*4)
							# _triangles.Push(1+triangle_count*4)
							# _triangles.Push(2+triangle_count*4)
							# _triangles.Push(2+triangle_count*4)
							# _triangles.Push(3+triangle_count*4)
							# _triangles.Push(0+triangle_count*4)
							if solid == 1:
								_calc_uvs(3,0)
							elif solid == 2:
								_calc_uvs(2,0)							
							triangle_count += 1
						if not solid_south:
							#_vertices.Push(Vector3(x+1, y, z))
							#_vertices.Push(Vector3(x, y, z))
							#_vertices.Push(Vector3(x, y+1, z))
							#_vertices.Push(Vector3(x+1, y+1, z))
							# _triangles.Push(0+triangle_count*4)
							# _triangles.Push(1+triangle_count*4)
							# _triangles.Push(2+triangle_count*4)
							# _triangles.Push(2+triangle_count*4)
							# _triangles.Push(3+triangle_count*4)
							# _triangles.Push(0+triangle_count*4)
							if solid == 1:
								_calc_uvs(3,0)
							elif solid == 2:
								_calc_uvs(2,0)							
							triangle_count += 1							
						if not solid_down:
							#_vertices.Push(Vector3(x+1, y, z+1))
							#_vertices.Push(Vector3(x, y, z+1))
							#_vertices.Push(Vector3(x, y, z))
							#_vertices.Push(Vector3(x+1, y, z))
							# _triangles.Push(0+triangle_count*4)
							# _triangles.Push(1+triangle_count*4)
							# _triangles.Push(2+triangle_count*4)
							# _triangles.Push(2+triangle_count*4)
							# _triangles.Push(3+triangle_count*4)
							# _triangles.Push(0+triangle_count*4)
							if solid == 1:
								_calc_uvs(3,0)
							elif solid == 2:
								_calc_uvs(2,0)							
							triangle_count += 1
						if not solid_up:
							#_vertices.Push(Vector3(x+1, y+1, z))
							#_vertices.Push(Vector3(x, y+1, z))
							#_vertices.Push(Vector3(x, y+1, z+1))
							#_vertices.Push(Vector3(x+1, y+1, z+1))
							# _triangles.Push(0+triangle_count*4)
							# _triangles.Push(1+triangle_count*4)
							# _triangles.Push(2+triangle_count*4)
							# _triangles.Push(2+triangle_count*4)
							# _triangles.Push(3+triangle_count*4)
							# _triangles.Push(0+triangle_count*4)
							if solid == 1:
								_calc_uvs(3,0)
							elif solid == 2:
								_calc_uvs(2,0)							
							triangle_count += 1
							
		# vertices = array(Vector3, _vertices)
		# triangles = array(int, _triangles)
		# uvs = array(Vector2, _uvs)
		

