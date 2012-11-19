import System
import UnityEngine
import LibNoise


class VoxelNoiseData (MonoBehaviour):
	perlin as LibNoise.Primitive.ImprovedPerlin
	octave_sum as LibNoise.Filter.SumFractal
	
	gradient as LibNoise.Primitive.MyGradient
	turbulence as LibNoise.Transformer.Turbulence
	
	#seed_generator = System.Random(System.DateTime.Now.Ticks & 0x0000FFFF)
	seed = Settings.Seed
	#seed_generator.Next()
	coord_scale = 1/Settings.TerrainDepth

	# cave_perlin_x as LibNoise.Primitive.SimplexPerlin
	# cave_turb_x as LibNoise.Filter.SumFractal
	# cave_perlin_z as LibNoise.Primitive.SimplexPerlin
	# cave_turb_z as LibNoise.Filter.SumFractal
	# cave_perlin_y as LibNoise.Primitive.SimplexPerlin
	# cave_turb_y as LibNoise.Filter.SumFractal
	# cave_turb as LibNoise.Tranformer.Turbulence
	cave_perlin_1 as LibNoise.Primitive.BevinsGradient
	cave_shape_1 as LibNoise.Filter.RidgedMultiFractal
	cave_scale_1 as LibNoise.Modifier.ScaleBias
	cave_perlin_2 as LibNoise.Primitive.BevinsGradient
	cave_shape_2 as LibNoise.Filter.RidgedMultiFractal
	cave_scale_2 as LibNoise.Modifier.ScaleBias
	cave_mult as LibNoise.Combiner.Max

	cave_invert_1 as LibNoise.Modifier.Invert
	cave_invert_2 as LibNoise.Modifier.Invert
	cave_invert as LibNoise.Modifier.Invert

	constant0 as LibNoise.Primitive.Constant
	constant1 as LibNoise.Primitive.Constant
	constant_neg1 as LibNoise.Primitive.Constant

	Solid as LibNoise.Primitive.Constant
	Air as LibNoise.Primitive.Constant
	Magma as LibNoise.Primitive.Constant
	
	cave_select_1 as LibNoise.Modifier.Select
	cave_select_2 as LibNoise.Modifier.Select	
	cave_turbulence as LibNoise.Transformer.Turbulence
	total_mult as LibNoise.Combiner.Max
	total_select as LibNoise.Modifier.Select
	perlin_select as LibNoise.Modifier.Select

	magma_select as LibNoise.Modifier.Select
	magma_combine as LibNoise.Combiner.Max

	def Awake ():
		constant0 = Primitive.Constant(0)
		constant1 = Primitive.Constant(1)
		constant_neg1 = Primitive.Constant(-1)

		Magma = Primitive.Constant(2)
		Solid = Primitive.Constant(1)
		Air = Primitive.Constant(0)
		
		
		# basic terrain
		octave_sum = Filter.SumFractal(Settings.Frequency, Settings.Lacunarity, Settings.Exponent, Settings.OctaveCount)
		octave_sum.Primitive3D = Primitive.ImprovedPerlin(seed, NoiseQuality.Standard)
		gradient = Primitive.MyGradient(0.0, 0.0, 0.0, 0.0, 0.0, 1.0)
		turbulence = Transformer.Turbulence(gradient, constant0, constant0, octave_sum, Settings.Power)
		perlin_select = Modifier.Select(turbulence, constant0, constant1, -1.0, 0.2, 0.0)

		# caves
		# cave 1
		cave_perlin_1 = Primitive.BevinsGradient(seed, NoiseQuality.Standard)
		cave_shape_1 = Filter.RidgedMultiFractal(2.0, 1.0, 1.0, 1.0) # frequency, lacunarity, exponent, octaves
		cave_shape_1.Primitive3D = cave_perlin_1
		cave_select_1 = Modifier.Select(cave_shape_1,
						constant1, constant0, 0.0, 0.8, 0.0)

		# cave 2
		cave_perlin_2 = Primitive.BevinsGradient(seed+1001, NoiseQuality.Standard)
		cave_shape_2 = Filter.RidgedMultiFractal(2.0, 1.0, 1.0, 1.0) # frequency, lacunarity, exponent, octaves
		cave_shape_2.Primitive3D = cave_perlin_2
		cave_select_2 = Modifier.Select(cave_shape_2,
						constant1, constant0, 0.0, 0.8, 0.0)
		
		# combine caves
		cave_mult = Combiner.Max(cave_select_1, cave_select_2)

		# cave turbulence
		cave_perlin_x = Primitive.ImprovedPerlin(1001, NoiseQuality.Standard)
		cave_sum_x = Filter.SumFractal(3.0, 1.0, 1.0, 3.0) # frequency, lacunarity, exponent, octaves
		cave_sum_x.Primitive3D = cave_perlin_x
		
		cave_perlin_z = Primitive.ImprovedPerlin(1201, NoiseQuality.Standard)
		cave_sum_z = Filter.SumFractal(3.0, 1.0, 1.0, 3.0) # frequency, lacunarity, exponent, octaves
		cave_sum_z.Primitive3D = cave_perlin_z
		
		cave_perlin_y = Primitive.ImprovedPerlin(1301, NoiseQuality.Standard)
		cave_sum_y = Filter.SumFractal(3.0, 1.0, 1.0, 3.0) # frequency, lacunarity, exponent, octaves
		cave_sum_y.Primitive3D = cave_perlin_y

		# final select functions
		cave_turbulence = Transformer.Turbulence(cave_mult, cave_sum_x, cave_sum_z, cave_sum_y, 0.25)
		total_mult = Combiner.Max(perlin_select, LibNoise.Modifier.ScaleBias(cave_turbulence, -1, 1))
		total_select = Modifier.Select(total_mult, constant1, constant0, 0.0, 0.5, 0.0) # 1 = solid, 0 = air


		# magma
		magma_select = Modifier.Select(gradient, Magma, Air, -1.0, -0.9, 0.0)
		
		magma_perlin_x = Primitive.ImprovedPerlin(9999, NoiseQuality.Standard)
		magma_sum_x = Filter.SumFractal(2.0, 2.0, 1.25, 2.0) # frequency, lacunarity, exponent, octaves
		magma_sum_x.Primitive3D = magma_perlin_x
		
		magma_turbulence = Transformer.Turbulence(magma_select, constant0, constant0, magma_sum_x, 0.25)
		magma_combine = Combiner.Max(total_select, magma_select)

		

	def GetBlock (x as int, z as int, y as int) as int:
		# 1 = solid, 0 = air
		block = magma_combine.GetValue(x*coord_scale, z*coord_scale, y*coord_scale)
		#block = total_select.GetValue(x*coord_scale, z*coord_scale, y*coord_scale)
		return block
		
