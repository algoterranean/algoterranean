import LibNoise
import Algorithmic.Chunks
import LibNoise.Primitive
import UnityEngine



class V1NoiseData (INoiseData):
	seed = Settings.Terrain.Seed
	total_select as IModule3D

	def constructor():
		# 1. all blocks above a threshold, height-wise should be air, and all below bedrock.
		# 2. then we want a few layers of soil above the bedrock.

		air = Constant(0)
		bedrock = Constant(30)
		topsoil = Constant(33)
		subsoil = Constant(32)
		subsoil2 = Constant(33)


		layer0 = VerticalFill(Constant(91), air, 7)
		layer1 = VerticalFill(topsoil, layer0, 6)
		layer2 = VerticalFill(subsoil, layer1, 4)
		layer3 = VerticalFill(subsoil2, layer2, 2)
		layer4 = VerticalFill(bedrock, layer3, 0)


		# frequency
		# lacunarity: how quickly the frequency increases per octave
		# exponent
		# octaves

		hills = Filter.SumFractal(0.01, 1, 1, 6)
		hills.Primitive3D = Primitive.SimplexPerlin(seed, NoiseQuality.Standard)

		turb = Transformer.Displace(layer4,
									Primitive.Constant(1),
									Modifier.Cache2D(hills),
									Primitive.Constant(1))
		
		total_select = turb



	def getBlock(x as long, y as long, z as long) as byte:
		return total_select.GetValue(x, y, z)
	
