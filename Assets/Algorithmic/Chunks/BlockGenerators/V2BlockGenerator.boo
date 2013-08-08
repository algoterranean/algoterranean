import LibNoise
import Algorithmic.Chunks
import LibNoise.Primitive
import UnityEngine


# 1. Noise values take the range of (-1, 1).
# 2. Noise values less than 0 are solid, greater than 1 are air. 


class V2BlockGenerator:
	seed = Settings.Terrain.Seed
	total_select as IModule3D
	vert_scale as single

	def constructor():
		vert_scale = 1.0 / ((Settings.Chunks.MaxVertical * 2 + 1) * Settings.Chunks.Size)
		# 1. all blocks above a threshold, height-wise should be air, and all below bedrock.

		gradient = SimpleVerticalGradient(-Settings.Chunks.MaxVertical * Settings.Chunks.Size,
										  Settings.Chunks.MaxVertical * Settings.Chunks.Size)
		air = Constant(0)
		bedrock = Constant(30)


		# hills = Filter.Billow() #0.01, 1, 1, 6)
		hills = Filter.SumFractal() #2.0, 2.5, 1.0, 3.0)
		hills.Frequency = 0.02 #2.0
		hills.Lacunarity = 2.5 # 2.5
		hills.OctaveCount = 4.0
		hills.Primitive3D = Primitive.SimplexPerlin(seed, NoiseQuality.Standard)
		
		turb = Transformer.Displace(gradient,
									Primitive.Constant(1),
									Modifier.Cache2D(Modifier.ScaleBias(hills, 10, 0)),
									Primitive.Constant(1))
		# octave_sum = Filter.SumFractal(2.5,
		# 							   1.2,
		# 							   1.0,
		# 							   4.0)
		# octave_sum.Primitive3D = Primitive.ImprovedPerlin(seed+1111, NoiseQuality.Standard)

		# total_select = Transformer.Turbulence(turb, octave_sum, octave_sum, octave_sum, 1.0)
		total_select = turb

		

	def getBlock(x as long, y as long, z as long) as single:
		f = total_select.GetValue(x, y, z)
		
		return f

	
