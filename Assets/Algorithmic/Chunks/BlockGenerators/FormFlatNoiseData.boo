import LibNoise
import Algorithmic.Chunks




class FormFlatNoiseData: #(INoiseData):
	seed = Settings.Terrain.Seed
	# coord_scale = 1 / (Settings.Chunks.MaxVertical * Settings.Chunks.Size)
	#1/Settings.Chunks.Depth * 4
	total_select as IModule3D
	r = System.Random()

	def constructor():
		air = Primitive.Constant(0)
		grass0 = Primitive.Constant(90)
		grass1 = Primitive.Constant(91)
		grass2 = Primitive.Constant(92)
		grass3 = Primitive.Constant(93)
		grass4 = Primitive.Constant(94)
		grass5 = Primitive.Constant(95)
		grass6 = Primitive.Constant(96)
		grass7 = Primitive.Constant(97)
		grass8 = Primitive.Constant(98)
		grass9 = Primitive.Constant(99)
		

		# basic ground structure (splits the world vertically between solid and air)
		gradient = Primitive.MyGradient(0.0, Settings.Chunks.Size/2, 0.0,
										0.0, Settings.Chunks.MaxVertical * Settings.Chunks.Size + Settings.Chunks.Size/2, 0.0)
		c = Modifier.Clamp(gradient, -1.0, 1.0)
		ground_select = Modifier.Select(gradient, grass0, air, -1.0, 0.0, 0.0)
		

		g0 = Modifier.Select(gradient, grass0, grass1, -1.0, -0.9, 0.0)
		g1 = Modifier.Select(gradient, g0, grass2, -1.0, -0.8, 0.0)
		g2 = Modifier.Select(gradient, g1, grass3, -1.0, -0.7, 0.0)
		g3 = Modifier.Select(gradient, g2, grass4, -1.0, -0.6, 0.0)
		g4 = Modifier.Select(gradient, g3, grass5, -1.0, -0.5, 0.0)
		g5 = Modifier.Select(gradient, g4, grass6, -1.0, -0.4, 0.0)
		g6 = Modifier.Select(gradient, g5, grass7, -1.0, -0.3, 0.0)
		g7 = Modifier.Select(gradient, g6, grass8, -1.0, -0.2, 0.0)
		g8 = Modifier.Select(gradient, g7, grass9, -1.0, -0.1, 0.0)
		g9 = Modifier.Select(gradient, g8, air, -1.0, 0.0, 0.0)


		# hills
		hills = Filter.SumFractal(0.1, 0.1, 1.2, 2.0)
		hills.Primitive3D = Primitive.SimplexPerlin(seed, NoiseQuality.Standard)
		
		turb = Transformer.Displace(g9,
									Primitive.Constant(1),
									hills,
									Primitive.Constant(1))
									
		

		total_select = turb
		
		

	def getBlock(x as long, y as long, z as long) as byte:
		return total_select.GetValue(x, y, z)
		
		# if b == BLOCK.GRASS0:
		# 	newval = r.Next(0, 9)
		# 	if newval == 0:
		# 		b = 90
		# 	elif newval == 1:
		# 		b = 91
		# 	elif newval == 2:
		# 		b = 92
		# 	elif newval == 3:
		# 		b = 93
		# 	elif newval == 4:
		# 		b = 94
		# 	elif newval == 5:
		# 		b = 95
		# 	elif newval == 6:
		# 		b = 96
		# 	elif newval == 7:
		# 		b = 97
		# 	elif newval == 8:
		# 		b = 98
		# 	elif newval == 9:
		# 		b = 99
			
		# return b
