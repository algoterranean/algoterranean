import UnityEngine

interface IChunkMeshData ():
	def setNeighborhoodChunks(west as IChunkBlockData, east as IChunkBlockData,
					  south as IChunkBlockData, north as IChunkBlockData,
					  down as IChunkBlockData, up as IChunkBlockData) as void
	def setWestNeighbor(chunk as IChunkBlockData) as void
	def setEastNeighbor(chunk as IChunkBlockData) as void
	def setSouthNeighbor(chunk as IChunkBlockData) as void
	def setNorthNeighbor(chunk as IChunkBlockData) as void
	def setDownNeighbor(chunk as IChunkBlockData) as void
	def setUpNeighbor(chunk as IChunkBlockData) as void
		

	def isMeshCalcualted() as bool
	def areNeighborsReady() as bool
	def CalculateMesh() as void
		
	def getVertices() as (Vector3)
	def getNormals() as (Vector3)
	def getTriangles() as (int)
	def getUVs() as (Vector2)
