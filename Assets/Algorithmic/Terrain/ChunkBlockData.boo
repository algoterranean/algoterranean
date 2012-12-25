import UnityEngine

class NullBlockData (IChunkBlockData):
	def isNull():
		return true
	def areBlocksCalculated():
		return false


class ChunkBlockData (IChunkBlockData):
	_coords as LongVector3
	_size as ByteVector3
	_blocks as (byte, 3)
	_blocks_calculated as bool
	_noise_module as INoiseData

	def constructor(coords as LongVector3, size as ByteVector3):
		setCoordinates(coords)
		setSize(size)
		_blocks = matrix(byte, size.x, size.y, size.z)
		_blocks_calculated = false
		_noise_module = MineralNoiseData()
		#_noise_module = BasicNoiseData()
		
	def setCoordinates(coords as LongVector3) as void:
		_coords = coords

	def getCoordinates() as LongVector3:
		return _coords

	def setSize(size as ByteVector3) as void:
		_size = size

	def getSize() as ByteVector3:
		return _size

	def setBlock(coords as ByteVector3, block as byte) as void:
		_blocks[coords.x, coords.y, coords.z] = block

	def getBlock(coords as ByteVector3) as byte:
		return _blocks[coords.x, coords.y, coords.z]

	def areBlocksCalculated() as bool:
		return _blocks_calculated

	def isNull() as bool:
		return false

	def CalculateBlocks() as void:
		for p in range(_size.x):
			for q in range(_size.y):
				for r in range(_size.z):
					_blocks[p, q, r] = _noise_module.getBlock(p + _coords.x, q + _coords.y, r + _coords.z)
		_blocks_calculated = true
		
