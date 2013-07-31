Shader "Custom/2" {
  Properties {
    _constant_color ("Refraction Color", Color) = (0.34, 0.85, 0.91, 1)
  }

  //Refer here : http://unity3d.com/support/documentation/Components/SL-SubShader.html
  SubShader {
    //Refer here : http://unity3d.com/support/documentation/Components/SL-Pass.html
    Pass {

      //Refer here : http://unity3d.com/support/documentation/Components/SL-ShaderPrograms.html
      CGPROGRAM
	// The vertex shader name should match the vertex shader function name
#pragma vertex C2E1v_green
	// The fragment shader name should match the fragment shader function name
#pragma fragment C2E2f_passthrough
 
 
	struct C2E1v_Output
      {
	float4 position : POSITION;
	float4 color : COLOR;
      };
 
      C2E1v_Output C2E1v_green(float4 position : POSITION,
			       uniform float4 _constant_color)
      {
	C2E1v_Output OUT;
	OUT.position = position; //,0,1);
	OUT.color    = _constant_color; //float4(0, 1, 0, 1);  // RGBA green
	return OUT;
      }		
 
      struct C2E2f_Output
      {
	float4 color : COLOR;
      };
      C2E2f_Output C2E2f_passthrough(float4 color : COLOR)
      {
	C2E2f_Output OUT;
	OUT.color = color;
	return OUT;
      }
 
      ENDCG
	}
  }
}
