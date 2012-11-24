

class Chunk ():
	blocks as (byte, 3)
	noise as VoxelNoiseData
	
	def constructor(chunk_x as int, chunk_z as int, chunk_y as int):
		blocks = matrix(byte, Settings.ChunkSize, Settings.ChunkSize, Settings.ChunkSize)
		noise = VoxelNoiseData()
		#size_x, size_z, size_y)
		
		for x in range(Settings.ChunkSize):
			for z in range(Settings.ChunkSize):
				for y in range(Settings.ChunkSize):
					blocks[x,z,y] = noise.GetBlock(x + chunk_x, z + chunk_z, y + chunk_y)
