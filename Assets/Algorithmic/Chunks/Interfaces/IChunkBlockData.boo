import UnityEngine

interface IChunkBlockData ():
	def setCoordinates(coords as WorldBlockCoordinate) as void
	def getCoordinates() as WorldBlockCoordinate
	def setSize(sizes as ByteVector3) as void
	def getSize() as ByteVector3
	def setBlock(coords as ByteVector3, block as byte) as void
	def getBlock(coords as ByteVector3) as byte
	def getBlock(x as byte, y as byte, z as byte) as byte
	def areBlocksCalculated() as bool
	def isNull() as bool
	def CalculateBlocks() as void

		
	
