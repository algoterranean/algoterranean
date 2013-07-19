namespace Algorithmic.Chunks
import UnityEngine

struct Block:
	id as int
	uv_x as single
	uv_y as single
	color as Color

	def constructor(_id as int, _uv_x as single, _uv_y as single, _color as Color):
		id = _id
		uv_x = _uv_x
		uv_y = _uv_y
		color = _color


enum BLOCK:
	AIR = 0
	##################
	SOLID = 50
	ROCK = 51
	MUD = 52
	##################
	DIRT = 80
	GRASS = 81
	SWAMP = 82
	##################
	LIQUID = 200
	WATER = 201
	MAGMA = 202
	BLOOD = 203


class Blocks:
	#public static block_def as List[of Block]
	public static block_def as (Block)

	static def constructor():
		#block_def = List[of Block](256)
		block_def = array(Block, 256)

		block_def[BLOCK.AIR] = Block(BLOCK.AIR, 0, 0, Color(0, 0, 0, 0))

		block_def[BLOCK.SOLID] = Block(BLOCK.SOLID, 0.3, 0, Color(133/255.0, 133/255.0, 133/255.0, 1)) # gray
		block_def[BLOCK.ROCK] = Block(BLOCK.ROCK, 0.3, 0, Color(133/255.0, 133/255.0, 133/255.0, 1))
		block_def[BLOCK.MUD] = Block(BLOCK.MUD, 0.6, 0, Color(89/255.0, 59/255.0, 29/255.0, 1)) # dark brown

		block_def[BLOCK.DIRT] = Block(BLOCK.DIRT, 0.0, 0, Color(150/255.0, 119/255.0, 87/255.0, 1)) # light brown
		block_def[BLOCK.GRASS] = Block(BLOCK.GRASS, 0.5, 0, Color(89/255.0, 150/255.0, 87/255.0, 1)) # light green
		block_def[BLOCK.SWAMP] = Block(BLOCK.SWAMP, 0.4, 0, Color(55/255.0, 92/255.0, 45/255.0)) # dark green

		block_def[BLOCK.LIQUID] = Block(BLOCK.LIQUID, 0.7, 0, Color(54/255.0, 83/255.0, 179/255.0, 1)) # blue
		block_def[BLOCK.WATER] = Block(BLOCK.WATER, 0.7, 0, Color(54/255.0, 83/255.0, 179/255.0, 1))
		block_def[BLOCK.MAGMA] = Block(BLOCK.MAGMA, 0.2, 0, Color(194/255.0, 42/255.0, 0/255.0, 1)) # red
		block_def[BLOCK.BLOOD] = Block(BLOCK.MAGMA, 0.1, 0, Color(194/255.0, 42/255.0, 0/255.0, 1))

		
