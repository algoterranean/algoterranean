
import System.Collections.Generic

class ChunkBall ():
	chunks as Dictionary[of double, Chunk]
	
	def constructor():
		chunks = Dictionary[of double, Chunk]()

	def calculateDistance(x_pos as double, z_pos as double, y_pos as double):
		for chunk in chunks:
			chunk.Value.setDistance(x_pos, z_pos, y_pos)

	def Contains(x_pos as double, z_pos as double, y_pos as double):
		
		return chunks.ContainsKey(x_pos + z_pos*x_pos + x_pos*z_pos*y_pos) #"$x_pos, $z_pos, $y_pos")

	def Set(x_pos as long, z_pos as long, y_pos as long, chunk as Chunk):
		chunks.Add(x_pos + x_pos*z_pos + x_pos*z_pos*y_pos, chunk)
		#chunks.Add("$x_pos, $z_pos, $y_pos", chunk)

	def updateNeighbors():
		for dict_item in chunks:
			chunk = dict_item.Value
			key = dict_item.Key
			coords = chunk.getCoordinates()
			x = coords[0]
			z = coords[1]
			y = coords[2]
			
			# west_name = (x-Settings.ChunkSize, z, y) #"$(x - Settings.ChunkSize), $z, $y"
			# east_name = (x+Settings.ChunkSize, z, y) #"$(x + Settings.ChunkSize), $z, $y"
			# south_name = (x, z-Settings.ChunkSize, y) #"$x, $(z - Settings.ChunkSize), $y"
			# north_name = (x, z+Settings.ChunkSize, y) #"$x, $(z + Settings.ChunkSize), $y"
			# down_name = (x, z, y-Settings.ChunkSize) #"$x, $z, $(y - Settings.ChunkSize)"
			# up_name = (x, z, y+Settings.ChunkSize) #"$x, $z, $(y + Settings.ChunkSize)"
			
			# west_name = "$(x - Settings.ChunkSize), $z, $y"
			# east_name = "$(x + Settings.ChunkSize), $z, $y"
			# south_name = "$x, $(z - Settings.ChunkSize), $y"
			# north_name = "$x, $(z + Settings.ChunkSize), $y"
			# down_name = "$x, $z, $(y - Settings.ChunkSize)"
			# up_name = "$x, $z, $(y + Settings.ChunkSize)"

			west_name = (x - Settings.ChunkSize) + (x - Settings.ChunkSize) * z + (x - Settings.ChunkSize) * z * y
			east_name = (x + Settings.ChunkSize) + (x + Settings.ChunkSize) * z + (x + Settings.ChunkSize) * z * y
			south_name = x + (z - Settings.ChunkSize) * x + (z - Settings.ChunkSize) * x * y
			north_name = x + (z + Settings.ChunkSize) * x + (z + Settings.ChunkSize) * x * y
			down_name = x + x*z + x*z*(y - Settings.ChunkSize)
			up_name = x + x*z + x*z*(y + Settings.ChunkSize)
			
			if chunks.ContainsKey(west_name):
				chunk.setWestChunk(chunks[west_name])
			if chunks.ContainsKey(east_name):
				chunk.setEastChunk(chunks[east_name])
			if chunks.ContainsKey(south_name):
				chunk.setSouthChunk(chunks[south_name])
			if chunks.ContainsKey(north_name):
				chunk.setNorthChunk(chunks[north_name])
			if chunks.ContainsKey(down_name):
				chunk.setDownChunk(chunks[down_name])
			if chunks.ContainsKey(up_name):
				chunk.setUpChunk(chunks[up_name])
							
			
