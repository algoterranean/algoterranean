namespace Algorithmic

import UnityEngine
#import System.Threading
#import System.Collections
#import Amib.Threading


# class ChunkManager (MonoBehaviour):
# 	origin as Vector3
# 	chunk_ball = ChunkBall()
# 	_locker = object()
# 	_observers = []
# 	#_thread_manager = ThreadManager(10)
# 	#_thread_pool = SmartThreadPool()
	
	
# 	new_chunk_queue = []
# 	noise_calculated_queue = []
# 	mesh_calculated_queue = []
# 	chunk_removal_queue = []
# 	completed_chunk_count = 0
# 	initial_chunks_complete = false


# 	def NoiseWorker(chunk as Chunk) as WaitCallback:
# 		try:
# 			#Thread.CurrentThread.Priority = System.Threading.ThreadPriority.Lowest
# 			chunk.CalculateNoise()
# 			coord = chunk.getCoordinates()
# 		except e:
# 			print "WHOOPS WE HAVE AN ERROR IN NOISE: " + e
# 		lock _locker:
# 			noise_calculated_queue.Push(chunk)

# 	def MeshWorker(chunk as Chunk) as WaitCallback:
# 		try:
# 			#Thread.CurrentThread.Priority = System.Threading.ThreadPriority.Lowest			
# 			chunk.CalculateMesh()
# 		except e:
# 			print "WHOOPS WE HAVE AN ERROR IN MESH: " + e
# 		lock _locker:
# 			mesh_calculated_queue.Push(chunk)
		

# 	def Awake ():
# 		origin = Vector3(0,0,0)
# 		o = GameObject()
# 		o.name = "Terrain Parent"
# 		initial_chunks_complete = true
# 		#ThreadPool.SetMaxThreads(8, 50)
# 		#Application.targetFrameRate = 30
		

# 	def areInitialChunksComplete() as bool:
# 		return initial_chunks_complete

# 	def _which_chunk(x as double, z as double, y as double) as List:
# 		x_pos = System.Math.Floor(x / Settings.ChunkSize)
# 		z_pos = System.Math.Floor(z / Settings.ChunkSize)
# 		y_pos = System.Math.Floor(y / Settings.ChunkSize)
# 		return [x_pos * Settings.ChunkSize, z_pos * Settings.ChunkSize,  y_pos * Settings.ChunkSize]

# 	def getOrigin() as Vector3:
# 		return origin
		

# 	def setOrigin(x_pos as double, z_pos as double, y_pos as double) as void:
# 		origin = Vector3(x_pos,z_pos, y_pos)
# 		chunks_to_remove = []
# 		chunk_ball.calculateDistance(x_pos, z_pos, y_pos)


# 		x = x_pos - Settings.MinChunkDistance + Settings.ChunkSize/2.0
# 		z = z_pos - Settings.MinChunkDistance + Settings.ChunkSize/2.0
# 		y = y_pos - Settings.MinChunkDistance + Settings.ChunkSize/2.0
# 		total_chunks = 0

# 		while x <= x_pos + Settings.MinChunkDistance:
# 			while z <= z_pos + Settings.MinChunkDistance:
# 				while y <= y_pos + Settings.MinChunkDistance:
					
# 					chunk_coord = _which_chunk(x cast double, z cast double, y cast double)
# 					if not chunk_ball.Contains(chunk_coord[0], chunk_coord[1], chunk_coord[2]):
# 						d_x = chunk_coord[0] cast long - x_pos
# 						d_z = chunk_coord[1] cast long - z_pos
# 						d_y = chunk_coord[2] cast long - y_pos
# 						distance = Math.Sqrt(d_x*d_x + d_z*d_z + d_y*d_y)
						
# 						if distance <= Settings.MinChunkDistance:
# 							chunk = Chunk(chunk_coord[0], chunk_coord[1], chunk_coord[2],
# 									  Settings.ChunkSize, Settings.ChunkSize, Settings.ChunkSize)
# 							chunk.setDistance(x_pos, z_pos, y_pos)
# 							chunk_ball.Set(chunk_coord[0], chunk_coord[1], chunk_coord[2], chunk)
# 							new_chunk_queue.Push(chunk)
							
