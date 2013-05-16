namespace Algorithmic.Chunks


class NullBlockData (IChunkBlockData):
	def isNull():
		return true
	def areBlocksCalculated():
		return false


class BlockData (IChunkBlockData):
	coords as WorldBlockCoordinate
	size as ByteVector3
	blocks as (byte, 3)
	blocks_calculated as bool
	noise_module as INoiseData

	def constructor(coords as WorldBlockCoordinate, size as ByteVector3):
		setCoordinates(coords)
		setSize(size)
		blocks = matrix(byte, size.x, size.y, size.z)
		blocks_calculated = false
		noise_module = BiomeNoiseData()
		#noise_module = MineralNoiseData()
		#noise_module = SolidNoiseData()
		#noise_module = BasicNoiseData()
		
	def setCoordinates(coords as WorldBlockCoordinate) as void:
		self.coords = coords

	def getCoordinates() as WorldBlockCoordinate:
		return coords

	def setSize(size as ByteVector3) as void:
		self.size = size

	def getSize() as ByteVector3:
		return size

	def setBlock(coords as ByteVector3, block as byte) as void:
		blocks[coords.x, coords.y, coords.z] = block

	def getBlock(coords as ByteVector3) as byte:
		# if coords.x >= size.x or coords.y >= size.y or coords.z >= size.z:
		# 	print "ERROR: Invalid Block Coordinates: ($(coords.x), $(coords.y), $(coords.z))"
		# 	return BLOCK.AIR
		return blocks[coords.x, coords.y, coords.z]

	def getBlock(x as byte, y as byte, z as byte) as byte:
		return blocks[x, y, z]

	def areBlocksCalculated() as bool:
		return blocks_calculated

	def isNull() as bool:
		return false

	def CalculateBlocks() as void:
		for p in range(size.x):
			for r in range(size.z):
				for q in range(size.y):					# rearrange to try out cache2D with voronoi
					blocks[p, q, r] = noise_module.getBlock(p + coords.x, q + coords.y, r + coords.z)
		blocks_calculated = true
		
