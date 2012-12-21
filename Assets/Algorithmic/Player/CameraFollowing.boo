import UnityEngine

class CameraFollowing (MonoBehaviour):
	_origin = Vector3(0.0, 0.0, 0.0)
	last_position = Vector3(0.0, 0.0, 0.0)
	chunk_manager as GameObject
	cm_obj as ChunkManager
	epsilon = 0.15

	def Start ():
		chunk_manager = gameObject.Find("ChunkManager")
		cm_obj = chunk_manager.GetComponent("ChunkManager") as ChunkManager
		cm_obj.setOrigin(_origin)
	
	def FixedUpdate ():
		t = gameObject.GetComponent(Transform)
		dist = (Settings.ChunkWidth*2+1)*Settings.ChunkSize
		
		t.position = Vector3(_origin.x + Settings.ChunkSize/2, _origin.y + dist, _origin.z - dist)
		t.LookAt(Vector3(_origin.x + Settings.ChunkSize/2, _origin.y, _origin.z))
		
		_origin = Vector3(_origin.x, _origin.y, _origin.z + epsilon)
		cm_obj.setOrigin(_origin)
