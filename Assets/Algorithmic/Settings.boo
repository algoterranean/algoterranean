namespace Algorithmic


struct Settings:
	struct Terrain:
		public static Frequency as single = 2.0 #1.2 #1.2
		public static Lacunarity as single = 2.5
		public static Exponent as single = 1.0
		public static OctaveCount as single = 3.0 #3.0
		public static Power = 0.5
		public static Seed as int = System.Random(System.DateTime.Now.Ticks & 0x0000FFFF).Next()	#1821724748 #

	struct Chunks:
		public static Size as int = 32
		public static MaxHorizontal as int = 10 # minecraft farthest by default is 8 (256 blocks in each direction)
		public static MaxVertical as int = 4 # minecraft farthest by default is 4 (256 blocks total up/down)
		public static Scale as single = 1.0/4.0
		struct Interpolate:
			public static X as int = 4
			public static Y as int = 4
			public static Z as int = 4
		public static Depth as single = (MaxVertical * 2 + 1) * Size

	struct Player:
		public static Radius = Vector3(1.5, 3.0, 1.5)


# struct Settings:
# 	public static Frequency as single = 2.0 #1.2 #1.2
# 	public static Lacunarity as single = 2.5
# 	public static Exponent as single = 1.0
# 	public static OctaveCount as single = 3.0 #3.0
# 	public static Power = 0.5


# 	public static ChunkSize as int = 32
# 	public static MaxChunks as int = 10 # minecraft farthest by default is 8 (256 blocks in each direction)
# 	public static MaxChunksVertical as int = 4 # minecraft farthest by default is 4 (256 blocks total up/down)
# 	public static ChunkScale as single = 1.0/4.0
# 	public static ChunkInterpolateSizeX as int = 4
# 	public static ChunkInterpolateSizeY as int = 4
# 	public static ChunkInterpolateSizeZ as int = 4
	
# 	public static PlayerRadius = Vector3(1.5, 3.0, 1.5)
# 	#public static PlayerRadius = Vector3(0.5, 1, 0.5)

# 	public static Seed as int = System.Random(System.DateTime.Now.Ticks & 0x0000FFFF).Next()	#1821724748 #
# 	public static TerrainDepth as single = (MaxChunksVertical * 2 + 1) * ChunkSize

# 	# seeds
# 	# 1821724748 = to test out lighting and SSAO bugs/effects
	

