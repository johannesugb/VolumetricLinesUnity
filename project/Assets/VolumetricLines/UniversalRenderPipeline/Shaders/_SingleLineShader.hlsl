#ifndef VOL_LINE_SINGLE_LINE_SHADER_URP_INC
#define VOL_LINE_SINGLE_LINE_SHADER_URP_INC
	
	// Property-variables declarations
	TEXTURE2D(_MainTex);
    SAMPLER(sampler_MainTex);
	half4 _MainTex_ST;
	float _LineWidth;
	float _LineScale;
#ifdef LIGHT_SABER_MODE_ON
	float _LightSaberFactor;
	float4 _Color;
#endif

	// Vertex shader input attributes
	struct a2v
	{
		float4 vertex : POSITION;
		float3 otherPos : NORMAL; // object-space position of the other end
		half2 texcoord : TEXCOORD0;
		float2 texcoord1 : TEXCOORD1;
	};
	
	// Vertex out/fragment in data:
	struct v2f
	{
		float4 pos : SV_POSITION;
		half2 uv : TEXCOORD0;
	};
	
	// Vertex shader
	v2f vert (a2v v)
	{
		v2f o;
		// Pass on texture coordinates to fragment shader as they are:
		o.uv = v.texcoord;
		
		// Transform to homogeneous clip space:
		float4 csPos = TransformObjectToHClip(v.vertex.xyz);
		float4 csPos_other = TransformObjectToHClip(v.otherPos);

		// Scale to properly match Unity's world space units:
		// The `projScale` factor also handles different field of view values, which 
		// used to be handled via FOV_SCALING_OFF in previous versions of this asset.
		// Furthermore, `projScale` handles orthographic projection matrices gracefully.
		float projScale = unity_CameraProjection._m11 * 0.5;
		float scaledLineWidth = _LineWidth * _LineScale * projScale;

		float2 lineDirProj = normalize(
			csPos.xy / csPos.w - 				// clip-space pos of current end
			csPos_other.xy / csPos_other.w 		// clip-space position of the other end
		)
		 * scaledLineWidth						// scale the offsets based on the line width
		 * sign(csPos.w) * sign(csPos_other.w);	// correct the cases when one end points is outside of the frustum
		
		// Offset for our current vertex:
		float2 offset =
			v.texcoord1.x * lineDirProj +
			v.texcoord1.y * float2(lineDirProj.y, -lineDirProj.x)
		;
		
		// Apply (aspect-ratio corrected) offset
		float aspectRatio = _ScreenParams.x / _ScreenParams.y;
		csPos.x += offset.x / aspectRatio;
		csPos.y += offset.y;
		o.pos = csPos;

		return o;
	}	
	
	// Fragment shader
	float4 frag(v2f i) : SV_Target
	{
		float4 tx = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv);
		
#ifdef LIGHT_SABER_MODE_ON
		return tx.a > _LightSaberFactor ? float4(1.0, 1.0, 1.0, tx.a) : tx * _Color;
#else
		return tx;
#endif
	}
	
#endif
