import System
import LibNoise
import Algorithmic

class MineralNoiseData (INoiseData):
	total_select as Modifier.Select
	seed = Settings.Seed
	coord_scale = 1/Settings.TerrainDepth

	def constructor():
		Grass = Primitive.Constant(BLOCK.GRASS cast int)
		Solid = Primitive.Constant(BLOCK.SOLID cast int)
		Rock = Primitive.Constant(BLOCK.ROCK cast int)
		Dirt = Primitive.Constant(BLOCK.DIRT cast int)
		Air = Primitive.Constant(BLOCK.AIR cast int)
		
		gradient = Primitive.MyGradient(0.0, 0.0, 0.0, 0.0, 1.0, 0.0)

		rock_select = Modifier.Select(gradient, Rock, Air, -1.0, 0.0, 0.0)
		dirt_select = Modifier.Select(gradient, Dirt, Air, 0.0, 0.075, 0.0)
		basic_land = Combiner.Max(dirt_select, rock_select)
		

		lowlands = Filter.SumFractal(Settings.Frequency, Settings.Lacunarity, Settings.Exponent + 0.75, Settings.OctaveCount)
		lowlands.Primitive3D = Primitive.ImprovedPerlin(seed, NoiseQuality.Standard)
		lowlands_scale = Modifier.ScaleBias(lowlands, 0.5, 0)
		lowlands_turbulence = Transformer.Turbulence(basic_land, Air, lowlands_scale, Air, Settings.Power - 0.2)

		hillcountry = Filter.SumFractal(Settings.Frequency, Settings.Lacunarity, Settings.Exponent + 0.75, Settings.OctaveCount)
		hillcountry.Primitive3D = Primitive.ImprovedPerlin(seed+111111, NoiseQuality.Standard)
		hillcountry_turbulence = Transformer.Turbulence(basic_land, Air, hillcountry, Air, Settings.Power + 0.1)

		terrain_type = Filter.SumFractal(0.5, Settings.Lacunarity, Settings.Exponent, Settings.OctaveCount)
		terrain_type.Primitive3D = Primitive.ImprovedPerlin(seed+9943, NoiseQuality.Standard)
		terrain_type_select = Modifier.Select(terrain_type, lowlands_turbulence, hillcountry_turbulence, -1.0, 0.0, 0.0)
		
		
		total_select = terrain_type_select

		
		

	def getBlock(x as long, y as long, z as long) as int:
		return total_select.GetValue(x * coord_scale, y*coord_scale, z*coord_scale)
		#return Modifier.Select(Model.Plane(Filter.Voronoi()), Rock, Dirt, -1.0, 0.0, 0.0).
	
		#return total_select.GetValue(x * coord_scale, y*coord_scale, z*coord_scale)
