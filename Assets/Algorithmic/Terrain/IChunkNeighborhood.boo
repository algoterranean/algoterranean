namespace Algorithmic

interface IChunkNeighborhood:
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
