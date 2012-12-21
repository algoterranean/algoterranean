import UnityEngine
#import System.Reflection
import System

class CameraStatic (MonoBehaviour):
	_origin = Vector3(0, 0, 0)

	def Awake ():
		pass
		
	def Update ():
		dist = ((Settings.ChunkCountA + Settings.ChunkCountB)/2 * Settings.ChunkSize) / 2
		t = gameObject.GetComponent(Transform)
		t.position = Vector3(dist, dist/2, dist) + Vector3(dist, dist, dist) * 2
		t.LookAt(_origin)
		
		v = gameObject.Find("ChunkManager").GetComponent("ChunkManager") as ChunkManager
		v.setOrigin(_origin)
		_origin = Vector3(_origin.x+0.1, _origin.y, _origin.z)


			
	

