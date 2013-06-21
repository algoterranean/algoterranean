namespace Algorithmic.Player

import UnityEngine
import System.Math
import Algorithmic.Chunks
import Algorithmic.Physics
import Algorithmic.Utils


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
	raycast_distance = 10.0
	public reticle_tex as Texture2D
	first as bool
	main_camera as GameObject
	block_outline as BlockOutline
	stats as Stats

	def Start ():
		rotate_speed = 3.5
		movement_speed = 5 * 3
		orientation = Vector3(0, 45, 0)
		first = true

		#player_particle = gameObject.Find("Player").GetComponent("Particle")
		chunk_manager = gameObject.Find("Engine/ChunkManager").GetComponent("DisplayManager")
		chunk_ball = gameObject.Find("Engine/ChunkManager").GetComponent("DataManager")
		main_camera = gameObject.Find("Player/First Person Controller/Main Camera")
		#player_camera = gameObject.Find("Player/1st Person Camera")
		#world = gameObject.Find("Engine/PhysicsManager").GetComponent("World")
		block_outline = gameObject.Find("Block Outline").GetComponent("BlockOutline")
		stats = gameObject.Find("Engine/ChunkManager").GetComponent("Stats")

	def getOrientation():
		return orientation

	def Update():
		scale = Settings.ChunkScale
		size as single = Settings.ChunkSize
		block_found = false
		chunk_ball.setOrigin(Vector3(transform.position.x, 0, transform.position.z)) #transform.position)		

		# outline the block that is in range
		out as RaycastHit
		if not Physics.Raycast(main_camera.transform.position, main_camera.transform.forward, out, raycast_distance):
			block_outline.disable()
		else:
			chunk_coord as WorldBlockCoordinate, local_coord as WorldBlockCoordinate, abs_coord as WorldBlockCoordinate = decomposeCoordinates(out.point)

			pos = Vector3(chunk_coord.x + local_coord.x,
						  chunk_coord.y + local_coord.y,
						  chunk_coord.z + local_coord.z)

			if out.normal.x == 1:
				pos.x -= 1
			elif out.normal.y == 1:
				pos.y -= 1
			elif out.normal.z == 1:
				pos.z -= 1
			pos.x *= scale
			pos.y *= scale
			pos.z *= scale
			stats.LookingAt(pos, 0)

			block_outline.setPosition(pos)
			block_outline.enable()
			block_found = true
			
				
		# digging
		if Input.GetButtonDown("Fire1"):
			if block_found:
				p = WorldBlockCoordinate(abs_coord.x, abs_coord.y, abs_coord.z)
				if out.normal.x == 1:
					p.x -= 1
				elif out.normal.y == 1:
					p.y -= 1
				elif out.normal.z == 1:
					p.z -= 1
				chunk_ball.setBlock(p, 0)
		# building
		elif Input.GetButtonDown("Fire2"):
			if block_found:
				p = WorldBlockCoordinate(abs_coord.x, abs_coord.y, abs_coord.z)
				if out.normal.x == -1:
					p.x -= 1
				elif out.normal.y == -1:
					p.y -= 1
				elif out.normal.z == -1:
					p.z -= 1
				chunk_ball.setBlock(p, 50)

		
	# 	horiz = Input.GetAxis("Mouse X") * rotate_speed
	# 	vert = Input.GetAxis("Mouse Y") * rotate_speed
	# 	transform.Rotate(0, horiz, 0)
		
	# 	if Input.GetKeyDown("space") and not jumping:
	# 		print 'JUMP'
	# 		jumping = true
	# 		player_particle.Velocity += Vector3(0, 8, 0)

	# 	tmp_speed = movement_speed
	# 	if Input.GetKey(KeyCode.LeftShift):
	# 		tmp_speed *= 2.2
 
	# 	world_dir = Vector3(tmp_speed * Input.GetAxis("Vertical"), 0, tmp_speed * -Input.GetAxis("Horizontal"))
	# 	local_dir = transform.rotation * world_dir
	# 	player_particle.Velocity.x = local_dir.x
	# 	player_particle.Velocity.z = local_dir.z

		# if Input.GetButtonDown("Fire1"):
		# 	# chunk_ball.setBlock(LongVector3(t, 54, 5), BLOCK.AIR)
		# 	# chunk_ball.setBlock(LongVector3(t, 55, 6), BLOCK.DIRT)
		# 	# t += 1
			
		# 	player_camera = gameObject.Find("Player/1st Person Camera")
		# 	p1 = player_camera.transform.position
		# 	dir = player_camera.transform.forward * 5
		# 	p2 = p1 + dir
			
		# 	print "DIGGING: camera: $(dir), p1: $(p1), p2: $(p2)"

		# 	# tc = world.getChunkCollider()
		# 	# c = tc.CheckCollisionsSweep(AABB(p2, Vector3(0, 0, 0)),
		# 	# 							AABB(p1, Vector3(0, 0, 0)))
			
		# 	# if len(c) > 0:
		# 	# 	ba = c[0].block_aabb
		# 	# 	print "DIGGING: $c"
		# 	# 	print "ACTUAL BLOCK: $ba"
		# 	# 	chunk_ball.setBlock(WorldBlockCoordinate(ba.center.x - ba.radius.x,
		# 	# 									ba.center.y - ba.radius.y,
		# 	# 									ba.center.z - ba.radius.z), BLOCK.AIR)

	# 	if Input.GetButtonDown("Fire2"):
	# 		player_camera = gameObject.Find("Player/1st Person Camera")
	# 		p1 = player_camera.transform.position
	# 		dir = player_camera.transform.forward * 5
	# 		p2 = p1 + dir
			
	# 		print "DIGGING: camera: $(dir), p1: $(p1), p2: $(p2)"

	# 		tc = world.getChunkCollider()
	# 		c = tc.CheckCollisionsSweep(AABB(p2, Vector3(0, 0, 0)),
	# 									AABB(p1, Vector3(0, 0, 0)))
			
	# 		if len(c) > 0:
	# 			for x in c:
	# 				if x.contact_normal != Vector3(0, 0, 0):
	# 					ba = x.block_aabb				
	# 					print "DIGGING: $c"
	# 					print "ACTUAL BLOCK: $ba"
	# 					n = x.contact_normal
	# 					print "NORMAL: $n"
	# 					chunk_ball.setBlock(WorldBlockCoordinate(ba.center.x - ba.radius.x + n.x,
	# 													ba.center.y - ba.radius.y + n.y,
	# 													ba.center.z - ba.radius.z + n.z), BLOCK.DIRT)
	# 					break
			
	# 	# if first:
	# 	# 	chunk_ball.setOrigin(Vector3(0, 0, 0))
	# 	# 	first = false
	# 	# else:
		


			
	def OnGUI():
		pass
		# GUI.DrawTexture(Rect(Screen.width/2 - reticle_size/2,
		# 					 Screen.height/2 - reticle_size/2,
		# 					 reticle_size,
		# 					 reticle_size), reticle_tex)


	

		



