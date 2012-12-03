import UnityEngine

class Player (MonoBehaviour):
	chunk_manager as GameObject
	initial_startup as bool = false
	
	def Start ():
		chunk_manager = gameObject.Find("ChunkManager")

	def center_player():
		x =(Settings.ChunkSize * Settings.ChunkCountA)/2
		z = (Settings.ChunkSize * Settings.ChunkCountB)/2
		gameObject.transform.position = Vector3(x, 200, z)
	
	def Update ():
		cm_obj = chunk_manager.GetComponent("ChunkManager") as ChunkManager
		if not cm_obj.areInitialChunksComplete():
			center_player()
			#initial_startup = true
