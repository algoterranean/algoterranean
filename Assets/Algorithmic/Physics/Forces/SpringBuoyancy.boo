

class SpringBuoyancy (IForceGenerator):
	_max_depth as single
	_volume as single
	_water_height as single
	_density as single
	
	def constructor(maxDepth as single, volume as single, waterHeight as single, density as single):
		_max_depth = maxDepth
		_volume = volume
		_water_height = waterHeight
		_density = density
		
	def updateForce(particle as IParticle, duration as single):
		depth = particle.Position.y
		if (depth >= _water_height + _max_depth):
			return
		
		force = Vector3(0, 0, 0)
		if (depth <= _water_height - _max_depth):
			force.y = _density * _volume
			particle.addForce(force)
			return

		force.y = _density * _volume * (depth - _max_depth - _water_height) / 2 * _max_depth
		particle.addForce(force)
		
