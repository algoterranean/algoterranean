import UnityEngine

class Player (MonoBehaviour):
	chunk_manager as GameObject
	initial_startup as bool = false
	#last_position as Vector3
	x_pos = 0.0
	#z_pos = 0.0
	
	def Start ():
		chunk_manager = gameObject.Find("ChunkManager")
		cm_obj = chunk_manager.GetComponent("ChunkManager") as ChunkManager
		cm_obj.setOrigin(Vector3(0, 0, 0))
		center_player()

	def center_player():
		#x = (Settings.ChunkSize * Settings.ChunkCountA)/2
		#z = (Settings.ChunkSize * Settings.ChunkCountB)/2
		gameObject.transform.position = Vector3(0, 200, 0)
	
	def Update ():
		cm_obj = chunk_manager.GetComponent("ChunkManager") as ChunkManager
		#cm_obj.setOrigin(transform.position)
		## if not cm_obj.areInitialChunksComplete():
		## 	center_player()
		## elif not initial_startup:
		## 	initial_startup = true
