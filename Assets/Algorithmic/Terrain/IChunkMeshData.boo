import UnityEngine

interface IChunkMeshData ():
	def setNeighborhoodChunks(west as IChunkBlockData, east as IChunkBlockData,
					  south as IChunkBlockData, north as IChunkBlockData,
					  down as IChunkBlockData, up as IChunkBlockData) as void
	def isMeshCalcualted() as bool
	def CalculateMesh() as void
		
	def getVertices() as (Vector3)
	def getNormals() as (Vector3)
	def getTriangles() as (int)
	def getUVs() as (Vector2)
