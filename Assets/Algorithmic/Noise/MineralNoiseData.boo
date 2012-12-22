import System
import LibNoise
import Algorithmic

class MineralNoiseData (INoiseData):
	total_select as Modifier.Select
	seed = Settings.Seed
	coord_scale = 1/Settings.TerrainDepth	

	def constructor():
		Forest = Primitive.Constant(BLOCK.GRASS cast int)
		Solid = Primitive.Constant(BLOCK.SOLID cast int)
		Dirt = Primitive.Constant(BLOCK.DIRT cast int)
		Air = Primitive.Constant(BLOCK.AIR cast int)
		
		#v = Filter.Voronoi()
		#v.Primitive3D = Primitive.ImprovedPerlin(3000+seed, NoiseQuality.Standard)
		gradient = Primitive.MyGradient(0.0, 0.0, 0.0, 0.0, 1.0, 0.0)
		total_select = Modifier.Select(gradient, Dirt, Air, -1.0, 0.0, 0.0)
		

	def getBlock(x as long, y as long, z as long) as int:
		return total_select.GetValue(x * coord_scale, y*coord_scale, z*coord_scale)