# 							total_chunks += 1
# 					y += Settings.ChunkSize
# 				z += Settings.ChunkSize
# 				y = y_pos - Settings.MinChunkDistance + Settings.ChunkSize/2.0
# 			x += Settings.ChunkSize
# 			y = y_pos - Settings.MinChunkDistance + Settings.ChunkSize/2.0
# 			z = z_pos - Settings.MinChunkDistance + Settings.ChunkSize/2.0

# 		# sort the new chunks so the closest one gets created first
# 		new_chunk_queue.Sort() do (left as Chunk, right as Chunk):
# 			return right.getDistanceSkewHeight() - left.getDistanceSkewHeight()
		
# 		chunk_removal_queue.Extend(chunk_ball.cullChunks()) # should this remove from the queue as well?
		
# 		#print "TO REMOVE: $chunk_removal_queue"
# 		chunk_ball.updateNeighbors()
# 		print "setOrigin: TOTAL CHUNKS: $total_chunks"

		

# 	def _create_mesh(chunk as Chunk): #as IEnumerable:
# 		# display a mesh if the mesh was calculated on a chunk
# 		if chunk != null:
# 			coords = chunk.getCoordinates()

# 			if chunk.getDistance() <= Settings.MinChunkDistance:
# 				chunk_name = "Chunk ($(coords[0]), $(coords[1]), $(coords[2]))"
# 				if gameObject.Find(chunk_name) == null:
# 					o = GameObject()
# 					o.name = chunk_name
# 					#o.transform.parent = gameObject.Find("Terrain Parent").transform
# 					o.AddComponent(MeshFilter)
# 					o.AddComponent(MeshRenderer)
# 					o.AddComponent(MeshCollider)
# 					mesh = Mesh()
# 					mesh.vertices = chunk.vertices
# 					mesh.triangles = chunk.triangles
# 					mesh.normals = chunk.normals
# 					mesh.uv = chunk.uvs
# 					#mesh.RecalculateNormals()
# 					o.GetComponent(MeshRenderer).material = Resources.Load("Materials/Measure") as Material
# 					o.GetComponent(MeshFilter).sharedMesh = mesh
# 					#o.GetComponent(MeshCollider).sharedMesh = mesh
# 					o.transform.position = Vector3(coords[0], coords[2], coords[1])
# 				else:
# 					o = gameObject.Find(chunk_name)
# 					mesh = Mesh()
# 					mesh.vertices = chunk.vertices
# 					mesh.triangles = chunk.triangles
# 					mesh.uv = chunk.uvs
# 					mesh.normals = chunk.normals
# 					#mesh.RecalculateNormals()
# 					o.GetComponent(MeshFilter).sharedMesh = mesh
# 					#o.GetComponent(MeshCollider).sharedMesh = mesh
# 				completed_chunk_count += 1
			

# 	def Update():
# 		lock _locker:
# 			# calculate the noise for a chunk if it's new
# 			if len(new_chunk_queue) > 0:
# 				chunk = new_chunk_queue.Pop()
# 				#_thread_pool.QueueWorkItem(NoiseWorker, chunk)
# 				ThreadPool.QueueUserWorkItem(NoiseWorker, chunk)
			
# 			# calculate a mesh if the noise has been completed on a chunk
# 			not_ready = []
# 			#if len(noise_calculated_queue) > 0:
# 			#	chunk = noise_calculated_queue.Pop()


# 			found_chunk = null
# 			for chunk as Chunk in noise_calculated_queue:
# 				if chunk.areNeighborsReady():
# 					#_thread_pool.QueueWorkItem(MeshWorker, chunk)
# 					ThreadPool.QueueUserWorkItem(MeshWorker, chunk)
# 					found_chunk = chunk
# 					break
# 			if found_chunk != null:
# 				noise_calculated_queue.Remove(found_chunk)
				

