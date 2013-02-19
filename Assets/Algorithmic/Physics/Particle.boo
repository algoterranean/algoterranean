namespace Algorithmic

class Particle (IParticle, MonoBehaviour):
	# position as Vector3
	# velocity as Vector3
	# acceleration as Vector3
	# mass as single # 80kg
	#inverse_mass as single
	#damping = 0.99	
	
	force_accum as Vector3


	[Property(Position)]
	position as Vector3
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
		position += velocity * duration
		acceleration += force_accum * inverse_mass
		velocity += acceleration * duration
		
		velocity *= Math.Pow(damping, duration)
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
		

