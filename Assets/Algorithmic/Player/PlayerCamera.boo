namespace Algorithmic.Player

import UnityEngine
import Algorithmic.Terrain


class PlayerCamera (MonoBehaviour):
	#chunk_manager as ChunkManager
	player as Player
	player_particle as Algorithmic.Particle
	zoom as single
	orientation as Vector3
	rotate_speed as single
	offset as Vector3

	def Start ():
		#chunk_manager = gameObject.Find("ChunkManager").GetComponent("ChunkManager") as ChunkManager		
		zoom = 1
		rotate_speed = 5
		orientation = Vector3(0, 45, 0)
		offset = Vector3(-10, 10, -3)
		#offset = Vector3(0, 10, 0)
		player = gameObject.Find("Player").GetComponent("Player")
		player_particle = gameObject.Find("Player").GetComponent("Particle")
		

	def LateUpdate ():
		zoom -= Input.GetAxis("Mouse ScrollWheel")
		zoom = Mathf.Clamp(zoom, 1, 5)
		
		rotation = Quaternion.Euler(0, player.transform.eulerAngles.y, player.transform.eulerAngles.z)
		#offset.y = offset.y * Input.GetAxis("Mouse Y")
		#offset.y += Input.GetAxis("Mouse Y")
		transform.position = player.transform.position + (rotation * (offset * zoom))
		transform.LookAt(player.transform)

		
		
		# transform.position = player.transform.position
		# transform.rotation = player.transform.rotation
		# transform.position += offset
		# transform.LookAt(player.transform)
		

		# transform.position = player.transform.position - (rotation * offset)
		# transform.LookAt(player.transform)

		
		# transform.rotation = player.transform.rotation
		
		# zoom += -Input.GetAxis("Mouse ScrollWheel")
		# zoom = Mathf.Clamp(zoom, 5, 30)

		# transform.position += Vector3(2, 10, -10)
		# transform.LookAt(player.transform.position)


		# horiz = Input.GetAxis("Mouse X") * rotate_speed
		# vert = Input.GetAxis("Mouse Y") * rotate_speed
		# transform.Rotate(0, horiz, 0)

		# transform.position = player.transform.position + offset * zoom
		# transform.LookAt(player.transform.position)

		


