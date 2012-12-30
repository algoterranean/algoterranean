namespace Algorithmic

import UnityEngine
#import System.Threading
#import System.Collections
#import Amib.Threading


class ChunkManager (MonoBehaviour, IObserver):
    _origin as Vector3
    _chunk_ball as ChunkBall
    _add_mesh_queue = []
    _remove_mesh_queue = []
    _mesh_cleanup_queue = []

    _initialized as bool = false
    _wait_for_init_queue = []


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

    def Start():
        # intialize world
        setOrigin(Vector3(0, 0, 0))
        _wait_for_init_queue.Push(LongVector3(0, 0, 0))
        
        # for x in range(Settings.ChunkHeight):
        #     _wait_for_init_queue.Push(Vector3(0, Settings.ChunkSize*x, 0))
        #_player = gameObject.Find("First Person Controller").GetComponent("Player")
        

    def Update():
        chunk_info as ChunkInfo
        _chunk_ball.Update()
        # check if all the needed chunks in initial load are completed
        if len(_wait_for_init_queue) == 0:
            _initialized = true
        
        
        if len(_add_mesh_queue) > 0:
            chunk_info = _add_mesh_queue.Pop()
            chunk = chunk_info.getChunk()
            coord = chunk.getCoordinates()
            _create_mesh_object(chunk_info)
            if coord in _wait_for_init_queue:
                _wait_for_init_queue.Remove(coord)

        if len(_remove_mesh_queue) > 0:
            chunk_info = _remove_mesh_queue.Pop()
            _remove_mesh_object(chunk_info)

        # check AABB bounding volumes
        # 1. grab the blocks surrounding the origin
        if isInitialized():
            _player = gameObject.Find("First Person Controller").GetComponent("Player") as Player
            _player_aabb = _player.getAABB()
            x = gameObject.Find("First Person Controller").GetComponent("Player") as Player            
            if _chunk_ball.CheckCollisions(_player_aabb):
                x.stopGravity()
            else:
                x.startGravity()
            
        #block_a = Vector3(Math.Floor(_origin.x), Math.Floor(_origin.y), Math.Floor(_origin.z))
        
        # 2. test each block for collision
        

    def isInitialized() as bool:
        return _initialized
	
    def areInitialChunksComplete() as bool:
        pass

    def setOrigin(origin as Vector3) as void:
        _chunk_ball.SetOrigin(origin)
        _origin = origin

    def _remove_mesh_object(chunk_info as ChunkInfo):
        chunk_blocks as ChunkBlockData = chunk_info.getChunk()
        coords = chunk_blocks.getCoordinates()
        o = gameObject.Find("Chunk ($(coords.x), $(coords.y), $(coords.z))")
        if o != null:
            gameObject.Destroy(o)
        else:
            updateObserver(ChunkBallMessage(Message.REMOVE, chunk_info))

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
        o.GetComponent(MeshRenderer).material = Resources.Load("Materials/Measure") as Material
        o.GetComponent(MeshFilter).sharedMesh = mesh
        #o.GetComponent(MeshCollider).sharedMesh = mesh

        o.transform.position = Vector3(coords.x, coords.y, coords.z)


