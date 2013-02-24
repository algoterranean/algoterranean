namespace Algorithmic

import Algorithmic.Misc

class Particle (IParticle, MonoBehaviour):
	# position as Vector3
	# velocity as Vector3
	# acceleration as Vector3
	# mass as single # 80kg
	#inverse_mass as single
	#damping = 0.99
	
	force_accum as Vector3
	position as Vector3
	last_position as Vector3

	LastPosition as Vector3:
		get:
			return last_position

	Position as Vector3:
		get:
			return position
		set:
			last_position = position
			position = value

	# [Property(Position)]
	# position as Vector3
	
	[Property(Velocity)]
	velocity as Vector3
	
	[Property(Acceleration)]
	acceleration as Vector3
	
	[Property(Mass)]
	mass as single = 80
	
	[Property(InverseMass)]
	inverse_mass as single
	
	[Property(Damping)]
	damping as single = 0.99
	

	def addForce(force as Vector3):
		force_accum += force

	def integrate(duration as single):
		if inverse_mass <= 0:
			return
		last_position = position
		position += velocity * duration
		acceleration += force_accum * inverse_mass
		velocity += acceleration * duration
		
		velocity *= Math.Pow(damping, duration)
		Log.Log("Particle: Pos $(position), Accel $(acceleration), Vel $(velocity)")

		force_accum = Vector3(0, 0, 0)

	def update_position():
		transform.position = position

	def Start():
		position = transform.position
		velocity = Vector3(0, 0, 0)
		acceleration = Vector3(0, 0, 0)
		force_accum = Vector3(0, 0, 0)
		if mass >= 0:
			inverse_mass = 1/mass
		else:
			inverse_mass = 0.0
		

