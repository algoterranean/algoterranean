"""World keeps track of all particles and updates them according to collisions."""
namespace Algorithmic

import UnityEngine
import Algorithmic
import Algorithmic.Player
import Algorithmic.Terrain
import Algorithmic.Misc


class World (MonoBehaviour):
	_registry as ForceParticleRegistry
	_resolver as ParticleContactResolver
	_particles = []
	_running = false
	force_gravity = Gravity()
	force_ground = Ground()

	def Start ():
		_particles = []
		_registry = ForceParticleRegistry()
		_resolver = ParticleContactResolver(50)
		p = gameObject.Find("Player").GetComponent("Particle") as Algorithmic.Particle
		_registry.add(p, force_gravity)
		_particles.Push(p)
		
	def FixedUpdate():
		if not _running:
			return
		Log.Log("Starting World Tick")
		
		# generate all possible collisions
		chunk_manager = gameObject.Find("ChunkManager").GetComponent("ChunkManager") as ChunkManager
		chunk_ball = chunk_manager.getChunkBall()
		_particle = gameObject.Find("Player").GetComponent("Particle") as Algorithmic.Particle

		#_player_aabb = AABB(_particle.Position, Vector3(0.5, 0.5, 0.5))
		_player_aabb_previous = AABB(_particle.Position, Vector3(0.5, 0.5, 0.5))
		_player_aabb = AABB(_particle.Position + _particle.Velocity * Time.deltaTime, Vector3(0.5, 0.5, 0.5))


		Log.Log("Pos Now: $_player_aabb_previous")
		Log.Log("Player Pos In Future: $_player_aabb")
		possible_collisions = chunk_ball.CheckCollisionsSweep(_player_aabb, _player_aabb_previous)
		earliest_contact = []

		for x as duck in possible_collisions:
			if x[1][2]:
				Log.Log("Definite Future Collision: $x")
				if earliest_contact == []:
					earliest_contact = x
				else:
					e_tmp as duck = earliest_contact[1]
					if x[1][0] < e_tmp[0]:
						earliest_contact = x

		fixed_time = Time.deltaTime
		if earliest_contact != []:
			e as duck = earliest_contact[1]
			Log.Log("Earliest Contact: $earliest_contact, $(e[0])")
			fixed_time *= e[0]
			

		# 	c_info as duck = x[1]
		# 	if x[1]
		# 		if earliest_contact == []:
		# 			earliest_contact = x
					
		# 		# elif earliest_contact[1][0]: #> x[1][0]:
		# 		# 	earliest_contact = x

		# Log.Log("First Contact: $earliest_contact")
		
		#Log.Log("Possible Collisions after Sweep: $possible_collisions")
		
		

		_registry.updateForces(fixed_time)
		for x as Algorithmic.Particle in _particles:
			x.integrate(fixed_time)
		
		# l = chunk_ball.CheckCollisions(_player_aabb, _player_aabb_previous)
		# remove_y = false
		
		# if len(l) > 0:
		# 	contacts = List[of ParticleContact]()
		# 	p = gameObject.Find("Player").GetComponent("Particle") as Algorithmic.Particle

		# 	for x as duck in l:
		# 		penetration = x[0]
		# 		contact_normal = x[1]

		# 		Log.Log("Contacts: Penetration ($(x[0].x), $(x[0].y), $(x[0].z)) Contact Normal ($(x[1].x), $(x[1].y), $(x[1].z))")
				
		# 		if contact_normal.y == 1 or contact_normal.y == -1:
		# 			c = ParticleContact(p, null, 0.0, Vector3(0, contact_normal.y, 0), penetration.y)
		# 			contacts.Push(c)

		# 			if contact_normal.y == 1:
		# 				remove_y = true

		# 	#print "COLLISIONS: $contacts"
		# 	#_running = false
		# 	_resolver.resolveContacts(contacts, Time.deltaTime)

		# if remove_y:
		# 	#_registry.add(p, force_ground)
		# 	p.Acceleration.y = 0
		# 	#_registry.clear()
		# 	#_registry.remove(p, force_gravity)

			
		# # if add_y:
		# # 	_registry.add(p, force_gravity)
			
			
		for x as Algorithmic.Particle in _particles:
			x.update_position()

		Log.Log("Finished World Tick\n\n")


			
	def Update():
		p = gameObject.Find("Player").GetComponent("Particle") as Algorithmic.Particle
		if Input.GetKeyDown("return"):
			_running = not _running

		if Input.GetKeyDown("space"):
			#_registry.add(p, Gravity())
			_registry.add(p, Jump())
			
		if Input.GetKey("a") and not Input.GetKey("left shift"):
			_registry.add(p, MoveLeft())
		if Input.GetKey("d"):
			_registry.add(p, MoveRight())
		if Input.GetKey("w"):
			_registry.add(p, MoveForward())
		if Input.GetKey("s"):
			_registry.add(p, MoveBackwards())

		# if not Input.GetKey("d") and not Input.GetKey("a"):
		# 	_registry.add(p, StopMovingSideways())
		# if not Input.GetKey("w") and not Input.GetKey("s"):
		# 	_registry.add(p, StopMovingToAndFro())





