import UnityEngine

# Awake - run when a scene is loaded
# Start - run immediatly before the first call to Update or FixedUpdate
# Update - run every frame
# LateUpdate - run every frame but called after Update
# FixedUpdate - run every framerate frame - used for RigidBody

# OnEnable - run when the GameObject becomes enabled and active
# etc.


class ConsoleBootstrap (MonoBehaviour):
	hi = 'hello'

	def Awake ():
		Debug.Log(self.hi)

	def Start ():
		pass
	
	def Update ():
		pass
