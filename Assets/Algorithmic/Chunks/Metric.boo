"""Metric is a distance function that, given two chunk coordinates,
will determine whether they are "close enough" or "too far". This is used
for the loading and unloading of chunks by the DataManager."""
namespace Algorithmic.Chunks

import System.Collections.Generic


class Metric ():
	
	max_distance as single

	
	def constructor(max_distance as single):
		self.max_distance = max_distance

	def tooFar(origin_coords as WorldBlockCoordinate, chunk_coords as WorldBlockCoordinate):
		#Math.Abs(origin_coords.y - chunk_coords.y) > max_distance or \		
		if Math.Abs(origin_coords.x - chunk_coords.x) > max_distance or \
			Math.Abs(origin_coords.y - chunk_coords.y) > (Settings.ChunkSize * Settings.MaxChunksVertical) or \
			Math.Abs(origin_coords.z - chunk_coords.z) > max_distance:
			return true
		return false

	# def closeEnough(origin_coords as WorldBlockCoordinate, chunk_coords as WorldBlockCoordinate):


class ChunkMetric:
	origin as Vector3
	size as byte
	max_x as int # distance in the number of chunks from origin
	max_y as int
	max_z as int

	def constructor(o as Vector3, s as byte,
					_max_x as byte, _max_y as byte, _max_z as byte):
		origin = o
		size = s
		max_x = _max_x cast int
		max_y = _max_y cast int
		max_z = _max_z cast int

	def getChunksInRange() as List[of WorldBlockCoordinate]:
		l = List[of WorldBlockCoordinate]()
		for x in range(-max_x, max_x+1):
			for y in range(-max_y, max_y+1):
				for z in range(-max_z, max_z+1):
					a as long = (origin.x + x * size)/size
					b as long = (origin.y + y * size)/size
					c as long = (origin.z + z * size)/size
					l.Add(WorldBlockCoordinate(a * size, b * size, c * size))
		return l

	def getOrderedChunksInRange() as List[of WorldBlockCoordinate]:
		l = List[of WorldBlockCoordinate]()
		for x in range(-max_x, max_x+1):
			for y in range(-max_y, max_y+1):
				for z in range(-max_z, max_z+1):
					c = WorldBlockCoordinate(x,  y, z)
					l.Add(c)
		l.Sort()
		return l
		

	def isChunkTooFar(c as WorldBlockCoordinate) as bool:
		if Math.Abs(c.x - origin.x)/size > max_x or \
			Math.Abs(c.y - origin.y)/size > max_y or \
			Math.Abs(c.z - origin.z)/size > max_z:
			return true
		return false

	Origin as Vector3:
		set:
			origin = value


		
