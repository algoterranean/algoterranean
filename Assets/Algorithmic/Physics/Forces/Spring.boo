import System.Math

class Spring (IForceGenerator):
	_spring_constant as single
	_rest_length as single	
	_other as IParticle

	def constructor(other as IParticle, springConstant as single, restLength as single):
		_other = other
		_spring_constant = springConstant
		_rest_length = restLength

	def updateForce(particle as IParticle, duration as single):
		force = particle.getPosition()
		force -= _other.getPosition()
		magnitude = Math.Abs(force.magnitude - _rest_length)
		magnitude *= _spring_constant
		f_n = force.normalized
		f_n *= -magnitude
		particle.addForce(f_n)
