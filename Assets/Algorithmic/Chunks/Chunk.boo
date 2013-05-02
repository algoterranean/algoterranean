namespace Algorithmic.Chunks

import Algorithmic.Physics

class Chunk ():
	blocks as IChunkBlockData
	mesh as IChunkMeshData
	bounds as AABB
	coords as LongVector3

	def constructor(blocks as IChunkBlockData, mesh as IChunkMeshData):
		self.blocks = blocks
		self.mesh = mesh
		coords = blocks.getCoordinates()
		radius = Settings.ChunkSize/2
		bounds = AABB(Vector3(coords.x + radius, coords.y + radius, coords.z + radius),
					  Vector3(radius, radius, radius))

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
