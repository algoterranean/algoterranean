

class ParticleContact:
	_particle_1 as IParticle
	_particle_2 as IParticle
	_restitution as single
	_contact_normal as Vector3
	_penetration as single
	_particle_movement_1 as Vector3
	_particle_movement_2 as Vector3
	
	def constructor(p1 as IParticle, p2 as IParticle, restitution as single, contact_normal as Vector3, penetration as single):
		_particle_1 = p1
		_particle_2 = p2
		_restitution = restitution
		_contact_normal = contact_normal
		_penetration = penetration
		_particle_movement_1 = Vector3(0, 0, 0)
		_particle_movement_2 = Vector3(0, 0, 0)



	def getParticle1() as IParticle:
		return _particle_1
	def getParticle2() as IParticle:
		return _particle_2

	def getMovement1() as Vector3:
		return _particle_movement_1
	def getMovement2() as Vector3:
		return _particle_movement_2

	def getPenetration() as single:
		return _penetration
	def setPenetration(penetration as single):
		_penetration = penetration

	def getContactNormal() as Vector3:
		return _contact_normal

	def resolve(duration as single):
		resolveVelocity(duration)
		resolveInterpenetration(duration)

	def calculateSeparatingVelocity() as single:
		relativeVelocity = _particle_1.getVelocity()
		if _particle_2 != null:
			relativeVelocity -= _particle_2.getVelocity()
		return Vector3.Dot(relativeVelocity, _contact_normal)
			

	def resolveVelocity(duration as single):
		separatingVelocity = calculateSeparatingVelocity()
		if separatingVelocity > 0:
			return
		
		#print "1: SEP VELOCITY: $separatingVelocity"
		newSepVelocity = -separatingVelocity * _restitution
		#newSepVelocity = 0 #(-1) * separatingVelocity * _restitution
		#print "2: NEW SEP VELOCITY: $newSepVelocity"

		### part for resting
		accCausedVelocity = _particle_1.getAcceleration()
		#print "3: ACTUAL CAUSED VELOCITY: $accCausedVelocity"
		if _particle_2 != null:
			accCausedVelocity -= _particle_2.getAcceleration()
		accCausedSepVelocity = Vector3.Dot(accCausedVelocity, _contact_normal) * duration
		#print "4: ACTUAL CAUSE SEP VELOCITY: $accCausedSepVelocity"

		if (accCausedSepVelocity < 0):
			newSepVelocity += accCausedSepVelocity * _restitution
			#print "5: NEW SEP VELOCITY: $newSepVelocity"
			if (newSepVelocity < 0):
				newSepVelocity = 0
		deltaVelocity = newSepVelocity - separatingVelocity
		#print "6: DELTA VELOCITY: $deltaVelocity"
		### end part for resting
		#print "VELOCITY: $accCausedSepVelocity, $newSepVelocity, $separatingVelocity"

		totalInverseMass = 1.0 / _particle_1.getInverseMass()
		if _particle_2 != null:
			totalInverseMass += 1.0 / _particle_2.getInverseMass()
		totalInverseMass = 1.0 / totalInverseMass
		if totalInverseMass <= 0:
			return
		impulse = deltaVelocity / totalInverseMass
		impulsePerIMass = _contact_normal * impulse
		#print "7: IMPULSE PER MASS: $impulsePerIMass"

		_particle_1.setVelocity(_particle_1.getVelocity() + impulsePerIMass * _particle_1.getInverseMass())
		#print "8: FINAL VELOCITY: $(_particle_1.getVelocity() + impulsePerIMass * _particle_1.getInverseMass())"

		if _particle_2 != null:
			_particle_2.setVelocity(_particle_2.getVelocity() + impulsePerIMass * -_particle_2.getInverseMass())

	def resolveInterpenetration(duration as single):
		if _penetration <= 0:
			return
		totalInverseMass = 1.0 / _particle_1.getInverseMass()
		if _particle_2 != null:
			totalInverseMass += 1.0 / _particle_2.getInverseMass()
		totalInverseMass = 1.0 / totalInverseMass
		if totalInverseMass <= 0:
			return

		movePerIMass = _contact_normal * (_penetration / totalInverseMass)
		#print "movePerIMass: $movePerIMass"
		_particle_movement_1 = movePerIMass * _particle_1.getInverseMass()
		#print "particle_movement_1: $_particle_movement_1"
		if _particle_2 != null:
			_particle_movement_2 = movePerIMass * -_particle_2.getInverseMass()
		else:
			_particle_movement_2 = Vector3(0, 0, 0)

		_particle_1.setPosition(_particle_1.getPosition() + _particle_movement_1)
		#print "INTERPENETRATION: $_particle_movement_1, $movePerIMass"
		
		if _particle_2 != null:
			_particle_2.setPosition(_particle_2.getPosition() + _particle_movement_2)
			

	
