namespace Algorithmic

class ChunkInfo():
	chunk_object as Chunk
	x_coord as long
	z_coord as long
	y_coord as long
	distance as double = 0.0

	def constructor(chunk_object as Chunk):
		self.chunk_object = chunk_object
		coords = chunk_object.getCoordinates()
		self.x_coord = coords[0]
		self.z_coord = coords[1]
		self.y_coord = coords[2]

	def getDistance() as double:
		return distance

	def getCoords() as (long):
		return (x_coord, z_coord, y_coord)

	def calculateDistance(x as long, z as long, y as long) as double:
		a = self.x_coord - x
		b = self.z_coord - z
		c = self.y_coord - y
		distance = Math.Sqrt(a*a + b*b + c*c)
		return distance

	def getChunk() as Chunk:
		return chunk_object

		
