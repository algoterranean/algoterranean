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
		cm_obj.setOrigin(0, 0, 0)
		center_player()

	def center_player():
		x = (Settings.ChunkSize * Settings.ChunkCountA)/2
		z = (Settings.ChunkSize * Settings.ChunkCountB)/2
		gameObject.transform.position = Vector3(0, 2000, 0)
	
	def Update ():
		cm_obj = chunk_manager.GetComponent("ChunkManager") as ChunkManager
		if not cm_obj.areInitialChunksComplete():
			center_player()
		elif not initial_startup:
			initial_startup = true
			#cm_obj.setOrigin(0, 0, 0)
			#cm_obj.setOrigin(100,0,0)

			#if initial_startup:
		 	#cm_obj.setOrigin(x_pos + 10 * Time.deltaTime, 0, 0)
		 	#x_pos += 0.1
			
		# if initial_startup:
		# 	origin = gameObject.transform.position
		# 	cm_obj.setOrigin(origin.x, origin.z, origin.y)
		# 	#last_position = Vector3(0,0,0)

		# if initial_startup:
		# 	#v = transform.position
		# 	#cm_obj.setOrigin(v.x, v.y, v.z)
		# 	cm_obj.setOrigin(x_pos + 10 * Time.deltaTime, 0, 0)
		# 	x_pos += 0.1
		# 	#z_pos += 0.1
