Shader "TestShader/Lava"
{
	Properties{
		_MainTex("Texture", 2D) = "black" {} //Textura que representa el mapa (Forma) de la lava

		_RampTex("Ramp Tex", 2D) = "white" {} //Textura que representa la gama de colores de la lava.

		_YAmplitude("Y_Amplitude" , Range(0,1)) = 0 //Variable que controla el movimiento vertical de la textura haciendo el efecto de olas en la lava.

		_FlowDirection("Flow direction", vector) = (1,0,0,0) //Variable que controla la direccion hacia donde se movera la textura para hacer el efecto del fluido de la lava.

		_FlowMap("Flow Map", 2D) = "grey" {} //Textura que representara el movimiento de la lava dentro de la textura (Se usara para simular el movmiento de la lava por su temperatura).
		_FlowMapSpeed("SMap Speed", Range(-1, 1)) = 0.2 // Velocidad a la que realizo el movimiento de de la lava dentro de la textura.
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

				sampler2D _RampTex;

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
				};

				v2f vert(appdata v)
				{
					v2f o;
					o.uv = TRANSFORM_TEX(v.uv, _MainTex);

					//Realizo el efecto de ebullision
					o.pos = UnityObjectToClipPos(v.vertex);
					o.screenuv = ComputeScreenPos(o.pos);
					o.pos.y += _YAmplitude * (sin(_Time.y * o.pos.x) + cos(_Time.y * o.pos.z)); // Computo la nueva posicion Y para
					//---------------------------------//

					return o;
				}

				fixed4 frag(v2f i) : SV_Target
				{
					i.uv += _Time.x * _FlowDirection; //Movimiento de la textura de la lava
					
					//Calculo el movimieno de la lava segun la textura _FlowMap y su velocidad _FlowMapSpeed
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
					float4 ramp = tex2D(_RampTex, float2(col.r,0));

					return ramp;
					//-------------------------------------------------------------------------------//
				}
				ENDCG
			}
		}
}
