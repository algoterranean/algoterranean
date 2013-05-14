namespace Algorithmic.Chunks

import Algorithmic.Physics

class Chunk ():
	blocks as IChunkBlockData
	mesh as IChunkMeshData
	bounds as AABB
	coords as LongVector3
	locker = object()
	flag_calculate_mesh = false
	flag_calculate_noise = false


	def constructor(blocks as IChunkBlockData, mesh as IChunkMeshData):
		self.blocks = blocks
		self.mesh = mesh
		coords = blocks.getCoordinates()
		radius = Settings.ChunkSize/2
		bounds = AABB(Vector3(coords.x + radius, coords.y + radius, coords.z + radius),
					  Vector3(radius, radius, radius))
		flag_calculate_noise = true
		flag_calculate_mesh = true

	def getCoords() as LongVector3:
		return coords

	def getBlocks() as IChunkBlockData:
		return blocks

	def getMesh() as IChunkMeshData:
		return mesh

	def setMesh(m as IChunkMeshData):
		mesh = m

	def ToString():
		return "Chunk ($(coords.x), $(coords.y), $(coords.z))"

	def getFlagMesh() as bool:
		lock flag_calculate_mesh:
			return flag_calculate_mesh
	def getFlagNoise() as bool:
		lock flag_calculate_noise:
			return flag_calculate_noise
	def setFlagMesh(f as bool):
		lock flag_calculate_mesh:
			flag_calculate_mesh = f
	def setFlagNoise(f as bool):
		lock flag_calculate_noise:
			flag_calculate_noise = f
		
