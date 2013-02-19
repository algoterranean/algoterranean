namespace Algorithmic.Player

import UnityEngine


class CameraThirdPerson (MonoBehaviour):
	pos as Vector3
	default_offset = Vector3(10, 10, 10)

	def Start ():
		player = gameObject.Find("Player")
		transform.position = player.transform.position
		transform.position += self.default_offset
		transform.LookAt(player.transform.position)
		pos = transform.position
		
	
	def Update ():
		pass

	def FixedUpdate ():
		#print "ROTATING"
		if Input.GetKey("left") and Input.GetKey("left shift"):
			player = gameObject.Find("Player")
			transform.RotateAround(player.transform.position, Vector3.up, 10 * Time.deltaTime)
			pos = transform.position
		else:
			player = gameObject.Find("Player")
			transform.position = player.transform.position + self.default_offset
			
			#pos = transform.position
			#transform.LookAt(player.transform.position)
			#transform.LookAt(player.transform.position)
			#transform.Rotate(rotation)
			#rotation = Vector3(0, 0, 0)
			#transform.LookAt(player.transform.position)


			


			


