import UnityEngine

class VoxelData (MonoBehaviour):
	public x_dimension as int
	public z_dimension as int
	public y_dimension as int
	public solid_cutoff as single   # value from 0 to 1.0 where <= is considered solid
	private _density_values as (single, 3)
	private _block_values as (int, 3)
	private initialized = false

	def GetXDimension():
		return x_dimension

	def GetZDimension():
		return z_dimension

	def GetYDimension():
		return y_dimension

	def GetDensity(x as int, z as int, y as int) as single:
		return _density_values[x,z,y]

	def IsInitialized ():
		return initialized

	def IsSolid (x as int, z as int, y as int) as bool:
		if _density_values[x,z,y] <= solid_cutoff:
			return true
		else:
			return false

	def GetBlock(x as int, z as int, y as int) as int:
		return _block_values[x,z,y]

	def Awake ():
		_density_values = matrix(single, x_dimension, z_dimension, y_dimension)
		_block_values = matrix(int, x_dimension, z_dimension, y_dimension)
		
		noise = gameObject.GetComponent(VoxelNoiseData)
		if noise is not null:
			for x in range(x_dimension):
				for z in range(z_dimension):
					for y in range(y_dimension):
						_density_values[x,z,y] = noise.GetDensity(x,z,y)
						if _density_values[x,z,y] <= solid_cutoff:
							_block_values[x,z,y] = 1
						else:
							_block_values[x,z,y] = 0
			initialized = true


	



