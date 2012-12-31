import UnityEngine

class Player (MonoBehaviour):
	_g as Vector3 = Vector3(0, -9.8, 0)
	_position as Vector3
	_velocity as Vector3
	_acceleration as Vector3
	_damping as single = 0.99
	_inverse_mass as single
	_mass as single
	_force_accum as Vector3
	
	
	_origin as Vector3
	_aabb as AABB
	_chunk_manager as ChunkManager
	initial_startup as bool = false

	def initialize():
		pass
	
	def Start ():
		_position = transform.position
		_velocity = Vector3(0, 0, 0)
		_mass = 80.0
		_inverse_mass = 1.0/_mass	
		_acceleration = _g #+ _g * _inverse_mass
		_force_accum = Vector3(0, 0, 0)
		
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

	def FixedUpdate():
		# position update
		_acceleration = _force_accum
		_position = _position + _velocity * Time.deltaTime
		_velocity = _velocity * _damping + _acceleration * Time.deltaTime #* _inverse_mass
		transform.position = _position
		_force_accum = Vector3(0, 0, 0)


	def getAABB():
		return _aabb

	def addForce(force as Vector3):
		_force_accum += force

	def stopGravity():
		_acceleration = Vector3(0, 0, 0)
		_velocity = Vector3(0, 0, 0)
		## x = gameObject.GetComponent(CharacterMotor) as CharacterMotor
		## x.movement.gravity = 0.0
		## x.movement.maxFallSpeed = 0.0

	def startGravity():
		_acceleration = _g #+ _g * _inverse_mass
		## x = gameObject.GetComponent(CharacterMotor) as CharacterMotor
		## x.movement.gravity = 20.0
		## x.movement.maxFallSpeed = 20.0
		

		

		
