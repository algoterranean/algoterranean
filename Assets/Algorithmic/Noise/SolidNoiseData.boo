import Algorithmic
import LibNoise
import UnityEngine

class SolidNoiseData (INoiseData):
	select as Primitive.Constant
	coord_scale = 1/Settings.TerrainDepth
	
	def constructor():
		select = Primitive.Constant(BLOCK.ROCK cast int)

	def getBlock(x as long, y as long, z as long) as int:
		return select.GetValue(x * coord_scale, y*coord_scale, z*coord_scale)
