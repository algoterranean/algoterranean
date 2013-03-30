namespace Algorithmic.Player

import UnityEngine
import Algorithmic.Terrain


class Player (MonoBehaviour):
	chunk_manager as ChunkManager
	orientation as Vector3
	rotate_speed as single
	movement_speed as single
	player_particle as Algorithmic.Particle
	public jumping = false

	def Start ():
		rotate_speed = 5
		movement_speed = 10
		orientation = Vector3(0, 45, 0)
		player_particle = gameObject.Find("Player").GetComponent("Particle")
		chunk_manager = gameObject.Find("ChunkManager").GetComponent("ChunkManager") as ChunkManager

	def getOrientation():
		return orientation


	def Update():
		horiz = Input.GetAxis("Mouse X") * rotate_speed
		vert = Input.GetAxis("Mouse Y") * rotate_speed
		transform.Rotate(0, horiz, 0)
		
		if Input.GetKeyDown("space") and not jumping:
			#print 'JUMP'
			jumping = true
			player_particle.Velocity += Vector3(0, 30, 0)

		world_dir = Vector3(movement_speed * Input.GetAxis("Vertical"), 0, movement_speed * -Input.GetAxis("Horizontal"))
		local_dir = transform.rotation * world_dir
		#local_dir = transform.TransformDirection(world_dir)
		player_particle.Velocity.x = local_dir.x
		player_particle.Velocity.z = local_dir.z

		
		#v_x = Mathf.Sin(transform.eulerAngles.x) * 5 * Input.GetAxis("Horizontal")
		#player_particle.Velocity.x = v_x


		
		# if Input.GetKey("a"):
		# 	#print 'KEYPRESS'
		# 	player_particle.Velocity.x = 5
		# if Input.GetKey("d"):
		# 	#print 'KEYPRESS'			
		# 	player_particle.Velocity.x = -5
		# if Input.GetKeyUp("d") or Input.GetKeyUp("a"):
		# 	player_particle.Velocity.x = 0
			
		# if Input.GetKey("w"):
		# 	#print 'KEYPRESS'			
		# 	player_particle.Velocity.z = -5
		# if Input.GetKey("s"):
		# 	#print 'KEYPRESS'			
		# 	player_particle.Velocity.z = 5
		# if Input.GetKeyUp("s") or Input.GetKeyUp("w"):
		# 	player_particle.Velocity.z = 0
		




