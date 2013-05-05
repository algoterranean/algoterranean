import UnityEngine
import Vectrosity

class Reticle (MonoBehaviour):
	r1 as VectorLine
	r2 as VectorLine
	reticle_size = 32
	color = Color(1.0, 1.0, 1.0, 0.7)	
	
	def Start ():
		r1 = VectorLine.SetLine(color,
								Vector2(Screen.width/2, Screen.height/2 - reticle_size/2),
								Vector2(Screen.width/2, Screen.height/2 + reticle_size/2))
		r2 = VectorLine.SetLine(color,
								Vector2(Screen.width/2 - reticle_size/2, Screen.height/2),
								Vector2(Screen.width/2 + reticle_size/2, Screen.height/2))
		r1.lineWidth = 2.0
		r2.lineWidth = 2.0

	def Update():
		r1.Draw()
		r2.Draw()
		



	
