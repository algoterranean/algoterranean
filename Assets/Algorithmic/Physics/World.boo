"""World keeps track of all particles and updates them according to collisions."""
namespace Algorithmic.Physics

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
	player as Player
	player_radius as Vector3
	terrain_collider as TerrainCollider

	def getTerrainCollider():
		return terrain_collider
	

	def Start ():
		particles = []
		registry = ForceParticleRegistry()
		_resolver = ParticleContactResolver(50)
		chunk_manager = gameObject.Find("ChunkManager").GetComponent("ChunkManager")
		chunk_ball = chunk_manager.getChunkBall()
		player_particle = gameObject.Find("Player").GetComponent("Particle")
		player = gameObject.Find("Player").GetComponent("Player")
		registry.add(player_particle, forces.gravity)
		particles.Push(player_particle)
		player_radius = Settings.PlayerRadius
		terrain_collider = TerrainCollider(chunk_ball)
		
	def FixedUpdate():
		if not _running:
			return
		Log.Log("Starting World Tick", LOG_MODULE.PHYSICS)

		current_time = 0.0
		end_time = 1.0
		loop_count = 1
		max_loops = 10 # for degenerate cases



		#registry.updateForces(Time.deltaTime)
		# for p as Algorithmic.Particle in particles:
		# 	p.addForce(Vector3(0, -9.8*p.Mass, 0))
		# 	p.integrate(Time.deltaTime)
		# 	p.update_position()



		
		while current_time < end_time and loop_count < max_loops:
			#Log.Log("LOOP COUNT $loop_count", LOG_MODULE.PHYSICS)
			future_pos, future_vel, future_accel = player_particle.getFutureState(Time.deltaTime)
			player_aabb_previous = AABB(player_particle.Position, player_radius)
			player_aabb_future = AABB(future_pos, player_radius)
			sweep_contacts = terrain_collider.CheckCollisionsSweep(player_aabb_future, player_aabb_previous)

			found_valid_contact = false
			if len(sweep_contacts) > 0:
				for x in sweep_contacts:
					if x.start_time == 0 and x.contact_normal == Vector3(0, -1, 0):
						pass
					else:
						#Log.Log("Possible Contact: $x", LOG_MODULE.CONTACTS)
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


			if not found_valid_contact:
				registry.updateForces((end_time - current_time) * Time.deltaTime)
				for p as Algorithmic.Particle in particles:
					p.integrate((end_time - current_time) * Time.deltaTime)
				current_time = end_time
				break

			# max_surface_area = Vector3
			# for c in sweep_contacts:
			# 	if c.surface_area > max_surface_area and c.start_time <= earliest_contact.start_time:
			# 		max_surface_area = c.surface_area
				
			registry.updateForces((earliest_contact.start_time - current_time) * Time.deltaTime)
			for p as Algorithmic.Particle in particles:
				p.integrate((earliest_contact.start_time - current_time) * Time.deltaTime)

				
				for c in sweep_contacts:
					if c.start_time == earliest_contact.start_time: #and c.surface_area == max_surface_area:
						current_aabb = AABB(p.Position, player_radius)
						block_aabb = c.block_aabb
						left_plane = current_aabb.max.x - block_aabb.min.x
						right_plane = current_aabb.min.x - block_aabb.max.x
						bottom_plane = current_aabb.max.y - block_aabb.min.y
						top_plane = current_aabb.min.y - block_aabb.max.y
						front_plane = current_aabb.max.z - block_aabb.min.z
						back_plane = current_aabb.min.z - block_aabb.max.z
						planes = [left_plane, right_plane,
								  bottom_plane, top_plane,
								  front_plane, back_plane]
						plane_normals = [Vector3(-1, 0, 0), Vector3(1, 0, 0),
										 Vector3(0, -1, 0), Vector3(0, 1, 0),
										 Vector3(0, 0, -1), Vector3(0, 0, 1)]
						surfaces = [(Min(c.block_aabb.max.y, current_aabb.max.y) - Max(c.block_aabb.min.y, current_aabb.min.y)) * (Min(c.block_aabb.max.z, current_aabb.max.z) - Max(c.block_aabb.min.z, current_aabb.min.z)),
									(Min(c.block_aabb.max.y, current_aabb.max.y) - Max(c.block_aabb.min.y, current_aabb.min.y)) * (Min(c.block_aabb.max.z, current_aabb.max.z) - Max(c.block_aabb.min.z, current_aabb.min.z)),
									
									(Min(c.block_aabb.max.x, current_aabb.max.x) - Max(c.block_aabb.min.x, current_aabb.min.x)) * (Min(c.block_aabb.max.z, current_aabb.max.z) - Max(c.block_aabb.min.z, current_aabb.min.z)),
									(Min(c.block_aabb.max.x, current_aabb.max.x) - Max(c.block_aabb.min.x, current_aabb.min.x)) * (Min(c.block_aabb.max.z, current_aabb.max.z) - Max(c.block_aabb.min.z, current_aabb.min.z)),
									
									(Min(c.block_aabb.max.y, current_aabb.max.y) - Max(c.block_aabb.min.y, current_aabb.min.y)) * (Min(c.block_aabb.max.x, current_aabb.max.x) - Max(c.block_aabb.min.x, current_aabb.min.x)),
									(Min(c.block_aabb.max.y, current_aabb.max.y) - Max(c.block_aabb.min.y, current_aabb.min.y)) * (Min(c.block_aabb.max.x, current_aabb.max.x) - Max(c.block_aabb.min.x, current_aabb.min.x))]
									
						min_dist = 999999999999999999.0
						#max_surface_area = 0
						c_n = Vector3(0, 0, 0)
						for i in range(len(planes)):
							if System.Math.Abs(planes[i] cast single) < min_dist:
								min_dist = System.Math.Abs(planes[i] cast single)
								c_n = plane_normals[i]
								#max_surface_area = surfaces[i]

						c_n = c.contact_normal
						#print "NEW CONTACT NORMAL: $c_n"

						if c_n.x != 0 and c.surface_area.x > c.surface_area.y and c.surface_area.x > c.surface_area.z:
							p.Velocity.x = 0
							p.Acceleration.x = 0
							#Log.Log("Setting X to 0", LOG_MODULE.PHYSICS)
						elif c_n.y != 0 and c.surface_area.y > c.surface_area.x and c.surface_area.y > c.surface_area.z:
							if c_n.y == 1:
								player.jumping = false
								p.Velocity.y = 0
								p.Acceleration.y = 0
								#Log.Log("Setting Y to 0", LOG_MODULE.PHYSICS)
								
							elif c_n.y == -1:
								if p.Velocity.y > 0 or p.Acceleration.y > 0:
									p.Velocity.y = 0
									p.Acceleration.y = 0
									#Log.Log("Setting Y to 0", LOG_MODULE.PHYSICS)
							
								
						elif c_n.z != 0 and c.surface_area.z > c.surface_area.x and c.surface_area.z > c.surface_area.y:
							p.Velocity.z = 0
							p.Acceleration.z = 0
							#Log.Log("Setting Z to 0", LOG_MODULE.PHYSICS)
							

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
			
			



			





