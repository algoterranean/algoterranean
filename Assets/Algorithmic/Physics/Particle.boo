namespace Algorithmic

class Particle (IParticle, MonoBehaviour):
	_position as Vector3
	_velocity as Vector3
	_acceleration as Vector3
	public _mass as single # 80kg
	_inverse_mass as single
	_force_accum as Vector3
	_damping = 0.99
	
	def getPosition():
		return _position
	def getVelocity():
		return _velocity
	def getAcceleration():
		return _acceleration
	def getMass():
		return _mass
	def getInverseMass():
		return _inverse_mass
	def setPosition(p as Vector3):
		_position = p
	def setVelocity(v as Vector3):
		_velocity = v
	def setAcceleration(a as Vector3):
		_acceleration = a
	def addForce(force as Vector3):
		_force_accum += force


	def integrate(duration as single):
		if _inverse_mass <= 0:
			return
		_position += _velocity * duration
		_acceleration += _force_accum * _inverse_mass
		_velocity += _acceleration * duration
		
		_velocity *= Math.Pow(_damping, duration)
		_force_accum = Vector3(0, 0, 0)
		transform.position = _position


	def Start():
		_position = transform.position
		_velocity = Vector3(0, 0, 0)
		_acceleration = Vector3(0, 0, 0)
		_force_accum = Vector3(0, 0, 0)
		if _mass >= 0:
			_inverse_mass = 1/_mass
		else:
			_inverse_mass = 0.0
		
	#def FixedUpdate():
	#	integrate(Time.deltaTime)

