import Algorithmic.Misc

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
			Log.Log("Movement for index $max_index: 1 ($(move_1.x), $(move_1.y), $(move_1.z)), 2 ($(move_2.x), $(move_2.y), $(move_2.z))")

			for i in range(len(contacts)):
				if contacts[i].getParticle1() == contacts[max_index].getParticle1():
					a = contacts[i].getPenetration()
					b = move_1
					c = contacts[i].getContactNormal()
					d = Vector3.Dot(move_1, contacts[i].getContactNormal())
					
					p = contacts[i].getPenetration() - Vector3.Dot(move_1, contacts[i].getContactNormal())
					Log.Log("Setting Penetration: $p")
					#print "Adjusting... $a, $b, $c, $d = $p"
					contacts[i].setPenetration(p)
					
				elif contacts[i].getParticle1() == contacts[max_index].getParticle2():
					p = contacts[i].getPenetration() - Vector3.Dot(move_2, contacts[i].getContactNormal())
					#print "Adjusting 2... $move_2, $p"
					contacts[i].setPenetration(p)

			_iterations_used += 1
				
