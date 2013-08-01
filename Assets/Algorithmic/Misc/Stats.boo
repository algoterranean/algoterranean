import UnityEngine
import System.Timers

class Stats (MonoBehaviour):
	display = true
	
	text_style as GUIStyle
	chunks_max = 0
	chunks_visible = 0
	chunks_created = 0
	font_resource as Font 
	player_position = Vector3(0, 0, 0)

	perf_mesh_creation_time = 0.0
	perf_mesh_creation_count = 0
	perf_mesh_max_time = 0.0
	perf_mesh_last_time = 0.0
	perf_mesh_min_time = 9999.0
	perf_block_creation_time = 0.0
	perf_block_creation_count = 0
	perf_block_max_time = 0.0
	perf_block_min_time = 9999.0	
	perf_block_last_time = 0.0
	seed = 0
	looking_at as Vector3
	looking_at_type as byte
	t1 as string
	t2 as string

	

	def Start ():
		#looking_at = Vector3(9, 9, 9)
		looking_at_type = 0
		font_resource = Resources.Load("Fonts/whiterabbit") as Font
		text_style = GUIStyle()
		text_style.font = font_resource
		text_style.normal.textColor = Color.white
		text_style.richText = true
		seed = Settings.Terrain.Seed

		InvokeRepeating("_update_text", 2, 1.0)


	def Update():
		if Input.GetKeyDown(KeyCode.F3):
			display = not display

	def LookingAt(v as Vector3, block as int):
		self.looking_at = v
		self.looking_at_type = block

	def _update_text():
		s = "<b>Seed</b>: $seed\n"
		s += "<b>Chunks</b>: $chunks_visible / $chunks_max\n"
		s += "<b>Looking at</b>: $(self.looking_at), $(self.looking_at_type)\n"
		t1 = s

		b_time = String.Format("{0:0.0}", perf_block_creation_time/perf_block_creation_count)
		b_time_last = String.Format("{0:0.0}", perf_block_last_time)
		b_time_max = String.Format("{0:0.0}", perf_block_max_time)
		b_time_min = String.Format("{0:0.0}", perf_block_min_time)		
		m_time = String.Format("{0:0.0}", perf_mesh_creation_time/perf_mesh_creation_count)
		m_time_last = String.Format("{0:0.0}", perf_mesh_last_time)
		m_time_max = String.Format("{0:0.0}", perf_mesh_max_time)
		m_time_min = String.Format("{0:0.0}", perf_mesh_min_time)
		col1_len = 10
		col2_len = 10
		col3_len = 10
		col4_len = 10
		col5_len = 10		

		block_creation_count = String.Format("{0}", perf_block_creation_count)
		mesh_creation_count = String.Format("{0}", perf_mesh_creation_count)

		p = "<b>Performance</b>\n\n"
		p += "<b>Name</b>" + " " * (col1_len - 4) + "<b>Total</b>" + " " * (col2_len-5) + "<b>Avg (ms)</b>" + " " * (col3_len - 8) + "<b>Min (ms)</b>" + " " * (col4_len-8) + "<b>Max (ms)</b>" + " " * (col5_len-8) + "\n"
		p += "Chunk" + " " * (col1_len-5) + "$block_creation_count" + " " * (col2_len-len(block_creation_count)) + "$b_time" + " " * (col3_len-len(b_time)) + "$b_time_min" + " " * (col4_len - len(b_time_min)) + "$b_time_max" + "\n"
		p += "Mesh" + " " * (col1_len-4) + "$mesh_creation_count" + " " * (col2_len-len(mesh_creation_count)) + "$m_time" + " " * (col3_len-len(m_time)) + "$m_time_min" + " " * (col4_len - len(m_time_min)) + "$m_time_max" + "\n"

		t2 = p
		
	def OnGUI():
		if display:
			GUI.Label(Rect(25, 25, 200, 100), t1, text_style)
			GUI.Label(Rect(350, 25, 400, 200), t2, text_style)

	def FixedUpdate():
		pass
		#_update_text()

	def PerfMaxChunks(i as int):
		chunks_max = i

	def CreateMesh():
	# def incrementChunksVisible():
		chunks_visible += 1
		chunks_created += 1

	def RemoveMesh2():
	# def decrementChunksVisible():
		chunks_visible -= 1

	def PerfMeshCreation(time as single):
		perf_mesh_creation_count += 1
		perf_mesh_creation_time += time
		if time > perf_mesh_max_time:
			perf_mesh_max_time = time
		if time < perf_mesh_min_time:
			perf_mesh_min_time = time
		perf_mesh_last_time = time

	def PerfBlockCreation(time as single):
		perf_block_creation_count += 1
		perf_block_creation_time += time
		if time > perf_block_max_time:
			perf_block_max_time = time
		if time < perf_block_min_time:
			perf_block_min_time = time			
		perf_block_last_time = time


		

		


		
