import UnityEngine
import System.Reflection
import System

class CameraStatic (MonoBehaviour):
	#public look_at_mesh as GameObject

	#def _check_mesh () as IEnumerator:
		# voxel_mesh_data = mesh.GetComponent(VoxelMeshData)
		# while not voxel_mesh_data.IsInitialized():
		# 	yield
		# bounds = mesh.GetComponent(MeshFilter).mesh.bounds
		

	def Awake ():
		# print out the version of mono being used
		m = Type.GetType("Mono.Runtime").GetMethod("GetDisplayName", BindingFlags.NonPublic | BindingFlags.Static) as MethodInfo
		print m.Invoke(null, null)

		
		dist = ((Settings.ChunkCountX + Settings.ChunkCountZ)/2 * Settings.ChunkSize) / 2
		t = gameObject.GetComponent(Transform)
		t.position = Vector3(dist, dist/2, dist) + Vector3(dist, dist, dist) * 2
		t.LookAt(Vector3(dist, dist, dist))
		#t.Rotate(Vector3(10,0,0))
		
		#StartCoroutine(_check_mesh())
			
	

