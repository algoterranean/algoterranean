import UnityEngine

class ChunkMeshData (IChunkMeshData):
	_chunk as IChunkBlockData
	_mesh_calculated as bool
	_vertices as (Vector3)
	_normals as (Vector3)
	_triangles as (int)
	_uvs as (Vector2)
	_west_neighbor as IChunkBlockData
	_east_neighbor as IChunkBlockData
	_south_neighbor as IChunkBlockData
	_north_neighbor as IChunkBlockData
	_down_neighbor as IChunkBlockData
	_up_neighbor as IChunkBlockData

	def constructor(chunk as IChunkBlockData):
		_chunk = chunk
		_mesh_calculated = false
		_west_neighbor = NullBlockData()
		_east_neighbor = NullBlockData()
		_south_neighbor = NullBlockData()
		_north_neighbor = NullBlockData()
		_down_neighbor = NullBlockData()
		_up_neighbor = NullBlockData()

	def setNeighborhoodChunks(west as IChunkBlockData, east as IChunkBlockData,
					  south as IChunkBlockData, north as IChunkBlockData,
					  down as IChunkBlockData, up as IChunkBlockData) as void:
		_west_neighbor = west
		_east_neighbor = east
		_south_neighbor = south
		_north_neighbor = north
		_down_neighbor = down
		_up_neighbor = up

	def isMeshCalculated() as bool:
		return _mesh_calculated

	def getVertices() as (Vector3):
		return _vertices

	def getNormals() as (Vector3):
		return _normals

	def getTriangles() as (int):
		return _triangles

	def getUVs() as (Vector2):
		return _uvs

	def CalculateMesh() as void:
		size = _chunk.getSize()
		p_size = size.x
		q_size = size.y
		r_size = size.z
		vertice_size = 0
		triangle_size = 0
		uv_size = 0

		for p as byte in range(p_size):
			for q as byte in range(q_size):
				for r as byte in range(r_size):
					#for p, q, r in Utils.Product(p_size, q_size, r_size):
					solid = _chunk.getBlock(ByteVector3(p, q, r))

					if p == 0 and _west_neighbor.isNull():
						solid_west = 0
					elif p == 0 and not _west_neighbor.isNull():
						solid_west = _west_neighbor.getBlock(ByteVector3(p_size-1, q, r))
					else:
						solid_west = _chunk.getBlock(ByteVector3(p-1, q, r))

					if p == p_size-1 and _east_neighbor.isNull():
						solid_east = 0
					elif p == p_size-1 and not _east_neighbor.isNull():
						solid_east = _east_neighbor.getBlock(ByteVector3(0, q, r))
					else:
						solid_east = _chunk.getBlock(ByteVector3(p+1, q, r))

					if q == 0 and _south_neighbor.isNull():
						solid_south = 0
					elif q == 0 and not _south_neighbor.isNull():
						solid_south = _south_neighbor.getBlock(ByteVector3(p, q_size-1, r))
					else:
						solid_south = _chunk.getBlock(ByteVector3(p, q-1, r))

					if q == q_size - 1 and _north_neighbor.isNull():
						solid_north = 0
					elif q == q_size - 1 and not _north_neighbor.isNull():
						solid_north = _north_neighbor.getBlock(ByteVector3(p, 0, r))
					else:
						solid_north = _chunk.getBlock(ByteVector3(p, q+1, r))

					if r == 0 and _down_neighbor.isNull():
						solid_down = 0
					elif r == 0 and not _down_neighbor.isNull():
						solid_down = _down_neighbor.getBlock(ByteVector3(p, q, r_size-1))
					else:
						solid_down = _chunk.getBlock(ByteVector3(p, q, r-1))

					if r == r_size - 1 and _up_neighbor.isNull():
						solid_up = 0
					elif r == r_size - 1 and not _up_neighbor.isNull():
						solid_up = _up_neighbor.getBlock(ByteVector3(p, q, 0))
					else:
						solid_up = _chunk.getBlock(ByteVector3(p, q, r+1))


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
					
		_vertices = matrix(Vector3, vertice_size)
		_triangles = matrix(int, triangle_size)
		_uvs = matrix(Vector2, uv_size)
		_normals = matrix(Vector3, vertice_size)

		vertice_count = 0
		triangle_count = 0
		uv_count = 0
		normal_count = 0


		def _calc_uvs(x as int, y as int):
			# give x, y coordinates in (0-9) by (0-9)
			_uvs[uv_count] = Vector2(0.1*x, 1.0 - 0.1*y - 0.1)
			uv_count += 1
			_uvs[uv_count] = Vector2(0.1*x, 1.0 - 0.1*y)
			uv_count += 1
			_uvs[uv_count] = Vector2(0.1*x + 0.1, 1.0 - 0.1*y)
			uv_count += 1
			_uvs[uv_count] = Vector2(0.1*x + 0.1, 1.0 - 0.1*y - 0.1)
			uv_count += 1

		def _calc_triangles():
			_triangles[triangle_count] = vertice_count-4 # 0
			triangle_count += 1
			_triangles[triangle_count] = vertice_count-3 # 1
			triangle_count += 1			
			_triangles[triangle_count] = vertice_count-2 # 2
			triangle_count += 1			
			_triangles[triangle_count] = vertice_count-2 # 2
			triangle_count += 1			
			_triangles[triangle_count] = vertice_count-1 # 3
			triangle_count += 1			
			_triangles[triangle_count] = vertice_count-4 # 0
			triangle_count += 1

		def _add_normals(n as Vector3):
			_normals[normal_count] = n
			normal_count += 1
			_normals[normal_count] = n
			normal_count += 1			
			_normals[normal_count] = n
			normal_count += 1			
			_normals[normal_count] = n
			normal_count += 1

			
		for p as byte in range(p_size):
			for q as byte in range(q_size):
				for r as byte in range(r_size):
					#for p, q, r in Utils.Product(p_size, q_size, r_size):
					solid = _chunk.getBlock(ByteVector3(p, q, r))

					if p == 0 and _west_neighbor.isNull():
						solid_west = 0
					elif p == 0 and not _west_neighbor.isNull():
						solid_west = _west_neighbor.getBlock(ByteVector3(p_size-1, q, r))
					else:
						solid_west = _chunk.getBlock(ByteVector3(p-1, q, r))

					if p == p_size-1 and _east_neighbor.isNull():
						solid_east = 0
					elif p == p_size-1 and not _east_neighbor.isNull():
						solid_east = _east_neighbor.getBlock(ByteVector3(0, q, r))
					else:
						solid_east = _chunk.getBlock(ByteVector3(p+1, q, r))

					if q == 0 and _south_neighbor.isNull():
						solid_south = 0
					elif q == 0 and not _south_neighbor.isNull():
						solid_south = _south_neighbor.getBlock(ByteVector3(p, q_size-1, r))
					else:
						solid_south = _chunk.getBlock(ByteVector3(p, q-1, r))

					if q == q_size - 1 and _north_neighbor.isNull():
						solid_north = 0
					elif q == q_size - 1 and not _north_neighbor.isNull():
						solid_north = _north_neighbor.getBlock(ByteVector3(p, 0, r))
					else:
						solid_north = _chunk.getBlock(ByteVector3(p, q+1, r))

					if r == 0 and _down_neighbor.isNull():
						solid_down = 0
					elif r == 0 and not _down_neighbor.isNull():
						solid_down = _down_neighbor.getBlock(ByteVector3(p, q, r_size-1))
					else:
						solid_down = _chunk.getBlock(ByteVector3(p, q, r-1))

					if r == r_size - 1 and _up_neighbor.isNull():
						solid_up = 0
					elif r == r_size - 1 and not _up_neighbor.isNull():
						solid_up = _up_neighbor.getBlock(ByteVector3(p, q, 0))
					else:
						solid_up = _chunk.getBlock(ByteVector3(p, q, r+1))



					if solid:
						if not solid_west:
							_vertices[vertice_count] = Vector3(p, r, q)
							vertice_count += 1
							_vertices[vertice_count] = Vector3(p, r, q+1)
							vertice_count += 1
							_vertices[vertice_count] = Vector3(p, r+1, q+1)
							vertice_count += 1
							_vertices[vertice_count] = Vector3(p, r+1, q)
							vertice_count += 1
							_calc_triangles()
							_add_normals(Vector3(-1, 0, 0))
							if solid == 1:
								_calc_uvs(3,0)
							elif solid == 2:
								_calc_uvs(2,0)

						if not solid_east:
							_vertices[vertice_count] = Vector3(p+1, r, q+1)
							vertice_count += 1
							_vertices[vertice_count] = Vector3(p+1, r, q)
							vertice_count += 1
							_vertices[vertice_count] = Vector3(p+1, r+1, q)
							vertice_count += 1
							_vertices[vertice_count] = Vector3(p+1, r+1, q+1)
							vertice_count += 1
							_calc_triangles()
							_add_normals(Vector3(1, 0, 0))
							if solid == 1:
								_calc_uvs(3, 0)
							elif solid == 2:
								_calc_uvs(2, 0)

						if not solid_south:
							_vertices[vertice_count] = Vector3(p+1, r, q)
							vertice_count += 1
							_vertices[vertice_count] = Vector3(p, r, q)
							vertice_count += 1
							_vertices[vertice_count] = Vector3(p, r+1, q)
							vertice_count += 1
							_vertices[vertice_count] = Vector3(p+1, r+1, q)
							vertice_count += 1
							_calc_triangles()
							_add_normals(Vector3(0, 0, -1))
							if solid == 1:
								_calc_uvs(3,0)
							elif solid == 2:
								_calc_uvs(2, 0)							

						if not solid_north:
							_vertices[vertice_count] = Vector3(p, r, q+1)
							vertice_count += 1
							_vertices[vertice_count] = Vector3(p+1, r, q+1)
							vertice_count += 1
							_vertices[vertice_count] = Vector3(p+1, r+1, q+1)
							vertice_count += 1
							_vertices[vertice_count] = Vector3(p, r+1, q+1)
							vertice_count += 1
							_calc_triangles()
							_add_normals(Vector3(0, 0, 1))
							if solid == 1:
								_calc_uvs(3,0)
							elif solid == 2:
								_calc_uvs(2, 0)

						if not solid_down:
							_vertices[vertice_count] = Vector3(p+1, r, q+1)
							vertice_count += 1
							_vertices[vertice_count] = Vector3(p, r, q+1)
							vertice_count += 1
							_vertices[vertice_count] = Vector3(p, r, q)
							vertice_count += 1
							_vertices[vertice_count] = Vector3(p+1, r, q)
							vertice_count += 1
							_calc_triangles()
							_add_normals(Vector3(0, -1, 0))
							if solid == 1:
								_calc_uvs(3,0)
							elif solid == 2:
								_calc_uvs(2, 0)							

						if not solid_up:
							_vertices[vertice_count] = Vector3(p+1, r+1, q)
							vertice_count += 1
							_vertices[vertice_count] = Vector3(p, r+1, q)
							vertice_count += 1
							_vertices[vertice_count] = Vector3(p, r+1, q+1)
							vertice_count += 1
							_vertices[vertice_count] = Vector3(p+1, r+1, q+1)
							vertice_count += 1
							_calc_triangles()
							_add_normals(Vector3(0, 1, 0))
							if solid == 1:
								_calc_uvs(3,0)
							elif solid == 2:							
								_calc_uvs(2, 0)
			_mesh_calculated = true
