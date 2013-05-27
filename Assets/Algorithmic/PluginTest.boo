import UnityEngine
import System.Runtime.InteropServices
#import bullet

[DllImport("ASimplePlugin")]
def PrintHello() as string:
	pass
[DllImport("ASimplePlugin")]
def PrintANumber() as int:
	pass

[DllImport("bullet")]
def runTest() as int:
	pass


class PluginTest (MonoBehaviour):

	def Start ():
		print "TEST"
		print runTest()
		print "TEST"
	
	def Update ():
		pass
