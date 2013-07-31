Shader "Custom/1" {
	//Refer here : http://unity3d.com/support/documentation/Components/SL-SubShader.html
	SubShader 
	{
		//Refer here : http://unity3d.com/support/documentation/Components/SL-Pass.html
		Pass 
		{

		//Refer here : http://unity3d.com/support/documentation/Components/SL-ShaderPrograms.html
		CGPROGRAM
// Upgrade NOTE: excluded shader from OpenGL ES 2.0 because it does not contain a surface program or both vertex and fragment programs.
#pragma exclude_renderers gles
		// The vertex shader name should match the vertex shader function name
		//#pragma vertex C2E1v_green
		// The fragment shader name should match the fragment shader function name
		#pragma fragment C2E2f_passthrough
 
 
		struct C2E1v_Output 
		{
			float4 position : POSITION;
			float4 color : COLOR;
		};
 
		C2E1v_Output C2E1v_green(float4 position : POSITION)
		{
		  C2E1v_Output OUT;
		  OUT.position = position; //,0,1);
		  OUT.color    = float4(0, 1, 0, 1);  // RGBA green
		  return OUT;
		}		
 
		struct C2E2f_Output
		{
			float4 color : COLOR;
		};
		C2E2f_Output C2E2f_passthrough(float4 color : COLOR)
		{
			C2E2f_Output OUT;
			OUT.color = float4(0, 1, 0, 1);
			return OUT;
		}
 
		ENDCG
		}
	}
}
