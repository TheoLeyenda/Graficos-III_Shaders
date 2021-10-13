Shader "Custom/WaterShader_Unlit"
{
	Properties{
		_Color("Colour", Color) = (0, 0, 0, 1)
		_Strength("Strength", Range(0,2)) = 1.0
		_Speed("Speed", Range(-200, 200)) = 100
	}
	SubShader
	{
		Tags { "RenderType" = "Transparent" "Queue" = "Transparent" }

		Pass
		{
			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha
		CGPROGRAM
	#pragma vertex vertexFunc
	#pragma fragment fragmentFunc
			
			#include "UnityCG.cginc"
		float4 vec4(float x,float y,float z,float w) { return float4(x,y,z,w); }
		float4 vec4(float x) { return float4(x,x,x,x); }
		float4 vec4(float2 x,float2 y) { return float4(float2(x.x,x.y),float2(y.x,y.y)); }
		float4 vec4(float3 x,float y) { return float4(float3(x.x,x.y,x.z),y); }


		float3 vec3(float x,float y,float z) { return float3(x,y,z); }
		float3 vec3(float x) { return float3(x,x,x); }
		float3 vec3(float2 x,float y) { return float3(float2(x.x,x.y),y); }

		float2 vec2(float x,float y) { return float2(x,y); }
		float2 vec2(float x) { return float2(x,x); }

		float vec(float x) { return float(x); }

		float4 _Color;
		float _Strength;
		float _Speed;

		struct vertexInput
		{
			float4 vertex : POSITION;
			float2 uv:TEXCOORD0;
			float4 tangent : TANGENT;
			float3 normal : NORMAL;
			//VertexInput
		};

		struct vertexOutput
		{
			float4 pos : SV_POSITION;
			float2 uv:TEXCOORD0;
			//VertexOutput
		};

		vertexOutput vertexFunc(vertexInput IN)
		{
			vertexOutput o;

			float4 worldPos = mul(unity_ObjectToWorld, IN.vertex);

			float displacement = (cos(worldPos.y) + cos(worldPos.x + (_Speed * _Time)));
			worldPos.y = worldPos.y + (displacement * _Strength);

			o.pos = mul(UNITY_MATRIX_VP, worldPos);

			o.pos = UnityObjectToClipPos(IN.vertex) + o.pos;
			o.uv = IN.uv;

			return o;
		}

#define TAU 6.28318530718
#define MAX_ITER 5

		fixed4 fragmentFunc(vertexOutput vertex_output) : SV_Target
		{
				float time = _Time.y * .5 + 23.0;
				// uv should be the 0-1 uv of tex2D...
				float2 uv = vertex_output.uv / 1;

#ifdef SHOW_TILING
				float2 p = fmod(uv*TAU*2.0, TAU) - 250.0;
#else
				float2 p = fmod(uv*TAU, TAU) - 250.0;
#endif
				float2 i = vec2(p);
				float c = 1.0;
				float inten = .005;

				for (int n = 0; n < MAX_ITER; n++)
				{
					float t = time * (1.0 - (3.5 / float(n + 1)));
					i = p + vec2(cos(t - i.x) + sin(t + i.y), sin(t - i.y) + cos(t + i.x));
					c += 1.0 / length(vec2(p.x / (sin(i.x + t) / inten),p.y / (cos(i.y + t) / inten)));
				}
				c /= float(MAX_ITER);
				c = 1.17 - pow(c, 1.4);
				float3 colour = vec3(pow(abs(c), 8.0));
				colour = clamp(colour + vec3(0.0, 0.35, 0.5), 0.0, 1.0);


#ifdef SHOW_TILING
				// Flash tile borders...
				float2 pixel = 2.0 / 1;
				uv *= 2.0;

				float f = floor(fmod(_Time.y*.5, 2.0)); 	// Flash value.
				float2 first = step(pixel, uv) * f;		   	// Rule out first screen pixels and flash.
				uv = step(frac(uv), pixel);				// Add one line of pixels per tile.
				colour = lerp(colour, vec3(1.0, 1.0, 0.0), (uv.x + uv.y) * first.x * first.y); // Yellow line

				#endif
				return vec4(colour, 1.0) * _Color;
		}

		ENDCG
		}
	}
}
