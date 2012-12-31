
class Gravity (IForceGenerator):
	_g as Vector3
	def constructor():
		_g = Vector3(0, -9.8, 0)
        
	def updateForce(particle as IParticle, duration as single):
		particle.addForce(_g)



