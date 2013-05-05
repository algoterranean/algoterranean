import Algorithmic.Chunks
import LibNoise
import UnityEngine

class SolidNoiseData (INoiseData):
	select as Primitive.Constant
	coord_scale = 1/Settings.TerrainDepth
	
	def constructor():
		select = Primitive.Constant(BLOCK.ROCK cast int)

	def getBlock(x as long, y as long, z as long) as int:
		if y <= 54:
			return 50
		else:
			return 0 #select.GetValue(x * coord_scale, y*coord_scale, z*coord_scale)
