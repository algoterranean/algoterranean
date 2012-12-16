namespace Algorithmic

class Utils ():
    static def Product(x as int, y as int, z as int):
        for x in range(x):
            for y in range(y):
                for z in range(z):
                    yield x, y, z

    static def whichChunk(coords as Vector3) as LongVector3:
        x_pos = System.Math.Floor(coords.x / Settings.ChunkSize)
        z_pos = System.Math.Floor(coords.z / Settings.ChunkSize)
        y_pos = System.Math.Floor(coords.y / Settings.ChunkSize)
        return LongVector3(x_pos * Settings.ChunkSize, y_pos * Settings.ChunkSize,  z_pos * Settings.ChunkSize)