# 			if len(mesh_calculated_queue) > 0:
# 				chunk = mesh_calculated_queue.Pop()
# 			else:
# 				chunk = null
				
# 		_create_mesh(chunk)
		
# 		if len(chunk_removal_queue) > 0:
# 			c as Chunk = chunk_removal_queue.Pop()
# 			coords = c.getCoordinates()
# 			o = gameObject.Find("Chunk ($(coords[0]), $(coords[1]), $(coords[2]))")
# 			print "Removing Chunk ($(coords[0]), $(coords[1]), $(coords[2])): $o"
# 			gameObject.Destroy(o)




class ChunkManager (MonoBehaviour, IObserver):
    _chunk_ball as ChunkBall
    _add_mesh_queue = []
    _remove_mesh_queue = []


    def updateObserver(o as object):
        if o isa ChunkBallMessage:
            cm = o cast ChunkBallMessage
            message = cm.getMessage()
            chunk_info as ChunkInfo = cm.getData()
            chunk_blocks as IChunkBlockData = chunk_info.getChunk()
            #chunk_mesh as IChunkMeshData = chunk_info.getMesh()
            coords = chunk_blocks.getCoordinates()

            print "ChunkManager: Receiving ChunkBall Update: $message ($(coords.x), $(coords.y), $(coords.z))"
            if message == Message.MESH_READY:
                _add_mesh_queue.Push(chunk_info)
            elif message == Message.REMOVE:
                _remove_mesh_queue.Push(chunk_info)

    def Awake():
        _chunk_ball = ChunkBall(Settings.ChunkWidth, Settings.ChunkDepth, Settings.ChunkSize)
        _chunk_ball.registerObserver(self)

    def Update():
        chunk_info as ChunkInfo
        _chunk_ball.Update()
        if len(_add_mesh_queue) > 0:
            chunk_info = _add_mesh_queue.Pop()
            _create_mesh_object(chunk_info)

        if len(_remove_mesh_queue) > 0:
            chunk_info = _remove_mesh_queue.Pop()
            _remove_mesh_object(chunk_info)
                
	
    def areInitialChunksComplete() as bool:
        pass

    def setOrigin(origin as Vector3) as void:
        #print "ChunkManager: Setting Origin"
        #_chunk_ball.getMaxChunkDistance()
        _chunk_ball.SetOrigin(origin)

    def _remove_mesh_object(chunk_info as ChunkInfo):
        chunk_blocks as ChunkBlockData = chunk_info.getChunk()
        coords = chunk_blocks.getCoordinates()
        o = gameObject.Find("Chunk ($(coords.x), $(coords.y), $(coords.z))")
        if o != null:
            gameObject.Destroy(o)

    def _create_mesh_object(chunk_info as ChunkInfo):
        chunk_blocks as ChunkBlockData = chunk_info.getChunk()
        chunk_mesh as ChunkMeshData = chunk_info.getMesh()
        coords = chunk_blocks.getCoordinates()

        o = GameObject()
        o.name = "Chunk ($(coords.x), $(coords.y), $(coords.z))"
        #o.transform.parent = gameObject.Find("Terrain Parent").transform
        o.AddComponent(MeshFilter)
        o.AddComponent(MeshRenderer)
        o.AddComponent(MeshCollider)
        mesh = Mesh()
        mesh.vertices = chunk_mesh.getVertices()
        mesh.triangles = chunk_mesh.getTriangles()
        mesh.normals = chunk_mesh.getNormals()
        mesh.uv = chunk_mesh.getUVs()
        #mesh.RecalculateNormals()
        o.GetComponent(MeshRenderer).material = Resources.Load("Materials/Measure") as Material
        o.GetComponent(MeshFilter).sharedMesh = mesh
        #o.GetComponent(MeshCollider).sharedMesh = mesh

        o.transform.position = Vector3(coords.x, coords.y, coords.z)
        #o.transform.position = Vector3(coords.x, coords.y, coords.z + Settings.ChunkSize)
        #o.transform.eulerAngles = Vector3(270, 0, 0)


        
        #o.transform.eulerAngles = Vector3(90, 0, 0)


