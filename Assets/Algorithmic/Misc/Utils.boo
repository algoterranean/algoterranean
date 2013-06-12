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
        x_pos = Floor(coords.x / size)
        y_pos = Floor(coords.y / size)
        z_pos = Floor(coords.z / size)
        return WorldBlockCoordinate(x_pos * Settings.ChunkSize, y_pos * Settings.ChunkSize,  z_pos * Settings.ChunkSize)


