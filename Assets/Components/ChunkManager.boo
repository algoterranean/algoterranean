import UnityEngine

class ChunkManager (MonoBehaviour, IObserver, IObservable):
	chunks as (GameObject, 3)
	_observers = []

	def Subscribe(obj as IObserver):
		if obj not in _observers:
			_observers.Add(obj)

	def Unsubscribe(obj as IObserver):
		if obj in _observers:
			_observers.Remove(obj)

	def OnData(obj as IObservable):
		pass

	def AddChunk(x as int, z as int, y as int):
		pass
	

	def Awake ():
		chunks = matrix(GameObject, Settings.ChunkCount, Settings.ChunkCount, Settings.ChunkCount)
		terrain_parent = GameObject("Chunks")
		
		for x in range(Settings.ChunkCount):
			for z in range(Settings.ChunkCount):
				for y in range(Settings.ChunkCount):
					obj = GameObject("Chunk ($x, $z, $y)")
					obj.active = false
					
					obj.AddComponent(MeshFilter)
					obj.AddComponent(MeshCollider)					
					obj.AddComponent(MeshRenderer)
					r = obj.GetComponent(MeshRenderer)
					r.material = Resources.Load("Materials/Measure")
					
					obj.AddComponent(VoxelNoiseData)
					obj.AddComponent(VoxelData)
					d = obj.GetComponent(VoxelData)
					d.x_offset = x * Settings.ChunkSize
					d.z_offset = z * Settings.ChunkSize
					d.y_offset = y * Settings.ChunkSize
					obj.AddComponent(VoxelMeshData)
					
					t = obj.GetComponent(Transform)
					t.parent = terrain_parent.transform
					t.position = Vector3(d.x_offset, d.y_offset, d.z_offset)
					chunks[x, z, y] = obj
					
					
		for x in range(Settings.ChunkCount):
			for z in range(Settings.ChunkCount):
				for y in range(Settings.ChunkCount):
					obj = chunks[x, z, y]
					data = obj.GetComponent(VoxelData)
					if z == 0:
						south = null
					else:
						south = chunks[x, z-1, y]
					if z == Settings.ChunkCount - 1:
						north = null
					else:
						north = chunks[x, z+1, y]
					if x == Settings.ChunkCount - 1:
						east = null
					else:
						east = chunks[x+1, z, y]
					if x == 0:
						west = null
					else:
						west = chunks[x-1, z, y]
					if y == 0:
						down = null
					else:
						down = chunks[x,z,y-1]
					if y == Settings.ChunkCount - 1:
						up = null
					else:
						up = chunks[x, z, y+1]
						
					data.SetNeighboringChunks(west, east, north, south, up, down)
					obj.active = true
					
