#ifndef VOL_LINE_SINGLE_LINE_SHADER_INC
#define VOL_LINE_SINGLE_LINE_SHADER_INC
	
	#include "UnityCG.cginc"
	
	// Property-variables declarations
	sampler2D _MainTex;
	float _LineWidth;
	float _LineScale;
#ifdef LIGHT_SABER_MODE_ON
	fixed _LightSaberFactor;
	fixed4 _Color;
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
		float4 csPos = UnityObjectToClipPos(v.vertex);
		float4 csPos_other = UnityObjectToClipPos(float4(v.otherPos, 1.0));

		// Scale to properly match Unity's world space units:
		// The `projScale` factor also handles different field of view values, which 
		// used to be handled via FOV_SCALING_OFF in previous versions of this asset.
		// Furthermore, `projScale` handles orthographic projection matrices gracefully.
		float projScale = unity_CameraProjection._m11 * 0.5;
		float scaledLineWidth = _LineWidth * _LineScale * projScale;

		float aspectRatio = _ScreenParams.x / _ScreenParams.y;
		// The line direction in (aspect-ratio corrected) clip space (and scaled by witdh):
		float2 lineDirProj = normalize(
			csPos.xy * aspectRatio / csPos.w - // screen-space pos of current end
			csPos_other.xy * aspectRatio / csPos_other.w // screen-space position of the other end
		) * sign(csPos.w) * sign(csPos_other.w) * scaledLineWidth;
		
		// Offset for our current vertex:
		float2 offset =
			v.texcoord1.x * lineDirProj +
			v.texcoord1.y * float2(lineDirProj.y, -lineDirProj.x)
		;

		// Apply (aspect-ratio corrected) offset
		csPos.x += offset.x / aspectRatio;
		csPos.y += offset.y;
		o.pos = csPos;

		return o;
	}
	
	// Fragment shader
	fixed4 frag(v2f i) : SV_Target
	{
		fixed4 tx = tex2D(_MainTex, i.uv);
		
#ifdef LIGHT_SABER_MODE_ON
		return tx.a > _LightSaberFactor ? float4(1.0, 1.0, 1.0, tx.a) : tx * _Color;
#else
		return tx;
#endif
	}
	
#endif
