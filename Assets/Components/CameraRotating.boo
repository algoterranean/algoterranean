import UnityEngine

class CameraRotating (CameraStatic):
	def Update ():
		#bounds = look_at_mesh.GetComponent(MeshFilter).mesh.bounds
		t = gameObject.GetComponent(Transform)
		dist = (Settings.ChunkSize * Settings.ChunkCount) / 2
		t.RotateAround(Vector3(dist, dist, dist), Vector3.up, 30 * Time.deltaTime)

		if Input.GetKey("escape"):
			Application.Quit()		

