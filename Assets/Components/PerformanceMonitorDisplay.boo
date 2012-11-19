import UnityEngine

class PerformanceMonitorDisplay (MonoBehaviour):
	private display = true

	def ShowPerformanceCounters ():
		col0 = 550
		col1 = col0 + 230
		col2 = col1 + 100
		col3 = col2 + 80
		col4 = col3 + 60
		col5 = col4 + 60
		col6 = col5 + 80

		#counters = PerformanceMonitor
		# counters = gameObject.GetComponent(PerformanceMonitor).counters
		# for counter in counters:
		# 	pass

	def OnGui ():
		ShowPerformanceCounters()

