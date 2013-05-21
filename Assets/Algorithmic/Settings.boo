namespace Algorithmic

struct Settings:
	public static Frequency as single = 2.0 #1.2 #1.2
	public static Lacunarity as single = 2.5
	public static Exponent as single = 1.0
	public static OctaveCount as single = 3.0 #3.0
	public static Power = 0.5


	public static ChunkSize as int = 32
	public static MaxChunks as int = 0
	public static MaxChunksVertical as int = 1
	
	public static PlayerRadius = Vector3(1.5, 3.0, 1.5)
	#public static PlayerRadius = Vector3(0.5, 1, 0.5)

	public static Seed as int = 1 #System.Random(System.DateTime.Now.Ticks & 0x0000FFFF).Next()
	public static TerrainDepth as single = (MaxChunksVertical * 2 + 1) * ChunkSize
	

