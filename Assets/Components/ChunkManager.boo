import UnityEngine

class ChunkManager (MonoBehaviour):
	chunks as (GameObject, 2)

	def Awake ():
		chunks = matrix(GameObject, 10, 10)

