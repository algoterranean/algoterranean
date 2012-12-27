import UnityEngine
import Algorithmic
import System.Math

struct AABB:
	center as Vector3
	radius as Vector3
	def constructor(_center as Vector3, _radius as Vector3):
		center = _center
		radius = _radius
		
	def Test(a as AABB, b as AABB) as bool:
		if Math.Abs(a.center.y - b.center.y) > (a.radius.y + b.radius.y):
			return false
		if Math.Abs(a.center.x - b.center.x) > (a.radius.x + b.radius.x): 
			return false
		if Math.Abs(a.center.z - b.center.z) > (a.radius.z + b.radius.z):
			return false
		return true


class ChunkMeshData (IChunkMeshData):
	_chunk as IChunkBlockData
	_mesh_calculated as bool
	_vertices as (Vector3)
	_normals as (Vector3)
	_triangles as (int)
	_uvs as (Vector2)
	_bounding_volumes as (AABB)
	_bounding_volume_tree as BoundingVolumeTree

	
	_west_neighbor as IChunkBlockData
	_east_neighbor as IChunkBlockData
	_south_neighbor as IChunkBlockData
	_north_neighbor as IChunkBlockData
	_down_neighbor as IChunkBlockData
	_up_neighbor as IChunkBlockData

	def getTree() as BoundingVolumeTree:
		return _bounding_volume_tree

	def constructor(chunk as IChunkBlockData):
		_chunk = chunk
		_mesh_calculated = false
		_west_neighbor = NullBlockData()
		_east_neighbor = NullBlockData()
		_south_neighbor = NullBlockData()
		_north_neighbor = NullBlockData()
		_down_neighbor = NullBlockData()
		_up_neighbor = NullBlockData()

		c = _chunk.getCoordinates()
		_bounding_volume_tree = BoundingVolumeTree(AABB(Vector3(c.x + Settings.ChunkSize/2, c.y + Settings.ChunkSize/2, c.z + Settings.ChunkSize/2),
								Vector3(Settings.ChunkSize/2, Settings.ChunkSize/2, Settings.ChunkSize/2)))

	def setNeighborhoodChunks(west as IChunkBlockData, east as IChunkBlockData,
					  south as IChunkBlockData, north as IChunkBlockData,
					  down as IChunkBlockData, up as IChunkBlockData) as void:
		_west_neighbor = west
		_east_neighbor = east
		_south_neighbor = south
		_north_neighbor = north
		_down_neighbor = down
		_up_neighbor = up

	def setWestNeighbor(chunk as IChunkBlockData):
		lock _west_neighbor:
			if chunk != _west_neighbor:
				_west_neighbor = chunk
	def setEastNeighbor(chunk as IChunkBlockData):
		lock _east_neighbor:
			if chunk != _east_neighbor:
				_east_neighbor = chunk		
	def setSouthNeighbor(chunk as IChunkBlockData):
		lock _south_neighbor:
			if chunk != _south_neighbor:
				_south_neighbor = chunk		
	def setNorthNeighbor(chunk as IChunkBlockData):
		lock _north_neighbor:
			if chunk != _north_neighbor:
				_north_neighbor = chunk		
	def setDownNeighbor(chunk as IChunkBlockData):
		lock _down_neighbor:
			if chunk != _down_neighbor:
				_down_neighbor = chunk		
	def setUpNeighbor(chunk as IChunkBlockData):
		lock _up_neighbor:
			if chunk != _up_neighbor:
				_up_neighbor = chunk		

	def isMeshCalculated() as bool:
		return _mesh_calculated

	def areNeighborsReady() as bool:
		if (_west_neighbor.isNull() and _east_neighbor.isNull() and _south_neighbor.isNull() and \
		    _north_neighbor.isNull() and _down_neighbor.isNull() and _up_neighbor.isNull()):
			print "Chunk's Neighbors are all NULL!"
		if (_west_neighbor.isNull() or _west_neighbor.areBlocksCalculated()) and \
		    (_east_neighbor.isNull() or _east_neighbor.areBlocksCalculated()) and \
		    (_south_neighbor.isNull() or _south_neighbor.areBlocksCalculated()) and \
		    (_north_neighbor.isNull() or _north_neighbor.areBlocksCalculated()) and \
		    (_down_neighbor.isNull() or _down_neighbor.areBlocksCalculated()) and \
		    (_up_neighbor.isNull() or _up_neighbor.areBlocksCalculated()):
			return true
		return false

	def getVertices() as (Vector3):
		return _vertices

	def getNormals() as (Vector3):
		return _normals

	def getTriangles() as (int):
		return _triangles

	def getUVs() as (Vector2):
		return _uvs

	def getBoundingVolumes() as (AABB):
		return _bounding_volumes

	def CalculateMesh() as void:
		size = _chunk.getSize()
		vertice_size = 0
		triangle_size = 0
		uv_size = 0
		aabb_size = 0

		for x as byte in range(size.x):
			for y as byte in range(size.y):
				for z as byte in range(size.z):
					#for p, q, r in Utils.Product(p_size, q_size, r_size):
					block = _chunk.getBlock(ByteVector3(x, y, z))

					if x == 0 and _west_neighbor.isNull():
						block_west = BLOCK.AIR
					elif x == 0 and not _west_neighbor.isNull():
						block_west = _west_neighbor.getBlock(ByteVector3(size.x-1, y, z))
					else:
						block_west = _chunk.getBlock(ByteVector3(x-1, y, z))

					if x == size.x -1 and _east_neighbor.isNull():
						block_east = BLOCK.AIR
					elif x == size.x - 1 and not _east_neighbor.isNull():
						block_east = _east_neighbor.getBlock(ByteVector3(0, y, z))
					else:
						block_east = _chunk.getBlock(ByteVector3(x+1, y ,z))

					if z == 0 and _south_neighbor.isNull():
						block_south = BLOCK.AIR
					elif z == 0 and not _south_neighbor.isNull():
						block_south = _south_neighbor.getBlock(ByteVector3(x, y, size.z-1))
					else:
						block_south = _chunk.getBlock(ByteVector3(x, y, z-1))

					if z == size.z-1 and _north_neighbor.isNull():
						block_north = BLOCK.AIR
					elif z == size.z - 1 and not _north_neighbor.isNull():
						block_north = _north_neighbor.getBlock(ByteVector3(x, y, 0))
					else:
						block_north = _chunk.getBlock(ByteVector3(x, y, z+1))

					if y == 0 and _down_neighbor.isNull():
						block_down = BLOCK.AIR
					elif y == 0 and not _down_neighbor.isNull():
						block_down = _down_neighbor.getBlock(ByteVector3(x, size.y-1, z))
					else:
						block_down = _chunk.getBlock(ByteVector3(x, y-1, z))

					if y == size.y-1 and _up_neighbor.isNull():
						block_up = BLOCK.AIR
					elif y == size.y-1 and not _up_neighbor.isNull():
						block_up = _up_neighbor.getBlock(ByteVector3(x, 0, z))
					else:
						block_up = _chunk.getBlock(ByteVector3(x, y+1, z))
						
					
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

					
		_vertices = matrix(Vector3, vertice_size)
		_triangles = matrix(int, triangle_size)
		_uvs = matrix(Vector2, uv_size)
		_normals = matrix(Vector3, vertice_size)
		_bounding_volumes = matrix(AABB, aabb_size)

		vertice_count = 0
		triangle_count = 0
		uv_count = 0
		normal_count = 0
		aabb_count = 0

		def _add_uvs(x as single, y as single):
			# give x, y coordinates in (0-9) by (0-9)
			_uvs[uv_count]   = Vector2(x, 1.0 - y - 0.1)
			_uvs[uv_count+1] = Vector2(x, 1.0 - y)
			_uvs[uv_count+2] = Vector2(x + 0.1, 1.0 - y)
			_uvs[uv_count+3] = Vector2(x + 0.1, 1.0 - y - 0.1)
			uv_count += 4
			
		def _calc_triangles():
			_triangles[triangle_count]   = vertice_count-4 # 0
			_triangles[triangle_count+1] = vertice_count-3 # 1
			_triangles[triangle_count+2] = vertice_count-2 # 2
			_triangles[triangle_count+3] = vertice_count-2 # 2
			_triangles[triangle_count+4] = vertice_count-1 # 3
			_triangles[triangle_count+5] = vertice_count-4 # 0
			triangle_count += 6

		def _add_normals(n as Vector3):
			_normals[normal_count]   = n
			_normals[normal_count+1] = n
			_normals[normal_count+2] = n
			_normals[normal_count+3] = n
			normal_count += 4


		for x as byte in range(size.x):
			for y as byte in range(size.y):
				for z as byte in range(size.z):
					block = _chunk.getBlock(ByteVector3(x, y, z))
					if x == 0 and _west_neighbor.isNull():
						block_west = BLOCK.AIR
					elif x == 0 and not _west_neighbor.isNull():
						block_west = _west_neighbor.getBlock(ByteVector3(size.x-1, y, z))
					else:
						block_west = _chunk.getBlock(ByteVector3(x-1, y, z))

					if x == size.x -1 and _east_neighbor.isNull():
						block_east = BLOCK.AIR
					elif x == size.x - 1 and not _east_neighbor.isNull():
						block_east = _east_neighbor.getBlock(ByteVector3(0, y, z))
					else:
						block_east = _chunk.getBlock(ByteVector3(x+1, y ,z))

					if z == 0 and _south_neighbor.isNull():
						block_south = BLOCK.AIR
					elif z == 0 and not _south_neighbor.isNull():
						block_south = _south_neighbor.getBlock(ByteVector3(x, y, size.z-1))
					else:
						block_south = _chunk.getBlock(ByteVector3(x, y, z-1))

					if z == size.z-1 and _north_neighbor.isNull():
						block_north = BLOCK.AIR
					elif z == size.z-1 and not _north_neighbor.isNull():
						block_north = _north_neighbor.getBlock(ByteVector3(x, y, 0))
					else:
						block_north = _chunk.getBlock(ByteVector3(x, y, z+1))

					if y == 0 and _down_neighbor.isNull():
						block_down = BLOCK.AIR
					elif y == 0 and not _down_neighbor.isNull():
						block_down = _down_neighbor.getBlock(ByteVector3(x, size.y-1, z))
					else:
						block_down = _chunk.getBlock(ByteVector3(x, y-1, z))

					if y == size.y-1 and _up_neighbor.isNull():
						block_up = BLOCK.AIR
					elif y == size.y-1 and not _up_neighbor.isNull():
						block_up = _up_neighbor.getBlock(ByteVector3(x, 0, z))
					else:
						block_up = _chunk.getBlock(ByteVector3(x, y+1, z))


					
					


					if block:
						aabb_test = false
						if not block_west:
							_vertices[vertice_count] = Vector3(x, y, z)
							_vertices[vertice_count+1] = Vector3(x, y, z+1)
							_vertices[vertice_count+2] = Vector3(x, y+1, z+1)
							_vertices[vertice_count+3] = Vector3(x, y+1, z)
							vertice_count += 4
							_calc_triangles()
							_add_normals(Vector3(-1, 0, 0))
							_add_uvs(Blocks.block_def[block].uv_x, Blocks.block_def[block].uv_y)
							aabb_test = true
						if not block_east:
							_vertices[vertice_count] = Vector3(x+1, y, z+1)
							_vertices[vertice_count+1] = Vector3(x+1, y, z)
							_vertices[vertice_count+2] = Vector3(x+1, y+1, z)
							_vertices[vertice_count+3] = Vector3(x+1, y+1, z+1)
							vertice_count += 4
							_calc_triangles()
							_add_normals(Vector3(1, 0, 0))
							_add_uvs(Blocks.block_def[block].uv_x, Blocks.block_def[block].uv_y)
							aabb_test = true
						if not block_south:
							_vertices[vertice_count] = Vector3(x+1, y, z)
							_vertices[vertice_count+1] = Vector3(x, y, z)
							_vertices[vertice_count+2] = Vector3(x, y+1, z)
							_vertices[vertice_count+3] = Vector3(x+1, y+1, z)
							vertice_count += 4
							_calc_triangles()
							_add_normals(Vector3(0, 0, -1))
							_add_uvs(Blocks.block_def[block].uv_x, Blocks.block_def[block].uv_y)
							aabb_test = true
						if not block_north:
							_vertices[vertice_count] = Vector3(x, y, z+1)
							_vertices[vertice_count+1] = Vector3(x+1, y, z+1)
							_vertices[vertice_count+2] = Vector3(x+1, y+1, z+1)
							_vertices[vertice_count+3] = Vector3(x, y+1, z+1)
							vertice_count += 4
							_calc_triangles()
							_add_normals(Vector3(0, 0, 1))
							_add_uvs(Blocks.block_def[block].uv_x, Blocks.block_def[block].uv_y)
							aabb_test = true
						if not block_down:
							_vertices[vertice_count] = Vector3(x+1, y, z+1)
							_vertices[vertice_count+1] = Vector3(x, y, z+1)
							_vertices[vertice_count+2] = Vector3(x, y, z)
							_vertices[vertice_count+3] = Vector3(x+1, y, z)
							vertice_count += 4
							_calc_triangles()
							_add_normals(Vector3(0, -1, 0))
							_add_uvs(Blocks.block_def[block].uv_x, Blocks.block_def[block].uv_y)
							aabb_test = true
						if not block_up:
							_vertices[vertice_count] = Vector3(x+1, y+1, z)
							_vertices[vertice_count+1] = Vector3(x, y+1, z)
							_vertices[vertice_count+2] = Vector3(x, y+1, z+1)
							_vertices[vertice_count+3] = Vector3(x+1, y+1, z+1)
							vertice_count += 4
							_calc_triangles()
							_add_normals(Vector3(0, 1, 0))
							_add_uvs(Blocks.block_def[block].uv_x, Blocks.block_def[block].uv_y)
							aabb_test = true
						if aabb_test:
							_bounding_volumes[aabb_count] = AABB(Vector3(x + 0.5, y + 0.5, z + 0.5), Vector3(0.5, 0.5, 0.5))
							aabb_count += 1
			_mesh_calculated = true
