namespace Algorithmic.Misc

enum LOG_MODULE:
	PHYSICS
	CONTACTS


static class Log:
	def constructor():
		pass

	static def Log(s as string, module as LOG_MODULE):
		if module == LOG_MODULE.PHYSICS:
			m = "PHYSICS"
		elif module == LOG_MODULE.CONTACTS:
			m = "CONTACTS"
		else:
			m = "UNKNOWN"
		dt = System.DateTime.Now
		print "    [$(dt.Minute):$(dt.Second):$(dt.Millisecond)] [$m] $s"
		

