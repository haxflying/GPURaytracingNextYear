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
			#pragma multi_compile __ _INIT
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

			struct fout
			{
				float4 dest0 : SV_Target0;
				float4 dest1 : SV_Target1;
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
			sampler2D _TexLastHitNormal;
			sampler2D _TexLastHitPos;
			sampler2D _CameraGBufferTexture2;

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

			inline bool raytrace(float3 origin, float3 direction, sphere obj, inout float3 point, inout float3 normal)
			{
				float3 rayDir = direction;
				float3 originToCenter = origin - obj.center;
				float b = dot(rayDir, originToCenter);
				float c = dot(originToCenter, originToCenter) - obj.radius * obj.radius;
				float d = sqrt(b * b - c);
				float start = -b - d;
				float end = -b + d;
				point = origin + rayDir * min(start, end);
				normal = normalize(point - obj.center);

				return (start > 0) && (end > 0)
			}



			fout frag (v2f i) : SV_Target
			{
				fout o;
				
				#if _INIT
				i.ray *= (_ProjectionParams.z / i.ray.z);
				float3 vpos = computeCameraSpacePosFromDepthAndVSInfo(i);
				float3 wpos = mul (unity_CameraToWorld, float4(vpos, 1));
				float3 wnormal = tex2D(_CameraGBufferTexture2, i.uv).rgb;
				o.dest0 = float4(wpos, 1);
				o.dest1 = float4(wnormal, 1);
				#else
				o.dest0 = 0;
				o.dest1 = 0;
				float4 origins = tex2D(_TexLastHitPos, i.uv);
				if(origins.a != 0)
				{
					float3 normals = tex2D(_TexLastHitNormal, i.uv);
					float3 point = 0;
					float3 normal = 0;
					for (int j = 0; j < obj_spheres_length; ++j)
					{
						if(raytrace(origins.xyz, normals, obj_spheres[j], point, normal))
						{
							o.dest0 = float4(point, 1);
							o.dest1 = float4(normal, 1);
						}
					}	
				}			
				#endif
				return o;
			}
			ENDCG
		}
	}
}
