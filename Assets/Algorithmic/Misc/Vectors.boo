
struct LongVector3:
	x as long
	z as long
	y as long
	s as string
	def constructor(x as long, y as long, z as long):
		self.x = x
		self.y = y
		self.z = z
		s = "($x, $y, $z)"

	def ToString():
		return s

	override def GetHashCode() as int:
		return s.GetHashCode()
	

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
