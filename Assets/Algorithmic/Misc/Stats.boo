import UnityEngine

class Stats (MonoBehaviour):
	text_style as GUIStyle
	display = true
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

	

	def Start ():
		font_resource = Resources.Load("Fonts/whiterabbit") as Font
		text_style = GUIStyle()
		text_style.font = font_resource
		text_style.normal.textColor = Color.white
		
		# text_style.richText = true
		# text_style.fontStyle = FontStyle.BoldAXS
		# text_style.fontSize = 20
		# text_style.font = Font(

	def OnGUI():
		s = "Chunks: $chunks_visible / $chunks_max"
		GUI.Label(Rect(25, 25, 200, 25), s, text_style)

		b_time = String.Format("{0:0.0}", perf_block_creation_time/perf_block_creation_count)
		b_time_last = String.Format("{0:0.0}", perf_block_last_time)
		b_time_max = String.Format("{0:0.0}", perf_block_max_time)
		b_time_min = String.Format("{0:0.0}", perf_block_min_time)		
		m_time = String.Format("{0:0.0}", perf_mesh_creation_time/perf_mesh_creation_count)
		m_time_last = String.Format("{0:0.0}", perf_mesh_last_time)
		m_time_max = String.Format("{0:0.0}", perf_mesh_max_time)
		m_time_min = String.Format("{0:0.0}", perf_mesh_min_time)
		col1_len = 12
		col2_len = 12
		col3_len = 12
		col4_len = 12
		col5_len = 12		

		block_creation_count = String.Format("{0}", perf_block_creation_count)
		mesh_creation_count = String.Format("{0}", perf_mesh_creation_count)
		
		p = "Performance\n\n"
		p += "Name" + " " * (col1_len - 4) + "Total" + " " * (col2_len-5) + "Avg (ms)" + " " * (col3_len - 8) + "Min (ms)" + " " * (col4_len-8) + "Max (ms)" + " " * (col5_len-8) + "\n"
		p += "Chunk" + " " * (col1_len-5) + "$block_creation_count" + " " * (col2_len-len(block_creation_count)) + "$b_time" + " " * (col3_len-len(b_time)) + "$b_time_min" + " " * (col4_len - len(b_time_min)) + "$b_time_max" + "\n"
		p += "Mesh" + " " * (col1_len-4) + "$mesh_creation_count" + " " * (col2_len-len(mesh_creation_count)) + "$m_time" + " " * (col3_len-len(m_time)) + "$m_time_min" + " " * (col4_len - len(m_time_min)) + "$m_time_max" + "\n"


		
		GUI.Label(Rect(300, 25, 400, 200), p, text_style)

	def PerfMaxChunks(i as int):
		chunks_max = i

	def CreateMesh():
	# def incrementChunksVisible():
		chunks_visible += 1
		chunks_created += 1

	def RemoveMesh():
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
		


		
