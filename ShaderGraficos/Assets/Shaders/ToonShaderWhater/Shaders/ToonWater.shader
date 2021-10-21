Shader "TestShader/Toon/Water"
{
    Properties
    {	
		_DepthGradientShallow("Depth Gradient Shallow", Color) = (0.325, 0.807, 0.971, 0.725) // Color del agua de la orilla.
		_DepthGradientDeep("Depth Gradient Deep", Color) = (0.086, 0.407, 1, 0.749) // Color del agua profunda.
		_DepthMaxDistance("Depth Maximum Distance", Float) = 1 // Variable que controla el maximo de gradiente de la profundidad del agua.

		_SurfaceNoise("Surface Noise", 2D) = "white" {} // Textura de ruido para simular el flujo del agua en la superficie.
		_SurfaceNoiseCutoff("Surface Noise Cutoff", Range(0, 1)) = 0.777 // Variable entre el 0 y el 1 para controlar la aparicion de la espuma en la superficie.

		_FoamMinDistance("Foam Minimum Distance", Float) = 0.04 //Minima cantidad de espuma que se puede generar en la costa.
		_FoamMaxDistance("Foam Maximum Distance", Float) = 0.4 // Maxima cantidad de espuma que se puede generar en la costa.

		_SurfaceNoiseScroll("Surface Noise Scroll Amount", Vector) = (0.03, 0.03, 0, 0) //Vector de direccion y velocidad del movimiento del agua.
		_SurfaceDistortion("Surface Distortion", 2D) = "white" {} //Textura de distorcion que utilizaremos para generar una sensacion aleatoria a la hora de mover la espuma del agua.
		_SurfaceDistortionAmount("Surface Distortion Amount", Range(0, 1)) = 0.27 // Valor que representa que tanto se distorcionara el movimiento de la espuma.
		_FoamColor("Foam Color", Color) = (1,1,1,1) // Color de la espuma.

		_Strength("Strength", Range(0,2)) = 1.0
		_Speed("Speed", Range(-200, 200)) = 100
    }
    SubShader
    {
        Pass
        {
			//Haremos que el shader tenga transparencia para que simule mejor el agua.
			Tags
			{
				"Queue" = "Transparent"
			}
			Blend SrcAlpha OneMinusSrcAlpha
			ZWrite Off
			//-----------------------------------------------//

			CGPROGRAM
			#define SMOOTHSTEP_AA 0.01
			#pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
			
			float4 alphaBlend(float4 top, float4 bottom)
			{
				float3 color = (top.rgb * top.a) + (bottom.rgb * (1 - top.a));
				float alpha = top.a + bottom.a * (1 - top.a);

				return float4(color, alpha);
			}			
			
			float random(float2 uv)
			{
				return frac(sin(dot(uv,float2(12.9898,78.233)))*43758.5453123);
			}

            struct appdata
            {
				float3 normal : NORMAL;
				float4 uv : TEXCOORD0;
                float4 vertex : POSITION;
            };

            struct v2f
            {
				float3 viewNormal : NORMAL;
				float2 noiseUV : TEXCOORD0;
				float2 distortUV : TEXCOORD1;
                float4 vertex : SV_POSITION;
				float4 screenPosition : TEXCOORD2;
            };

			//Propiedades declaradas dentro del shader para poder ser usadas.
			float4 _DepthGradientShallow;
			float4 _DepthGradientDeep;
			float _DepthMaxDistance;
			sampler2D _CameraDepthTexture;
			sampler2D _SurfaceNoise;
			float4 _SurfaceNoise_ST;
			float _SurfaceNoiseCutoff;
			//float _FoamDistance; // REMPLAZADO POR LAS DOS LINEAS DE ABAJO
			float _FoamMaxDistance;
			float _FoamMinDistance;
			float2 _SurfaceNoiseScroll;
			sampler2D _SurfaceDistortion;
			float4 _SurfaceDistortion_ST;
			float _SurfaceDistortionAmount;
			sampler2D _CameraNormalsTexture;
			float4 _FoamColor;

			

			float _Strength;
			float _Speed;
			//---------------------------------------------------------------//

            v2f vert (appdata v)
            {
                v2f o;

                //o.vertex = UnityObjectToClipPos(v.vertex);

				float4 worldPos = mul(unity_ObjectToWorld, v.vertex);

				float displacement = (cos(worldPos.y) + cos(worldPos.x + (_Speed * _Time)));
				worldPos.y = worldPos.y + (displacement * _Strength);

				o.vertex = mul(UNITY_MATRIX_VP, worldPos);

				o.screenPosition = ComputeScreenPos(o.vertex); //Computamos la posicion del pixel de profundidad.
				o.noiseUV = TRANSFORM_TEX(v.uv, _SurfaceNoise); //Computamos la textura de ruido.
				o.distortUV = TRANSFORM_TEX(v.uv, _SurfaceDistortion); // Computamos la textura de distorcion.
				o.viewNormal = COMPUTE_VIEW_NORMAL;
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
				//Proceso la profundidad del pixel en funcion a la posicion de la camara, si movemos la camara veremos como el gradiente de la profundidad del agua tambien se mueve.
				float existingDepth01 = tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD(i.screenPosition)).r;
				float existingDepthLinear = LinearEyeDepth(existingDepth01); 
				float depthDifference = existingDepthLinear - i.screenPosition.w;
				//--------------------------------------------------------------------//

				//Generamos el color interpolado utilizando el depthDifference antes calculado, el color 
				//_DepthGradientShallow que representa el color del agua cerca de la superficie (orillas) y 
				//el color _DepthGradientDeep que representa el color del agua en la parte donde su profundidad es alta.
				float waterDepthDifference01 = saturate(depthDifference / _DepthMaxDistance);
				float4 waterColor = lerp(_DepthGradientShallow, _DepthGradientDeep, waterDepthDifference01);
				//------------------------------------------------------------------------------//

				//Generamos la distorcion de la espuma utilizando el _SurfaceDistortion y el _SurfaceDistortionAmount
				float2 distortSample = (tex2D(_SurfaceDistortion, i.distortUV).xy * 2 - 1) * _SurfaceDistortionAmount;
				//------------------------------------------------------------------------------//

				//Utilizamos el _SurfaceNoiseScroll y movemos la textura del agua para generar una sensacion de flujo en el agua.
				float2 noiseUV = float2((i.noiseUV.x + _Time.y * _SurfaceNoiseScroll.x) + distortSample.x, (i.noiseUV.y + _Time.y * _SurfaceNoiseScroll.y) + distortSample.y);
				//---------------------------------------------------------------------------------//

				//Calculamos el surfaceNoiseSample que representara la "espuma" que se genera en el agua y que representa el flujo de esta
				//Utilizando la textura de ruido _SurfaceNoise y el noiseUV.
				float surfaceNoiseSample = tex2D(_SurfaceNoise, noiseUV).r; 
				//-------------------------------------------------------------------------------//

				//Utilizamos las normales de la camara para poder generar una espuma uniforme en el shader y que no se vea pixelada.
				float3 existingNormal = tex2Dproj(_CameraNormalsTexture, UNITY_PROJ_COORD(i.screenPosition));
				float3 normalDot = saturate(dot(existingNormal, i.viewNormal));
				//----------------------------------------------------------------------------------------------------//

				// Generamos la espuma en la orilla utilizando el _FoamMaxDistance, el _FoamMinDistanc y la normalDot
				float foamDistance = lerp(_FoamMaxDistance, _FoamMinDistance, normalDot);
				float foamDepthDifference01 = saturate(depthDifference / foamDistance);
				float surfaceNoiseCutoff = foamDepthDifference01 * _SurfaceNoiseCutoff;
				//------------------------------------------------------------------------------------//

				//Utilizams el surfaceNoiseCutoff para determinar cuanto afectara la textura de _SurfaceDistortion a nuestra espuma.
				float surfaceNoise = smoothstep(surfaceNoiseCutoff - SMOOTHSTEP_AA, surfaceNoiseCutoff + SMOOTHSTEP_AA, surfaceNoiseSample);
				//----------------------------------------------------------------------------------------------------------------------------//

				//Utilizamos el _FoamColor para darle color a la espuma
				float4 surfaceNoiseColor = _FoamColor;
				surfaceNoiseColor.a *= surfaceNoise;
				//---------------------------------------------------//

				//Retorno el color del pixel actual y genero un alphaBlend para que si el pixel se trata de espuma este tome el color de _FoamColor.
				return alphaBlend(surfaceNoiseColor, waterColor);
				//--------------------------------------------------//
            }
            ENDCG
        }
    }
}