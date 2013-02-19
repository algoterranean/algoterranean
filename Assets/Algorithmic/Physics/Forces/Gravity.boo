
class Gravity (IForceGenerator):
	_g as Vector3
	def constructor():
		_g = Vector3(0, -9.8, 0)
        
	def updateForce(particle as IParticle, duration as single):
		particle.addForce(_g * particle.Mass)

		

class Jump(IForceGenerator):
	_jumped = false
	
	def updateForce(particle as IParticle, duration as single):
		if not _jumped:
			#particle.setVelocity(Vector3(0, 0, 0))
			a = particle.Acceleration
			a.y = 0
			particle.Acceleration = a
			particle.Velocity = particle.Velocity + Vector3(0, 30, 0)

			_jumped = true



class MoveLeft(IForceGenerator):
	def updateForce(particle as IParticle, duration as single):
		v = particle.Velocity
		a = particle.Acceleration
		v.x = -5
		a.x = 0
		particle.Acceleration = a
		particle.Velocity = v

class MoveRight(IForceGenerator):
	def updateForce(particle as IParticle, duration as single):
		v = particle.Velocity
		a = particle.Acceleration
		v.x = 5
		a.x = 0
		particle.Acceleration = a
		particle.Velocity = v

class MoveForward(IForceGenerator):
	def updateForce(particle as IParticle, duration as single):
		v = particle.Velocity
		a = particle.Acceleration
		v.z = 5
		a.z = 0
		particle.Acceleration = a
		particle.Velocity = v

class MoveBackwards(IForceGenerator):
	def updateForce(particle as IParticle, duration as single):
		v = particle.Velocity
		a = particle.Acceleration
		v.z = -5
		a.z = 0
		particle.Acceleration = a
		particle.Velocity = v

class StopMovingSideways(IForceGenerator):
	def updateForce(particle as IParticle, duration as single):
		v = particle.Velocity
		v.x = 0
		particle.Velocity = v

class StopMovingToAndFro(IForceGenerator):
	def updateForce(particle as IParticle, duration as single):
		v = particle.Velocity
		v.z = 0
		particle.Velocity = v
		



