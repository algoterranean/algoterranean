import UnityEngine

interface IChunkBall ():
	def setMinChunkDistance(min_distance as byte) as void
	def getMinChunkDistance() as byte
	def setMaxChunkDistance(max_distance as byte) as void
	def getMaxChunkDistance() as byte
	def SetOrigin(origin as Vector3) as void
	def getMaxHeight(location as Vector3) as int
            
