namespace Algorithmic.Chunks

#import Algorithmic.Physics
import System.Collections.Generic

# Chunk stores all of the block and light data for a chunk.
# it is also responsible for generating this data via the provided
# generator functions when necessary.
class Chunk:
	coords as WorldBlockCoordinate
	
	size as byte
	blocks as (byte, 3)
	lights as (byte, 3)
	
	mesh_data as MeshData
	mesh_physx_data as MeshData
	
	block_generator as BlockGenerator # TODO: block generator is actually getValue(x, y, z) from a Noise module
	mesh_generator as MeshGenerator
	mesh_physx_generator as MeshGenerator

	_generate_lights as bool
	_generate_blocks as bool
	_generate_mesh as bool
	
	interpolate = true
	

	# coordinates, size, block generator, visual mesh generator, physics mesh generator
	def constructor(c as WorldBlockCoordinate,
					s as byte,
					b_func as BlockGenerator,
					m_func as MeshGenerator,
					m_physx_func as MeshGenerator):
		coords = c
		size = s
		block_generator = b_func
		mesh_generator = m_func
		mesh_physx_generator = m_physx_func
		blocks = matrix(byte, size+1, size+1, size+1) # +1 for last block necessary for interpolation
		lights = matrix(byte, size+1, size+1, size+1)
		_generate_blocks = true
		_generate_mesh = true
		_generate_lights = true


	override def ToString() as string:
		return "$coords"

	GenerateBlocks as bool:
		get:
			return _generate_blocks
		set:
			_generate_blocks = value

	GenerateMesh as bool:
		get:
			return _generate_mesh
		set:
			_generate_mesh = value

	GenerateLights as bool:
		get:
			return _generate_lights
		set:
			_generate_lights = value

	Blocks as (byte, 3):
		get:
			return blocks

	Lights as (byte, 3):
		get:
			return lights


	# this is used to inform the GC that it can reclaim this memory
	# and is called by the Display Manager once it has consumed this
	# data into a Mesh format. obviously this means that there can
	# be only one object handling this chunk's mesh (for now).
	def clearMeshData():
		mesh_data = null
		mesh_physx_data = null
			

	def getBlock(x as byte, y as byte, z as byte) as byte:
		lock blocks:
			return blocks[x, y, z]

	def getLight(x as byte, y as byte, z as byte) as byte:
		lock lights:
			return lights[x, y, z]
		
	def setBlock(x as byte, y as byte, z as byte, val as byte):
		lock blocks:
			blocks[x, y, z] = val

	def setLight(x as byte, y as byte, z as byte, val as byte):
		lock lights:
			lights[x, y, z] = val

	# def trilinear_interpolation(v000 as byte, v100 as byte, v010 as byte,
	# 							v110 as byte, v001 as byte, v101 as byte,
	# 							v011 as byte, v111 as byte,
	# 							x as single, y as single, z as single):

	# 	result = v000 * (1-x)*(1-y)*(1-z) + \
	# 		v100 * x * (1-y) * (1-z) + \
	# 		v010 * (1-x) * y * (1-z) + \
	# 		v110 * x * y * (1-z) + \
	# 		v001 * (1-x) * (1-y) * z + \
	# 		v101 * x * (1-y) * z + \
	# 		v011 * (1-x) * y * z + \
	# 		v111*x*y*z

		

	# 	new_distance = 256
	# 	new_block = 0

	# 	#int d = X > 0 ? X : -X;
	# 	# abs(x) = (x^(x>>31))-(x>>31)
	# 	# r1 = result - v000
	# 	# r2 = result - v100
	# 	# r3 = result - v010
	# 	# r4 = result - v110
	# 	# r5 = result - v001
	# 	# r6 = result - v101
	# 	# r7 = result - v011
	# 	# r8 = result - v111


	# 	a = (result - v000 if result - v000 > 0 else v000 - result)
	# 	b = (result - v100 if result - v100 > 0 else v100 - result)
	# 	c = (result - v010 if result - v010 > 0 else v010 - result)
	# 	d = (result - v110 if result - v110 > 0 else v110 - result)
	# 	e = (result - v001 if result - v001 > 0 else v001 - result)
	# 	f = (result - v101 if result - v101 > 0 else v101 - result)
	# 	g = (result - v011 if result - v011 > 0 else v011 - result)
	# 	h = (result - v111 if result - v111 > 0 else v111 - result)		
	# 	# b = Math.Abs(result - v100)
	# 	# c = Math.Abs(result - v010)
	# 	# d = Math.Abs(result - v110)
	# 	# e = Math.Abs(result - v001)
	# 	# f = Math.Abs(result - v101)
	# 	# g = Math.Abs(result - v011)
	# 	# h = Math.Abs(result - v111)

		
	# 	if h <= new_distance:
	# 		new_block = v111
	# 		new_distance = h
	# 	if g <= new_distance:
	# 		new_block = v011
	# 		new_distance = g
	# 	if f <= new_distance:
	# 		new_block = v101
	# 		new_distance = f
	# 	if e <= new_distance:
	# 		new_block = v001
	# 		new_distance = e
	# 	if d <= new_distance:
	# 		new_block = v110
	# 		new_distance = d
	# 	if c <= new_distance:
	# 		new_block = v010
	# 		new_distance = c
	# 	if b <= new_distance:
	# 		new_block = v100
	# 		new_distance = b
	# 	if a <= new_distance:
	# 		new_block = v000
	# 		new_distance = a

	# 	return new_block

	def trilinear_interpolation(v000 as single, v100 as single, v010 as single,
								v110 as single, v001 as single, v101 as single,
								v011 as single, v111 as single,
								x as single, y as single, z as single):

		result = v000 * (1-x)*(1-y)*(1-z) + \
			v100 * x * (1-y) * (1-z) + \
			v010 * (1-x) * y * (1-z) + \
			v110 * x * y * (1-z) + \
			v001 * (1-x) * (1-y) * z + \
			v101 * x * (1-y) * z + \
			v011 * (1-x) * y * z + \
			v111*x*y*z
		return result
	
	
	# def trilinear_interpolation(v000 as byte, v100 as byte, v010 as byte,
	# 							v110 as byte, v001 as byte, v101 as byte,
	# 							v011 as byte, v111 as byte,
	# 							x as single, y as single, z as single):

	# 	# print "v000: $v000, v100: $v100, v010: $v010, v110: $v110, v001: $v001, v101: $v101, v001: $v001, v111: $v111, x: $x, y: $y, z: $z, block1: $block1, block2: $block2"
	# 	result = v000 * (1-x)*(1-y)*(1-z) + \
	# 		v100 * x * (1-y) * (1-z) + \
	# 		v010 * (1-x) * y * (1-z) + \
	# 		v110 * x * y * (1-z) + \
	# 		v001 * (1-x) * (1-y) * z + \
	# 		v101 * x * (1-y) * z + \
	# 		v011 * (1-x) * y * z + \
	# 		v111*x*y*z

	# 	if Math.Abs(result - v000) >= Math.Abs(v111 - result):
	# 		return v111
	# 	else:
	# 		return v000
		

	# set the lights for any solid block to 0 and any transparent block
	# (that is, AIR) to full brightness. this needs to be called before
	# any flood-fill algorithms for smooth lighting for performance reasons.
	def initializeLights():
		for x in range(size):
			for y in range(size):
				for z in range(size):
					if blocks[x, y, z] > 0:
						lights[x, y, z] = 0
					else:
						lights[x, y, z] = 255

	# generate all of the blocks for this chunk using the provided
	# block generator function. either generate each block directly or
	# use interpolation to generate the "corner" blocks and then interpolate
	# between the corners for performance reasons.
	def generateBlocks():
		if not interpolate:
			scale = 1/Settings.Chunks.Scale
			c_x as long = coords.x / Settings.Chunks.Scale
			c_y as long = coords.y / Settings.Chunks.Scale
			c_z as long = coords.z / Settings.Chunks.Scale
			new_size = size cast int
			lock blocks:
				for x in range(new_size):
					for z in range(new_size):
						for y in range(new_size):
							blocks[x, y, z] = block_generator(x + c_x, y + c_y, z + c_z)

		else:
			temp_floats = matrix(single, size+1, size+1, size+1) # +1 for last block necessary for interpolation
			
			skip_size_x = Settings.Chunks.Interpolate.X
			skip_size_f_x = skip_size_x cast single
			skip_size_y = Settings.Chunks.Interpolate.Y
			skip_size_f_y = skip_size_y cast single
			skip_size_z = Settings.Chunks.Interpolate.Z
			skip_size_f_z = skip_size_z cast single			
			scale = 1/Settings.Chunks.Scale
			c_x2 as long = coords.x / Settings.Chunks.Scale
			c_y2 as long = coords.y / Settings.Chunks.Scale
			c_z2 as long = coords.z / Settings.Chunks.Scale


			
			# set all of the corner blocks necessary for interpolation
			for x in range(0, size+1, skip_size_x):
				for z in range(0, size+1, skip_size_z):
					for y in range(0, size+1, skip_size_y):
						temp_floats[x, y, z] = block_generator(x + c_x2, y + c_y2, z + c_z2)
						# blocks[x, y, z] = 
						
			# generate all the other blocks via interpolation
			for x in range(size+1):
				for y in range(size+1):
					for z in range(size+1):
						# Profiler.BeginSample("INTERPOLATE")
						m_x = x % skip_size_x
						m_y = y % skip_size_y
						m_z = z % skip_size_z
			
						if m_x > 0 or m_y > 0 or m_z > 0:
							x_0 = x / skip_size_x * skip_size_x
							y_0 = y / skip_size_y * skip_size_y
							z_0 = z / skip_size_z * skip_size_z

							x_1 = (x if x == size else x_0 + skip_size_x)
							y_1 = (y if y == size else y_0 + skip_size_y)
							z_1 = (z if z == size else z_0 + skip_size_z)

							# these are the values for all of the "corners"
							v000 = temp_floats[x_0, y_0, z_0]
							v100 = temp_floats[x_1, y_0, z_0]
							v010 = temp_floats[x_0, y_1, z_0]
							v110 = temp_floats[x_1, y_1, z_0]
							v001 = temp_floats[x_0, y_0, z_1]
							v101 = temp_floats[x_1, y_0, z_1]
							v011 = temp_floats[x_0, y_1, z_1]
							v111 = temp_floats[x_1, y_1, z_1]

							relative_x = (x - x_0) / skip_size_f_x
							relative_y = (y - y_0) / skip_size_f_y
							relative_z = (z - z_0) / skip_size_f_z

							result = trilinear_interpolation(v000, v100, v010,
															 v110, v001, v101,
															 v011, v111,
															 relative_x, relative_y, relative_z)
															 # blocks[x_0, y_0, z_0], blocks[x_1, y_1, z_1])
							temp_floats[x, y, z] = result
							
			for x in range(size+1):
				for y in range(size+1):
					for z in range(size+1):
						blocks[x, y, z] = (30 if temp_floats[x, y, z] < 0.5 else 0)




	# use the provided mesh generator functions to generate the physics mesh
	# and the display mesh.
	def generateMesh(neighbors as Dictionary[of WorldBlockCoordinate, Chunk]):
		mesh_data = mesh_generator(self, neighbors)
		mesh_physx_data = mesh_physx_generator(self, neighbors)

	# used by DisplayManager
	def getMeshData() as MeshData:
		return mesh_data

	# used by DisplayManager
	def getMeshPhysXData() as MeshData:
		return mesh_physx_data	

	def getCoords() as WorldBlockCoordinate:
		return coords
	

