Shader "Custom/3" {

	Properties //
	{
		decal ("Base (RGB)", 2D) = "white" {}
    }
	//Reference  : http://unity3d.com/support/documentation/Components/SL-SubShader.html
	SubShader 
	{
		//Reference  : http://unity3d.com/support/documentation/Components/SL-Pass.html
		Pass 
		{
		//Reference  : http://unity3d.com/support/documentation/Components/SL-ShaderPrograms.html
		CGPROGRAM
		// The vertex shader name should match the vertex shader function name
		#pragma vertex C3E2v_varying
		// The fragment shader name should match the fragment shader function name
		#pragma fragment C3E3f_texture
 
 
 
		struct v2f 
		{
			float4 position : SV_POSITION;
			float4 color    : COLOR;
			float4 texCoord  : TEXCOORD0;
		};
 
		struct a2v
		{
			float4 vertex   : POSITION;
			float4 color    : COLOR;
			float4 texcoord : TEXCOORD0;
		};		
 
		v2f  C3E2v_varying(a2v In)
		{
			v2f  OUT;
			OUT.position = float4(In.vertex.xy, 0, 1);
			OUT.color    = In.color;
			//o.uv_MainTex = TRANSFORM_TEX(v.texcoord, _MainTex);
			OUT.texCoord  = In.texcoord ;
			return OUT;
		}
 
		struct C3E3f_Output 
		{
			float4 color : COLOR;
		};
 
		C3E3f_Output C3E3f_texture(float4 texcoord : TEXCOORD0,
									sampler2D decal)
		{
			C3E3f_Output OUT;
			OUT.color = tex2D(decal, texcoord.xy);
			return OUT;
		}
 
		ENDCG
		}
	}
}
