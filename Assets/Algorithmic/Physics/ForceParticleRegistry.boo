import Algorithmic.Misc

class Registration:
	public particle as IParticle
	public force as IForceGenerator
	public active as bool

	def constructor(p as IParticle, f as IForceGenerator):
		particle = p
		force = f
		active = true
		
	
class ForceParticleRegistry:
	_registry as List[of Registration]

	def constructor():
		_registry = List[of Registration]()

	def add (particle as IParticle, force as IForceGenerator):
		add_new = true
		for reg in _registry:
			if reg.particle == particle and reg.force == force:
				Log.Log("Re-enabling particle/force to registry, $force", LOG_MODULE.PHYSICS)
				add_new = false
				reg.active = true

		if add_new:
			Log.Log("Adding particle/force to registry, $force", LOG_MODULE.PHYSICS)
			_registry.Push(Registration(particle, force))

	def remove (particle as IParticle, force as IForceGenerator):
		for reg in _registry:
			if reg.particle == particle and reg.force == force:
				Log.Log("Disabling particle/force from registry: $force", LOG_MODULE.PHYSICS)
				reg.active = false

	def clear ():
		Log.Log("Clearing registry", LOG_MODULE.PHYSICS)
		_registry = List[of Registration]()

	def updateForces(duration as single):
		for reg in _registry:
			if reg.active:
				Log.Log("Update Forces: Force: $(reg.force), Particle: $(reg.particle), Duration: $(duration)", LOG_MODULE.PHYSICS)
				reg.force.updateForce(reg.particle, duration)

	def getForces(particle as IParticle) as List[of IForceGenerator]:
		b = List[of IForceGenerator]()
		for reg in _registry:
			if reg.particle == particle and reg.active:
				b.Add(reg.force)
		return b
	
