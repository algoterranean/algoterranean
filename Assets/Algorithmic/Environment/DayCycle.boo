import UnityEngine

class DayCycle (MonoBehaviour): 
	time_of_day = (24 * 60 * 60)/2.0 # in seconds. start off at noon
	speed_factor = 72.0 # speedup factor. 72.0 means 12 hours is 10 minutes in real time
	sun_light as GameObject
	player_obj as GameObject
	
	def Start ():
		sun_light = gameObject.Find("Sun")
		player_obj = gameObject.Find("Player")
	
	def Update ():
		pass

	def FixedUpdate():
		time_of_day = (time_of_day + Time.deltaTime * speed_factor) % 86400 # 86400 = number of seconds in a day
		#sun_light.transform.RotateAround(player_obj.transform.position, Vector3.right, 0.3 * Time.deltaTime)
		#sun_light.transform.LookAt(player_obj.transform.position)
		
