"""World keeps track of all particles and updates them according to collisions."""
namespace Algorithmic

import UnityEngine
import Algorithmic
import Algorithmic.Player
import Algorithmic.Terrain


class WorldPhysics (MonoBehaviour):
	_registry as ForceParticleRegistry
	_resolver as ParticleContactResolver
	_particles = []
	_running = false

	def Start ():
		_particles = []
		_registry = ForceParticleRegistry()
		_resolver = ParticleContactResolver(10)
		p = gameObject.Find("Player").GetComponent("Particle") as Algorithmic.Particle
		_registry.add(p, Gravity())
		_particles.Push(p)
		
		# p = gameObject.Find("Person2").GetComponent("Particle") as Algorithmic.Particle
		# _registry.add(p, Gravity())
		# _particles.Push(p)		
		# p = gameObject.Find("Ground").GetComponent("Particle") as Algorithmic.Particle
		# _registry.add(p, Gravity())
		# _particles.Push(p)
		
	def FixedUpdate():
		if not _running:
			return
		
		_registry.updateForces(Time.deltaTime)
		for x as Algorithmic.Particle in _particles:
			x.integrate(Time.deltaTime)

		_player = gameObject.Find("Player").GetComponent("Player") as Player
		_player_aabb = _player.getAABB()
		x = gameObject.Find("Player").GetComponent("Player") as Player
		chunk_manager = gameObject.Find("ChunkManager").GetComponent("ChunkManager") as ChunkManager
		chunk_ball = chunk_manager.getChunkBall()
		l = chunk_ball.CheckCollisions(_player_aabb)
		if l:
			print "COLLISIONS: $l"
			contacts = List[of ParticleContact]()
			p = gameObject.Find("Player").GetComponent("Particle") as Algorithmic.Particle
			for collision as Vector3 in l:
				c = ParticleContact(p, null, 0.0, Vector3(0, 1, 0), 1.0 - collision.y)
				contacts.Push(c)
			_resolver.resolveContacts(contacts, Time.deltaTime)
			
	def Update():
		p = gameObject.Find("Player").GetComponent("Particle") as Algorithmic.Particle		
		if Input.GetKeyDown("return"):
			_running = not _running
		if Input.GetKeyDown("space"):
			_registry.add(p, Jump())
			
		if Input.GetKey("left"):
			_registry.add(p, MoveLeft())
		if Input.GetKey("right"):
			_registry.add(p, MoveRight())
		if Input.GetKey("up"):
			pass
		if Input.GetKey("down"):
			pass

		if not Input.GetKey("right") and not Input.GetKey("left"):
			_registry.add(p, StopMoving())





