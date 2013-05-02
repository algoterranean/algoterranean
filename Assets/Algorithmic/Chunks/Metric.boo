"""Metric is a distance function that, given two chunk coordinates,
will determine whether they are "close enough" or "too far". This is used
for the loading and unloading of chunks by the DataManager."""
namespace Algorithmic.Chunks


class Metric ():
	
	max_distance as single

	
	def constructor(max_distance as single):
		self.max_distance = max_distance

	def tooFar(origin_coords as LongVector3, chunk_coords as LongVector3):
		#Math.Abs(origin_coords.y - chunk_coords.y) > (Settings.ChunkSize * Settings.MaxChunksVertical)		
		if Math.Abs(origin_coords.x - chunk_coords.x) > max_distance or \
			Math.Abs(origin_coords.y - chunk_coords.y) > max_distance or \
			Math.Abs(origin_coords.z - chunk_coords.z) > max_distance:
			return true
		return false

	# def closeEnough(origin_coords as LongVector3, chunk_coords as LongVector3):
		
		
