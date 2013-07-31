Shader "Custom/VertexColor2" {
    SubShader {
	Tags { "RenderType" = "Opaque" }
	Pass {

	    CGPROGRAM
	    #pragma vertex vert
	    #pragma fragment frag
	    #include "UnityCG.cginc"

	    struct vertex_input {
		float4 position: POSITION;
		float4 color: COLOR;
	    };


	    struct vertex_output {
		float4 position: POSITION;
		float4 color: COLOR;
	    };

	    struct fragment_output {
		float4 color: COLOR;
	    };

	    vertex_output vert(vertex_input IN) {
		vertex_output OUT;
		OUT.position = mul(UNITY_MATRIX_MVP, IN.position);
		OUT.color = IN.color;
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
