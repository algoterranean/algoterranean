import LibNoise
import Algorithmic.Chunks

class BiomeNoiseData2 (INoiseData):
	total_select as Transformer.Turbulence

	voronoi_select as Filter.Voronoi
	seed = Settings.Seed
	coord_scale = 1/Settings.TerrainDepth * 4

	
	def constructor():
		Air = Primitive.Constant(BLOCK.AIR cast int)		
		b1 = Primitive.Constant(BLOCK.DIRT cast int)
		b2 = Primitive.Constant(BLOCK.ROCK cast int)
		b3 = Primitive.Constant(BLOCK.GRASS cast int)
		b4 = Primitive.Constant(BLOCK.SWAMP cast int)
		b5 = Primitive.Constant(BLOCK.WATER cast int)
		b6 = Primitive.Constant(BLOCK.BLOOD cast int)
		b7 = Primitive.Constant(BLOCK.MAGMA cast int)
		b8 = Primitive.Constant(BLOCK.MUD cast int)
		
		
		gradient = Primitive.MyGradient(0.0, 0.0, 0.0, 0.0, 1.0, 0.0)
		
		voronoi_select = Filter.Voronoi()
		# voronoi_select.Displacement = 0.5
		# voronoi_select.Frequency = 0.1
		voronoi_select.Primitive3D = Primitive.BevinsValue(seed + 11111, NoiseQuality.Standard)
		c = Modifier.Cache2D(voronoi_select)
		
		s1 = Modifier.Select(c, b1, b2, 0, 0.1, 0)
		s2 = Modifier.Select(c, s1, b3, 0, 0.2, 0)
		s3 = Modifier.Select(c, s2, b4, 0, 0.3, 0)
		s4 = Modifier.Select(c, s3, b5, 0, 0.4, 0)
		s5 = Modifier.Select(c, s4, b6, 0, 0.5, 0)
		s6 = Modifier.Select(c, s5, b7, 0, 0.6, 0)
		s7 = Modifier.Select(c, s6, b8, 0, 0.7, 0)


		c2 = Modifier.Cache2D(Primitive.ImprovedPerlin(1, NoiseQuality.Fast))
		c3 = Modifier.Cache2D(Primitive.ImprovedPerlin(21, NoiseQuality.Fast))
		
		biome_select = Modifier.Select(gradient, s7, Air, -1.0, 0.0, 0.0)
		total_select = Transformer.Turbulence(biome_select,
											  c2,
											  Primitive.Constant(1),
											  c3,
											  0.5)



		
		# # frequency, lacunarity, exponent, octaves
		lowlands = Filter.SumFractal(0.3, 0.8, 1.0, 1.0)
		lowlands.Primitive3D = Primitive.SimplexPerlin(seed, NoiseQuality.Standard)
		lowlands_turb = Transformer.Displace(Modifier.Select(gradient, b1, Air, -1, 0, 0),
											Primitive.Constant(1),
											Modifier.ScaleBias(lowlands, 0.2, 0.0),
											Primitive.Constant(1))

		s1 = Modifier.Select(c, lowlands_turb, Modifier.Select(gradient, b2, Air, -1, 0, 0), 0, 0.14, 0)
		s2 = Modifier.Select(c, s1, Modifier.Select(gradient, b3, Air, -1, 0, 0), 0, 0.28, 0)
		s3 = Modifier.Select(c, s2, Modifier.Select(gradient, b4, Air, -1, 0, 0), 0, 0.42, 0)
		s4 = Modifier.Select(c, s3, Modifier.Select(gradient, b5, Air, -1, 0, 0), 0, 0.57, 0)
		s5 = Modifier.Select(c, s4, Modifier.Select(gradient, b6, Air, -1, 0, 0), 0, 0.71, 0)
		s6 = Modifier.Select(c, s5, Modifier.Select(gradient, b7, Air, -1, 0, 0), 0, 0.86, 0)
		#s7 = Modifier.Select(c, s6, Modifier.Select(gradient, b8, Air, -1, 0, 0), 0, 0.7, 0)
		
		# biome_select = Modifier.Select(gradient, s1, Air, -1.0, 0.0, 0.0)
		total_select = Transformer.Turbulence(s6,
											  c2,
											  Primitive.Constant(1),
											  c3,
											  0.5)

		
		




											  


															   
											  


		# gradient = Primitive.MyGradient(0.0, 0.0, 0.0, 0.0, 1.0, 0.0)
		# basic_land = Modifier.Select(gradient, Lowland_Block, Air, -1.0, 0.0, 0.0)
		# basic_land2 = Modifier.Select(gradient, Highland_Block, Air, -1.0, 0.0, 0.0)		

		# # frequency, lacunarity, exponent, octaves
		# lowlands = Filter.SumFractal(0.3, 0.8, 1.0, 1.0)
		# lowlands.Primitive3D = Primitive.SimplexPerlin(seed, NoiseQuality.Standard)
		# lowlands_turb = Tranformer.Displace(basic_land,
		# 									Primitive.Constant(1),
		# 									Modifier.ScaleBias(lowlands, 0.2, 0.0),
		# 									Primitive.Constant(1))


		# highlands = Filter.SumFractal(0.3, 3.0, 1.0, 3.0)
		# highlands.Primitive3D = Primitive.SimplexPerlin(seed, NoiseQuality.Standard)
		# highlands_turb = Tranformer.Displace(basic_land2,
		# 									Primitive.Constant(1),
		# 									Modifier.ScaleBias(highlands, 0.5, 0.0),
		# 									Primitive.Constant(1))
		
		# #biome_select = Filter.SumFractal(0.1, 1.0, 1.0, 2.0) # lowering frequency drasticly spreads out the biome select function
		# biome_select = Filter.Billow()
		# #biome_select.Bias = -1.0
		# biome_select.Primitive3D = Primitive.SimplexPerlin(seed+999, NoiseQuality.Standard)


		# voronoi_select = Filter.Voronoi()
		# #voronoi_select.Distance = true
		# voronoi_select.Displacement = 0.5
		# voronoi_select.Frequency = 0.1
		# voronoi_select.Primitive3D = Primitive.BevinsValue(seed + 11111, NoiseQuality.Standard)

		# total_select = Modifier.Select(Modifier.Cache2D(voronoi_select), lowlands_turb, highlands_turb, 0.0, 0.5, 0.0)
		


	def getBlock(x as long, y as long, z as long) as byte:
		# if biome_select.GetValue(x * coord_scale, 0, z * coord_scale) >= 0.8:
		# 	return highlands_turb.GetValue(x * coord_scale, y * coord_scale, z * coord_scale)
		# else:
		# 	return lowlands_turb.GetValue(x * coord_scale, y * coord_scale, z * coord_scale)
		
		return total_select.GetValue(x * coord_scale,
									 y * coord_scale,
									 z * coord_scale)
