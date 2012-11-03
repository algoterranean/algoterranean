import UnityEngine

class CameraRotating (CameraStatic):
	def Update ():
		bounds = look_at_mesh.GetComponent(MeshFilter).mesh.bounds		
		t = gameObject.GetComponent(Transform)
		t.RotateAround(bounds.center, Vector3.up, 30 * Time.deltaTime)
