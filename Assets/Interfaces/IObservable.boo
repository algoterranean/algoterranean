import UnityEngine

interface IObservable:
	def Subscribe(obj as IObserver)
	def UnSubscribe(obj as IObserver)

