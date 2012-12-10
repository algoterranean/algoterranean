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

	###################################################
	def areNeighborsReady() as bool
	def setNeighboringChunks(west as IChunk, east as IChunk,
					 south as IChunk, north as IChunk,
					 down as IChunk, up as IChunk) as void
		
	def setEastChunk(east as IChunk) as void
	def setWestChunk(west as IChunk) as void
	def setSouthChunk(south as IChunk) as void
	def setNorthChunk(north as IChunk) as void
	def setDownChunk(down as IChunk) as void
	def setUpChunk(up as IChunk) as void

	def getEastChunk() as IChunk
	def getWestChunk() as IChunk
	def getSouthChunk() as IChunk
	def getNorthChunk() as IChunk
	def getDownChunk() as IChunk
	def getUpChunk() as IChunk		
	
	
