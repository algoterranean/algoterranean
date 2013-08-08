Shader "Custom/TestWater" {
Properties {
    _MainTex ("Base (RGB) Transparency (A)", 2D) = "" {}
    
}

Category {
    Tags { "Queue"="Transparent" }
    
    BindChannels {
        Bind "Color", color
        Bind "Vertex", vertex
        /* Bind "TexCoord", texcoord */
    }
    SubShader {
        Pass {
	     ZWrite On
	     Blend SrcAlpha OneMinusSrcAlpha
             SetTexture [_MainTex] {
	     		Combine texture * primary DOUBLE
             }
        }
    }
  }

}
