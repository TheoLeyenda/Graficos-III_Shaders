Shader "TestShader/Standard"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
		_Saturation ("Saturation", Float) = 0.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;
        half _Glossiness;
        half _Metallic;
		float _Saturation;
        fixed4 _Color;

		struct Input
		{
			float2 uv_MainTex;
		};

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // Albedo comes from a texture tinted by color
			float2 uv = IN.uv_MainTex;

			uv.y += sin(uv.x * 6.2831 + _Time.y) * 0.1;
            fixed4 c = tex2D (_MainTex, uv) * _Color;
            o.Albedo = lerp((c.r + c.g + c.b) / 3, c, _Saturation);
            // Metallic and smoothness come from slider variables
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
