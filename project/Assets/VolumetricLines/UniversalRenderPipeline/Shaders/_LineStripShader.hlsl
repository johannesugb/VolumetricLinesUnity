#ifndef VOL_LINE_LINE_STRIP_SHADER_URP_INC
#define VOL_LINE_LINE_STRIP_SHADER_URP_INC
	
	// Property-variables declarations
	TEXTURE2D(_MainTex);
    SAMPLER(sampler_MainTex);
	half4 _MainTex_ST;
	float _LineWidth;
	float _LineScale;
#ifdef LIGHT_SABER_MODE_ON
	float _LightSaberFactor;
	int _UvBasedLightSaberFactor;
	float4 _Color;
#endif
	
	// Vertex shader input attributes
	struct a2v
	{
		float4 vertex : POSITION;
		float3 prevPos : NORMAL;
		float3 nextPos : TANGENT;
		half2 texcoord : TEXCOORD0;
		float2 texcoord1 : TEXCOORD1;

		UNITY_VERTEX_INPUT_INSTANCE_ID
	};
	
	// Vertex out/fragment in data:
	struct v2f
	{
		float4 pos : SV_POSITION;
		half2 uv : TEXCOORD0;

		UNITY_VERTEX_INPUT_INSTANCE_ID
		UNITY_VERTEX_OUTPUT_STEREO
	};
	
	// Vertex shader
	v2f vert (a2v v)
	{
		v2f o;
						
		UNITY_SETUP_INSTANCE_ID(v);
		ZERO_INITIALIZE(v2f, o);
		UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

		// Pass on texture coordinates to fragment shader as they are:
		o.uv = v.texcoord;
		
		// Transform to homogeneous clip space:
		float4 csPos = TransformObjectToHClip(v.vertex.xyz);
		float4 csPos_prev = TransformObjectToHClip(v.prevPos);
		float4 csPos_next = TransformObjectToHClip(v.nextPos);
		
		// Scale to properly match Unity's world space units:
		// The `projScale` factor also handles different field of view values, which 
		// used to be handled via FOV_SCALING_OFF in previous versions of this asset.
		// Furthermore, `projScale` handles orthographic projection matrices gracefully.
		float projScale = unity_CameraProjection._m11 * 0.5;
		float scaledLineWidth = _LineWidth * _LineScale * projScale;

		float aspectRatio = unity_CameraProjection._m11 / unity_CameraProjection._m00;
		// The line direction in (aspect-ratio corrected) clip space (and scaled by witdh):
		float2 lineDirProj_prev = normalize(
			csPos.xy * aspectRatio / csPos.w - // screen-space pos of current end
			csPos_prev.xy * aspectRatio / csPos_prev.w // screen-space position of the other "previous" end
		) * sign(csPos.w) * sign(csPos_prev.w) * scaledLineWidth;
		float2 lineDirProj_next = normalize(
			csPos.xy * aspectRatio / csPos.w - // screen-space pos of current end
			csPos_next.xy * aspectRatio / csPos_next.w // screen-space position of the other "next" end
		) * sign(csPos.w) * sign(csPos_next.w) * scaledLineWidth;
		
		float2 offset;
		if (distance(v.prevPos, v.nextPos) < 1.0)
		{
			offset =
				v.texcoord1.x * lineDirProj_prev +
				v.texcoord1.y * float2(lineDirProj_prev.y, -lineDirProj_prev.x);
		}
		else
		{
			float2 deltaNextPrev = lineDirProj_prev - lineDirProj_next;
			offset = 0.5 * (
				v.texcoord1.x * deltaNextPrev +
				v.texcoord1.y * float2(deltaNextPrev.y, -deltaNextPrev.x)
			);
		}

		// Apply (aspect-ratio corrected) offset
		csPos.x += offset.x / aspectRatio;
		csPos.y += offset.y;
		o.pos = csPos;

		return o;
	}

	// Fragment shader
	float4 frag(v2f i) : SV_Target
	{
		UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);

		float4 tx = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv);
		
#ifdef LIGHT_SABER_MODE_ON
		if (_UvBasedLightSaberFactor == 1) 
		{
			float2 uv2 = i.uv * 2.0 - 1.0;
			float c = sqrt(uv2[0] * uv2[0] + uv2[1] * uv2[1]);
			return lerp(tx * _Color, float4(1.0, 1.0, 1.0, tx.a), clamp((1.02 - c - _LightSaberFactor) * 100.0, 0, 1));
		}
		else 
		{
			return tx.a > _LightSaberFactor ? float4(1.0, 1.0, 1.0, tx.a) : tx * _Color;
		}
#else
		return tx;
#endif
	}
	
#endif
