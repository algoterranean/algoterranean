using UnityEngine;
using System.Collections;




namespace LibNoise.Primitive {
  public class MyGradient : PrimitiveModule, IModule4D, IModule3D, IModule2D, IModule1D
  {

    float m_gx1;
    float m_gy1;
    float m_gz1;
    //float m_gx2;
    //float m_gy2;
    //float m_gz2;
    float m_dx;
    float m_dy;
    float m_dz;
    float m_len;
    
    public MyGradient(float x1, float y1, float z1, float x2, float y2, float z2)
    {
      m_gx1 = x1;
      m_gy1 = y1;
      m_gz1 = z1;
      //m_gx2 = x2;
      //m_gy2 = y2;
      //m_gz2 = z2;
      m_dx = x1 - x2;
      m_dy = y1 - y2;
      m_dz = z1 - z2;
      m_len = (float)System.Math.Sqrt(m_dx*m_dx + m_dy*m_dy + m_dz*m_dz);

	}
    

   

    #region IModule4D Members

    /// <summary>
    /// Generates an output value given the coordinates of the specified input value.
    /// </summary>
    /// <param name="x">The input coordinate on the x-axis.</param>
    /// <param name="y">The input coordinate on the y-axis.</param>
    /// <param name="z">The input coordinate on the z-axis.</param>
    /// <param name="t">The input coordinate on the t-axis.</param>
    /// <returns>The resulting output value.</returns>
    public float GetValue(float x, float y, float z, float t) {
      return 0;
    }//end GetValue

    #endregion

    #region IModule3D Members

    /// <summary>
    /// Generates an output value given the coordinates of the specified input value.
    /// </summary>
    /// <param name="x">The input coordinate on the x-axis.</param>
    /// <param name="y">The input coordinate on the y-axis.</param>
    /// <param name="z">The input coordinate on the z-axis.</param>
    /// <returns>The resulting output value.</returns>
    public float GetValue(float x, float y, float z) {
      float dx = (x - m_gx1);
      float dy = (y - m_gy1);
      float dz = (z - m_gz1);
      float dp = dx*m_dx + dy*m_dy + dz*m_dz;
      //float result = System.Math.Abs(dp/m_len);
      float result = dp/m_len * -1.0f;
      //result = 1.0f / result;
      result = (float)Libnoise.Clamp(result, 0.0, 1.0);
      result = Libnoise.Lerp(-1.0f, 1.0f, result);
      return result;
      
    }//end GetValue

    #endregion

    #region IModule2D Members

    /// <summary>
    /// Generates an output value given the coordinates of the specified input value.
    /// </summary>
    /// <param name="x">The input coordinate on the x-axis.</param>
    /// <param name="y">The input coordinate on the y-axis.</param>
    /// <returns>The resulting output value.</returns>
    public float GetValue(float x, float y) {
      return 0;
    }//end GetValue

    #endregion


    #region IModule1D Members

    /// <summary>
    /// Generates an output value given the coordinates of the specified input value.
    /// </summary>
    /// <param name="x">The input coordinate on the x-axis.</param>
    /// <returns>The resulting output value.</returns>
    public float GetValue(float x) {
      return 0;
    }//end GetValue

    #endregion

  }
}