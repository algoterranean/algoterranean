
struct Settings:
	public static Frequency as single = 1.2
	public static Lacunarity as single = 2.5
	public static Exponent as single = 1.0
	public static OctaveCount as single = 3.0
	public static Power = 0.3

	public static ChunkCountX as int = 10
	public static ChunkCountZ as int = 10
	public static ChunkCountY as int = 5
	public static ChunkSize as int = 32
	public static Seed as int = System.Random(System.DateTime.Now.Ticks & 0x0000FFFF).Next()

	public static TerrainDepth as single = ChunkCountY * ChunkSize
	public static SolidCutoff as single = 0.0
