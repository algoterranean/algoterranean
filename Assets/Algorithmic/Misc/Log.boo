namespace Algorithmic.Misc


static class Log:
	def constructor():
		pass

	static def Log(s as string):
		dt = System.DateTime.Now
		print "    [$(dt.Minute):$(dt.Second):$(dt.Millisecond)] $s"
		

