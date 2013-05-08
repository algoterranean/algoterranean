
struct LongVector3:
	x as long
	z as long
	y as long
	hash as int
	
	def constructor(x as long, y as long, z as long):
		self.x = x
		self.y = y
		self.z = z
		hash = (x * 397) ^ (y * 647) ^ z

	override def GetHashCode() as int:
		return hash

	# override def Equals(o) as bool:
	# 	return o.x == x and o.y == y and o.z == z


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
