import UnityEngine

class NullBlockData (IChunkBlockData):
	def isNull():
		return false

class ChunkBlockData (IChunkBlockData):
	_coords as LongVector3
	_size as ByteVector3
	_blocks as (byte, 3)
	_blocks_calculated as bool
	_noise_module as VoxelNoiseData

	def constructor(coords as LongVector3, size as ByteVector3):
		setCoordinates(coords)
		setSize(size)
		_blocks = matrix(byte, size.x, size.z, size.y)
		_blocks_calculated = false
		_noise_module = VoxelNoiseData()
		
	def setCoordinates(coords as LongVector3) as void:
		_coords = coords

	def getCoordinates() as LongVector3:
		return _coords

	def setSize(size as ByteVector3) as void:
		_size = size

	def getSize() as ByteVector3:
		return _size

	def setBlock(coords as ByteVector3, block as byte) as void:
		_blocks[coords.x, coords.z, coords.y] = block

	def getBlock(coords as ByteVector3) as byte:
		return _blocks[coords.x, coords.z, coords.y]

	def areBlocksCalculated() as bool:
		return _blocks_calculated

	def isNull() as bool:
		return false

	def CalculateBlocks() as void:
		for p in range(_size.x):
			for q in range(_size.z):
				for r in range(_size.y):
					_blocks[p, q, r] = _noise_module.GetBlock(p + _coords.x, q + _coords.z, r + _coords.y)
		_blocks_calculated = true
		
