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
				float4 dest2 : SV_Target2;
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
			sampler2D _TexLastHitColor;
			sampler2D _CameraGBufferTexture0;
			sampler2D _CameraGBufferTexture2;
			uint rng_state = 2;

			float rand_xorshift()
			{
			    // Xorshift algorithm from George Marsaglia's paper
			    rng_state ^= (rng_state << 13);
			    rng_state ^= (rng_state >> 17);
			    rng_state ^= (rng_state << 5);
			    float f0 = float(rng_state) * (1.0 / 4294967296.0);
			    return f0;
			}

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

			inline bool raytrace(float3 origin, float3 direction, float3 center, float radius, 
				inout float3 hitpoint, inout float3 hitnormal, inout float dist)
			{
				direction = direction;
				float3 oc = origin - center;
				float a = dot(direction, direction);
				float b = 2 * dot(oc, direction);
				float c = dot(oc, oc) - radius * radius;
				float discriminant = b * b - 4 * a * c;
				dist = (-b - sqrt(discriminant))/ (2 * a);
				hitpoint = origin + direction * dist;
				hitnormal = normalize(hitpoint - center);

				return discriminant > 0;
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
				o.dest2 = tex2D(_CameraGBufferTexture0, i.uv);

				#else

				o.dest0 = 0;
				o.dest1 = 0;
				o.dest2 = UNITY_LIGHTMODEL_AMBIENT;
				float4 origins = tex2D(_TexLastHitPos, i.uv);
				//if this ray is still alive
				if(origins.a != 0)
				{
					float3 normals = tex2D(_TexLastHitNormal, i.uv);
					float4 colors = tex2D(_TexLastHitColor, i.uv);
					float4 albedo = tex2D(_CameraGBufferTexture0, i.uv);
					float3 hitpoint = 0;
					float3 hitnormal = 0;

					float dist = 0;
					float minDist = _ProjectionParams.z;
					for (int j = 0; j < obj_spheres_length; ++j)
					{
						//if this ray hit anything
						if(raytrace(origins.xyz, normals, obj_spheres[j].center, obj_spheres[j].radius, hitpoint, hitnormal, dist))
						{
							//if(dist < minDist)
							{
								o.dest0 = float4(hitpoint, 1);
								o.dest1 = float4(hitnormal, 1);
								o.dest2 = 0;//colors * albedo;
								minDist = dist;
							}															
						}
						else
						{
							o.dest2 = 1;//colors * UNITY_LIGHTMODEL_AMBIENT;
						}						
					}	

				}	
				else
				{
					o.dest2 = 0.5;//UNITY_LIGHTMODEL_AMBIENT;
				}	
				#endif

				return o;
			}
			ENDCG
		}
	}
}
