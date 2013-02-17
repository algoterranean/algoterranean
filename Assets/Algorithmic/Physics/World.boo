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
		p = gameObject.Find("Person2").GetComponent("Particle") as Algorithmic.Particle
		_registry.add(p, Gravity())
		_particles.Push(p)		
		p = gameObject.Find("Ground").GetComponent("Particle") as Algorithmic.Particle
		_registry.add(p, Gravity())
		_particles.Push(p)
		
	def FixedUpdate():
		_registry.updateForces(Time.deltaTime)		
		for x as Algorithmic.Particle in _particles:
			x.integrate(Time.deltaTime)

		# force a collision all hackish-like
		p1 = gameObject.Find("Person2").GetComponent("Particle") as Algorithmic.Particle
		p2 = gameObject.Find("Ground").GetComponent("Particle") as Algorithmic.Particle

		t = gameObject.Find("Person2").GetComponent("Transform") as Transform
		l = List[of ParticleContact]()
		
		if t.position.y <= -37:
			c = ParticleContact(p1, null, 0.0, Vector3(0, 1, 0), -1 * (37 + t.position.y))
			l.Push(c)
		if t.position.x <= - 39:
			c = ParticleContact(p1, null, 0.0, Vector3(1, 0, 0), -1 * (39 + t.position.x))
			l.Push(c)

		_resolver.resolveContacts(l, Time.deltaTime)
		
			
	def Update():
		p = gameObject.Find("Person2").GetComponent("Particle") as Algorithmic.Particle		
		if Input.GetKeyDown("space"):
			_registry.add(p, Jump())
		if Input.GetKey("left"):
			_registry.add(p, MoveLeft())
		if Input.GetKey("right"):
			_registry.add(p, MoveRight())

		if not Input.GetKey("right") and not Input.GetKey("left"):
			_registry.add(p, StopMovingSideways())



