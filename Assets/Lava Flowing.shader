// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "ARCore/Unlit/Distort" 
{
Properties {
	_Color ("Main Color", Color) = (1,1,1)
	_DistortX ("Distortion in X", Range (0,2)) = 1
	_DistortY ("Distortion in Y", Range (0,2)) = 0
	_MainTex ("_MainTex RGBA", 2D) = "white" {}
	_Distort ("_Distort A", 2D) = "white" {}
	_LavaTex ("_LavaTex RGB", 2D) = "white" {}


	//_MainTex ("Texture", 2D) = "white" {}
    _UvRotation ("UV Rotation", float) = 30

}

Category {
	Tags { "RenderType"="Opaque" }

	Lighting Off
	
	Tags { "Queue"="Transparent" "RenderType"="Opaque" }
        Blend SrcAlpha OneMinusSrcAlpha
        ZTest on
        ZWrite off



	SubShader {
		Pass {
		
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			sampler2D _MainTex;
			sampler2D _Distort;
			sampler2D _LavaTex;
			
			struct appdata_t {
				fixed4 vertex : POSITION;
				fixed2 texcoord : TEXCOORD0;
			
				fixed4 color : COLOR;
			};

			struct v2f {
				fixed4 vertex : SV_POSITION;
				fixed2 texcoord : TEXCOORD0;
				fixed2 texcoord1 : TEXCOORD1;


                fixed4 color : COLOR;
			};
			
			fixed4 _MainTex_ST;
			fixed4 _LavaTex_ST;
			
			fixed _DistortX;
			fixed _DistortY;

		
            fixed _UvRotation;

			v2f vert (appdata_t v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.texcoord = TRANSFORM_TEX(v.texcoord,_MainTex);
				o.texcoord1 = TRANSFORM_TEX(v.texcoord,_LavaTex);




				fixed cosr = cos(_UvRotation);
                fixed sinr = sin(_UvRotation);
                fixed2x2 uvrotation = fixed2x2(cosr, -sinr, sinr, cosr);

                float2 uv = mul(UNITY_MATRIX_M, v.vertex).xz * _MainTex_ST.xy;
                o.texcoord = mul(uvrotation, uv);
                o.color = v.color;
            




				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 tex = tex2D(_MainTex, i.texcoord);
				fixed distort = tex2D(_Distort, i.texcoord).a;
				fixed4 tex2 = tex2D(_LavaTex, fixed2(i.texcoord1.x-distort*_DistortX,i.texcoord1.y-distort*_DistortY));
				tex = lerp(tex2,tex,tex.a);

				return tex;
			}
			ENDCG 
		}
	}	
}
}
