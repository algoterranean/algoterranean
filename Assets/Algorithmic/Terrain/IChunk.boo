namespace Algorithmic

interface IChunk:
	def isNull() as bool
	def areBlocksCalculated() as bool
	def isMeshCalculated() as bool
		
	def getBlock(p as byte, q as byte, r as byte) as byte
	def getCoordinates() as (long)
		
	def setBlock(p as byte, q as byte, r as byte, block as byte) as void
	def setCoordinates(x as long, z as long, y as long) as void
	def setSizes(p_size as byte, q_size as byte, r_size as byte) as void
		
	def CalculateNoise() as void
	def CalculateMesh() as void
	
	
