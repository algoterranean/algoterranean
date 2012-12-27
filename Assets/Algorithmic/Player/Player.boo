import UnityEngine

class Player (MonoBehaviour):
	_origin as Vector3
	_aabb as AABB
	_chunk_manager as ChunkManager
	initial_startup as bool = false

	def initialize():
		pass
	
	def Start ():
		_chunk_manager = gameObject.Find("ChunkManager").GetComponent("ChunkManager") as ChunkManager
		_origin = transform.position
		_aabb = AABB(transform.position, Vector3(0.5, 1.0, 0.5))
		#chunk_manager.setOrigin(transform.position)

	def Update ():
		_aabb = AABB(transform.position, Vector3(0.5, 1.0, 0.5))
		if _chunk_manager.isInitialized() and not initial_startup:
			initial_startup = true
			print 'CHUNK MANAGER IS INITIALIZED'

		#if initial_startup:
		#chunk_manager.setOrigin(transform.position)

	def getAABB():
		return _aabb
		
