import UnityEngine

class CameraFollowing (MonoBehaviour):
	origin = Vector3(0.0, 0.0, 0.0)
	last_position = Vector3(0.0, 0.0, 0.0)
	chunk_manager as GameObject
	cm_obj as ChunkManager
	epsilon = 0.2

	def Start ():
		chunk_manager = gameObject.Find("ChunkManager")
		cm_obj = chunk_manager.GetComponent("ChunkManager") as ChunkManager
		cm_obj.setOrigin(origin.x, origin.z, origin.y)
	
	def Update ():
		gameObject.GetComponent(Transform).position = Vector3(origin.x - 80.0, origin.y + 150.0, origin.z - 80.0)
		gameObject.GetComponent(Transform).LookAt(Vector3(origin.x, origin.y + 90, origin.z))
		origin = Vector3(origin.x + epsilon, origin.y, origin.z + epsilon)
		
		if Vector3.Distance(origin, last_position) >= 10.0:
			last_position = origin
			cm_obj.setOrigin(origin.x, origin.z, origin.y)
