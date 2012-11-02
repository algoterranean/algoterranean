import UnityEngine

class CameraStatic (MonoBehaviour):
	public look_at_mesh as GameObject

	def _check_mesh (mesh as GameObject) as IEnumerator:
		voxel_mesh_data = mesh.GetComponent(VoxelMeshData)
		while not voxel_mesh_data.IsInitialized():
			yield
		bounds = mesh.GetComponent(MeshFilter).mesh.bounds
		t = gameObject.GetComponent(Transform)
		t.position = bounds.center + bounds.extents * 2
		t.LookAt(bounds.center)
		

	def Awake ():
		if look_at_mesh is not null:
			StartCoroutine(_check_mesh(look_at_mesh))
	

