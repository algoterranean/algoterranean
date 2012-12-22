import LibNoise
import Algorithmic

class BiomeNoiseData (INoiseData):
	total_select as Modifier.Select
	seed = Settings.Seed
	coord_scale = 1/Settings.TerrainDepth	

	def constructor():
		Forest = Primitive.Constant(BLOCK.GRASS cast int)
		Solid = Primitive.Constant(BLOCK.SOLID cast int)
		
		v = Filter.Voronoi()
		v.Primitive3D = Primitive.ImprovedPerlin(3000+seed, NoiseQuality.Standard)
		total_select = Modifier.Select(v, Forest, Solid, -1.0, 0.0, 0.0)
		

	def getBlock(x as long, y as long, z as long) as int:
		return total_select.GetValue(x * coord_scale, y*coord_scale, z*coord_scale)
