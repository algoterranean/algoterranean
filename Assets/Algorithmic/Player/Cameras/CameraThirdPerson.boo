namespace Algorithmic.Player

import UnityEngine


class CameraThirdPerson (MonoBehaviour):

	def Start ():
		pass
	
	def Update ():
		player = gameObject.Find("Player")
		transform.position = player.transform.position
		transform.position += Vector3(10, 5, 10)
		transform.LookAt(player.transform.position)


