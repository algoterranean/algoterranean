using UnityEngine;
using System.Collections;




namespace LibNoise.Primitive {
    public class SimpleVerticalGradient : PrimitiveModule, IModule3D, IModule2D, IModule1D
  {

      float min_y, max_y;
    // float m_gx1;
    // float m_gy1;
    // float m_gz1;
    // //float m_gx2;
    // //float m_gy2;
    // //float m_gz2;
    // float m_dx;
    // float m_dy;
    // float m_dz;
    // float m_len;
    
    public SimpleVerticalGradient(float y0, float y1)
    {
	min_y = y0;
	max_y = y1;
      // m_gx1 = x1;
      // m_gy1 = y1;
      // m_gz1 = z1;
      // //m_gx2 = x2;
      // //m_gy2 = y2;
      // //m_gz2 = z2;
      // if (x1 < 0)
      // {
      // 	  m_dx = x2 - x1;
      // } else
      // 	{
      // 	    m_dx = x1 - x2;	    
      // 	}
      // if (y1 < 0)
      // {
      // 	  m_dy = y2 - y1;
      // } else
      // 	{
      // 	          m_dy = y1 - y2;
      // 	}
      // if (z1 < 0)
      // {
      // 	  m_dz = z2 - z1;
      // } else
      // 	{
      // m_dz = z1 - z2;	    
      // 	}

      // m_len = (float)System.Math.Sqrt(m_dx*m_dx + m_dy*m_dy + m_dz*m_dz);

	}


    #region IModule3D Members

    /// <summary>
    /// Generates an output value given the coordinates of the specified input value.
    /// </summary>
    /// <param name="x">The input coordinate on the x-axis.</param>
    /// <param name="y">The input coordinate on the y-axis.</param>
    /// <param name="z">The input coordinate on the z-axis.</param>
    /// <returns>The resulting output value.</returns>
    public float GetValue(float x, float y, float z) {
	return (y - min_y) / (max_y - min_y);
    }//end GetValue

    #endregion

    // #region IModule2D Members

    // /// <summary>
    // /// Generates an output value given the coordinates of the specified input value.
    // /// </summary>
    // /// <param name="x">The input coordinate on the x-axis.</param>
    // /// <param name="y">The input coordinate on the y-axis.</param>
    // /// <returns>The resulting output value.</returns>
    public float GetValue(float x, float y) {
	return (y - min_y) / (max_y - min_y);
    }//end GetValue

    // #endregion


    // #region IModule1D Members

    // /// <summary>
    // /// Generates an output value given the coordinates of the specified input value.
    // /// </summary>
    // /// <param name="x">The input coordinate on the x-axis.</param>
    // /// <returns>The resulting output value.</returns>
    public float GetValue(float y) {
	return (y - min_y) / (max_y - min_y);
    }//end GetValue

    // #endregion

  }
}