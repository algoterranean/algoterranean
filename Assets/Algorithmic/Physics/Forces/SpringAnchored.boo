

class SpringAnchored (IForceGenerator):
	_anchor as Vector3
	_spring_constant as single
	_rest_length as single

	def constructor(anchor as Vector3, springConstant as single, restLength as single):
		_anchor = anchor
		_spring_constant = springConstant
		_rest_length = restLength

	def updateForce(particle as IParticle, duration as single):
		force = particle.getPosition()
		force -= _anchor
		magnitude = (_rest_length - force.magnitude) * _spring_constant
		f_n = force.normalized
		f_n *= magnitude
		particle.addForce(f_n)
