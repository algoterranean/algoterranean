using System;
using System.Collections.Generic;
using System.Linq;

internal static class PerformanceMonitor
{
	public class Counter : IComparable<Counter>
	{
		public string Name { get; private set; }
		public long Time { get; private set; }
		public long Last { get; private set; }
		public long Max { get; private set; }
		public int Count { get; private set; }
		public float Average
		{
			get { return Time / (float)Count; }
		}

		public Counter(string name, long time)
		{
			Name = name;

			Time = time;
			Last = time;
			Max = time;
			Count = 1;
		}

		public void Increment(long ms)
		{
			Time += ms;
			Last = ms;
			if (ms > Max)
			{
				Max = ms;
			}
			Count++;
		}

		public int CompareTo(Counter other)
		{
			return String.Compare(Name, other.Name, StringComparison.Ordinal);
		}
	}

	private static readonly Dictionary<string, Counter> counters;

	static PerformanceMonitor()
	{
		counters = new Dictionary<string, Counter>();
	}

	public static List<Counter> Counters
	{
		get
		{
			lock (counters)
			{
				var list = counters.Values.OrderBy(counter => counter.Name).ToList();
				return list;
			}
		}
	}

	public static void IncrementCounter(string name, long ms)
	{
		lock (counters)
		{
			Counter counter;

			if (counters.TryGetValue(name, out counter))
			{
				counter.Increment(ms);
			}
			else
			{
				counters.Add(name, new Counter(name, ms));
			}
		}
	}

	public static void Clear()
	{
		lock (counters)
		{
			counters.Clear();
		}
	}
}