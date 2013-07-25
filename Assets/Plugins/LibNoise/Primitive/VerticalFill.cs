using UnityEngine;
using System.Collections;


namespace LibNoise.Primitive {
  public class VerticalFill : PrimitiveModule, IModule3D
  {
    IModule3D m1;
    IModule3D m2;
    float cutoff;
    public VerticalFill(IModule3D m1, IModule3D m2, float cutoff)
    {
      this.m1 = m1;
      this.m2 = m2;
      this.cutoff = cutoff;
    }

    // public VerticalFill(IModule3D m1, IModule3D m2, float lower_cutoff, float upper_cutoff)
    // {
    //   this.m1 = m1;
    //   this.m2 = m2;
    // }

    public float GetValue(float x, float y, float z)
    {
      if (y < cutoff) {
	return m1.GetValue(x, y, z);
      } else {
	return m2.GetValue(x, y, z);
      }
    }

  }
}


