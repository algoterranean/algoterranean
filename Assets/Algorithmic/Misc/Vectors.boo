
struct LongVector3:
	x as long
	z as long
	y as long
	def constructor(x as long, y as long, z as long):
		self.x = x
		self.z = z
		self.y = y

	def ToString():
		return "$x, $y, $z"

struct ByteVector3:
	x as byte
	z as byte
	y as byte
	def constructor(x as byte, y as byte, z as byte):
		self.x = x
		self.z = z
		self.y = y

	def ToString():
		return "$x, $y, $z"
