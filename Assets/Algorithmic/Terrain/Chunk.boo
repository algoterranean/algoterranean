

class NullChunk(IChunk):
	#def constructor():
	#	pass
	def isNull() as bool:
		return true
	# def areBlocksCalculated() as bool:
	# 	return false
	# def isMeshCalculated() as bool:
	# 	return false
	# def getBlock(p as byte, q as byte, r as byte) as byte:
	# 	return 0
	# def getCoordinates() as (long):
	# 	x as long = 0
	# 	z as long = 0
	# 	y as long = 0
	# 	return (x, z, y)
	# def setBlock(p as byte, q as byte, r as byte, block as byte) as void:
	# 	pass
	# def setCoordinates(x as long, z as long, y as long) as void:
	# 	pass
	# def setSizes(p_size as byte, q_size as byte, r_size as byte) as void:
	# 	pass
	# def CalculateNoise() as void:
	# 	pass
	# def CalculateMesh() as void:
	# 	pass

	

class Chunk (IChunk, IChunkNeighborhood):
	blocks_calculated as bool
	mesh_is_dirty as bool
	mesh_calculated as bool
	mesh_visible as bool
	blocks as (byte, 3)
	noise_module as VoxelNoiseData
	x_coord as long
	z_coord as long
	y_coord as long
	p_size as byte
	q_size as byte
	r_size as byte
	
	west_chunk as IChunk = NullChunk()
	east_chunk as IChunk = NullChunk()
	south_chunk as IChunk = NullChunk()
	north_chunk as IChunk = NullChunk()
	down_chunk as IChunk = NullChunk()
	up_chunk as IChunk = NullChunk()

	public vertices as (Vector3)
	public triangles as (int)
	public uvs as (Vector2)
	public colors as (Color32)
	public normals as (Vector3)


	def constructor(x_coord as long, z_coord as long, y_coord as long, p_size as byte, q_size as byte, r_size as byte):
		setCoordinates(x_coord, z_coord, y_coord)
		setSizes(p_size, q_size, r_size)
		blocks = matrix(byte, p_size, q_size, r_size)
		noise_module = VoxelNoiseData()
		blocks_calculated = false
		mesh_calculated = false
		mesh_visible = false
		mesh_is_dirty = false

	def setCoordinates(x_coord as long, z_coord as long, y_coord as long) as void:
		self.x_coord = x_coord
		self.z_coord = z_coord
		self.y_coord = y_coord

	def setSizes(p_size as byte, q_size as byte, r_size as byte) as void:
		self.p_size = p_size
		self.q_size = q_size
		self.r_size = r_size

	def setBlock(p as byte, q as byte, r as byte, block as byte) as void:
		blocks[p, q, r] = block
		
	def isNull() as bool:
		return false
		
	def areBlocksCalculated () as bool:
		lock blocks_calculated:
			return blocks_calculated

	def isMeshCalculated () as bool:
		lock mesh_calculated:
			return mesh_calculated

	def isMeshDirty() as bool:
		lock mesh_is_dirty:
			return mesh_is_dirty
		
	def getBlock(p as byte, q as byte, r as byte) as byte:
		return blocks[p, q, r]

	def getCoordinates() as (long):
		lock x_coord, z_coord, y_coord:
			return (x_coord, z_coord, y_coord)
		

	def CalculateNoise():
		for p in range(p_size):
			for q in range(q_size):
				for r in range(r_size):
					blocks[p,q,r] = noise_module.GetBlock(p + x_coord, q + z_coord, r + y_coord)
					
		lock blocks_calculated:
			blocks_calculated = true

	###############################
	def setNeighboringChunks(west as IChunk, east as IChunk, south as IChunk, north as IChunk,
					 down as IChunk, up as IChunk) as void:
		setWestChunk(west)
		setEastChunk(east)
		setSouthChunk(south)
		setNorthChunk(north)
		setDownChunk(down)
		setUpChunk(up)

	def setWestChunk(west as IChunk) as void:
		if west_chunk != west and mesh_calculated:
			mesh_is_dirty = true			
		west_chunk = west


	def setEastChunk(east as IChunk) as void:
		if east_chunk != east and mesh_calculated:
			mesh_is_dirty = true
		east_chunk = east

	def setSouthChunk(south as IChunk) as void:
		if south_chunk != south and mesh_calculated:
			mesh_is_dirty = true
		south_chunk = south
		
	def setNorthChunk(north as IChunk) as void:
		if north_chunk != north and mesh_calculated:
			mesh_is_dirty = true
		north_chunk = north

	def setDownChunk(down as IChunk) as void:
		if down_chunk != down and mesh_calculated:
			mesh_is_dirty = true
		down_chunk = down

	def setUpChunk(up as IChunk) as void:
		if up_chunk != up and mesh_calculated:
			mesh_is_dirty = true
		up_chunk = up

	def getWestChunk() as IChunk:
		return west_chunk

	def getEastChunk() as IChunk:
		return east_chunk

	def getSouthChunk() as IChunk:
		return south_chunk

	def getNorthChunk() as IChunk:
		return north_chunk

	def getDownChunk() as IChunk:
		return down_chunk

	def getUpChunk() as IChunk:
		return up_chunk

		

	def areNeighborsReady():
		if (north_chunk.isNull() or north_chunk.areBlocksCalculated()) and \
		    (south_chunk.isNull() or south_chunk.areBlocksCalculated()) and \
		    (east_chunk.isNull() or east_chunk.areBlocksCalculated()) and \
		    (west_chunk.isNull() or west_chunk.areBlocksCalculated()) and \
		    (up_chunk.isNull() or up_chunk.areBlocksCalculated()) and \
		    (down_chunk.isNull() or down_chunk.areBlocksCalculated()):
			return true
		return false


	def IsVisible():
		return mesh_visible

	def SetVisible(mesh_visible as bool):
		lock self.mesh_visible:
			self.mesh_visible = mesh_visible

	# def MeshVisible ():
	# 	lock mesh_visible:
	# 		return mesh_visible

	# def GetCoordinates ():
	# 	return {'x': x_coord, 'z': z_coord, 'y': y_coord}

		
	def CalculateMesh():
		triangle_size = 0
		vertice_size = 0
		uv_size = 0


		for p in range(p_size):
			for q in range(q_size):
				for r in range(r_size):
					solid = blocks[p, q, r]
					# solid_west = (0 if p == 0 else blocks[p-1, q, r])
					# solid_east = (0 if p == p_size-1 else blocks[p+1, q, r])
					# solid_south = (0 if q == 0 else blocks[p, q-1, r])
					# solid_north = (0 if q == q_size-1 else blocks[p, q+1, r])
					# solid_down = (0 if r == 0 else blocks[p, q, r-1])
					# solid_up = (0 if r == r_size-1 else blocks[p, q, r+1])
					
					if p == 0 and west_chunk.isNull():
						solid_west = 0
					elif p == 0 and not west_chunk.isNull():
						solid_west = west_chunk.getBlock(p_size-1, q, r)
					else:
						solid_west = blocks[p-1, q, r]
						
					if p == p_size-1 and east_chunk.isNull():
						solid_east = 0
					elif p == p_size-1 and not east_chunk.isNull():
						solid_east = east_chunk.getBlock(0, q, r)
					else:
						solid_east = blocks[p+1, q, r]
						
					if q == 0 and south_chunk.isNull():
						solid_south = 0
					elif q == 0 and not south_chunk.isNull():
						solid_south = south_chunk.getBlock(p, q_size-1, r)
					else:
						solid_south = blocks[p, q-1, r]

					if q == q_size - 1 and north_chunk.isNull():
						solid_north = 0
					elif q == q_size - 1 and not north_chunk.isNull():
						solid_north = north_chunk.getBlock(p, 0, r)
					else:
						solid_north = blocks[p, q+1, r]

					if r == 0 and down_chunk.isNull():
						solid_down = 0
					elif r == 0 and not down_chunk.isNull():
						solid_down = down_chunk.getBlock(p, q, r_size-1)
					else:
						solid_down = blocks[p, q, r-1]

					if r == r_size - 1 and up_chunk.isNull():
						solid_up = 0
					elif r == r_size - 1 and not up_chunk.isNull():
						solid_up = up_chunk.getBlock(p, q, 0)
					else:
						solid_up = blocks[p, q, r+1]
						

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
			


		for p in range(p_size):
			for q in range(q_size):
				for r in range(r_size):
					solid = blocks[p, q, r]
					# solid_west = (0 if p == 0 else blocks[p-1, q, r])
					# solid_east = (0 if p == p_size-1 else blocks[p+1, q, r])
					# solid_south = (0 if q == 0 else blocks[p, q-1, r])
					# solid_north = (0 if q == q_size-1 else blocks[p, q+1, r])
					# solid_down = (0 if r == 0 else blocks[p, q, r-1])
					# solid_up = (0 if r == r_size-1 else blocks[p, q, r+1])
					if p == 0 and west_chunk.isNull():
						solid_west = 0
					elif p == 0 and not west_chunk.isNull():
						solid_west = west_chunk.getBlock(p_size-1, q, r)
					else:
						solid_west = blocks[p-1, q, r]
						
					if p == p_size-1 and east_chunk.isNull():
						solid_east = 0
					elif p == p_size-1 and not east_chunk.isNull():
						solid_east = east_chunk.getBlock(0, q, r)
					else:
						solid_east = blocks[p+1, q, r]
						
					if q == 0 and south_chunk.isNull():
						solid_south = 0
					elif q == 0 and not south_chunk.isNull():
						solid_south = south_chunk.getBlock(p, q_size-1, r)
					else:
						solid_south = blocks[p, q-1, r]

					if q == q_size - 1 and north_chunk.isNull():
						solid_north = 0
					elif q == q_size - 1 and not north_chunk.isNull():
						solid_north = north_chunk.getBlock(p, 0, r)
					else:
						solid_north = blocks[p, q+1, r]

					if r == 0 and down_chunk.isNull():
						solid_down = 0
					elif r == 0 and not down_chunk.isNull():
						solid_down = down_chunk.getBlock(p, q, r_size-1)
					else:
						solid_down = blocks[p, q, r-1]

					if r == r_size - 1 and up_chunk.isNull():
						solid_up = 0
					elif r == r_size - 1 and not up_chunk.isNull():
						solid_up = up_chunk.getBlock(p, q, 0)
					else:
						solid_up = blocks[p, q, r+1]					
						
					if solid:
						if not solid_west:
							vertices[vertice_count] = Vector3(p, r, q)
							vertice_count += 1
							vertices[vertice_count] = Vector3(p, r, q+1)
							vertice_count += 1
							vertices[vertice_count] = Vector3(p, r+1, q+1)
							vertice_count += 1
							vertices[vertice_count] = Vector3(p, r+1, q)
							vertice_count += 1
							_calc_triangles()
							if solid == 1:
								_calc_uvs(3,0)
							elif solid == 2:
								_calc_uvs(2,0)														
						if not solid_east:
							vertices[vertice_count] = Vector3(p+1, r, q+1)
							vertice_count += 1
							vertices[vertice_count] = Vector3(p+1, r, q)
							vertice_count += 1
							vertices[vertice_count] = Vector3(p+1, r+1, q)
							vertice_count += 1
							vertices[vertice_count] = Vector3(p+1, r+1, q+1)
							vertice_count += 1
							_calc_triangles()
							if solid == 1:
								_calc_uvs(3, 0)
							elif solid == 2:
								_calc_uvs(2, 0)
						if not solid_south:
							vertices[vertice_count] = Vector3(p+1, r, q)
							vertice_count += 1
							vertices[vertice_count] = Vector3(p, r, q)
							vertice_count += 1
							vertices[vertice_count] = Vector3(p, r+1, q)
							vertice_count += 1
							vertices[vertice_count] = Vector3(p+1, r+1, q)
							vertice_count += 1
							_calc_triangles()
							if solid == 1:
								_calc_uvs(3,0)
							elif solid == 2:
								_calc_uvs(2, 0)							
						if not solid_north:
							vertices[vertice_count] = Vector3(p, r, q+1)
							vertice_count += 1
							vertices[vertice_count] = Vector3(p+1, r, q+1)
							vertice_count += 1
							vertices[vertice_count] = Vector3(p+1, r+1, q+1)
							vertice_count += 1
							vertices[vertice_count] = Vector3(p, r+1, q+1)
							vertice_count += 1
							_calc_triangles()
							if solid == 1:
								_calc_uvs(3,0)
							elif solid == 2:
								_calc_uvs(2, 0)							
						if not solid_down:
							vertices[vertice_count] = Vector3(p+1, r, q+1)
							vertice_count += 1
							vertices[vertice_count] = Vector3(p, r, q+1)
							vertice_count += 1
							vertices[vertice_count] = Vector3(p, r, q)
							vertice_count += 1
							vertices[vertice_count] = Vector3(p+1, r, q)
							vertice_count += 1
							_calc_triangles()
							if solid == 1:
								_calc_uvs(3,0)
							elif solid == 2:
								_calc_uvs(2, 0)							
						if not solid_up:
							vertices[vertice_count] = Vector3(p+1, r+1, q)
							vertice_count += 1
							vertices[vertice_count] = Vector3(p, r+1, q)
							vertice_count += 1
							vertices[vertice_count] = Vector3(p, r+1, q+1)
							vertice_count += 1
							vertices[vertice_count] = Vector3(p+1, r+1, q+1)
							vertice_count += 1
							_calc_triangles()
							if solid == 1:
								_calc_uvs(3,0)
							elif solid == 2:							
								_calc_uvs(2, 0)
		mesh_calculated = true
		mesh_is_dirty = false


		
		



		

