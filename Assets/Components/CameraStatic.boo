import UnityEngine

class CameraStatic (MonoBehaviour):
	#public look_at_mesh as GameObject

	#def _check_mesh () as IEnumerator:
		# voxel_mesh_data = mesh.GetComponent(VoxelMeshData)
		# while not voxel_mesh_data.IsInitialized():
		# 	yield
		# bounds = mesh.GetComponent(MeshFilter).mesh.bounds
		

	def Awake ():
		dist = (Settings.ChunkCount * Settings.ChunkSize) / 2
		t = gameObject.GetComponent(Transform)
		t.position = Vector3(dist, dist/2, dist) + Vector3(dist, dist, dist) * 2
		t.LookAt(Vector3(dist, dist, dist))
		#t.Rotate(Vector3(10,0,0))
		
		#StartCoroutine(_check_mesh())
			
	

