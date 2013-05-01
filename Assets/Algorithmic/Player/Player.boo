namespace Algorithmic.Player

import UnityEngine
import Algorithmic.Chunks


class Player (MonoBehaviour):
	chunk_manager as DisplayManager
	chunk_ball as DataManager
	orientation as Vector3
	rotate_speed as single
	movement_speed as single
	player_particle as Algorithmic.Particle
	player_camera as GameObject
	terrain_collider as Algorithmic.Physics.TerrainCollider
	world as Algorithmic.Physics.World
	public jumping = false

	def Start ():
		rotate_speed = 3.5
		movement_speed = 5
		orientation = Vector3(0, 45, 0)

		player_particle = gameObject.Find("Player").GetComponent("Particle")
		chunk_manager = gameObject.Find("Engine/ChunkManager").GetComponent("DisplayManager") as DisplayManager
		chunk_ball = chunk_manager.getChunkBall()
		player_camera = gameObject.Find("Player/Camera")
		world = gameObject.Find("Engine/PhysicsManager").GetComponent("World")

	def getOrientation():
		return orientation

	def Update():
		horiz = Input.GetAxis("Mouse X") * rotate_speed
		vert = Input.GetAxis("Mouse Y") * rotate_speed
		transform.Rotate(0, horiz, 0)
		
		if Input.GetKeyDown("space") and not jumping:
			print 'JUMP'
			jumping = true
			player_particle.Velocity += Vector3(0, 8, 0)

		tmp_speed = movement_speed
		if Input.GetKey(KeyCode.LeftShift):
			tmp_speed *= 2.2
 
		world_dir = Vector3(tmp_speed * Input.GetAxis("Vertical"), 0, tmp_speed * -Input.GetAxis("Horizontal"))
		local_dir = transform.rotation * world_dir
		player_particle.Velocity.x = local_dir.x
		player_particle.Velocity.z = local_dir.z

		# if Input.GetButtonDown("Fire1"):
		# 	player_camera = gameObject.Find("Player/Camera")			
		# 	p1 = player_camera.transform.position
		# 	dir = player_camera.transform.forward
		# 	dir.Normalize()
		# 	p2 = Vector3(dir.x * 5, dir.y * 5, dir.z * 5)

		# 	tc = world.getTerrainCollider()
		# 	c = tc.CheckCollisionsSweep(AABB(p1, Vector3(0, 0, 0)),
		# 								AABB(dir, Vector3(0, 0, 0)))
		# 	if len(c) > 0:
		# 		print "REMOVE BLOCK $(c[0])"
		# 		ba = c[0].block_aabb
		# 		chunk_ball.setBlock(LongVector3(ba.center.x - ba.radius.x,
		# 										ba.center.y - ba.radius.y,
		# 										ba.center.z - ba.radius.z))
		# 	#print "DIGGING: $c"
			
		chunk_manager.setOrigin(transform.position)

	

		



