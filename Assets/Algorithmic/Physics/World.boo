import UnityEngine
import Algorithmic


class World (MonoBehaviour):
	_registry as ForceParticleRegistry
	_resolver as ParticleContactResolver
	

	def Start ():
		_registry = ForceParticleRegistry()
		_resolver = ParticleContactResolver(50)
		p = gameObject.Find("Person").GetComponent("Particle") as Algorithmic.Particle
		_registry.add(p, Gravity())
		p = gameObject.Find("Ground").GetComponent("Particle") as Algorithmic.Particle
		_registry.add(p, Gravity())
	
	def FixedUpdate():
		_registry.updateForces(Time.deltaTime)
		p1 = gameObject.Find("Person").GetComponent("Particle") as Algorithmic.Particle
		p2 = gameObject.Find("Ground").GetComponent("Particle") as Algorithmic.Particle

		t = gameObject.Find("Person").GetComponent("Transform") as Transform
		if t.position.y <= -37:
			c = ParticleContact(p1, p2, 0.6, Vector3(0, 1, 0), Math.Abs(t.position.y + 40))
			l = List[of ParticleContact]()
			l.Push(c)
			_resolver.resolveContacts(l, Time.deltaTime)
			
		
