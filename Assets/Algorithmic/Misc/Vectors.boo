
struct WorldBlockCoordinate:
	x as long
	z as long
	y as long
	hash as int
	
	def constructor(_x as long, _y as long, _z as long):
		x = _x
		y = _y
		z = _z
		hash = (x * 397) ^ (y * 647) ^ z

	override def GetHashCode() as int:
		return hash

	override def Equals(o) as bool:
		v = o cast WorldBlockCoordinate
		return v.x == x and v.y == y and v.z == z

	override def ToString() as string:
		return "($x, $y, $z)"


struct ByteVector3:
	x as byte
	y as byte	
	z as byte

	def constructor(x as byte, y as byte, z as byte):
		self.x = x
		self.y = y
		self.z = z		

	def ToString():
		return "($x, $y, $z)"
