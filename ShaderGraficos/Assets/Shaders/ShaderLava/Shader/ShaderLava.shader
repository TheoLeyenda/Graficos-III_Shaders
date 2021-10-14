Shader "TestShader/Lava"
{
	Properties{
		_MainTex("Texture", 2D) = "black" {}

		_RampTex("Ramp Tex", 2D) = "white" {}
		_Threshold("Threshold", float) = 0
		_PowLevel("Power level", Range(0, 4)) = 1

		_YAmplitude("Y_Amplitude" , Range(0,1)) = 0

		_FlowDirection("Flow direction", vector) = (1,0,0,0)

		_FlowMap("Flow Map", 2D) = "grey" {}
		_FlowMapSpeed("SMap Speed", Range(-1, 1)) = 0.2
	}
		SubShader
		{
			Tags { "RenderType" = "Opaque" }

			Pass
			{
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#pragma target 4.6

				#include "UnityCG.cginc"

				sampler2D _MainTex;
				float4 _MainTex_ST;

				float _Threshold;
				sampler2D _CameraDepthTexture;
				sampler2D _RampTex;
				int _PowLevel;

				half _YAmplitude;

				float2 _FlowDirection;

				sampler2D _FlowMap;
				fixed _FlowMapSpeed;

				struct appdata {
					float4 vertex : POSITION;
					float2 uv : TEXCOORD0;
				};

				struct v2f
				{
					float4 pos : SV_POSITION;
					float2 uv : TEXCOORD0;
					float4 screenuv : TEXCOORD1;
					half dist : DEPTH;
				};

				v2f vert(appdata v)
				{
					v2f o;
					o.uv = TRANSFORM_TEX(v.uv, _MainTex);
					o.pos = UnityObjectToClipPos(v.vertex);
					o.screenuv = ComputeScreenPos(o.pos);
					o.pos.y += _YAmplitude * (sin(_Time.y * o.pos.x) + cos(_Time.y * o.pos.z));

					o.dist = -UnityObjectToViewPos(v.vertex).z *_ProjectionParams.w;

					return o;
				}

				fixed4 frag(v2f i) : SV_Target
				{
					i.uv += _Time.x * _FlowDirection;

					half3 flowVal = (tex2D(_FlowMap, i.uv) * 2 - 1) * _FlowMapSpeed;

					float dif1 = frac(_Time.y * 0.25 + 0.5);
					float dif2 = frac(_Time.y * 0.25);

					half lerpVal = abs((0.5 - dif1) / 0.5);

					half4 col1 = tex2D(_MainTex, i.uv - flowVal.xy * dif1);
					half4 col2 = tex2D(_MainTex, i.uv - flowVal.xy * dif2);

					fixed4 col;
					col = lerp(col1, col2, lerpVal);

					// --------- Border ------------

					float2 uv = i.screenuv.xy / i.screenuv.w;
					float depth = Linear01Depth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, uv));
					float dif = abs(depth - i.dist);
					if ((dif <= _Threshold)) {
						float v = 0;
						// Para borde brillante activa estas dos líneas y desactiva las 
						// siguientes tres:
						//v = 1-dif/_Threshold;
						//col.rgb = (col.rgb + v * 1.3 +col.rgb)/2;

						v = smoothstep(0,1,dif / _Threshold);
						v = pow(v,_PowLevel);
						col.rgb = (col.rgb + col.rgb * v) / 2;
					}
					float4 ramp = tex2D(_RampTex, float2(col.r,0));

					return ramp;
				}
				ENDCG
			}
		}
}
