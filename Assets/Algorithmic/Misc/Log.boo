namespace Algorithmic.Misc

enum LOG_MODULE:
	PHYSICS
	CONTACTS
	CHUNKS


static class Log:
	def constructor():
		pass

	def Log(s as string, module as LOG_MODULE):
		if module == LOG_MODULE.PHYSICS:
			m = "PHYSICS"
		elif module == LOG_MODULE.CONTACTS:
			m = "CONTACTS"
		elif module == LOG_MODULE.CHUNKS:
			m = "CHUNKS"
		else:
			m = "UNKNOWN"
		dt = System.DateTime.Now
		print "    [$(dt.Minute):$(dt.Second):$(dt.Millisecond)] [$m] $s"
		

