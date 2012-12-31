
struct Registration:
	particle as IParticle
	force as IForceGenerator

	def constructor(p as IParticle, f as IForceGenerator):
		particle = p
		force = f
		
	
class ForceParticleRegistry:
	_registry as List[of Registration]

	def constructor():
		_registry = List[of Registration]()

	def add (particle as IParticle, force as IForceGenerator):
		_registry.Push(Registration(particle, force))

	def remove (particle as IParticle, force as IForceGenerator):
		pass

	def clear ():
		pass

	def updateForces(duration as single):
		for reg in _registry:
			reg.force.updateForce(reg.particle, duration)
	
