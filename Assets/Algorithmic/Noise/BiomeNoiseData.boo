import LibNoise
import Algorithmic.Chunks

class BiomeNoiseData (INoiseData):
	total_select as Modifier.Select
	biome_select as Filter.Billow
	lowlands_turb as Transformer.Displace
	highlands_turb as Transformer.Displace

	voronoi_select as Filter.Voronoi
	seed = Settings.Seed
	coord_scale = 1/Settings.TerrainDepth * 4

	
	def constructor():
		Lowland_Block = Primitive.Constant(BLOCK.DIRT cast int)
		Highland_Block = Primitive.Constant(BLOCK.SOLID cast int)
		Air = Primitive.Constant(BLOCK.AIR cast int)

		gradient = Primitive.MyGradient(0.0, 0.0, 0.0, 0.0, 1.0, 0.0)
		basic_land = Modifier.Select(gradient, Lowland_Block, Air, -1.0, 0.0, 0.0)
		basic_land2 = Modifier.Select(gradient, Highland_Block, Air, -1.0, 0.0, 0.0)		

		# frequency, lacunarity, exponent, octaves
		lowlands = Filter.SumFractal(0.3, 0.8, 1.0, 1.0)
		lowlands.Primitive3D = Primitive.SimplexPerlin(seed, NoiseQuality.Standard)
		lowlands_turb = Tranformer.Displace(basic_land,
											Primitive.Constant(1),
											Modifier.ScaleBias(lowlands, 0.2, 0.0),
											Primitive.Constant(1))


		highlands = Filter.SumFractal(0.3, 3.0, 1.0, 3.0)
		highlands.Primitive3D = Primitive.SimplexPerlin(seed, NoiseQuality.Standard)
		highlands_turb = Tranformer.Displace(basic_land2,
											Primitive.Constant(1),
											Modifier.ScaleBias(highlands, 0.5, 0.0),
											Primitive.Constant(1))
		
		#biome_select = Filter.SumFractal(0.1, 1.0, 1.0, 2.0) # lowering frequency drasticly spreads out the biome select function
		biome_select = Filter.Billow()
		#biome_select.Bias = -1.0
		biome_select.Primitive3D = Primitive.SimplexPerlin(seed+999, NoiseQuality.Standard)


		voronoi_select = Filter.Voronoi()
		#voronoi_select.Distance = true
		voronoi_select.Displacement = 0.5
		voronoi_select.Frequency = 0.1
		voronoi_select.Primitive3D = Primitive.BevinsValue(seed + 11111, NoiseQuality.Standard)

		total_select = Modifier.Select(Modifier.Cache2D(voronoi_select), lowlands_turb, highlands_turb, 0.0, 0.5, 0.0)
		


	def getBlock(x as long, y as long, z as long) as byte:
		# if biome_select.GetValue(x * coord_scale, 0, z * coord_scale) >= 0.8:
		# 	return highlands_turb.GetValue(x * coord_scale, y * coord_scale, z * coord_scale)
		# else:
		# 	return lowlands_turb.GetValue(x * coord_scale, y * coord_scale, z * coord_scale)
		
		return total_select.GetValue(x * coord_scale,
									 y * coord_scale,
									 z * coord_scale)
