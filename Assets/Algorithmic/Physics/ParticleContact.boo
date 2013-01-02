

class ParticleContact:
	_particle_1 as IParticle
	_particle_2 as IParticle
	_restitution as single
	_contact_normal as Vector3
	_penetration as single
	
	def constructor(p1 as IParticle, p2 as IParticle, restitution as single, contact_normal as Vector3, penetration as single):
		_particle_1 = p1
		_particle_2 = p2
		_restitution = restitution
		_contact_normal = contact_normal
		_penetration = penetration

	def getPenetration():
		return _penetration

	def resolve(duration as single):
		resolveVelocity(duration)
		#resolveInterpenetration(duration)

	def calculateSeparatingVelocity() as single:
		relativeVelocity = _particle_1.getVelocity()
		if _particle_2 != null:
			relativeVelocity -= _particle_2.getVelocity()
		return Vector3.Dot(relativeVelocity, _contact_normal)
			

	def resolveVelocity(duration as single):
		separatingVelocity = calculateSeparatingVelocity()
		if separatingVelocity > 0:
			return
		newSepVelocity = -separatingVelocity * _restitution

		### part for resting
		accCausedVelocity = _particle_1.getAcceleration()
		if _particle_2:
			accCausedVelocity -= _particle_2.getAcceleration()
		accCausedSepVelocity = Vector3.Dot(accCausedVelocity, _contact_normal) * duration

		if (accCausedSepVelocity < 0):
			newSepVelocity += _restitution * accCausedSepVelocity
			if (newSepVelocity < 0):
				newSepVelocity = 0
		deltaVelocity = newSepVelocity - separatingVelocity				
		### end part for resting


		totalInverseMass = _particle_1.getInverseMass()
		#if _particle_2:
		#	totalInverseMass += _particle_2.getInverseMass()
		#if totalInverseMass <= 0:
		#	return
		impulse = deltaVelocity / totalInverseMass
		impulsePerIMass = _contact_normal * impulse

		_particle_1.setVelocity(_particle_1.getVelocity() + impulsePerIMass * _particle_1.getInverseMass())

		#if _particle_2:
		#	_particle_2.setVelocity(_particle_2.getVelocity() + impulsePerIMass * -_particle_2.getInverseMass())

	def resolveInterpenetration(duration as single):
		if _penetration <= 0:
			return
		totalInverseMass = _particle_1.getInverseMass()
		if _particle_2:
			totalInverseMass += _particle_2.getInverseMass()
		#if totalInverseMass <= 0:
		#	return

		movePerIMass = _contact_normal * (_penetration / totalInverseMass)
		particle_movement_1 = movePerIMass * _particle_1.getInverseMass()
		if _particle_2:
			particle_movement_2 = movePerIMass * -_particle_2.getInverseMass()
		else:
			particle_movement_2 = Vector3(0, 0, 0)

		_particle_1.setPosition(_particle_1.getPosition() + particle_movement_1)
		#if _particle_2:
		#	_particle_2.setPosition(_particle_2.getPosition() + particle_movement_2)
			

	
