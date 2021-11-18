Shader "TestShader/DisolveLava"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_DisolveTexture("Disolve Texture", 2D) = "white" {} //Textura que se usara para dar el efecto de explocion de burbuja.
		_DisolveY("Current Y of the disolve effect", Float) = 0 //Variable que indica que tanto afecta la textura al material.
		_StartingY("Startting point of the effect", Float) = -10 //Variable que controla la altura del objeto desde donde comienza el efecto
		_ColorTexture("Color Texture", Color) = (0.086, 0.407, 1, 0.749)

		_RampTex("Ramp Tex", 2D) = "white" {}
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

            sampler2D _MainTex;
            float4 _MainTex_ST;
			sampler2D _DisolveTexture;
			float _DisolveY;
			float _DisolveSize;
			float _StartingY;
			float4 _ColorTexture;

			sampler2D _RampTex;
			sampler2D _FlowMap;

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float3 worldPos : TEXCOORD1;
			};

            v2f vert (appdata v)
            {
                v2f o;
                //Calculamos el vertex para luego calcular el worldPos
				o.vertex = UnityObjectToClipPos(v.vertex);
				//Calculamos la uv que utilizaremos luego en el fragment para determinar si se debe dibujar o no el pixel 
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				//Calculamos el worldPos
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {

				//Hago el calculo para disolver la burbuja de lava utilizando el worldPos, _DisolveY y el _StartingY.
				float transition = _DisolveY - i.worldPos.y;
				clip(_StartingY + (transition + (tex2D(_DisolveTexture, i.uv)) * _DisolveY));
				//----------------------------------------------------//
				
				//Genero y retorno el color del pixel actual de la lava con la textura _RampTex.
				float4 ramp = tex2D(_RampTex, float2(0.7, 0));

                // sample the texture
				fixed4 col = tex2D(_MainTex, i.uv) * ramp;
                return col * _ColorTexture;
            }
            ENDCG
        }
    }
}
