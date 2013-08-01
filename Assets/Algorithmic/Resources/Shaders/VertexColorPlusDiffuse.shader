Shader "Custom/VertexColorPlusDiffuse" {
    Properties {
	_Color ("Diffuse Color", Color) = (1.0, 1.0, 1.0, 1.0)
    }
    SubShader {
	Tags { "RenderType" = "Opaque" }
	Pass {

	    CGPROGRAM
	    #pragma vertex vert
	    #pragma fragment frag
	    #include "UnityCG.cginc"
	    #include "Lighting.cginc"

	    uniform float4 _Color;

	    struct vertex_input {
		float4 position : POSITION;
		float4 color : COLOR;
		float3 normal : NORMAL;
	    };

	    struct vertex_output {
		float4 position : POSITION;
		float4 color : COLOR;
	    };

	    struct fragment_output {
		float4 color : COLOR;
	    };

	    vertex_output vert(vertex_input IN) {
		vertex_output OUT;
		// convert the local position to world position
		OUT.position = mul(UNITY_MATRIX_MVP, IN.position);

		float4x4 model_matrix = _Object2World;
		float4x4 model_matrix_inverse = _World2Object;
		// calculate the diffuse lighting
		float3 normal_dir = normalize(float3(mul(float4(IN.normal, 0.0), model_matrix_inverse))); 
		float3 light_dir = normalize(float3(_WorldSpaceLightPos0));
		float3 diffuse_reflection = float3(_LightColor0) * float3(_Color) * max(0.0, dot(normal_dir, light_dir));

		// combine the diffuse lighting from the light source 
                // with the vertex color passed in by the mesh generator
		/* OUT.color = (IN.color + float4(diffuse_reflection, 1.0)) * 0.5; */
		OUT.color = lerp(IN.color, float4(diffuse_reflection, 1.0), 0.5);

		return OUT;
	    };

	    fragment_output frag(vertex_output IN) {
		fragment_output OUT;
		OUT.color = IN.color;
		return OUT;
	    };
	    ENDCG

	}
    }
}
