import LibNoise
import Algorithmic

class HeightNoiseData (INoiseData):
	total_select as Modifier.Select
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
		lowlands.Primitive3D = Primitive.ImprovedPerlin(seed, NoiseQuality.Standard)
		lowlands_turb = Tranformer.Displace(basic_land,
											Primitive.Constant(1),
											Modifier.ScaleBias(lowlands, 0.5, 0.0),
											Primitive.Constant(1))


		highlands = Filter.SumFractal(2.0, 2.0, 1.0, 2.0)
		highlands.Primitive3D = Primitive.ImprovedPerlin(seed+1001, NoiseQuality.Standard)
		highlands_turb = Tranformer.Displace(basic_land2,
											Primitive.Constant(1),
											Modifier.ScaleBias(highlands, 0.8, 0.0),
											Primitive.Constant(1))
		
		d = Filter.SumFractal(1.0, 0.5, 0.5, 1.0)
		d.Primitive3D = Primitive.ImprovedPerlin(seed, NoiseQuality.Standard)
		
		total_select = Modifier.Select(d, lowlands_turb, highlands_turb, -1.0, 0.0, 0.0)
		#total_select = highlands_turb

		# voronoi = Filter.Voronoi()
		# voronoi.Primitive3D = Primitive.ImprovedPerlin(seed, NoiseQuality.Standard)
		# voronoi_select = Modifier.Select(voronoi, lowlands_turb, highlands_turb, -1.0, 0.0, 0.0)

		# total_select = voronoi_select




	def getBlock(x as long, y as long, z as long) as int:
		return total_select.GetValue(x * coord_scale,
									 y * coord_scale,
									 z * coord_scale)
