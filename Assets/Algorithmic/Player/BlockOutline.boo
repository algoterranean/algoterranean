import UnityEngine
import Vectrosity

class BlockOutline (MonoBehaviour):
	_enabled = false
	position = Vector3(0, 0, 0)
	p1 as VectorLine
	p2 as VectorLine
	offset = 0.01

	coordinates = [ # back
					[Vector3(0 , 0 , 0 ), Vector3(0, 1 , 0 )],
					[Vector3(0, 1 , 0), Vector3(0, 1 , 1 )],
					[Vector3(0, 1 , 1 ), Vector3(0, 0 , 1 )],
					[Vector3(0, 0 , 1 ), Vector3(0, 0 , 0 )],
					# front
					[Vector3(1, 0, 0), Vector3(1, 1, 0)],
					[Vector3(1, 1, 0), Vector3(1, 1, 1)],
					[Vector3(1, 1, 1), Vector3(1, 0, 1)],
					[Vector3(1, 0, 1), Vector3(1, 0, 0)],
					# top
					[Vector3(1, 1, 0), Vector3(0, 1, 0)],
					[Vector3(1, 1, 1), Vector3(0, 1, 1)],
					# bottom
					[Vector3(1, 0, 0), Vector3(0, 0, 0)],
					[Vector3(1, 0, 1), Vector3(0, 0, 1)]
					
					]

	lines = []

	def updateLines():
		for x in range(len(lines)):
			l = lines[len(lines) - x - 1] cast VectorLine
			c = coordinates[x] cast Boo.Lang.List
			a = c[0] cast Vector3
			b = c[1] cast Vector3
			l.points3[0] = Vector3(position.x + a.x, position.y + a.y, position.z + a.z)
			l.points3[1] = Vector3(position.x + b.x, position.y + b.y, position.z + b.z)
			if a.x:
				l.points3[0].x += offset
			else:
				l.points3[0].x -= offset
			if a.y:
				l.points3[0].y += offset
			else:
				l.points3[0].y -= offset
			if a.z:
				l.points3[0].z += offset
			else:
				l.points3[0].z -= offset
			if b.x:
				l.points3[1].x += offset
			else:
				l.points3[1].x -= offset
			if b.y:
				l.points3[1].y += offset
			else:
				l.points3[1].y -= offset
			if b.z:
				l.points3[1].z += offset
			else:
				l.points3[1].z -= offset
				
				
				
			

	def Start ():
		for x as Boo.Lang.List in coordinates:
			a = x[0] cast Vector3
			b = x[1] cast Vector3
			l = VectorLine.SetRay3D(Color.white,
									Vector3(position.x + a.x, position.y + a.y, position.z + a.z),
									Vector3(position.x + b.x, position.y + b.y, position.z + b.z))
			lines.Push(l)
		
	def Update ():
		if _enabled:
			for x as VectorLine in lines:
				x.Draw3D()

	def setPosition(p as Vector3):
		position = Vector3(p.x - 0.5, p.y - 0.5, p.z - 0.5)
		updateLines()


	def disable():
		for x as VectorLine in lines:
			x.active = false
		_enabled = false

	def enable():
		for x as VectorLine in lines:
			x.active = true
		_enabled = true
							 
