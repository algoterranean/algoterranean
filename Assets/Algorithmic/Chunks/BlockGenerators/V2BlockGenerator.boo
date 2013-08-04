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
		hills.Lacunarity = 0.5 # 2.5
		hills.OctaveCount = 3.0
		hills.Primitive3D = Primitive.SimplexPerlin(seed, NoiseQuality.Standard)
		
		turb = Transformer.Displace(gradient,
									Primitive.Constant(0),
									Modifier.Cache2D(Modifier.ScaleBias(hills, 5, 0)),
									Primitive.Constant(0))

		total_select = turb #Modifier.Select(turb, bedrock, air, 0.0, 0.5, 0.0)

		
		# # 2. then we want a few layers of soil above the bedrock.
		# air = Constant(0)
		# bedrock = Constant(30)
		# topsoil = Constant(33)
		# subsoil = Constant(32)
		# subsoil2 = Constant(33)


		# layer0 = VerticalFill(Constant(91), air, 7)
		# layer1 = VerticalFill(topsoil, layer0, 6)
		# layer2 = VerticalFill(subsoil, layer1, 4)
		# layer3 = VerticalFill(subsoil2, layer2, 2)
		# layer4 = VerticalFill(bedrock, layer3, 0)


		# # frequency
		# # lacunarity: how quickly the frequency increases per octave
		# # exponent
		# # octaves

		# hills = Filter.Billow() #0.01, 1, 1, 6)
		# # hills = Filter.SinFractal() #2.0, 2.5, 1.0, 3.0)
		# hills.Frequency = 0.05 #2.0
		# hills.Lacunarity = 0.5 # 2.5
		# hills.OctaveCount = 3.0
		# # hills.Frequency = 0.2
		# # hills.Lacunarity = 1
		# # hills.OctaveCount = 3
		# hills.Primitive3D = Primitive.SimplexPerlin(seed, NoiseQuality.Standard)

		# turb = Transformer.Displace(layer4,
		# 							Primitive.Constant(1),
		# 							Modifier.Cache2D(hills),
		# 							Primitive.Constant(1))
		
		# total_select = turb



	def getBlock(x as long, y as long, z as long) as single:
		f = total_select.GetValue(x, y, z)
		
		# (y + Settings.Chunks.Size * Settings.Chunks.MaxVertical) * vert_scale,
		# z * vert_scale)
		
		# f = total_select.GetValue(x, y, z)
		# print "BLOCK $f ($x, $y, $z)"

		return f
		# return total_select.GetValue(x, y, z)
	
