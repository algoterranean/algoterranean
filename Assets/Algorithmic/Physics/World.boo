"""World keeps track of all particles and updates them according to collisions."""
namespace Algorithmic

import UnityEngine
import Algorithmic

class World (MonoBehaviour):
	_registry as ForceParticleRegistry
	_resolver as ParticleContactResolver
	_particles = []

	def Start ():
		_particles = []
		_registry = ForceParticleRegistry()
		_resolver = ParticleContactResolver(50)
		p = gameObject.Find("Person").GetComponent("Particle") as Algorithmic.Particle
		_registry.add(p, Gravity())
		_particles.Push(p)		
		p = gameObject.Find("Ground").GetComponent("Particle") as Algorithmic.Particle
		_registry.add(p, Gravity())
		_particles.Push(p)
		
	def FixedUpdate():
		_registry.updateForces(Time.deltaTime)
		for x as Algorithmic.Particle in _particles:
			x.integrate(Time.deltaTime)

		p1 = gameObject.Find("Person").GetComponent("Particle") as Algorithmic.Particle
		p2 = gameObject.Find("Ground").GetComponent("Particle") as Algorithmic.Particle

		t = gameObject.Find("Person").GetComponent("Transform") as Transform
		if t.position.y <= -37:
			c = ParticleContact(p1, null, 0.5, Vector3(0, 1, 0), -1 * (37 + t.position.y))
			l = List[of ParticleContact]()
			l.Push(c)
			_resolver.resolveContacts(l, Time.deltaTime)
			
	def Update():
		if Input.GetKeyDown("space"):
			p = gameObject.Find("Person").GetComponent("Particle") as Algorithmic.Particle
			_registry.add(p, Jump())



