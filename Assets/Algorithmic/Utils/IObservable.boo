
interface IObservable ():
	def registerObserver(o as object) as void
	def removeObserver(o as object) as void
	def notifyObservers() as void
