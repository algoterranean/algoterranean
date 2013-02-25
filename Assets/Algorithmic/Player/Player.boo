namespace Algorithmic.Player

import UnityEngine
import Algorithmic.Terrain


class Player (MonoBehaviour):
	# IParticle stuff
	#_g as Vector3 = Vector3(0, -9.8, 0)
	# _position as Vector3
	# _velocity as Vector3
	# _acceleration as Vector3
	# _damping as single = 0.99
	# _inverse_mass as single
	# _mass as single
	# _force_accum as Vector3
	
	# Player Stuff
	_origin as Vector3
	_aabb as AABB
	_chunk_manager as ChunkManager
	initial_startup as bool = false

	def initialize():
		pass


	# def integrate(duration as single):
	# 	if _inverse_mass <= 0:
	# 		return
	# 	_position += _velocity * duration
	# 	_acceleration += _force_accum * _inverse_mass
	# 	_velocity += _acceleration * duration
		
	# 	_velocity *= Math.Pow(_damping, duration)
	# 	_force_accum = Vector3(0, 0, 0)

	# def update_position():
	# 	transform.position = _position

	# def fake_integrate(duration as single):
	# 	if _inverse_mass <= 0:
	# 		return
	# 	p = _position + _velocity * duration
	# 	a = _acceleration + _force_accum * _inverse_mass
	# 	v = _velocity + _acceleration * duration
	# 	v *= Math.Pow(_damping, duration)
	# 	return [p, v, a]
	
	def Start ():
		# setPosition(transform.position)
		# setVelocity(Vector3(0, 0, 0))
		# setAcceleration(_g)
		# _mass = 80.0
		# _inverse_mass = 1.0/_mass
		# _force_accum = Vector3(0, 0, 0)
		
		_chunk_manager = gameObject.Find("ChunkManager").GetComponent("ChunkManager") as ChunkManager
		_origin = transform.position
		_aabb = AABB(transform.position, Vector3(0.5, 0.5, 0.5))


	def FixedUpdate ():
		_aabb = AABB(transform.position, Vector3(0.5, 0.5, 0.5))
		_origin = transform.position
		if _chunk_manager.isInitialized() and not initial_startup:
			initial_startup = true
			#print 'CHUNK MANAGER IS INITIALIZED'
		# elif _chunk_manager.isInitialized():
		# 	_chunk_manager.setOrigin(_origin)
	
	# def getPosition() as Vector3:
	# 	return _position
	# def getVelocity() as Vector3:
	# 	return _velocity
	# def getAcceleration() as Vector3:
	# 	return _acceleration
	# def getMass() as single:
	# 	return _mass
	# def getInverseMass() as single:
	# 	return _inverse_mass
	# def setPosition(p as Vector3):
	# 	_position = p
	# 	#transform.position = _position
	# def setVelocity(v as Vector3):
	# 	_velocity = v
	# def setAcceleration(a as Vector3):
	# 	_acceleration = a
		
	# def addForce(force as Vector3):
	# 	_force_accum += force
	

	# def FixedUpdate():
	# 	setPosition(_position + _velocity * Time.deltaTime)
	# 	resulting_acc = _acceleration + _force_accum * _inverse_mass
	# 	setVelocity(_velocity + resulting_acc * Time.deltaTime)     
	# 	setVelocity(_velocity * Math.Pow(_damping, Time.deltaTime)) # damping/drag
		
	# 	transform.position = getPosition()
	# 	_force_accum = Vector3(0, 0, 0)

	def getAABB():
		return _aabb

	def getAABBPlusOne():
		return _aabb

	# def stopGravity():
	# 	setAcceleration(Vector3(0, 0, 0))
	# 	setVelocity(Vector3(0, 0, 0))

	# def startGravity():
	# 	setAcceleration(_g)
		

		

		
