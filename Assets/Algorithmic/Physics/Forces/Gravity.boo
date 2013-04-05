
class Gravity (IForceGenerator):
	_g as Vector3
	_terminal_velocity as Vector3
	
	def constructor():
		_g = Vector3(0, -9.8, 0)
		_g = Vector3(0, -20, 0)
		_terminal_velocity = Vector3(0, -250, 0)
        
	def updateForce(particle as IParticle, duration as single):
		particle.addForce(_g * particle.Mass)

	def getType() as FORCE_TYPE:
		return FORCE_TYPE.GRAVITY

	def getForce():
		return _g

	def ToString():
		return "GRAVITY $_g"


	

class Ground (IForceGenerator):
	force as Vector3
	def constructor(f as Vector3):
		force = f
	def updateForce(particle as IParticle, duration as single):
		particle.addForce(force * particle.Mass)
	def ToString():
		return "GROUND $force"
	def getForce():
		return force
	def getType():
		return FORCE_TYPE.GROUND_REACTION



# class Ground (IForceGenerator):
# 	_g as Vector3
# 	def constructor():
# 		_g = Vector3(0, 9.8, 0)
        
# 	def updateForce(particle as IParticle, duration as single):
# 		particle.addForce(_g * particle.Mass)

# 	def getType() as FORCE_TYPE:
# 		return FORCE_TYPE.GROUND_REACTION

# 	def ToString():
# 		return "GROUND $_g"

# 	def getForce():
# 		return _g

		

class Jump(IForceGenerator):
	_jumped = false
	
	def updateForce(particle as IParticle, duration as single):
		if not _jumped:
			#particle.setVelocity(Vector3(0, 0, 0))
			#a = particle.Acceleration
			#a.y = 0
			#particle.Acceleration = a
			#particle.Acceleration = Vector3(0, 0, 0)
			particle.Velocity = Vector3(0, 30, 0)
			_jumped = true

	def ToString():
		return "JUMP"

	def getForce():
		return Vector3(0, 0, 0)
	


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
		



