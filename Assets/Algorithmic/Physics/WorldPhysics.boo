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
		_resolver = ParticleContactResolver(50)
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
		#_player_aabb = _player.getAABB()

		t = gameObject.Find("Player").transform
		_player_aabb = AABB(t.position, Vector3(0.5, 0.5, 0.5))
		
		x = gameObject.Find("Player").GetComponent("Player") as Player
		chunk_manager = gameObject.Find("ChunkManager").GetComponent("ChunkManager") as ChunkManager
		chunk_ball = chunk_manager.getChunkBall()
		l = chunk_ball.CheckCollisions(_player_aabb)
		
		
		if len(l) > 0:
			contacts = List[of ParticleContact]()
			p = gameObject.Find("Player").GetComponent("Particle") as Algorithmic.Particle

			for x as duck in l:
				distance = x[0]
				block_pos = x[1]

				c = ParticleContact(p, null, 0.0, Vector3(0, 1, 0), distance.y)
				#print "Check: $(distance.y), $(c.getPenetration())"
				contacts.Push(c)
			print "COLLISIONS: $contacts"
			#_running = false
			_resolver.resolveContacts(contacts, Time.deltaTime)
			
			# for x as Algorithmic.Particle in _particles:
			# 	x.integrate(Time.deltaTime)

			
			# if _running:
			# 	_running = false
			# 	_registry.updateForces(Time.deltaTime)
			# 	for x as Algorithmic.Particle in _particles:
			# 		x.integrate(Time.deltaTime)

			
	def Update():
		p = gameObject.Find("Player").GetComponent("Particle") as Algorithmic.Particle
		if Input.GetKeyDown("return"):
			_running = not _running
		if Input.GetKeyDown("space"):
			_registry.add(p, Jump())
			
		if Input.GetKey("left") and not Input.GetKey("left shift"):
			_registry.add(p, MoveLeft())
		if Input.GetKey("right"):
			_registry.add(p, MoveRight())
		if Input.GetKey("up"):
			_registry.add(p, MoveForward())
		if Input.GetKey("down"):
			_registry.add(p, MoveBackwards())

		if not Input.GetKey("right") and not Input.GetKey("left"):
			_registry.add(p, StopMovingSideways())
		if not Input.GetKey("up") and not Input.GetKey("down"):
			_registry.add(p, StopMovingToAndFro())			





