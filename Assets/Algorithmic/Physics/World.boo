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
	registry as ForceParticleRegistry
	_resolver as ParticleContactResolver
	particles = []
	_running = false
	jumping = false
	forces = AvailableForces(Gravity(), Ground(Vector3(0, 9.8, 0)), Jump())
	chunk_manager as ChunkManager
	chunk_ball as ChunkBall
	player_particle as Algorithmic.Particle 
	

	def Start ():
		particles = []
		registry = ForceParticleRegistry()
		_resolver = ParticleContactResolver(50)
		chunk_manager = gameObject.Find("ChunkManager").GetComponent("ChunkManager")
		chunk_ball = chunk_manager.getChunkBall()
		player_particle = gameObject.Find("Player").GetComponent("Particle")
		registry.add(player_particle, forces.gravity)
		particles.Push(player_particle)
		
	def FixedUpdate():
		if not _running:
			return
		Log.Log("Starting World Tick", LOG_MODULE.PHYSICS)

		current_time = 0.0
		end_time = 1.0
		loop_count = 1

		
		while current_time < end_time:
			Log.Log("LOOP COUNT $loop_count", LOG_MODULE.PHYSICS)
			future_pos, future_vel, future_accel = player_particle.getFutureState(Time.deltaTime)
			player_aabb_previous = AABB(player_particle.Position, Vector3(0.5, 0.5, 0.5))
			player_aabb_future = AABB(future_pos, Vector3(0.5, 0.5, 0.5))
			sweep_contacts = chunk_ball.CheckCollisionsSweep(player_aabb_future, player_aabb_previous)
			

			found_valid_contact = false
			if len(sweep_contacts) > 0:
				for x in sweep_contacts:
					Log.Log("Possible Contact: $x", LOG_MODULE.CONTACTS)
					if x.offset_vector != Vector3(0, 0, 0):
						found_valid_contact = true
						earliest_contact = x
						break

				if found_valid_contact:
					for x in sweep_contacts:
						if x.start_time < earliest_contact.start_time and x.offset_vector != Vector3(0, 0, 0):
							earliest_contact = x


			# if not found_valid_contact:
			# 	registry.updateForces((end_time	- current_time) * Time.deltaTime)
			# 	for p as Algorithmic.Particle in particles:
			# 		p.integrate((end_time - current_time) * Time.deltaTime)
			# 	break


			#if len(sweep_contacts) == 0:
			if not found_valid_contact: #len(sweep_contacts) == 0:
				#if loop_count == 1:
				registry.updateForces((end_time - current_time) * Time.deltaTime)
				for p as Algorithmic.Particle in particles:
					p.integrate((end_time - current_time) * Time.deltaTime)
				break
				
			registry.updateForces((earliest_contact.start_time - current_time) * Time.deltaTime)
			for p as Algorithmic.Particle in particles:
				p.integrate((earliest_contact.start_time - current_time) * Time.deltaTime)
				if earliest_contact.contact_normal.x != 0:
					p.Velocity.x = 0
					p.Acceleration.x = 0
				elif earliest_contact.contact_normal.y != 0:
					p.Velocity.y = 0
					p.Acceleration.y = 0
					
					# apply opposite reaction force
					# all_forces = registry.getForces(p)
					# force_sum = Vector3(0, 0, 0)
					# for f in all_forces:
					# 	force_sum.y += f.getForce().y
					# registry.add(p, Ground(-force_sum))
					
					jumping = false
				elif earliest_contact.contact_normal.z != 0:
					p.Velocity.z = 0
					p.Acceleration.z = 0

				# if earliest_contact.contact_normal.y == 0:
				# 	all_forces = registry.getForces(p)
				# 	for f in all_forces:
				# 		if f.getForce().y > 0:
				# 			registry.remove(p, f)
					
			current_time += (earliest_contact.start_time - current_time)
			loop_count += 1

		for p as Algorithmic.Particle in particles:
			p.update_position()


		Log.Log("Finished World Tick\n\n", LOG_MODULE.PHYSICS)


	def Update():
		
		if Input.GetKeyDown("return"):
			_running = not _running
		if Input.GetKeyDown("space") and not jumping:
			jumping = true
			#registry.remove
			player_particle.Velocity += Vector3(0, 30, 0)
			# all_forces = registry.getForces(player_particle)
			# for f in all_forces:
			# 	if f.getType() == FORCE_TYPE.GROUND_REACTION and f.getForce().y > 0:
			# 		registry.remove(player_particle, f)

		if Input.GetKeyDown("a"):
			player_particle.Velocity += Vector3(5, 0, 0)
		if Input.GetKeyDown("d"):
			player_particle.Velocity += Vector3(-5, 0, 0)
		if Input.GetKeyDown("w"):
			player_particle.Velocity += Vector3(0, 0, -5)
		if Input.GetKeyDown("s"):
			player_particle.Velocity += Vector3(0, 0, 5)



			





