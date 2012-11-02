import UnityEngine
import System.Collections
import Vectrosity

class VoxelMeshData (MonoBehaviour):
	public outline = false
	private vertices as (Vector3)
	private triangles as (int)
	private uvs as (Vector2)
	private colors as (Color32)
	private normals as (Vector3)
	private initialized = false

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

	def _check_voxels (voxels as VoxelData) as IEnumerator:
		while not voxels.IsInitialized():
			yield
		_build_mesh(voxels)
		mesh = Mesh()
		mesh.vertices = vertices
		mesh.triangles = triangles
		mesh.uv = uvs
		mesh.RecalculateNormals()
		gameObject.GetComponent(MeshFilter).sharedMesh = mesh
		initialized = true
		
	def Awake ():
		voxels = gameObject.GetComponent(VoxelData)
		if voxels is not null:
			StartCoroutine(_check_voxels(voxels))


	def _build_mesh(voxels as VoxelData):
		x_width = voxels.GetXDimension()
		z_width = voxels.GetZDimension()
		y_width = voxels.GetYDimension()
		
		_vertices = []
		_triangles = []
		_uvs = []
		_colors = []
		_normals = []
		_outline_vertices = []


		triangle_count = 0
		for x in range(x_width):
			for z in range(z_width):
				for y in range(y_width):
					solid = voxels.IsSolid(x, z, y)
					solid_west = (false if x == 0 else voxels.IsSolid(x-1, z, y))
					solid_east = (false if x == x_width-1 else voxels.IsSolid(x+1, z, y))
					
					solid_south = (false if z == 0 else voxels.IsSolid(x, z-1, y))
					solid_north = (false if z == z_width-1 else voxels.IsSolid(x, z+1, y))
					
					solid_down = (false if y == 0 else voxels.IsSolid(x, z, y-1))
					solid_up = (false if y == y_width-1 else voxels.IsSolid(x, z, y+1))

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
							_uvs.Push(Vector2(0, 0))
							_uvs.Push(Vector2(1, 0))
							_uvs.Push(Vector2(1, 1))
							_uvs.Push(Vector2(0, 1))
							triangle_count += 1
							if outline:
								pass
							#								_outline_vertices.Push(
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
							_uvs.Push(Vector2(0, 0))
							_uvs.Push(Vector2(1, 0))
							_uvs.Push(Vector2(1, 1))
							_uvs.Push(Vector2(0, 1))
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
							_uvs.Push(Vector2(0, 0))
							_uvs.Push(Vector2(1, 0))
							_uvs.Push(Vector2(1, 1))
							_uvs.Push(Vector2(0, 1))
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
							_uvs.Push(Vector2(0, 0))
							_uvs.Push(Vector2(1, 0))
							_uvs.Push(Vector2(1, 1))
							_uvs.Push(Vector2(0, 1))
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
							_uvs.Push(Vector2(0, 0))
							_uvs.Push(Vector2(1, 0))
							_uvs.Push(Vector2(1, 1))
							_uvs.Push(Vector2(0, 1))
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
							_uvs.Push(Vector2(0, 0))
							_uvs.Push(Vector2(1, 0))
							_uvs.Push(Vector2(1, 1))
							_uvs.Push(Vector2(0, 1))
							triangle_count += 1

		vertices = array(Vector3, _vertices)
		triangles = array(int, _triangles)
		uvs = array(Vector2, _uvs)
		if outline:
			vl = VectorLine("Block Outline", vertices, Resources.Load("Materials/Outline", Material), 1.0)
			vl.Draw3D()

		
