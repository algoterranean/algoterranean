import UnityEngine

interface IChunkBlockData ():
	def setCoordinates(coords as LongVector3) as void
	def getCoordinates() as LongVector3
	def setSize(sizes as ByteVector3) as void
	def getSize() as ByteVector3
	def setBlock(coords as ByteVector3, block as byte) as void
	def getBlock(coords as ByteVector3) as byte
	def areBlocksCalculated() as bool
	def isNull() as bool
	def CalculateBlocks() as void

		
	
