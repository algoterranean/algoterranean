"""World keeps track of all particles and updates them according to collisions."""
namespace Algorithmic

import UnityEngine
import Algorithmic
import Algorithmic.Player
import Algorithmic.Terrain
import Algorithmic.Misc

struct AvailableForces:
	gravity as IForceGenerator
	ground as IForceGenerator
	jump as IForceGenerator

	def constructor(gravity as IForceGenerator, ground as IForceGenerator, jump as IForceGenerator):
		self.gravity = gravity
		self.ground = ground
		self.jump = jump


class World (MonoBehaviour):
	_registry as ForceParticleRegistry
	_resolver as ParticleContactResolver
	_particles = []
	_running = false
	_jumping = false
	forces = AvailableForces(Gravity(), Ground(), Jump())

	def Start ():
		_particles = []
		_registry = ForceParticleRegistry()
		_resolver = ParticleContactResolver(50)
		p = gameObject.Find("Player").GetComponent("Particle") as Algorithmic.Particle
		_registry.add(p, forces.gravity)
		_particles.Push(p)
		
	def FixedUpdate():
		if not _running:
			return
		Log.Log("Starting World Tick", LOG_MODULE.PHYSICS)

		# generate all possible collisions
		chunk_manager = gameObject.Find("ChunkManager").GetComponent("ChunkManager") as ChunkManager
		chunk_ball = chunk_manager.getChunkBall()
		_particle = gameObject.Find("Player").GetComponent("Particle") as Algorithmic.Particle

		_player_aabb_previous = AABB(_particle.Position, Vector3(0.5, 0.5, 0.5))
		future_pos = _particle.getFutureState(Time.deltaTime)[0]
		future_vel = _particle.getFutureState(Time.deltaTime)[1]
		future_accel = _particle.getFutureState(Time.deltaTime)[2]
		_player_aabb = AABB(future_pos, Vector3(0.5, 0.5, 0.5))


		Log.Log("Pos Now: $_player_aabb_previous", LOG_MODULE.PHYSICS)
		Log.Log("Player Pos In Future: $_player_aabb", LOG_MODULE.PHYSICS)
		possible_collisions = chunk_ball.CheckCollisionsSweep(_player_aabb, _player_aabb_previous)

		
		earliest_contact as duck = []
		if len(possible_collisions) > 0:
			earliest_contact = possible_collisions[0]

		fixed_time = Time.deltaTime
		if earliest_contact != []:
			Log.Log("Earliest Contact: $earliest_contact", LOG_MODULE.PHYSICS)
			fixed_time *= earliest_contact.start_time

		if possible_collisions == []:
			Log.Log("NO CONTACTS", LOG_MODULE.PHYSICS)
			p = gameObject.Find("Player").GetComponent("Particle") as Algorithmic.Particle
			_registry.remove(p, forces.ground)
			
			# p = gameObject.Find("Player").GetComponent("Particle") as Algorithmic.Particle
			# _registry.remove(p, forces.ground)
	
		_registry.updateForces(fixed_time)
		for x as Algorithmic.Particle in _particles:
			x.integrate(fixed_time)

		if earliest_contact != []:
			pass


		if earliest_contact != []:
			if earliest_contact.contact_normal == Vector3(0, 1, 0):
				if earliest_contact.direction.x == 0 and earliest_contact.direction.y == 0 and earliest_contact.direction.z == 0:
					pass
				else:
					Log.Log("Canceling Gravity", LOG_MODULE.PHYSICS)
					p = gameObject.Find("Player").GetComponent("Particle") as Algorithmic.Particle
					#_registry.add(p, Ground(-p.Acceleration))
					_registry.add(p, forces.ground)
					_registry.remove(p, forces.jump)
					_jumping = false
					p.Acceleration.y = 0
					p.Velocity.y = 0


			# else:
			# 	p = gameObject.Find("Player").GetComponent("Particle") as Algorithmic.Particle
			# 	_registry.remove(p, force_ground)
				
				#_particle.Acceleration.y = 0
				#_particle.Velocity.y = 0
				
			
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

		Log.Log("Finished World Tick\n\n", LOG_MODULE.PHYSICS)

	def try_forces():
		p = gameObject.Find("Player").GetComponent("Particle") as Algorithmic.Particle
		if Input.GetKeyDown("return"):
			_running = not _running

		if Input.GetKeyDown("space") and not _jumping:
			#_registry.add(p, Gravity())
			Log.Log("BEGIN JUMP", LOG_MODULE.PHYSICS)
			#_registry.remove(p, forces.ground)
			forces.jump = Jump()
			_registry.add(p, forces.jump)
			_registry.remove(p, forces.ground)
			_jumping = true
			#p.Velocity = Vector3(0, -9.8, 0)

			
		if Input.GetKey("a") and not Input.GetKey("left shift"):
			_registry.add(p, MoveLeft())
		if Input.GetKey("d"):
			_registry.add(p, MoveRight())
		if Input.GetKey("w"):
			_registry.add(p, MoveForward())
		if Input.GetKey("s"):
			_registry.add(p, MoveBackwards())

			
	def Update():
		try_forces()



		# p = gameObject.Find("Player").GetComponent("Particle") as Algorithmic.Particle
		# if Input.GetKeyDown("return"):
		# 	_running = not _running

		# if Input.GetKeyDown("space"):
		# 	#_registry.add(p, Gravity())
		# 	Log.Log("BEGIN JUMP")
		# 	_registry.add(p, Jump())
			
		# if Input.GetKey("a") and not Input.GetKey("left shift"):
		# 	_registry.add(p, MoveLeft())
		# if Input.GetKey("d"):
		# 	_registry.add(p, MoveRight())
		# if Input.GetKey("w"):
		# 	_registry.add(p, MoveForward())
		# if Input.GetKey("s"):
		# 	_registry.add(p, MoveBackwards())
			

		# if not Input.GetKey("d") and not Input.GetKey("a"):
		# 	_registry.add(p, StopMovingSideways())
		# if not Input.GetKey("w") and not Input.GetKey("s"):
		# 	_registry.add(p, StopMovingToAndFro())





