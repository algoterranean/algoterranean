import UnityEngine

# Awake - run when a scene is loaded
# Start - run immediatly before the first call to Update or FixedUpdate
# Update - run every frame
# LateUpdate - run every frame but called after Update
# FixedUpdate - run every framerate frame - used for RigidBody

# OnEnable - run when the GameObject becomes enabled and active
# etc.


class ConsoleBootstrap (MonoBehaviour):
	console_display = false
	console_text = "> "
	command_history = []

	def Update ():
		if Input.GetKeyDown('`'):
			console_display = not console_display

		if console_display:
			if Input.GetKeyDown(KeyCode.UpArrow):
				pass
			
			for c as char in Input.inputString:
				if c == '\b'[0]: # if delete key, delete the previous character
					if console_text.Length != 2:
						console_text = console_text.Substring(0, (console_text.Length - 1))
				elif c == '\n'[0] or c == '\r'[0]:
					# if enter key, we know that a command has been entered
					command_start = console_text.LastIndexOf("> ", console_text.Length - 2) + 2
					command_end = console_text.Length
					command = console_text[command_start:command_end]
					command_history.Add(command)
					
					console_text += '\n' + self.runCommand(command) # run command
					console_text += c + "> "
				elif c == '`'[0]:
					pass
				else:
					console_text += c
				

	def runCommand (command as string):
		if command == 'generate':
			console_text += "WHAT"
			return "Generating Terrain"
		return "EXECUTING " + command
		

	def OnGUI ():
		if console_display:
			w = Screen.width - 20
			h = Screen.height / 3
			
			GUI.Box(Rect(10,10,w,h),'')
			GUI.SetNextControlName("console")
			GUI.Label(Rect(15,15,w-5,h-5), console_text)
			GUI.FocusControl("console")
			GUI.VerticalSlider(Rect(w-10, 10, 10, h-5), 0.0, 1.0, 0.0)

			
			


			
