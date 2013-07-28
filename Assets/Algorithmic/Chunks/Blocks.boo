namespace Algorithmic.Chunks
import UnityEngine
import System.IO
import System

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


static class Blocks:
	public static block_def as (Block)
	
	def constructor():
		# open up the blocks data file that defines all the block info
		path = "$(Application.dataPath)/Algorithmic/Resources/blocks.dat"
		block_def = array(Block, 256)

		# read each line and use it to populate a Block object
		using input = StreamReader(path):
			for line in input:
				line = line.Trim()
				if len(line) > 0 and line[0] != char('#'): # # is a comment
					properties = line.Split(','[0])
					
					name = properties[0].Trim()
					id as byte = Convert.ToByte(properties[1].Trim())
					uv_x as single = Convert.ToSingle(properties[2].Trim())
					uv_y as single = Convert.ToSingle(properties[3].Trim())
					r as byte = Convert.ToByte(properties[4].Trim())
					g as byte = Convert.ToByte(properties[5].Trim())
					b as byte = Convert.ToByte(properties[6].Trim())
					
					block_def[id] = Block(id, uv_x, uv_y, Color(r/255.0, g/255.0, b/255.0, 0))

					


	




