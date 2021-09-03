Shader "Headjack/anyDegree"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_H("Horizontal Degrees",float)=360
		_V("Vertical Degrees",float)=180
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

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
				float4 vertex : SV_POSITION;
				float3 pos : TEXCOORD0;
				float2 uvScale : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _H;
            float _V;

            v2f vert (appdata v)
            {
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);

				 //The pixel shader needs to know the local vertex positions
				 //These are saved in o.pos
				o.pos=  v.vertex.xyz;

				//Divide the full panorama angles (360x180) by the custom angles
				o.uvScale=float2(360.0/_H,180.0/_V);
				return o;
            }

			//This function transforms a XYZ position/direction to an equirectangular coordinate
			float2 PositionToUV(float3 p)
			{
				return float2(atan2(p.x,p.z)*0.15915495087 ,asin(p.y)*0.3183099524);
			}
            fixed4 frag (v2f i) : SV_Target
            {
				//Calculate the uv coordinate on the texture for this pixel
				float2 uv=i.uvScale*(PositionToUV(normalize(i.pos)))+.5;

				//Check if the coordinates are between 0 and 1, multiply the result
				return tex2D(_MainTex,uv)*all(ceil(uv)==1);
            }
            ENDCG
        }
    }
}
