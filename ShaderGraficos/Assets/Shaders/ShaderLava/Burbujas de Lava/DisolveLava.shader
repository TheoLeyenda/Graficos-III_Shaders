Shader "TestShader/DisolveLava"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_DisolveTexture("Disolve Texture", 2D) = "white" {}
		_DisolveY("Current Y of the disolve effect", Float) = 0
		_DisolveSize("Size of the effect", Float) = 2
		_StartingY("Startting point of the effect", Float) = -10
		_ColorTexture("Color Texture", Color) = (0.086, 0.407, 1, 0.749)

		_RampTex("Ramp Tex", 2D) = "white" {}
		_FlowMap("Flow Map", 2D) = "grey" {}
		_FlowMapSpeed("SMap Speed", Range(-1, 1)) = 0.2
		_FlowDirection("Flow direction", vector) = (1,0,0,0)
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
				float3 worldPos : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
			sampler2D _DisolveTexture;
			float _DisolveY;
			float _DisolveSize;
			float _StartingY;
			float4 _ColorTexture;

			sampler2D _RampTex;
			sampler2D _FlowMap;
			fixed _FlowMapSpeed;
			float2 _FlowDirection;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				i.uv += _Time.x * _FlowDirection; //Movimiento de la textura de la lava

				float transition = _DisolveY - i.worldPos.y;
				
				clip(_StartingY + (transition + (tex2D(_DisolveTexture, i.uv)) * _DisolveSize));


				half3 flowVal = (tex2D(_FlowMap, i.uv) * 2 - 1) * _FlowMapSpeed;

				float dif1 = frac(_Time.y * 0.25 + 0.5);
				float dif2 = frac(_Time.y * 0.25);

				half lerpVal = abs((0.5 - dif1) / 0.5);

				half4 col1 = tex2D(_MainTex, i.uv - flowVal.xy * dif1);
				half4 col2 = tex2D(_MainTex, i.uv - flowVal.xy * dif2);

				fixed4 col;
				col = lerp(col1, col2, lerpVal);
				//--------------------------------------------------------------------------//

				//Genero y retorno el color del pixel actual de la lava con la textura _RampTex.
				float4 ramp = tex2D(_RampTex, float2(col.r, 0));

                // sample the texture
                col = tex2D(_MainTex, i.uv) * ramp;
                return col * _ColorTexture;
            }
            ENDCG
        }
    }
}
