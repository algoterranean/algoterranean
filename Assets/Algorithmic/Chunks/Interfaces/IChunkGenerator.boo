import UnityEngine

interface IChunkGenerator ():
	# def setMinChunkDistance(min_distance as byte) as void
	# def getMinChunkDistance() as byte
	# def setMaxChunkDistance(max_distance as byte) as void
	# def getMaxChunkDistance() as byte
	def setOrigin(origin as Vector3) as void
	def setBlock(world as WorldBlockCoordinate, block as byte) as void
	def getBlock(world as WorldBlockCoordinate) as byte
	def setBlocks(world as WorldBlockCoordinate, size as byte, block as byte) as void
	def getChunk(coords as WorldBlockCoordinate) as Chunk
	# def getMaxHeight(location as Vector3) as int
            
