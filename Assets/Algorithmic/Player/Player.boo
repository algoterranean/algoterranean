import UnityEngine

class Player (MonoBehaviour, IParticle):
	# IParticle stuff
	_g as Vector3 = Vector3(0, -9.8, 0)
	_position as Vector3
	_velocity as Vector3
	_acceleration as Vector3
	_damping as single = 0.99
	_inverse_mass as single
	_mass as single
	_force_accum as Vector3
	
	# Player Stuff
	_origin as Vector3
	_aabb as AABB
	_chunk_manager as ChunkManager
	initial_startup as bool = false

	def initialize():
		pass
	
	def Start ():
		setPosition(transform.position)
		setVelocity(Vector3(0, 0, 0))
		setAcceleration(_g)		
		_mass = 80.0
		_inverse_mass = 1.0/_mass
		_force_accum = Vector3(0, 0, 0)
		
		_chunk_manager = gameObject.Find("ChunkManager").GetComponent("ChunkManager") as ChunkManager
		_origin = transform.position
		_aabb = AABB(transform.position, Vector3(0.5, 1.0, 0.5))
		#chunk_manager.setOrigin(transform.position)

	def Update ():
		_aabb = AABB(transform.position, Vector3(0.5, 1.0, 0.5))
		if _chunk_manager.isInitialized() and not initial_startup:
			initial_startup = true
			#print 'CHUNK MANAGER IS INITIALIZED'
	
	def getPosition() as Vector3:
		return _position
	def getVelocity() as Vector3:
		return _velocity
	def getAcceleration() as Vector3:
		return _acceleration
	def setPosition(p as Vector3):
		_position = p
	def setVelocity(v as Vector3):
		_velocity = v
	def setAcceleration(a as Vector3):
		_acceleration = a
		
	def addForce(force as Vector3):
		_force_accum += force
	

	def FixedUpdate():
		# position update
		setAcceleration(_force_accum)
		setPosition(_position + _velocity * Time.deltaTime)
		setVelocity(_velocity * _damping + _acceleration * Time.deltaTime)
		transform.position = getPosition()
		_force_accum = Vector3(0, 0, 0)

	def getAABB():
		return _aabb


	def stopGravity():
		setAcceleration(Vector3(0, 0, 0))
		setVelocity(Vector3(0, 0, 0))

	def startGravity():
		setAcceleration(_g)
		

		

		
