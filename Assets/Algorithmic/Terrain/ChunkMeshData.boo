namespace Algorithmic.Terrain

import UnityEngine
import Algorithmic
import System.Math

struct AABBSize:
	x as single
	y as single
	z as single
	def constructor(x as single, y as single, z as single):
		self.x = x
		self.y = y
		self.z = z

struct AABB:
	center as Vector3
	radius as Vector3
	min as AABBSize
	max as AABBSize
	
	def constructor(_center as Vector3, _radius as Vector3):
		center = _center
		radius = _radius
		min.x = center.x - radius.x
		min.y = center.y - radius.y
		min.z = center.z - radius.z
		max.x = center.x + radius.x
		max.y = center.y + radius.y
		max.z = center.z + radius.z
		
		
	def Test(a as AABB, b as AABB) as bool:
		if Math.Abs(a.center.y - b.center.y) > (a.radius.y + b.radius.y):
			return false
		if Math.Abs(a.center.x - b.center.x) > (a.radius.x + b.radius.x):
			return false
		if Math.Abs(a.center.z - b.center.z) > (a.radius.z + b.radius.z):
			return false
		return true

	def getCollision(a as AABB, b as AABB) as Vector3:
		y_component = 0.0
		x_component = 0.0
		z_component = 0.0

		if Math.Abs(a.center.y - b.center.y) <= (a.radius.y + b.radius.y):
			y_component = (b.center.y + b.radius.y) - (a.center.y - a.radius.y)
			#y_component = a.center.y - b.center.y #- (a.radius.y + b.radius.y)
		if Math.Abs(a.center.x - b.center.x) <= (a.radius.x + b.radius.x):
			x_component = Math.Abs(a.center.x - b.center.x)
		if Math.Abs(a.center.z - b.center.z) <= (a.radius.z + b.radius.z):
			z_component = Math.Abs(a.center.z - b.center.z)
			
		return Vector3(x_component, y_component, z_component)
	
	def ToString():
		return "(Center: ($(center.x), $(center.y), $(center.z)), Radius: ($(radius.x), $(radius.y), $(radius.z)))"

	

	


