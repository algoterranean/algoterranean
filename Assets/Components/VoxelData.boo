import UnityEngine

class VoxelData (MonoBehaviour, IObservable):
	public x_dimension as int = Settings.ChunkSize
	public z_dimension as int = Settings.ChunkSize
	public y_dimension as int = Settings.ChunkSize
	public x_offset as int = 0
	public z_offset as int = 0
	public y_offset as int = 0
	
	private _density_values as (single, 3)
	private _block_values as (int, 3)
	private initialized = false
	private _observers = []

	private chunk_west as duck
	private chunk_east as duck
	private chunk_north as duck
	private chunk_south as duck
	private chunk_up as duck
	private chunk_down as duck

	def Subscribe(obj as IObserver):
		if obj not in _observers:
			_observers.Add(obj)
			obj.OnData(self)

	def Unsubscribe(obj as IObserver):
		if obj in _observers:
			_observers.Remove(obj)

	def SetNeighboringChunks(west as object, east as object, north as object,
					 south as object, up as object, down as object):
		chunk_west = west
		chunk_east = east
		chunk_north = north
		chunk_south = south
		chunk_up = up
		chunk_down = down
		
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
		if _block_values[x,z,y] == 0.0:
			return true
		else:
			return false

	def GetBlock(x as int, z as int, y as int) as int:
		return _block_values[x, z, y]

	def GetEastBlock(x as int, z as int, y as int) as int:
		if x == Settings.ChunkSize - 1:
			if chunk_east is null:
				return 0
			else:
				return chunk_east.GetComponent(VoxelData).GetBlock(0, z, y)
		else:
			return self.GetBlock(x+1, z, y)

	def GetWestBlock(x as int, z as int, y as int) as int:
		if x == 0:
			if chunk_west is null:
				return 0
			else:
				return chunk_west.GetComponent(VoxelData).GetBlock(Settings.ChunkSize - 1, z, y)
		else:
			return self.GetBlock(x-1, z, y)

	def GetNorthBlock(x as int, z as int, y as int) as int:
		if z == Settings.ChunkSize - 1:
			if chunk_north is null:
				return 0
			else:
				return chunk_north.GetComponent(VoxelData).GetBlock(x, 0, y)
		else:
			return self.GetBlock(x, z+1, y)

	def GetSouthBlock(x as int, z as int, y as int) as int:
		if z == 0:
			if chunk_south is null:
				return 0
			else:
				return chunk_south.GetComponent(VoxelData).GetBlock(x, Settings.ChunkSize - 1, y)
		else:
			return self.GetBlock(x, z-1, y)

	def GetUpBlock(x as int, z as int, y as int) as int:
		if y == Settings.ChunkSize - 1:
			if chunk_up is null:
				return 0
			else:
				c = chunk_up.GetComponent(VoxelData)
				if c is null:
					return 0
				else:
					return c.GetBlock(x, z, 0)
		else:
			return self.GetBlock(x, z, y+1)

	def GetDownBlock(x as int, z as int, y as int) as int:
		if y == 0:
			if chunk_down is null:
				return 0
			else:
				return chunk_down.GetComponent(VoxelData).GetBlock(x, z, Settings.ChunkSize - 1)
		else:
			return self.GetBlock(x, z, y-1)

	def _generate_noise(noise as VoxelNoiseData):
		if noise is not null:
			for x in range(x_dimension):
				for z in range(z_dimension):
					for y in range(y_dimension):
						_block_values[x,z,y] = noise.GetBlock(x + x_offset, z + z_offset, y + y_offset)
						#_density_values[x,z,y] = 

						# if _density_values[x,z,y] <= solid_cutoff:
						# 	_block_values[x,z,y] = 1
						# else:
						# 	_block_values[x,z,y] = 0
			initialized = true
			for obj as IObserver in _observers:
				obj.OnData(self)
				

	def Awake ():
		_density_values = matrix(single, x_dimension, z_dimension, y_dimension)
		_block_values = matrix(int, x_dimension, z_dimension, y_dimension)

		noise = gameObject.GetComponent(VoxelNoiseData)
		_generate_noise(noise)





	



