Shader "Hidden/FullScreenResolve"
{
	Properties
	{
	}
	SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always
		Tags{ "Queue" = "Transparent" }

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 5.0

			#include "UnityCG.cginc"
			#include "Structs.cginc"

			StructuredBuffer<Ray> _Rays;

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

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}

			float2 _AccumulatedImageSize;

			float4 frag(v2f i) : SV_Target{
				float2 size = _AccumulatedImageSize;
				int2 xy = i.uv * size;

				uint rayCount, stride;
				_Rays.GetDimensions(rayCount, stride);

				float4 color = float4(0, 0, 0, 0);

				for (int z = 0; z < 8; z++) {
					int rayIndex = xy.x * size.y
						+ xy.y
						+ size.x * size.y * (z);

					color += _Rays[rayIndex % rayCount].accumColor;
				}
				return color / color.a;
			}
			ENDCG
		}
	}
}
