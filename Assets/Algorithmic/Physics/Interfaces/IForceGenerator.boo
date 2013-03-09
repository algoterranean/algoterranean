enum FORCE_TYPE:
	GRAVITY
	GROUND_REACTION

interface IForceGenerator:
	def updateForce(particle as IParticle, duration as single)
	def getType() as FORCE_TYPE
	def getForce() as Vector3
	
		
