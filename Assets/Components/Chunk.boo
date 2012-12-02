
class NullChunk():
	def constructor():
		pass
	def IsNull():
		return true
	def BlocksGenerated():
		return true
	def GetBlock(x as byte, z as byte, y as byte):
		return 0

class Chunk (NullChunk):
	blocks_generated as bool
	mesh_generated as bool
	mesh_visible as bool
	blocks as (byte, 3)
	noise_module as VoxelNoiseData
	x_coord as long
	z_coord as long
	y_coord as long
	x_size as byte
	z_size as byte
	y_size as byte
	north_chunk as NullChunk = NullChunk()
	south_chunk as NullChunk = NullChunk()
	east_chunk as NullChunk = NullChunk()
	west_chunk as NullChunk = NullChunk()
	up_chunk as NullChunk = NullChunk()
	down_chunk as NullChunk = NullChunk()

	public vertices as (Vector3)
	public triangles as (int)
	public uvs as (Vector2)
	public colors as (Color32)
	public normals as (Vector3)


	def constructor(x_coord as long, z_coord as long, y_coord as long, x_size as byte, z_size as byte, y_size as byte):
		self.x_coord = x_coord
		self.z_coord = z_coord
		self.y_coord = y_coord
		self.x_size = x_size
		self.z_size = z_size
		self.y_size = y_size
		blocks = matrix(byte, x_size, z_size, y_size)
		noise_module = VoxelNoiseData()
		blocks_generated = false
		mesh_generated = false
		mesh_visible = false

	def AreNeighborsReady():
		if (north_chunk.IsNull() or north_chunk.BlocksGenerated()) and \
		    (south_chunk.IsNull() or south_chunk.BlocksGenerated()) and \
		    (east_chunk.IsNull() or east_chunk.BlocksGenerated()) and \
		    (west_chunk.IsNull() or west_chunk.BlocksGenerated()) and \
		    (up_chunk.IsNull() or up_chunk.BlocksGenerated()) and \
		    (down_chunk.IsNull() or down_chunk.BlocksGenerated()):
			return true
		return false
			
			

	def GenerateNoise():
		for x in range(x_size):
			for z in range(z_size):
				for y in range(y_size):
					blocks[x,z,y] = noise_module.GetBlock(x + x_coord, z + z_coord, y + y_coord)
					
		lock blocks_generated:
			blocks_generated = true


	def SetNorthChunk(c as Chunk):
		lock north_chunk:
			north_chunk  = c

	def SetSouthChunk(c as Chunk):
		lock south_chunk:
			south_chunk = c

	def SetEastChunk(c as Chunk):
		lock east_chunk:
			east_chunk = c

	def SetWestChunk(c as Chunk):
		lock west_chunk:
			west_chunk = c

	def SetUpChunk(c as Chunk):
		lock up_chunk:
			up_chunk = c

	def SetDownChunk(c as Chunk):
		lock down_chunk:
			down_chunk = c

	def IsNull():
		return false

	def IsVisible():
		return mesh_visible

	def SetVisible(mesh_visible as bool):
		lock self.mesh_visible:
			self.mesh_visible = mesh_visible
	
	def BlocksGenerated ():
		lock blocks_generated:
			return blocks_generated

	def MeshGenerated ():
		lock mesh_generated:
			return mesh_generated

	def MeshVisible ():
		lock mesh_visible:
			return mesh_visible

	def GetCoordinates ():
		return {'x': x_coord, 'z': z_coord, 'y': y_coord}

	def GetBlock(x as int, z as int, y as int):
		lock blocks:
			return blocks[x, z, y]
		
	
		# #BuildMesh(size_x, size_z, size_y)
		
	def GenerateMesh():
		triangle_size = 0
		vertice_size = 0
		uv_size = 0

					
		for x in range(x_size):
			for z in range(z_size):
				for y in range(y_size):
					solid = blocks[x, z, y]
					if x == 0 and west_chunk.IsNull():
						solid_west = 0
					elif x == 0 and not west_chunk.IsNull():
						solid_west = west_chunk.GetBlock(x_size-1, z, y)
					else:
						solid_west = blocks[x-1, z, y]
						
					if x == x_size-1 and east_chunk.IsNull():
						solid_east = 0
					elif x == x_size-1 and not east_chunk.IsNull():
						solid_east = east_chunk.GetBlock(0, z, y)
					else:
						solid_east = blocks[x+1, z, y]
						
					if z == 0 and south_chunk.IsNull():
						solid_south = 0
					elif z == 0 and not south_chunk.IsNull():
						solid_south = south_chunk.GetBlock(x, z_size-1, y)
					else:
						solid_south = blocks[x, z-1, y]

					if z == z_size - 1 and north_chunk.IsNull():
						solid_north = 0
					elif z == z_size - 1 and not north_chunk.IsNull():
						solid_north = north_chunk.GetBlock(x, 0, y)
					else:
						solid_north = blocks[x, z+1, y]

					if y == 0 and down_chunk.IsNull():
						solid_down = 0
					elif y == 0 and not down_chunk.IsNull():
						solid_down = down_chunk.GetBlock(x, z, y_size-1)
					else:
						solid_down = blocks[x, z, y]

					if y == y_size - 1 and up_chunk.IsNull():
						solid_up = 0
					elif y == y_size - 1 and not up_chunk.IsNull():
						solid_up = up_chunk.GetBlock(x, z, 0)
					else:
						solid_up = blocks[x, z, y+1]
						
						#solid_west = (0 if x == 0 else blocks[x-1, z, y])
						#solid_east = (0 if x == x_size-1 else blocks[x+1, z, y])
						#solid_south = (0 if z == 0 else blocks[x, z-1, y])
						#solid_north = (0 if z == z_size-1 else blocks[x, z+1, y])
						#solid_down = (0 if y == 0 else blocks[x, z, y-1])
						#solid_up = (0 if y == y_size-1 else blocks[x, z, y+1])

					if solid:
						if not solid_west:
							vertice_size += 4
							uv_size += 4
							triangle_size += 6
						if not solid_east:
							vertice_size += 4
							uv_size += 4
							triangle_size += 6							
						if not solid_south:
							vertice_size += 4
							uv_size += 4
							triangle_size += 6							
						if not solid_north:
							vertice_size += 4
							uv_size += 4
							triangle_size += 6							
						if not solid_down:
							vertice_size += 4
							uv_size += 4
							triangle_size += 6							
						if not solid_up:
							vertice_size += 4
							uv_size += 4
							triangle_size += 6
		vertices = matrix(Vector3, vertice_size)
		triangles = matrix(int, triangle_size)
		uvs = matrix(Vector2, uv_size)

		vertice_count = 0
		triangle_count = 0
		uv_count = 0
		

		def _calc_uvs(x as int, y as int):
			# give x, y coordinates in (0-9) by (0-9)
			uvs[uv_count] = Vector2(0.1*x, 1.0 - 0.1*y - 0.1)
			uv_count += 1
			uvs[uv_count] = Vector2(0.1*x, 1.0 - 0.1*y)
			uv_count += 1
			uvs[uv_count] = Vector2(0.1*x + 0.1, 1.0 - 0.1*y)
			uv_count += 1
			uvs[uv_count] = Vector2(0.1*x + 0.1, 1.0 - 0.1*y - 0.1)
			uv_count += 1

		def _calc_triangles():
			triangles[triangle_count] = vertice_count-4 # 0
			triangle_count += 1
			triangles[triangle_count] = vertice_count-3 # 1
			triangle_count += 1			
			triangles[triangle_count] = vertice_count-2 # 2
			triangle_count += 1			
			triangles[triangle_count] = vertice_count-2 # 2
			triangle_count += 1			
			triangles[triangle_count] = vertice_count-1 # 3
			triangle_count += 1			
			triangles[triangle_count] = vertice_count-4 # 0
			triangle_count += 1
			


		for x in range(x_size):
			for z in range(z_size):
				for y in range(y_size):
					solid = blocks[x, z, y]
					if x == 0 and west_chunk.IsNull():
						solid_west = 0
					elif x == 0 and not west_chunk.IsNull():
						solid_west = west_chunk.GetBlock(x_size-1, z, y)
					else:
						solid_west = blocks[x-1, z, y]
						
					if x == x_size-1 and east_chunk.IsNull():
						solid_east = 0
					elif x == x_size-1 and not east_chunk.IsNull():
						solid_east = east_chunk.GetBlock(0, z, y)
					else:
						solid_east = blocks[x+1, z, y]
						
					if z == 0 and south_chunk.IsNull():
						solid_south = 0
					elif z == 0 and not south_chunk.IsNull():
						solid_south = south_chunk.GetBlock(x, z_size-1, y)
					else:
						solid_south = blocks[x, z-1, y]

					if z == z_size - 1 and north_chunk.IsNull():
						solid_north = 0
					elif z == z_size - 1 and not north_chunk.IsNull():
						solid_north = north_chunk.GetBlock(x, 0, y)
					else:
						solid_north = blocks[x, z+1, y]

					if y == 0 and down_chunk.IsNull():
						solid_down = 0
					elif y == 0 and not down_chunk.IsNull():
						solid_down = down_chunk.GetBlock(x, z, y_size-1)
					else:
						solid_down = blocks[x, z, y]

					if y == y_size - 1 and up_chunk.IsNull():
						solid_up = 0
					elif y == y_size - 1 and not up_chunk.IsNull():
						solid_up = up_chunk.GetBlock(x, z, 0)
					else:
						solid_up = blocks[x, z, y+1]					
					# solid_west = (0 if x == 0 else blocks[x-1, z, y])
					# solid_east = (0 if x == x_size-1 else blocks[x+1, z, y])
					# solid_south = (0 if z == 0 else blocks[x, z-1, y])
					# solid_north = (0 if z == z_size-1 else blocks[x, z+1, y])
					# solid_down = (0 if y == 0 else blocks[x, z, y-1])
					# solid_up = (0 if y == y_size-1 else blocks[x, z, y+1])
					if solid:
						if not solid_west:
							vertices[vertice_count] = Vector3(x, y, z)
							vertice_count += 1
							vertices[vertice_count] = Vector3(x, y, z+1)
							vertice_count += 1
							vertices[vertice_count] = Vector3(x, y+1, z+1)
							vertice_count += 1
							vertices[vertice_count] = Vector3(x, y+1, z)
							vertice_count += 1
							_calc_triangles()
							if solid == 1:
								_calc_uvs(3,0)
							elif solid == 2:
								_calc_uvs(2,0)														
						if not solid_east:
							vertices[vertice_count] = Vector3(x+1, y, z+1)
							vertice_count += 1
							vertices[vertice_count] = Vector3(x+1, y, z)
							vertice_count += 1
							vertices[vertice_count] = Vector3(x+1, y+1, z)
							vertice_count += 1
							vertices[vertice_count] = Vector3(x+1, y+1, z+1)
							vertice_count += 1
							_calc_triangles()
							if solid == 1:
								_calc_uvs(3, 0)
							elif solid == 2:
								_calc_uvs(2, 0)
						if not solid_south:
							vertices[vertice_count] = Vector3(x+1, y, z)
							vertice_count += 1
							vertices[vertice_count] = Vector3(x, y, z)
							vertice_count += 1
							vertices[vertice_count] = Vector3(x, y+1, z)
							vertice_count += 1
							vertices[vertice_count] = Vector3(x+1, y+1, z)
							vertice_count += 1
							_calc_triangles()
							if solid == 1:
								_calc_uvs(3,0)
							elif solid == 2:
								_calc_uvs(2, 0)							
						if not solid_north:
							vertices[vertice_count] = Vector3(x, y, z+1)
							vertice_count += 1
							vertices[vertice_count] = Vector3(x+1, y, z+1)
							vertice_count += 1
							vertices[vertice_count] = Vector3(x+1, y+1, z+1)
							vertice_count += 1
							vertices[vertice_count] = Vector3(x, y+1, z+1)
							vertice_count += 1
							_calc_triangles()
							if solid == 1:
								_calc_uvs(3,0)
							elif solid == 2:
								_calc_uvs(2, 0)							
						if not solid_down:
							vertices[vertice_count] = Vector3(x+1, y, z+1)
							vertice_count += 1
							vertices[vertice_count] = Vector3(x, y, z+1)
							vertice_count += 1
							vertices[vertice_count] = Vector3(x, y, z)
							vertice_count += 1
							vertices[vertice_count] = Vector3(x+1, y, z)
							vertice_count += 1
							_calc_triangles()
							if solid == 1:
								_calc_uvs(3,0)
							elif solid == 2:
								_calc_uvs(2, 0)							
						if not solid_up:
							vertices[vertice_count] = Vector3(x+1, y+1, z)
							vertice_count += 1
							vertices[vertice_count] = Vector3(x, y+1, z)
							vertice_count += 1
							vertices[vertice_count] = Vector3(x, y+1, z+1)
							vertice_count += 1
							vertices[vertice_count] = Vector3(x+1, y+1, z+1)
							vertice_count += 1
							_calc_triangles()
							if solid == 1:
								_calc_uvs(3,0)
							elif solid == 2:							
								_calc_uvs(2, 0)
		mesh_generated = true


		
		



		

