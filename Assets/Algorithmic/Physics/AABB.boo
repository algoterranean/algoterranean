namespace Algorithmic.Physics


struct AABBSize:
	x as single
	y as single
	z as single
	def constructor(x as single, y as single, z as single):
		self.x = x
		self.y = y
		self.z = z

struct AABB:
	center as Vector3
	radius as Vector3
	min as AABBSize
	max as AABBSize
	
	def constructor(_center as Vector3, _radius as Vector3):
		center = _center
		radius = _radius
		min.x = center.x - radius.x
		min.y = center.y - radius.y
		min.z = center.z - radius.z
		max.x = center.x + radius.x
		max.y = center.y + radius.y
		max.z = center.z + radius.z
		
		
	def Test(a as AABB, b as AABB) as bool:
		if Math.Abs(a.center.y - b.center.y) > (a.radius.y + b.radius.y):
			return false
		if Math.Abs(a.center.x - b.center.x) > (a.radius.x + b.radius.x):
			return false
		if Math.Abs(a.center.z - b.center.z) > (a.radius.z + b.radius.z):
			return false
		return true

	def getCollision(a as AABB, b as AABB) as Vector3:
		y_component = 0.0
		x_component = 0.0
		z_component = 0.0

		if Math.Abs(a.center.y - b.center.y) <= (a.radius.y + b.radius.y):
			y_component = (b.center.y + b.radius.y) - (a.center.y - a.radius.y)
			#y_component = a.center.y - b.center.y #- (a.radius.y + b.radius.y)
		if Math.Abs(a.center.x - b.center.x) <= (a.radius.x + b.radius.x):
			x_component = Math.Abs(a.center.x - b.center.x)
		if Math.Abs(a.center.z - b.center.z) <= (a.radius.z + b.radius.z):
			z_component = Math.Abs(a.center.z - b.center.z)
			
		return Vector3(x_component, y_component, z_component)
	
	def ToString():
		return "(Center: ($(center.x), $(center.y), $(center.z)), Radius: ($(radius.x), $(radius.y), $(radius.z)))"

	
