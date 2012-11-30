
interface IChunk:
	def isNull() as bool
	def areBlocksCalculated() as bool
	def isMeshCalculated() as bool

	def CalculateNoise() as void
	def CalculateMesh() as void
		
	def setCoordinates(x_coord as long, z_coord as long, y_coord as long) as void
	def setChunkSizes(p_size as byte, q_size as byte, r_size as byte) as void
	def setBlock(p as byte, q as byte, r as byte, block as byte) as void
		
	def getBlock(p as byte, q as byte, r as byte) as byte
	def getCoordinates() as (long)
		
