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

	def constructor(c as WorldBlockCoordinate, s as byte, b_func as BlockGenerator, m_func as MeshGenerator):
		coords = c
		size = s
		block_generator = b_func
		mesh_generator = m_func
		blocks = matrix(byte, size, size, size)
		needs_work = true
		flag_gen_noise = true
		#flag_gen_noise = true


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

	def getBlock(x as byte, y as byte, z as byte) as byte:
		lock blocks:
			return blocks[x, y, z]
		
	def setBlock(x as byte, y as byte, z as byte, val as byte):
		lock blocks:
			blocks[x, y, z] = val

	def generateBlocks():
		lock blocks:
			for x in range(size):
				for z in range(size):
					for y in range(size):
						blocks[x, y, z] = block_generator(x + coords.x, y + coords.y, z + coords.z)
		# lock flag_gen_noise:
		# 	flag_gen_noise = false

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
		
