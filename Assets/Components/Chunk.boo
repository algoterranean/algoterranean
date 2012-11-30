
# class NullChunk():
# 	def constructor():
# 		pass
# 	def IsNull():
# 		return true
# 	def BlocksGenerated():
# 		return true
# 	def GetBlock(x as byte, z as byte, y as byte):
# 		return 0

class Chunk (IChunk):
	blocks_calculated as bool
	mesh_calculated as bool
	mesh_visible as bool
	blocks as (byte, 3)
	noise_module as VoxelNoiseData
	coordinates as (long)
	sizes as (byte)

	public vertices as (Vector3)
	public triangles as (int)
	public uvs as (Vector2)
	public colors as (Color32)
	public normals as (Vector3)


	def constructor(x_coord as long, z_coord as long, y_coord as long, p_size as byte, q_size as byte, r_size as byte):
		coordinates = array(long, 3)
		sizes = array(byte, 3)
		blocks = matrix(byte, p_size, q_size, r_size)
		noise_module = VoxelNoiseData()
		blocks_calculated = false
		mesh_calculated = false
		mesh_visible = false
		setCoordinates(x_coord, z_coord, y_coord)
		setChunkSizes(p_size, q_size, r_size)

	def setCoordinates(x_coord as long, z_coord as long, y_coord as long) as void:
		lock coordinates:
			coordinates[0] = x_coord
			coordinates[1] = z_coord
			coordinates[2] = y_coord

	def setChunkSizes(p_size as byte, q_size as byte, r_size as byte) as void:
		lock sizes:
			sizes[0] = p_size
			sizes[1] = q_size
			sizes[2] = r_size

	def setBlock(p as byte, q as byte, r as byte, block as byte) as void:
		lock blocks:
			blocks[p, q, r] = block

	def getBlock(p as byte, q as byte, r as byte) as byte:
		lock blocks:
			return blocks[p, q, r]

	def getCoordinates() as (long):
		lock coordinates:
			return coordinates

	def isNull() as bool:
		return false

	def isMeshCalculated() as bool:
		lock mesh_calculated:
			return mesh_calculated

	def areBlocksCalculated() as bool:
		lock blocks_calculated:
			return blocks_calculated

	def CalculateNoise() as void:
		lock sizes, coordinates:
			p_size = sizes[0]
			q_size = sizes[1]
			r_size = sizes[2]
			x_coord = coordinates[0]
			z_coord = coordinates[1]
			y_coord = coordinates[2]
		for p in range(p_size):
			for q in range(q_size):
				for r in range(r_size):
					blocks[p, q, r] = noise_module.GetBlock(x_coord + p, z_coord + q, y_coord + r)
		lock blocks_calculated:
			blocks_calculated = true

	def _init_mesh_array_sizes():
		vertice_size = 0
		uv_size = 0
		triangle_size = 0
		
		for p in range(sizes[0]):
			for q in range(sizes[1]):
				for r in range(sizes[2]):
					block = blocks[p, q, r]
					block_west = (0 if p == 0 else blocks[p-1, q, r])
					block_east = (0 if p == sizes[0] - 1 else blocks[p+1, q, r])
					block_south = (0 if q == 0 else blocks[p, q-1, r])
					block_north = (0 if q == sizes[1] - 1 else blocks[p, q+1, r])
					block_down = (0 if r == 0 else blocks[p, q, r-1])
					block_up = (0 if r == sizes[2] - 1 else blocks[p, q, r+1])

					if block > 0:
						for b in [block_west, block_east, block_south, block_north, block_down, block_up]:
							if b == 0:
								vertice_size += 4
								uv_size += 4
								triangle_size += 6
		
		vertices = matrix(Vector3, vertice_size)
		triangles = matrix(int, triangle_size)
		uvs = matrix(Vector2, uv_size)


	def CalculateMesh() as void:
		_init_mesh_array_sizes()
		uv_count = 0
		vertice_count = 0
		triangle_count = 0
		
		def _calc_uvs(x as int, y as int):
			# give x, y coordinates in (0-9) by (0-9)
			uvs[uv_count] = Vector2(0.1*x, 1.0 - 0.1*y - 0.1)
			uv_count += 1
			uvs[uv_count] = Vector2(0.1*x, 1.0 - 0.1*y)
			uv_count += 1
			uvs[uv_count] = Vector2(0.1*x + 0.1, 1.0 - 0.1*y)
			uv_count += 1
			uvs[uv_count] = Vector2(0.1*x + 0.1, 1.0 - 0.1*y - 0.1)
			uv_count += 1
			
		def _calc_triangles():
			triangles[triangle_count] = vertice_count-4 # 0
			triangle_count += 1
			triangles[triangle_count] = vertice_count-3 # 1
			triangle_count += 1			
			triangles[triangle_count] = vertice_count-2 # 2
			triangle_count += 1			
			triangles[triangle_count] = vertice_count-2 # 2
			triangle_count += 1			
			triangles[triangle_count] = vertice_count-1 # 3
			triangle_count += 1			
			triangles[triangle_count] = vertice_count-4 # 0
			triangle_count += 1

		lock sizes:
			p_size = sizes[0]
			q_size = sizes[1]
			r_size = sizes[2]
			
		for p in range(p_size):
			for q in range(q_size):
				for r in range(r_size):
					block = blocks[p, q, r]
					block_west = (0 if p == 0 else blocks[p-1, q, r])
					block_east = (0 if p == p_size - 1 else blocks[p+1, q, r])
					block_south = (0 if q == 0 else blocks[p, q-1, r])
					block_north = (0 if q == q_size - 1 else blocks[p, q+1, r])
					block_down = (0 if r == 0 else blocks[p, q, r-1])
					block_up = (0 if r == r_size - 1 else blocks[p, q, r+1])
