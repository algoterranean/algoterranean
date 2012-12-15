import UnityEngine

interface IChunkBlockData ():
	def setCoordinates(coords as Vector3) as void
	def getCoordinates() as Vector3
	def setSize(sizes as Vector3) as void
	def getSize() as Vector3
	def setBlock(coords as Vector3, block as byte) as void
	def getBlocks(coords as Vector3) as byte
	def areBlocksCalculated() as bool
	def CalculateBlocks() as void

		
	
