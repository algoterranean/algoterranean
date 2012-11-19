using System;

internal class Timer : MicroStopwatch, IDisposable
{
	private readonly string name;

	public Timer(string name)
	{
		this.name = name;

		Start();
	}

	public void Dispose()
	{
		PerformanceMonitor.IncrementCounter(name, ElapsedMicroseconds);
	}
}