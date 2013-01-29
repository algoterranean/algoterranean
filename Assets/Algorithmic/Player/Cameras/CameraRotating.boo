import UnityEngine

class CameraRotating (CameraStatic):
	def Update ():
		#bounds = look_at_mesh.GetComponent(MeshFilter).mesh.bounds
		t = gameObject.GetComponent(Transform)
		dist = (Settings.ChunkSize * (Settings.ChunkCountA + Settings.ChunkCountB)/2) / 2
		#dist = 0
		t.RotateAround(Vector3(dist, dist/2, dist) + Vector3(dist, dist, dist) * 2, Vector3.up, 30 * Time.deltaTime)
		

		if Input.GetKey("escape"):
			Application.Quit()		

