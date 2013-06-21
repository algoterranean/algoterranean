namespace Algorithmic.Chunks

import Algorithmic.Physics

class Chunk:
	coords as WorldBlockCoordinate
	size as byte
	blocks as (byte, 3)
	mesh_data as MeshData2
	block_generator as BlockGenerator
	mesh_generator as MeshGenerator
	flag_gen_noise as bool
	needs_work as bool
	_generate_blocks as bool
	_generate_mesh as bool
	interpolate = true
	

	def constructor(c as WorldBlockCoordinate, s as byte, b_func as BlockGenerator, m_func as MeshGenerator):
		coords = c
		size = s
		block_generator = b_func
		mesh_generator = m_func
		blocks = matrix(byte, size+1, size+1, size+1) # +1 for last block necessary for interpolation
		needs_work = true
		flag_gen_noise = true
		#flag_gen_noise = true
		_generate_blocks = true
		_generate_mesh = true


	override def ToString() as string:
		return "$coords"

	FlagGenBlocks as bool:
		get:
			return flag_gen_noise
		set:
			flag_gen_noise = value

	NeedsWork as bool:
		get:
			return needs_work
		set:
			lock needs_work:
				needs_work = value

	GenerateBlocks as bool:
		get:
			return _generate_blocks
		set:
			_generate_blocks = value

	GenerateMesh as bool:
		get:
			return _generate_mesh
		set:
			_generate_mesh = value
			

	def getBlock(x as byte, y as byte, z as byte) as byte:
		lock blocks:
			return blocks[x, y, z]
		
	def setBlock(x as byte, y as byte, z as byte, val as byte):
		lock blocks:
			blocks[x, y, z] = val


	def trilinear_interpolation(v000 as byte, v100 as byte, v010 as byte,
								v110 as byte, v001 as byte, v101 as byte,
								v011 as byte, v111 as byte,
								x as single, y as single, z as single,
								block1 as byte, block2 as byte):
		result = v000 * (1-x)*(1-y)*(1-z) + \
			v100 * x * (1-y) * (1-z) + \
			v010 * (1-x) * y * (1-z) + \
			v110 * x * y * (1-z) + \
			v001 * (1-x) * (1-y) * z + \
			v101 * x * (1-y) * z + \
			v011 * (1-x) * y * z + \
			v111*x*y*z


		if Math.Abs(result - block1) >= Math.Abs(block2 - result):
			return block2
		else:
			return block1


			

	def generateBlocks():
		if not interpolate:
			scale = 1/Settings.ChunkScale
			c_x as long = coords.x / Settings.ChunkScale
			c_y as long = coords.y / Settings.ChunkScale
			c_z as long = coords.z / Settings.ChunkScale
			lock blocks:
				for x in range(size):
					for z in range(size):
						for y in range(size):
							blocks[x, y, z] = block_generator(x + c_x, y + c_y, z + c_z)
		else:
			skip_size_x = Settings.ChunkInterpolateSizeX
			skip_size_f_x = skip_size_x cast single
			skip_size_y = Settings.ChunkInterpolateSizeY
			skip_size_f_y = skip_size_y cast single
			skip_size_z = Settings.ChunkInterpolateSizeZ
			skip_size_f_z = skip_size_z cast single			
			scale = 1/Settings.ChunkScale
			c_x2 as long = coords.x / Settings.ChunkScale
			c_y2 as long = coords.y / Settings.ChunkScale
			c_z2 as long = coords.z / Settings.ChunkScale

			for x in range(0, size+1, skip_size_x):
				for y in range(0, size+1, skip_size_y):
					for z in range(0, size+1, skip_size_z):
						blocks[x, y, z] = block_generator(x + c_x2, y + c_y2, z + c_z2)

			for x in range(size+1):
				for y in range(size+1):
					for z in range(size+1):
						m_x = x % skip_size_x
						m_y = y % skip_size_y
						m_z = z % skip_size_z
			
						if m_x > 0 or m_y > 0 or m_z > 0:
							x_0 = x / skip_size_x * skip_size_x
							y_0 = y / skip_size_y * skip_size_y
							z_0 = z / skip_size_z * skip_size_z

							x_1 = (x if x == size else x_0 + skip_size_x)
							y_1 = (y if y == size else y_0 + skip_size_y)
							z_1 = (z if z == size else z_0 + skip_size_z)

							# print x, y, z, x_0, y_0, z_0, x_1, y_1, z_1

							v000 = blocks[x_0, y_0, z_0]
							v100 = blocks[x_1, y_0, z_0]
							v010 = blocks[x_0, y_1, z_0]
							v110 = blocks[x_1, y_1, z_0]
							v001 = blocks[x_0, y_0, z_1]
							v101 = blocks[x_1, y_0, z_1]
							v011 = blocks[x_0, y_1, z_1]
							v111 = blocks[x_1, y_1, z_1]

							relative_x = (x - x_0) / skip_size_f_x
							relative_y = (y - y_0) / skip_size_f_y
							relative_z = (z - z_0) / skip_size_f_z

							result = trilinear_interpolation(v000, v100, v010,
															 v110, v001, v101,
															 v011, v111,
															 relative_x, relative_y, relative_z,
															 blocks[x_0, y_0, z_0], blocks[x_1, y_1, z_1])
							blocks[x, y, z] = result
			# 				if coords.x == 16 and coords.y == -8 and coords.z == 8 and x == 8 and z == 0:
			# 				 	print x, y, z, result, relative_x, relative_y, relative_z, x_0, x_1, y_0, y_1, z_0, z_1
			# if coords.x == 16 and coords.y == -8 and coords.z == 8:
			# 	for x in range(size+1):
			# 		for y in range(size+1):
			# 			for z in range(size+1):
			# 				if x == 8 and z == 0:
			# 					print x, y, z, blocks[x, y, z]



	def generateMesh():
		mesh_data = mesh_generator(blocks)

	def getMeshData() as MeshData2:
		return mesh_data

	def getCoords() as WorldBlockCoordinate:
		return coords
	

# class Chunk ():
# 	blocks as IChunkBlockData
# 	mesh as IChunkMeshData
# 	bounds as AABB
# 	coords as WorldBlockCoordinate
# 	locker = object()
# 	flag_calculate_mesh = false
# 	flag_calculate_noise = false



# 	def constructor(blocks as IChunkBlockData, mesh as IChunkMeshData):
# 		self.blocks = blocks
# 		self.mesh = mesh
# 		coords = blocks.getCoordinates()
# 		radius = Settings.ChunkSize/2
# 		bounds = AABB(Vector3(coords.x + radius, coords.y + radius, coords.z + radius),
# 					  Vector3(radius, radius, radius))
# 		flag_calculate_noise = true
# 		flag_calculate_mesh = true

# 	def getCoords() as WorldBlockCoordinate:
# 		return coords

# 	def getBlocks() as IChunkBlockData:
# 		return blocks

# 	def getMesh() as IChunkMeshData:
# 		return mesh

# 	def setMesh(m as IChunkMeshData):
# 		mesh = m

# 	def ToString():
# 		return "Chunk ($(coords.x), $(coords.y), $(coords.z))"

# 	def getFlagMesh() as bool:
# 		lock flag_calculate_mesh:
# 			return flag_calculate_mesh
# 	def getFlagNoise() as bool:
# 		lock flag_calculate_noise:
# 			return flag_calculate_noise
# 	def setFlagMesh(f as bool):
# 		lock flag_calculate_mesh:
# 			flag_calculate_mesh = f
# 	def setFlagNoise(f as bool):
# 		lock flag_calculate_noise:
# 			flag_calculate_noise = f
		
