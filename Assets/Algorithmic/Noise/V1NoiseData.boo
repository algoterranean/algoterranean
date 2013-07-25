import LibNoise
import Algorithmic.Chunks
import LibNoise.Primitive



class V1NoiseData (INoiseData):
	seed = Settings.Terrain.Seed
	total_select as IModule3D

	def constructor():
		# 1. all blocks above a threshold, height-wise should be air, and all below bedrock.
		# 2. then we want a few layers of soil above the bedrock.
		air = Constant(BLOCK.AIR cast int)
		bedrock = Constant(BLOCK.BEDROCK cast int)
		topsoil = Constant(BLOCK.TOPSOIL cast int)
		subsoil = Constant(BLOCK.SUBSOIL cast int)
		subsoil2 = Constant(BLOCK.SUBSOIL2 cast int)


		layer1 = VerticalFill(topsoil, air, 10)
		layer2 = VerticalFill(subsoil, layer1, 8)
		layer3 = VerticalFill(subsoil2, layer2, 4)
		layer4 = VerticalFill(bedrock, layer3, 0)
		


		# frequency
		# lacunarity: how quickly the frequency increases per octave
		# exponent
		# octaves
		hills = Filter.SumFractal(0.1, 0.1, 1.2, 2.0)
		hills.Primitive3D = Primitive.SimplexPerlin(seed, NoiseQuality.Standard)


		
		turb = Transformer.Displace(layer4,
									Primitive.Constant(1),
									Modifier.Cache2D(hills),
									Primitive.Constant(1))
		
		total_select = turb



	def getBlock(x as long, y as long, z as long) as byte:
		return total_select.GetValue(x, y, z)
	
