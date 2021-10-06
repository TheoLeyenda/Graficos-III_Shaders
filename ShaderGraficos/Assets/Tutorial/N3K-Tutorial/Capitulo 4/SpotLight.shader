Shader "TestShader/SpotLight"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_CharacterPosition ("Character position", vector) = (0,0,0,0)
		_CircleRadius ("Spotlight size", Range(0,20)) = 3
		_RingSize("Ring size", Range(0, 5)) = 1
		_ColorTint("Outside of the spotlight color", Color) = (0,0,0,0)
		_UseVertexEffectY_1("Use vertex y effect option 1", int) = 0
		_UseVertexEffectY_2("Use vertex y effect option 2", int) = 0
		_UseVertexEffectY_3("Use vertex y effect option 3", int) = 0
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
            // make fog work
            #pragma multi_compile_fog

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

				float dist : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

			float4 _CharacterPosition;
			float _CircleRadius;
			float _RingSize;
			float4 _ColorTint;
			int _UseVertexEffectY_1;
			int _UseVertexEffectY_2;
			int _UseVertexEffectY_3;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

				float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				o.dist = distance(worldPos, _CharacterPosition.xyz);

				if (_UseVertexEffectY_1 > 0) {
					o.vertex.y += o.dist;
				}
				else if (_UseVertexEffectY_2 > 0) {
					if (o.dist > 3)
						o.vertex.y += o.dist;
				}
				else if (_UseVertexEffectY_3 > 0) {
					if (o.dist > 5)
						o.vertex.y += (o.dist - 5) / 4;
				}
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = _ColorTint;
				
				//This is the player's spotlight
				if(i.dist < _CircleRadius)
					col = tex2D(_MainTex, i.uv);

				//This is the blending section
				else if (i.dist > _CircleRadius && i.dist < _CircleRadius + _RingSize)
				{
					float blendStrength = i.dist - _CircleRadius;
					col = lerp(tex2D(_MainTex, i.uv), _ColorTint, blendStrength / _RingSize);
				}
				//This is past both the player's spotlight and the blending section
				 
                return col;
            }
            ENDCG
        }
    }
}
