import LibNoise
import Algorithmic.Chunks




class FormFlatNoiseData (INoiseData):
	seed = Settings.Terrain.Seed
	# coord_scale = 1 / (Settings.Chunks.MaxVertical * Settings.Chunks.Size)
	#1/Settings.Chunks.Depth * 4
	total_select as IModule3D

	def constructor():
		air = Primitive.Constant(BLOCK.AIR cast int)		
		solid = Primitive.Constant(BLOCK.ROCK cast int)
		

		# basic ground structure (splits the world vertically between solid and air)
		gradient = Primitive.MyGradient(0.0, Settings.Chunks.Size/2, 0.0,
										0.0, Settings.Chunks.MaxVertical * Settings.Chunks.Size + Settings.Chunks.Size/2, 0.0)
		c = Modifier.Clamp(gradient, -1.0, 1.0)
		ground_select = Modifier.Select(gradient, solid, air, -1.0, 0.0, 0.0)

		# hills
		hills = Filter.SumFractal(0.1, 0.1, 1.2, 2.0)
		hills.Primitive3D = Primitive.SimplexPerlin(seed, NoiseQuality.Standard)
		
		
		turb = Transformer.Displace(ground_select,
									Primitive.Constant(1),
									hills,
									Primitive.Constant(1))
									
		

		total_select = turb
		
		

	def getBlock(x as long, y as long, z as long) as byte:
		return total_select.GetValue(x, y, z)
