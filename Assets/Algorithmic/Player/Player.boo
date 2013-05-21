namespace Algorithmic.Player

import UnityEngine
import Algorithmic.Chunks
import Algorithmic.Physics


class Player (MonoBehaviour):
	chunk_manager as DisplayManager
	chunk_ball as IChunkGenerator
	orientation as Vector3
	rotate_speed as single
	movement_speed as single
	player_particle as Algorithmic.Particle
	player_camera as GameObject
	terrain_collider as Algorithmic.Physics.ChunkCollider
	world as Algorithmic.Physics.World
	public jumping = false
	t = 0
	public reticle_tex as Texture2D
	first as bool

	def Start ():
		rotate_speed = 3.5
		movement_speed = 5 * 3
		orientation = Vector3(0, 45, 0)
		first = true

		player_particle = gameObject.Find("Player").GetComponent("Particle")
		chunk_manager = gameObject.Find("Engine/ChunkManager").GetComponent("DisplayManager")
		chunk_ball = gameObject.Find("Engine/ChunkManager").GetComponent("DataManager")
		player_camera = gameObject.Find("Player/1st Person Camera")
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

		if Input.GetButtonDown("Fire1"):
			# chunk_ball.setBlock(LongVector3(t, 54, 5), BLOCK.AIR)
			# chunk_ball.setBlock(LongVector3(t, 55, 6), BLOCK.DIRT)
			# t += 1
			
			player_camera = gameObject.Find("Player/1st Person Camera")
			p1 = player_camera.transform.position
			dir = player_camera.transform.forward * 5
			p2 = p1 + dir
			
			print "DIGGING: camera: $(dir), p1: $(p1), p2: $(p2)"

			tc = world.getChunkCollider()
			c = tc.CheckCollisionsSweep(AABB(p2, Vector3(0, 0, 0)),
										AABB(p1, Vector3(0, 0, 0)))
			
			if len(c) > 0:
				ba = c[0].block_aabb
				print "DIGGING: $c"
				print "ACTUAL BLOCK: $ba"
				chunk_ball.setBlock(WorldBlockCoordinate(ba.center.x - ba.radius.x,
												ba.center.y - ba.radius.y,
												ba.center.z - ba.radius.z), BLOCK.AIR)

		if Input.GetButtonDown("Fire2"):
			player_camera = gameObject.Find("Player/1st Person Camera")
			p1 = player_camera.transform.position
			dir = player_camera.transform.forward * 5
			p2 = p1 + dir
			
			print "DIGGING: camera: $(dir), p1: $(p1), p2: $(p2)"

			tc = world.getChunkCollider()
			c = tc.CheckCollisionsSweep(AABB(p2, Vector3(0, 0, 0)),
										AABB(p1, Vector3(0, 0, 0)))
			
			if len(c) > 0:
				for x in c:
					if x.contact_normal != Vector3(0, 0, 0):
						ba = x.block_aabb				
						print "DIGGING: $c"
						print "ACTUAL BLOCK: $ba"
						n = x.contact_normal
						print "NORMAL: $n"
						chunk_ball.setBlock(WorldBlockCoordinate(ba.center.x - ba.radius.x + n.x,
														ba.center.y - ba.radius.y + n.y,
														ba.center.z - ba.radius.z + n.z), BLOCK.DIRT)
						break
			
		if first:
			#chunk_ball.setOrigin(transform.position)
			chunk_ball.setOrigin(Vector3(0, 0, 0))
			first = false

	def OnGUI():
		pass
		# GUI.DrawTexture(Rect(Screen.width/2 - reticle_size/2,
		# 					 Screen.height/2 - reticle_size/2,
		# 					 reticle_size,
		# 					 reticle_size), reticle_tex)


	

		



