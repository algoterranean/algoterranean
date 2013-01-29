
class Drag (IForceGenerator):
	k1 as single
	k2 as single
	
	def constructor(_k1 as single, _k2 as single):
		k1 = _k1
		k2 = _k2
		
	def updateForce(particle as IParticle, duration as single):
		force as Vector3 = particle.getVelocity()
		dragCoeff = force.magnitude
		dragCoeff = k1 * dragCoeff + k2 * dragCoeff * dragCoeff
		f_n = force.normalized
		f_n *= -dragCoeff
		particle.addForce(f_n)
