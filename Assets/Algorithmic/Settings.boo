
namespace Algorithmic

struct Settings:
	public static Frequency as single = 1.2 #1.2
	public static Lacunarity as single = 2.5
	public static Exponent as single = 1.0
	public static OctaveCount as single = 3.0 #3.0
	public static Power = 0.5

	public static ChunkCountA as int = 5
	public static ChunkCountB as int = 5
	public static ChunkCountC as int = 3
	public static MinChunkDistance as double = 120 #80.0
	public static MaxChunkDistance as double = 240.0


	public static ChunkSize as int = 32
	# these are per side. i.e., 1 would mean 1 on each side
	# plus the origin chunk = 3 total chunks
	public static ChunkWidth as int = 0
	public static ChunkDepth as int = 0
	public static ChunkHeight as int = 0

	
	public static Seed as int = System.Random(System.DateTime.Now.Ticks & 0x0000FFFF).Next()

	public static TerrainDepth as single = (ChunkHeight * 2 + 1) * ChunkSize /2
	public static SolidCutoff as single = 0.0
	
