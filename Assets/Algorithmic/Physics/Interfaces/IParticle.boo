
interface IParticle:
	Position as Vector3:
		get
		set
	Velocity as Vector3:
		get
		set
	Acceleration as Vector3:
		get
		set
	Mass as single:
		get
		set
	InverseMass as single:
		get
		set
	Damping as single:
		get
		set
	
	# def getPosition() as Vector3
	# def getVelocity() as Vector3
	# def getAcceleration() as Vector3
	# def getMass() as single
	# def getInverseMass() as single
	# def setPosition(p as Vector3)
	# def setVelocity(v as Vector3)
	# def setAcceleration(a as Vector3)
		
	def addForce(force as Vector3)
		
	
