
interface IObservable:
	def Subscribe(obj as IObserver)
	def Unsubscribe(obj as IObserver)

