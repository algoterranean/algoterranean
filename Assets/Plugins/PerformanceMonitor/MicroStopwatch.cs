using System;
using System.Diagnostics;

public class MicroStopwatch : Stopwatch
{
	private readonly double microSecPerTick = 1000000D / Frequency;

	public MicroStopwatch()
	{
		if (!IsHighResolution)
		{
			throw new Exception("On this system the high-resolution " +
			                    "performance counter is not available");
		}
	}

	public long ElapsedMicroseconds
	{
		get { return (long)(ElapsedTicks * microSecPerTick); }
	}
}