class ChunkMeshData (IChunkMeshData):
	chunk as IChunkBlockData
	mesh_calculated as bool
	vertices as (Vector3)
	normals as (Vector3)
	triangles as (int)
	uvs as (Vector2)
	## _bounding_volumes as (AABB)
	bounding_volume_tree as BoundingVolumeTree

	
	west_neighbor as IChunkBlockData
	east_neighbor as IChunkBlockData
	south_neighbor as IChunkBlockData
	north_neighbor as IChunkBlockData
	down_neighbor as IChunkBlockData
	up_neighbor as IChunkBlockData

	def getTree() as BoundingVolumeTree:
		return bounding_volume_tree

	def constructor(chunk as IChunkBlockData):
		self.chunk = chunk
		mesh_calculated = false
		west_neighbor = NullBlockData()
		east_neighbor = NullBlockData()
		south_neighbor = NullBlockData()
		north_neighbor = NullBlockData()
		down_neighbor = NullBlockData()
		up_neighbor = NullBlockData()

		c = chunk.getCoordinates()
		#bounding_volume_tree = BoundingVolumeTree(chunk)
			#AABB(Vector3(c.x + Settings.ChunkSize/2, c.y + Settings.ChunkSize/2, c.z + Settings.ChunkSize/2),
			#					Vector3(Settings.ChunkSize/2, Settings.ChunkSize/2, Settings.ChunkSize/2)))

	def setNeighborhoodChunks(west as IChunkBlockData, east as IChunkBlockData,
					  south as IChunkBlockData, north as IChunkBlockData,
					  down as IChunkBlockData, up as IChunkBlockData) as void:
		west_neighbor = west
		east_neighbor = east
		south_neighbor = south
		north_neighbor = north
		down_neighbor = down
		up_neighbor = up

	def setWestNeighbor(chunk as IChunkBlockData):
		lock west_neighbor:
			if chunk != west_neighbor:
				west_neighbor = chunk
	def setEastNeighbor(chunk as IChunkBlockData):
		lock east_neighbor:
			if chunk != east_neighbor:
				east_neighbor = chunk		
	def setSouthNeighbor(chunk as IChunkBlockData):
		lock south_neighbor:
			if chunk != south_neighbor:
				south_neighbor = chunk		
	def setNorthNeighbor(chunk as IChunkBlockData):
		lock north_neighbor:
			if chunk != north_neighbor:
				north_neighbor = chunk		
	def setDownNeighbor(chunk as IChunkBlockData):
		lock down_neighbor:
			if chunk != down_neighbor:
				down_neighbor = chunk		
	def setUpNeighbor(chunk as IChunkBlockData):
		lock up_neighbor:
			if chunk != up_neighbor:
				up_neighbor = chunk		

	def isMeshCalculated() as bool:
		return mesh_calculated

	def areNeighborsReady() as bool:
		if (west_neighbor.isNull() and east_neighbor.isNull() and south_neighbor.isNull() and \
		    north_neighbor.isNull() and down_neighbor.isNull() and up_neighbor.isNull()):
			print "Chunk's Neighbors are all NULL!"
		if (west_neighbor.isNull() or west_neighbor.areBlocksCalculated()) and \
		    (east_neighbor.isNull() or east_neighbor.areBlocksCalculated()) and \
		    (south_neighbor.isNull() or south_neighbor.areBlocksCalculated()) and \
		    (north_neighbor.isNull() or north_neighbor.areBlocksCalculated()) and \
		    (down_neighbor.isNull() or down_neighbor.areBlocksCalculated()) and \
		    (up_neighbor.isNull() or up_neighbor.areBlocksCalculated()):
			return true
		return false

	def getVertices() as (Vector3):
		return vertices

	def getNormals() as (Vector3):
		return normals

	def getTriangles() as (int):
		return triangles

	def getUVs() as (Vector2):
		return uvs

	## def getBoundingVolumes() as (AABB):
	## 	return _bounding_volumes

	def CalculateMesh() as void:
		size = chunk.getSize()
		vertice_size = 0
		triangle_size = 0
		uv_size = 0
		aabb_size = 0

		for x as byte in range(size.x):
			for y as byte in range(size.y):
				for z as byte in range(size.z):
					#for p, q, r in Utils.Product(p_size, q_size, r_size):
					block = chunk.getBlock(ByteVector3(x, y, z))

					if x == 0 and west_neighbor.isNull():
						block_west = BLOCK.AIR
					elif x == 0 and not west_neighbor.isNull():
						block_west = west_neighbor.getBlock(ByteVector3(size.x-1, y, z))
					else:
						block_west = chunk.getBlock(ByteVector3(x-1, y, z))

					if x == size.x -1 and east_neighbor.isNull():
						block_east = BLOCK.AIR
					elif x == size.x - 1 and not east_neighbor.isNull():
						block_east = east_neighbor.getBlock(ByteVector3(0, y, z))
					else:
						block_east = chunk.getBlock(ByteVector3(x+1, y ,z))

					if z == 0 and south_neighbor.isNull():
						block_south = BLOCK.AIR
					elif z == 0 and not south_neighbor.isNull():
						block_south = south_neighbor.getBlock(ByteVector3(x, y, size.z-1))
					else:
						block_south = chunk.getBlock(ByteVector3(x, y, z-1))

					if z == size.z-1 and north_neighbor.isNull():
						block_north = BLOCK.AIR
					elif z == size.z - 1 and not north_neighbor.isNull():
						block_north = north_neighbor.getBlock(ByteVector3(x, y, 0))
					else:
						block_north = chunk.getBlock(ByteVector3(x, y, z+1))

					if y == 0 and down_neighbor.isNull():
						block_down = BLOCK.AIR
					elif y == 0 and not down_neighbor.isNull():
						block_down = down_neighbor.getBlock(ByteVector3(x, size.y-1, z))
					else:
						block_down = chunk.getBlock(ByteVector3(x, y-1, z))

					if y == size.y-1 and up_neighbor.isNull():
						block_up = BLOCK.AIR
					elif y == size.y-1 and not up_neighbor.isNull():
						block_up = up_neighbor.getBlock(ByteVector3(x, 0, z))
					else:
						block_up = chunk.getBlock(ByteVector3(x, y+1, z))
						
					
					if block:
						aabb_test = false						
						if not block_west:
							vertice_size += 4
							uv_size += 4
							triangle_size += 6
							aabb_test = true
						if not block_east:
							vertice_size += 4
							uv_size += 4
							triangle_size += 6
							aabb_test = true
						if not block_south:
							vertice_size += 4
							uv_size += 4
							triangle_size += 6
							aabb_test = true
						if not block_north:
							vertice_size += 4
							uv_size += 4
							triangle_size += 6
							aabb_test = true
						if not block_down:
							vertice_size += 4
							uv_size += 4
							triangle_size += 6
							aabb_test = true
						if not block_up:
							vertice_size += 4
							uv_size += 4
							triangle_size += 6
							aabb_test = true
						if aabb_test:
							aabb_size += 1

					
		vertices = matrix(Vector3, vertice_size)
		triangles = matrix(int, triangle_size)
		uvs = matrix(Vector2, uv_size)
		normals = matrix(Vector3, vertice_size)
		## _bounding_volumes = matrix(AABB, aabb_size)

		vertice_count = 0
		triangle_count = 0
		uv_count = 0
		normal_count = 0
		aabb_count = 0

		def _add_uvs(x as single, y as single):
			# give x, y coordinates in (0-9) by (0-9)
			uvs[uv_count]   = Vector2(x + 0.01, 1.0 - y - 0.1 + 0.01)
			uvs[uv_count+1] = Vector2(x + 0.01, 1.0 - y - 0.01)
			uvs[uv_count+2] = Vector2(x - 0.01 + 0.1, 1.0 - y - 0.01)
			uvs[uv_count+3] = Vector2(x - 0.01 + 0.1, 1.0 - y - 0.1 + 0.01)
			uv_count += 4
			
		def _calc_triangles():
			triangles[triangle_count]   = vertice_count-4 # 0
			triangles[triangle_count+1] = vertice_count-3 # 1
			triangles[triangle_count+2] = vertice_count-2 # 2
			triangles[triangle_count+3] = vertice_count-2 # 2
			triangles[triangle_count+4] = vertice_count-1 # 3
			triangles[triangle_count+5] = vertice_count-4 # 0
			triangle_count += 6

		def _add_normals(n as Vector3):
			normals[normal_count]   = n
			normals[normal_count+1] = n
			normals[normal_count+2] = n
			normals[normal_count+3] = n
			normal_count += 4


		for x as byte in range(size.x):
			for y as byte in range(size.y):
				for z as byte in range(size.z):
					block = chunk.getBlock(ByteVector3(x, y, z))
					#print "BLOCK: $block"
					if x == 0 and west_neighbor.isNull():
						block_west = BLOCK.AIR
					elif x == 0 and not west_neighbor.isNull():
						block_west = west_neighbor.getBlock(ByteVector3(size.x-1, y, z))
					else:
						block_west = chunk.getBlock(ByteVector3(x-1, y, z))

					if x == size.x -1 and east_neighbor.isNull():
						block_east = BLOCK.AIR
					elif x == size.x - 1 and not east_neighbor.isNull():
						block_east = east_neighbor.getBlock(ByteVector3(0, y, z))
					else:
						block_east = chunk.getBlock(ByteVector3(x+1, y ,z))

					if z == 0 and south_neighbor.isNull():
						block_south = BLOCK.AIR
					elif z == 0 and not south_neighbor.isNull():
						block_south = south_neighbor.getBlock(ByteVector3(x, y, size.z-1))
					else:
						block_south = chunk.getBlock(ByteVector3(x, y, z-1))

					if z == size.z-1 and north_neighbor.isNull():
						block_north = BLOCK.AIR
					elif z == size.z-1 and not north_neighbor.isNull():
						block_north = north_neighbor.getBlock(ByteVector3(x, y, 0))
					else:
						block_north = chunk.getBlock(ByteVector3(x, y, z+1))

					if y == 0 and down_neighbor.isNull():
						block_down = BLOCK.AIR
					elif y == 0 and not down_neighbor.isNull():
						block_down = down_neighbor.getBlock(ByteVector3(x, size.y-1, z))
					else:
						block_down = chunk.getBlock(ByteVector3(x, y-1, z))

					if y == size.y-1 and up_neighbor.isNull():
						block_up = BLOCK.AIR
					elif y == size.y-1 and not up_neighbor.isNull():
						block_up = up_neighbor.getBlock(ByteVector3(x, 0, z))
					else:
						block_up = chunk.getBlock(ByteVector3(x, y+1, z))


					
					


					if block:
						aabb_test = false
						if not block_west:
							vertices[vertice_count] = Vector3(x, y, z)
							vertices[vertice_count+1] = Vector3(x, y, z+1)
							vertices[vertice_count+2] = Vector3(x, y+1, z+1)
							vertices[vertice_count+3] = Vector3(x, y+1, z)
							vertice_count += 4
							_calc_triangles()
							_add_normals(Vector3(-1, 0, 0))
							_add_uvs(Blocks.block_def[block].uv_x, Blocks.block_def[block].uv_y)
							aabb_test = true
						if not block_east:
							vertices[vertice_count] = Vector3(x+1, y, z+1)
							vertices[vertice_count+1] = Vector3(x+1, y, z)
							vertices[vertice_count+2] = Vector3(x+1, y+1, z)
							vertices[vertice_count+3] = Vector3(x+1, y+1, z+1)
							vertice_count += 4
							_calc_triangles()
							_add_normals(Vector3(1, 0, 0))
							_add_uvs(Blocks.block_def[block].uv_x, Blocks.block_def[block].uv_y)
							aabb_test = true
						if not block_south:
							vertices[vertice_count] = Vector3(x+1, y, z)
							vertices[vertice_count+1] = Vector3(x, y, z)
							vertices[vertice_count+2] = Vector3(x, y+1, z)
							vertices[vertice_count+3] = Vector3(x+1, y+1, z)
							vertice_count += 4
							_calc_triangles()
							_add_normals(Vector3(0, 0, -1))
							_add_uvs(Blocks.block_def[block].uv_x, Blocks.block_def[block].uv_y)
							aabb_test = true
						if not block_north:
							vertices[vertice_count] = Vector3(x, y, z+1)
							vertices[vertice_count+1] = Vector3(x+1, y, z+1)
							vertices[vertice_count+2] = Vector3(x+1, y+1, z+1)
							vertices[vertice_count+3] = Vector3(x, y+1, z+1)
							vertice_count += 4
							_calc_triangles()
							_add_normals(Vector3(0, 0, 1))
							_add_uvs(Blocks.block_def[block].uv_x, Blocks.block_def[block].uv_y)
							aabb_test = true
						if not block_down:
							vertices[vertice_count] = Vector3(x+1, y, z+1)
							vertices[vertice_count+1] = Vector3(x, y, z+1)
							vertices[vertice_count+2] = Vector3(x, y, z)
							vertices[vertice_count+3] = Vector3(x+1, y, z)
							vertice_count += 4
							_calc_triangles()
							_add_normals(Vector3(0, -1, 0))
							_add_uvs(Blocks.block_def[block].uv_x, Blocks.block_def[block].uv_y)
							aabb_test = true
						if not block_up:
							vertices[vertice_count] = Vector3(x+1, y+1, z)
							vertices[vertice_count+1] = Vector3(x, y+1, z)
							vertices[vertice_count+2] = Vector3(x, y+1, z+1)
							vertices[vertice_count+3] = Vector3(x+1, y+1, z+1)
							vertice_count += 4
							_calc_triangles()
							_add_normals(Vector3(0, 1, 0))
							_add_uvs(Blocks.block_def[block].uv_x, Blocks.block_def[block].uv_y)
							aabb_test = true
						## if aabb_test:
						## 	_bounding_volumes[aabb_count] = AABB(Vector3(x + 0.5, y + 0.5, z + 0.5), Vector3(0.5, 0.5, 0.5))
						## 	aabb_count += 1
		mesh_calculated = true
		#bounding_volume_tree = BoundingVolumeTree(chunk.getSize(), chunk.getCoordinates())
