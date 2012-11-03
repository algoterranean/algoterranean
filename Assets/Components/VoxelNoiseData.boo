import System
import UnityEngine
import LibNoise


class VoxelNoiseData (MonoBehaviour):
	perlin as LibNoise.Primitive.SimplexPerlin
	octave_sum as LibNoise.Filter.SumFractal
	frequency as single = 2.5
	lacunarity as single = 2.5
	exponent as single = 1.0
	octave_count as single = 4.0
	gradient as LibNoise.Primitive.MyGradient
	turbulence as LibNoise.Tranformer.Turbulence
	
	seed_generator = System.Random(System.DateTime.Now.Ticks & 0x0000FFFF)
	seed = seed_generator.Next()
	coord_scale = 1/50.0

	# cave_perlin_x as LibNoise.Primitive.SimplexPerlin
	# cave_turb_x as LibNoise.Filter.SumFractal
	# cave_perlin_z as LibNoise.Primitive.SimplexPerlin
	# cave_turb_z as LibNoise.Filter.SumFractal
	# cave_perlin_y as LibNoise.Primitive.SimplexPerlin
	# cave_turb_y as LibNoise.Filter.SumFractal
	# cave_turb as LibNoise.Tranformer.Turbulence

	def Awake ():
		perlin = Primitive.SimplexPerlin(seed, NoiseQuality.Best)
		octave_sum = Filter.SumFractal()
		octave_sum.Frequency = frequency
		octave_sum.Lacunarity = lacunarity
		octave_sum.SpectralExponent = exponent
		octave_sum.OctaveCount = octave_count
		octave_sum.Primitive3D = perlin
		gradient = Primitive.MyGradient(0.0, 0.0, 0.0, 0.0, 0.0, 1.0)
		turbulence = Tranformer.Turbulence(gradient, LibNoise.Primitive.Constant(0), LibNoise.Primitive.Constant(0), perlin, 0.3)

		# cave_perlin_x = Primitive.SimplexPerlin(1001, NoiseQuality.Best)
		# cave_turb_x = Filter.SumFractal()
		# cave_turb_x.Frequency = 3.0
		# cave_turb_x.Lacunarity = lacunarity
		# cave_turb_x.SpectralExponent = exponent
		# cave_turb_x.OctaveCount = 3
		# cave_turb_x.Primitive3D = cave_perlin_x

		# cave_perlin_z = Primitive.SimplexPerlin(1201, NoiseQuality.Best)
		# cave_turb_z = Filter.SumFractal()
		# cave_turb_z.Frequency = 3.0
		# cave_turb_z.Lacunarity = lacunarity
		# cave_turb_z.SpectralExponent = exponent
		# cave_turb_z.OctaveCount = 3
		# cave_turb_z.Primitive3D = cave_perlin_z
		

		# cave_perlin_y = Primitive.SimplexPerlin(1301, NoiseQuality.Best)
		# cave_turb_y = Filter.SumFractal()
		# cave_turb_y.Frequency = 3.0
		# cave_turb_y.Lacunarity = lacunarity
		# cave_turb_y.SpectralExponent = exponent
		# cave_turb_y.OctaveCount = 3
		# cave_turb_y.Primitive3D = cave_perlin_y


		# cave_shape_1 = Filter.RidgedMultiFractal()
		# cave_sum_1 = Filter.SumFractal()
		# cave_sum_1
		

		# cave_turb = Tranformer.Turbulence()
		

		
		

	def GetDensity (x as int, z as int, y as int) as single:
		density = turbulence.GetValue(x*coord_scale, z*coord_scale, y*coord_scale)
		return density

