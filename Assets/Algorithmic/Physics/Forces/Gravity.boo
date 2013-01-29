
class Gravity (IForceGenerator):
	_g as Vector3
	def constructor():
		_g = Vector3(0, -9.8, 0)
        
	def updateForce(particle as IParticle, duration as single):
		particle.addForce(_g * particle.getMass())

class Jump(IForceGenerator):
	_jumped = false
	
	def updateForce(particle as IParticle, duration as single):
		if not _jumped:
			#particle.setVelocity(Vector3(0, 0, 0))
			particle.setVelocity(Vector3(0, 60, 0))
			#particle.setVelocity(particle.getVelocity() + Vector3(0, 40, 0))
			_jumped = true



