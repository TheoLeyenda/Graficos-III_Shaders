Shader "TestShader/Unlit"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
               

				float2 uv = i.uv - 0.5;
				float a = _Time.y;
				float2 p = float2(sin(a), cos(a)) * 0.4;
				float2 distort = uv - p;
				float d = length(distort);
				float m = smoothstep(0.07, 0, d);

				distort = distort*10*m;

				fixed4 col = tex2D(_MainTex, i.uv + distort);

				return col;
            }
            ENDCG
        }
    }
}
