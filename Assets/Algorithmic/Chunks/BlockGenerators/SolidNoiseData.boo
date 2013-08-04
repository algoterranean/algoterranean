import Algorithmic.Chunks
import LibNoise
import UnityEngine

class SolidNoiseData: #(INoiseData):
	select as Primitive.Constant
	coord_scale = 1/Settings.Chunks.Depth
	
	def constructor():
		select = Primitive.Constant(50)

	def getBlock(x as long, y as long, z as long) as byte:
		if y <= 54:
			return 50
		else:
			return 0 #select.GetValue(x * coord_scale, y*coord_scale, z*coord_scale)
