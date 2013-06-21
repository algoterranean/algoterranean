namespace Algorithmic.Utils
import System.Math

class Utils ():
    static def Product(x as int, y as int, z as int):
        for x in range(x):
            for y in range(y):
                for z in range(z):
                    yield x, y, z

	static def whichChunk(coords as Vector3) as WorldBlockCoordinate:
        size = Settings.ChunkSize cast single
        scale = Settings.ChunkScale
        x_pos = Floor(coords.x / size)
        y_pos = Floor(coords.y / size)
        z_pos = Floor(coords.z / size)
        return WorldBlockCoordinate(x_pos * Settings.ChunkSize * scale,
									y_pos * Settings.ChunkSize * scale,
									z_pos * Settings.ChunkSize * scale)

	static def decomposeCoordinates(world as WorldBlockCoordinate):
		size = Settings.ChunkSize
		size_f = size cast single
		scale = Settings.ChunkScale

		chunk_x = Floor(world.x / size_f) * size * scale
		chunk_y = Floor(world.y / size_f) * size * scale
		chunk_z = Floor(world.z / size_f) * size * scale
		
		local_x = Abs(chunk_x / scale - world.x)
		local_y = Abs(chunk_y / scale - world.y)
		local_z = Abs(chunk_z / scale - world.z)
		
		chunk_coord = WorldBlockCoordinate(chunk_x, chunk_y, chunk_z)
		local_coord = ChunkBlockCoordinate(local_x, local_y, local_z)
		return chunk_coord, local_coord

	static def decomposeCoordinates(world as Vector3):
		size = Settings.ChunkSize
		size_f = size cast single
		scale = Settings.ChunkScale
	
		chunk_coord = WorldBlockCoordinate(Floor(world.x / size / scale) * size * scale,
										   Floor(world.y / size / scale) * size * scale,
										   Floor(world.z / size / scale) * size * scale)

		abs_coord = WorldBlockCoordinate(Floor(world.x/scale),
										 Floor(world.y/scale),
										 Floor(world.z/scale))

		local_coord = WorldBlockCoordinate(abs_coord.x - chunk_coord.x,
										   abs_coord.y - chunk_coord.y,
										   abs_coord.z - chunk_coord.z)

		return chunk_coord, local_coord, abs_coord
		
		
		

	
