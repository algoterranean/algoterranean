namespace Algorithmic.Player

import UnityEngine


class PlayerCamera (MonoBehaviour):
	#chunk_manager as ChunkManager
	player as Player
	player_particle as Algorithmic.Particle
	zoom as single
	orientation as Vector3
	rotate_speed as single
	offset as Vector3
	player_graphics as List[of GameObject]
	mouse_look as MouseLook
	fps_camera as GameObject
	third_person_camera as GameObject
	

	def Start ():
		#chunk_manager = gameObject.Find("ChunkManager").GetComponent("ChunkManager") as ChunkManager		
		zoom = 1
		rotate_speed = 5
		orientation = Vector3(0, 45, 0)
		offset = Vector3(-10, 10, -3)
		#offset = Vector3(0, 10, 0)
		player = gameObject.Find("Player").GetComponent("Player")
		player_particle = gameObject.Find("Player").GetComponent("Particle")
		player_graphics = List[of GameObject]()
		
		player_graphics.Push(gameObject.Find("Player/Graphics - Body"))
		player_graphics.Push(gameObject.Find("Player/Graphics - Forward Marker"))
		player_graphics.Push(gameObject.Find("Player/Headlamp"))
		mouse_look = gameObject.Find("Player").GetComponent("MouseLook")
		fps_camera = gameObject.Find("Player/1st Person Camera")
		mouse_look.enabled = false
		fps_camera.SetActive(false)
		third_person_camera = gameObject.Find("Player/3rd Person Camera")
						   
		

	def LateUpdate ():
		#if not fps_camera.activeSelf:
		zoom -= Input.GetAxis("Mouse ScrollWheel")
		zoom = Mathf.Clamp(zoom, 0, 5)


		vert = 0 #Input.GetAxis("Mouse Y") * rotate_speed
		rotation = Quaternion.Euler(0, player.transform.eulerAngles.y, vert)
		desired_position = player.transform.position + (rotation * (offset * zoom))
		#transform.position = Vector3.Lerp(transform.position, desired_position, 0.2)
		transform.position = desired_position
		transform.LookAt(player.transform)

		if zoom == 0:
			player_graphics[0].renderer.enabled = false
			player_graphics[1].renderer.enabled = false
			mouse_look.enabled = true
			fps_camera.SetActive(true)
			#third_person_camera.SetActive(false)
		else:
			player_graphics[0].renderer.enabled = true
			player_graphics[1].renderer.enabled = true
			mouse_look.enabled = false
			fps_camera.SetActive(false)
			#third_person_camera.SetActive(true)
		
		

		


