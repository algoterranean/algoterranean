namespace Algorithmic

struct Settings:
	public static Frequency as single = 2.0 #1.2 #1.2
	public static Lacunarity as single = 2.5
	public static Exponent as single = 1.0
	public static OctaveCount as single = 3.0 #3.0
	public static Power = 0.5

	#public static ChunkCountA as int = 5
	#public static ChunkCountB as int = 5
	#public static ChunkCountC as int = 3
	# public static MinChunkDistance as byte = 1
	# public static MinChunkDistance as byte = 2


	public static ChunkSize as int = 32
	public static MaxChunks as int = 5
	public static MaxChunksVertical as int = 2

	public static PlayerRadius = Vector3(1.5, 3.0, 1.5)
	#public static PlayerRadius = Vector3(0.5, 1, 0.5)

	# these are per side. i.e., 1 would mean 1 on each side
	# plus the origin chunk = 3 total chunks
	# public static ChunkWidth as int = 1
	# public static ChunkDepth as int = 1
	#public static ChunkHeight as int = 1
	public static Seed as int = System.Random(System.DateTime.Now.Ticks & 0x0000FFFF).Next()
	public static TerrainDepth as single = (MaxChunksVertical * 2 + 1) * ChunkSize
	#(ChunkHeight * 2 + 1) * ChunkSize /2
	
	#public static SolidCutoff as single = 0.0

