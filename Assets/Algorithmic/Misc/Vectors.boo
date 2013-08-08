import System.Math

struct WorldBlockCoordinate (IComparable):
	x as long
	z as long
	y as long
	hash as int
	
	def constructor(_x as long, _y as long, _z as long):
		x = _x
		y = _y
		z = _z
		hash = (x * 907) ^ (y * 241) ^ z

	override def GetHashCode() as int:
		return hash

	override def Equals(o) as bool:
		v = o cast WorldBlockCoordinate
		return v.x == x and v.y == y and v.z == z

	override def ToString() as string:
		return "($x, $y, $z)"

	def CompareTo(o as object) as int:
		c = o cast WorldBlockCoordinate
		a = Abs(x) + Abs(y) + Abs(z)
		b = Abs(c.x) + Abs(c.y) + Abs(c.z)
		if a < b:
			return -1
		elif a > b:
			return 1
		else:
			return 0

	def UpdateHash():
		hash = (x * 907) ^ (y * 241) ^ z
		

struct ChunkBlockCoordinate(IComparable):
	x as byte
	y as byte
	z as byte
	hash as int

	def constructor(_x as byte, _y as byte, _z as byte):
		x = _x
		y = _y
		z = _z
		hash = (x * 397) ^ (y * 647) ^ z

	override def GetHashCode() as int:
		return hash

	override def Equals(o) as bool:
		v = o cast ChunkBlockCoordinate
		return v.x == x and v.y == y and v.z == z

	override def ToString() as string:
		return "($x, $y, $z)"

	def CompareTo(o as object) as int:
		c = o cast ChunkBlockCoordinate
		a = Abs(x cast int) + Abs(y cast int) + Abs(z cast int)
		b = Abs(c.x cast int) + Abs(c.y cast int) + Abs(c.z cast int)
		if a < b:
			return -1
		elif a > b:
			return 1
		else:
			return 0




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



struct ChunkCoordinate:
	x as long
	z as long
	y as long
	hash as int
	
	def constructor(_x as long, _y as long, _z as long):
		x = _x
		y = _y
		z = _z
		hash = (x * 907) ^ (y * 241) ^ z

	override def GetHashCode() as int:
		return hash

	override def Equals(o) as bool:
		v = o cast ChunkCoordinate
		return v.x == x and v.y == y and v.z == z

	override def ToString() as string:
		return "($x, $y, $z)"

	def CompareTo(o as object) as int:
		c = o cast ChunkCoordinate
		a = Abs(x) + Abs(y) + Abs(z)
		b = Abs(c.x) + Abs(c.y) + Abs(c.z)
		if a < b:
			return -1
		elif a > b:
			return 1
		else:
			return 0

	def UpdateHash():
		hash = (x * 907) ^ (y * 241) ^ z	
