import UnityEngine

interface IChunkGenerator ():
	# def setMinChunkDistance(min_distance as byte) as void
	# def getMinChunkDistance() as byte
	# def setMaxChunkDistance(max_distance as byte) as void
	# def getMaxChunkDistance() as byte
	def SetOrigin(origin as Vector3) as void
	def setBlock(world as LongVector3, block as byte) as void
	def getBlock(world as LongVector3) as byte
	def getChunk(coords as LongVector3) as Chunk
	# def getMaxHeight(location as Vector3) as int
            
