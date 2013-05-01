namespace Algorithmic.Chunks

enum BLOCK:
	AIR = 0
	##################
	SOLID = 50
	ROCK = 51
	##################
	DIRT = 80
	GRASS = 81
	SWAMP = 82
	##################
	LIQUID = 200
	WATER = 201
	MAGMA = 202


struct Block:
	id as int
	uv_x as single
	uv_y as single
	name as string

	def constructor(_id as int, _uv_x as single, _uv_y as single, _name as string):
		id = _id
		uv_x = _uv_x
		uv_y = _uv_y
		name = _name


####################################################################
class Blocks:
	#public static block_def as List[of Block]
	public static block_def as (Block)

	static def constructor():
		#block_def = List[of Block](256)
		block_def = array(Block, 256)

		block_def[BLOCK.AIR] = Block(BLOCK.AIR, 0, 0, "Air")

		block_def[BLOCK.SOLID] = Block(BLOCK.SOLID, 0.3, 0, "Solid/Generic")
		block_def[BLOCK.ROCK] = Block(BLOCK.ROCK, 0.3, 0, "Solid/Rock/Generic")

		block_def[BLOCK.DIRT] = Block(BLOCK.DIRT, 0.6, 0, "Solid/Dirt")
		block_def[BLOCK.GRASS] = Block(BLOCK.GRASS, 0.5, 0, "Solid/Grass")
		block_def[BLOCK.SWAMP] = Block(BLOCK.SWAMP, 0.4, 0, "Solid/Swamp")


		block_def[BLOCK.LIQUID] = Block(BLOCK.LIQUID, 0.7, 0, "Liquid/Generic")
		block_def[BLOCK.WATER] = Block(BLOCK.WATER, 0.7, 0, "Liquid/Water/Generic")
		block_def[BLOCK.MAGMA] = Block(BLOCK.MAGMA, 0.2, 0, "Liquid/Magma")

		