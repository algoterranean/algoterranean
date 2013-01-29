
class SpringBungee (IForceGenerator):
	_other as IParticle
	_spring_constant as single
	_rest_length as single

	def constructor(other as IParticle, springConstant as single, restLength as single):
		_other = other
		_spring_constant = springConstant
		_rest_length = restLength

	def updateForce(particle as IParticle, duration as single):
		force = particle.getPosition()
		force -= _other.getPosition()
		if (force.magnitude <= _rest_length):
			return
		magnitude = _spring_constant * (_rest_length - force.magnitude)
		f_n = force.normalized
		f_n *= -magnitude
		particle.addForce(f_n)
