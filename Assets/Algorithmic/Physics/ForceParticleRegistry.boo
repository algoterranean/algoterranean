import Algorithmic.Misc

struct Registration:
	particle as IParticle
	force as IForceGenerator
	active as bool

	def constructor(p as IParticle, f as IForceGenerator):
		particle = p
		force = f
		active = true
		
	
class ForceParticleRegistry:
	_registry as List[of Registration]

	def constructor():
		_registry = List[of Registration]()

	def add (particle as IParticle, force as IForceGenerator):
		Log.Log("Adding particle to registry")
		add_new = true
		for reg in _registry:
			if reg.particle == particle and reg.force == force:
				add_new = false
				reg.active = true

		if add_new:
			_registry.Push(Registration(particle, force))

	def remove (particle as IParticle, force as IForceGenerator):
		Log.Log("Removing particle from registry")
		for reg in _registry:
			if reg.particle == particle and reg.force == force:
				reg.active = false

	def clear ():
		Log.Log("Clearing registry")
		_registry = List[of Registration]()

	def updateForces(duration as single):
		for reg in _registry:
			if reg.active:
				reg.force.updateForce(reg.particle, duration)
	
