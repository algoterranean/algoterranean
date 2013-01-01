
interface IParticle:
	def getPosition() as Vector3
	def getVelocity() as Vector3
	def getAcceleration() as Vector3
	def getMass() as single
	def getInverseMass() as single
	def setPosition(p as Vector3)
	def setVelocity(v as Vector3)
	def setAcceleration(a as Vector3)
		
	def addForce(force as Vector3)
		
	
