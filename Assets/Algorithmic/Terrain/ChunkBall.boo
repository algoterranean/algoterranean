
import System.Collections.Generic

class ChunkBall ():
	chunks as Dictionary[of double, Chunk]
	
	def constructor():
		chunks = Dictionary[of double, Chunk]()

	def GetEnumerator():
		return chunks.GetEnumerator()

	def calculateDistance(x_pos as double, z_pos as double, y_pos as double):
		for chunk in chunks:
			chunk.Value.setDistance(x_pos, z_pos, y_pos)

	def Contains(x_pos as long, z_pos as long, y_pos as long):
		return chunks.ContainsKey(x_pos + Settings.ChunkSize*z_pos + Settings.ChunkSize*Settings.ChunkSize*y_pos)

	def Set(x_pos as long, z_pos as long, y_pos as long, chunk as Chunk):
		chunks.Add(x_pos + Settings.ChunkSize*z_pos + Settings.ChunkSize*Settings.ChunkSize*y_pos, chunk)
		#updateNeighbors(x_pos, z_pos, y_pos)
		#chunks.Add("$x_pos, $z_pos, $y_pos", chunk)

	def cullChunks():
		to_remove = []
		to_remove2 = []
		for d in chunks:
			chunk = d.Value
			key = d.Key
			if chunk.getDistance() > Settings.MinChunkDistance:
				to_remove.Push(d.Key)
				to_remove2.Push(d.Value)

		for key in to_remove:
			chunks.Remove(key)
		return to_remove2
		


	def updateNeighbors(): #:x_pos as long, z_pos as long, y_pos as long):
		for d in chunks:
			chunk = d.Value
			key = d.Key
			coords = chunk.getCoordinates()
			x = coords[0]
			z = coords[1]
			y = coords[2]
		
			# chunk = chunks[x_pos + z_pos * x_pos + z_pos * x_pos * y_pos]
			# x = x_pos
			# z = z_pos
			# y = y_pos
			
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

			west_name = (x - Settings.ChunkSize) + Settings.ChunkSize * z + Settings.ChunkSize * Settings.ChunkSize * y
			east_name = (x + Settings.ChunkSize) + Settings.ChunkSize * z + Settings.ChunkSize * Settings.ChunkSize * y
			south_name = x + (z - Settings.ChunkSize) * Settings.ChunkSize + Settings.ChunkSize * Settings.ChunkSize * y
			north_name = x + (z + Settings.ChunkSize) * Settings.ChunkSize + Settings.ChunkSize * Settings.ChunkSize * y
			down_name = x + Settings.ChunkSize * z + Settings.ChunkSize * Settings.ChunkSize * (y - Settings.ChunkSize)
			up_name = x + Settings.ChunkSize * z + Settings.ChunkSize * Settings.ChunkSize * (y + Settings.ChunkSize)

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
							
			
