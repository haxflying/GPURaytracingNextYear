Shader "Hidden/InitRaytraceShader"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		Cull Off ZWrite Off ZTest Always

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
				float3 ray : TEXCOORD1;
				float4 vertex : SV_POSITION;
			};

			struct sphere
			{
				float3 center;
				float radius;
				float4 color;
			};

			StructuredBuffer<sphere> obj_spheres;
			int obj_spheres_length;
			int _index;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				o.ray =  mul(unity_CameraInvProjection, float4((float2(v.uv.x, v.uv.y) - 0.5) * 2, -1, -1));
				return o;
			}
			
			UNITY_DECLARE_DEPTH_TEXTURE(_CameraDepthTexture);
			sampler2D _MainTex;

			inline float3 computeCameraSpacePosFromDepthAndVSInfo(v2f i)
			{
			    float zdepth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv.xy);

			    // 0..1 linear depth, 0 at camera, 1 at far plane.
			    float depth = lerp(Linear01Depth(zdepth), zdepth, unity_OrthoParams.w);
				#if defined(UNITY_REVERSED_Z)
				    zdepth = 1 - zdepth;
				#endif

			    float3 vposPersp = i.ray * depth;
			    return vposPersp.xyz;
			}


			fixed4 frag (v2f i) : SV_Target
			{
				i.ray *= (_ProjectionParams.z / i.ray.z);
				float3 vpos = computeCameraSpacePosFromDepthAndVSInfo(i);
				float3 wpos = mul (unity_CameraToWorld, float4(vpos, 1));				
				return float4(wpos, 1);
			}
			ENDCG
		}
	}
}
