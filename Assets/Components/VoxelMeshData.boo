import UnityEngine
import Vectrosity

class VoxelMeshData (MonoBehaviour, IObserver):
	public outline = false
	private vertices as (Vector3)
	private triangles as (int)
	private uvs as (Vector2)
	private colors as (Color32)
	private normals as (Vector3)
	private initialized = false

	def OnData(data as IObservable):
		_build_mesh(data)
		

	def IsInitialized ():
		return initialized

	def GetVertices ():
		return vertices

	def GetTriangles ():
		return triangles

	def GetUVs ():
		return uvs

	def GetColors ():
		return colors

	def GetNormals ():
		return normals
	

	def Awake ():
		voxels = gameObject.GetComponent(VoxelData)
		if voxels is not null:
			voxels.Subscribe(self)

	def _build_mesh(voxels as VoxelData): #as IEnumerator:
		# while not voxels.IsInitialized():
		# 	yield
			
		x_width = voxels.GetXDimension()
		z_width = voxels.GetZDimension()
		y_width = voxels.GetYDimension()
		
		_vertices = []
		_triangles = []
		_uvs = []
		#_colors = []
		#_normals = []
		#_outline_vertices = []


		triangle_count = 0

		def _calc_uvs(x as int, y as int):
			# give x, y coordinates in (0-9) by (0-9)
			_uvs.Push(Vector2(0.1*x, 1.0 - 0.1*y - 0.1))
			_uvs.Push(Vector2(0.1*x, 1.0 - 0.1*y))
			_uvs.Push(Vector2(0.1*x + 0.1, 1.0 - 0.1*y))
			_uvs.Push(Vector2(0.1*x + 0.1, 1.0 - 0.1*y - 0.1))
			
			

		for x in range(x_width):
			for z in range(z_width):
				for y in range(y_width):
					solid = voxels.GetBlock(x, z, y)
					# solid_west = voxels.GetWestBlock(x, z, y)
					# solid_east = voxels.GetEastBlock(x, z, y)
					# solid_south = voxels.GetSouthBlock(x, z, y)
					# solid_north = voxels.GetNorthBlock(x, z, y)
					# solid_down = voxels.GetDownBlock(x, z, y)
					# solid_up = voxels.GetUpBlock(x, z, y)
					
					solid_west = (0 if x == 0 else voxels.GetBlock(x-1, z, y))
					solid_east = (0 if x == x_width-1 else voxels.GetBlock(x+1, z, y))
					
					solid_south = (0 if z == 0 else voxels.GetBlock(x, z-1, y))
					solid_north = (0 if z == z_width-1 else voxels.GetBlock(x, z+1, y))
					
					solid_down = (0 if y == 0 else voxels.GetBlock(x, z, y-1))
					solid_up = (0 if y == y_width-1 else voxels.GetBlock(x, z, y+1))

					if solid:
						if not solid_west:
							_vertices.Push(Vector3(x, y, z))
							_vertices.Push(Vector3(x, y, z+1))
							_vertices.Push(Vector3(x, y+1, z+1))
							_vertices.Push(Vector3(x, y+1, z))
							_triangles.Push(0+triangle_count*4)
							_triangles.Push(1+triangle_count*4)
							_triangles.Push(2+triangle_count*4)
							_triangles.Push(2+triangle_count*4)
							_triangles.Push(3+triangle_count*4)
							_triangles.Push(0+triangle_count*4)
							if solid == 1:
								_calc_uvs(3,0)
							elif solid == 2:
								_calc_uvs(2,0)
							triangle_count += 1
							if outline:
								pass
						if not solid_east:
							_vertices.Push(Vector3(x+1, y, z+1))
							_vertices.Push(Vector3(x+1, y, z))
							_vertices.Push(Vector3(x+1, y+1, z))
							_vertices.Push(Vector3(x+1, y+1, z+1))
							_triangles.Push(0+triangle_count*4)
							_triangles.Push(1+triangle_count*4)
							_triangles.Push(2+triangle_count*4)
							_triangles.Push(2+triangle_count*4)
							_triangles.Push(3+triangle_count*4)
							_triangles.Push(0+triangle_count*4)
							if solid == 1:
								_calc_uvs(3,0)
							elif solid == 2:
								_calc_uvs(2,0)							
							triangle_count += 1							
						if not solid_north:
							_vertices.Push(Vector3(x, y, z+1))
							_vertices.Push(Vector3(x+1, y, z+1))
							_vertices.Push(Vector3(x+1, y+1, z+1))
							_vertices.Push(Vector3(x, y+1, z+1))
							_triangles.Push(0+triangle_count*4)
							_triangles.Push(1+triangle_count*4)
							_triangles.Push(2+triangle_count*4)
							_triangles.Push(2+triangle_count*4)
							_triangles.Push(3+triangle_count*4)
							_triangles.Push(0+triangle_count*4)
							if solid == 1:
								_calc_uvs(3,0)
							elif solid == 2:
								_calc_uvs(2,0)							
							triangle_count += 1
						if not solid_south:
							_vertices.Push(Vector3(x+1, y, z))
							_vertices.Push(Vector3(x, y, z))
							_vertices.Push(Vector3(x, y+1, z))
							_vertices.Push(Vector3(x+1, y+1, z))
							_triangles.Push(0+triangle_count*4)
							_triangles.Push(1+triangle_count*4)
							_triangles.Push(2+triangle_count*4)
							_triangles.Push(2+triangle_count*4)
							_triangles.Push(3+triangle_count*4)
							_triangles.Push(0+triangle_count*4)
							if solid == 1:
								_calc_uvs(3,0)
							elif solid == 2:
								_calc_uvs(2,0)							
							triangle_count += 1							
						if not solid_down:
							_vertices.Push(Vector3(x+1, y, z+1))
							_vertices.Push(Vector3(x, y, z+1))
							_vertices.Push(Vector3(x, y, z))
							_vertices.Push(Vector3(x+1, y, z))
							_triangles.Push(0+triangle_count*4)
							_triangles.Push(1+triangle_count*4)
							_triangles.Push(2+triangle_count*4)
							_triangles.Push(2+triangle_count*4)
							_triangles.Push(3+triangle_count*4)
							_triangles.Push(0+triangle_count*4)
							if solid == 1:
								_calc_uvs(3,0)
							elif solid == 2:
								_calc_uvs(2,0)							
							triangle_count += 1
						if not solid_up:
							_vertices.Push(Vector3(x+1, y+1, z))
							_vertices.Push(Vector3(x, y+1, z))
							_vertices.Push(Vector3(x, y+1, z+1))
							_vertices.Push(Vector3(x+1, y+1, z+1))
							_triangles.Push(0+triangle_count*4)
							_triangles.Push(1+triangle_count*4)
							_triangles.Push(2+triangle_count*4)
							_triangles.Push(2+triangle_count*4)
							_triangles.Push(3+triangle_count*4)
							_triangles.Push(0+triangle_count*4)
							if solid == 1:
								_calc_uvs(3,0)
							elif solid == 2:
								_calc_uvs(2,0)							
							triangle_count += 1
							
		vertices = array(Vector3, _vertices)
		triangles = array(int, _triangles)
		uvs = array(Vector2, _uvs)
		if outline:
			vl = VectorLine("Block Outline", vertices, Resources.Load("Materials/Outline", Material), 1.0)
			vl.Draw3D()
			
		mesh = Mesh()
		mesh.vertices = vertices
		mesh.triangles = triangles
		mesh.uv = uvs
		mesh.RecalculateNormals()
		gameObject.GetComponent(MeshFilter).sharedMesh = mesh
		gameObject.GetComponent(MeshCollider).sharedMesh = mesh
		initialized = true
			

		
