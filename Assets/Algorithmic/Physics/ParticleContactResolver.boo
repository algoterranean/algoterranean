
class ParticleContactResolver:
	_iterations as int
	_iterations_used as int


	def constructor(iterations as int):
		setIterations(iterations)
		_iterations_used = 0

	def setIterations(iterations as int):
		_iterations = iterations

	def resolveContacts(contacts as List[of ParticleContact], duration as single):

		_iterations_used = 0
		while _iterations_used < _iterations:
			max as single = 99999999999999999 #REAL_MAX
			max_index = len(contacts)
			for i in range(len(contacts)):
				sepVel = contacts[i].calculateSeparatingVelocity()
				if sepVel < max and (sepVel < 0 or contacts[i].getPenetration() > 0):
					max = sepVel
					max_index = i
			if max_index == len(contacts):
				break

			contacts[max_index].resolve(duration)
			move_1 = contacts[max_index].getMovement1()
			move_2 = contacts[max_index].getMovement2()
			for i in range(len(contacts)):
				if contacts[i].getParticle1() == contacts[max_index].getParticle1():
					contacts[i].setPenetration(contacts[i].getPenetration() - Vector3.Dot(move_1, contacts[i].getContactNormal()))
				elif contacts[i].getParticle1() == contacts[max_index].getParticle2():
					contacts[i].setPenetration(contacts[i].getPenetration() - Vector3.Dot(move_2, contacts[i].getContactNormal()))
								   
			
			_iterations_used += 1
				
