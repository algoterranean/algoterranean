
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
			a = particle.getAcceleration()
			a.y = 0
			particle.setAcceleration(a)
			particle.setVelocity(particle.getVelocity() + Vector3(0, 30, 0))

			_jumped = true

class MoveLeft(IForceGenerator):
	def updateForce(particle as IParticle, duration as single):
		v = particle.getVelocity()
		a = particle.getAcceleration()
		v.x = -5
		a.x = 0
		particle.setAcceleration(a)
		particle.setVelocity(v)

class MoveRight(IForceGenerator):
	def updateForce(particle as IParticle, duration as single):
		v = particle.getVelocity()
		a = particle.getAcceleration()
		v.x = 5
		a.x = 0
		particle.setAcceleration(a)
		particle.setVelocity(v)

class MoveForward(IForceGenerator):
	def updateForce(particle as IParticle, duration as single):
		v = particle.getVelocity()
		a = particle.getAcceleration()
		v.z = 5
		a.z = 0
		particle.setAcceleration(a)
		particle.setVelocity(v)

class MoveBackwards(IForceGenerator):
	def updateForce(particle as IParticle, duration as single):
		v = particle.getVelocity()
		a = particle.getAcceleration()
		v.z = -5
		a.z = 0
		particle.setAcceleration(a)
		particle.setVelocity(v)		

class StopMovingSideways(IForceGenerator):
	def updateForce(particle as IParticle, duration as single):
		v = particle.getVelocity()
		v.x = 0
		particle.setVelocity(v)

class StopMovingToAndFro(IForceGenerator):
	def updateForce(particle as IParticle, duration as single):
		v = particle.getVelocity()
		v.z = 0
		particle.setVelocity(v)
		



