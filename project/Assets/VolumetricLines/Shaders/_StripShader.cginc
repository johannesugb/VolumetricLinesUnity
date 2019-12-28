// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

#ifndef VOL_LINE_STRIP_SHADER_INC
#define VOL_LINE_STRIP_SHADER_INC
	
	#include "UnityCG.cginc"
	
	float _LineWidth;
	float _LineScale;
	
	struct a2v
	{
		float4 vertex : POSITION;
		float3 prevPos : NORMAL;
		float3 nextPos : TANGENT;
		half2 texcoord : TEXCOORD0;
		float2 texcoord1 : TEXCOORD1;
	};
	
	struct v2f
	{
		float4 pos : SV_POSITION;
		half2 uv : TEXCOORD0;
	};
	
	v2f vert (a2v v)
	{
		v2f o;
		o.uv = v.texcoord;
		
#if UNITY_VERSION >= 540
		float4 clipPos = UnityObjectToClipPos(v.vertex);
		float4 clipPos_prev = UnityObjectToClipPos(float4(v.prevPos, 1.0));
		float4 clipPos_next = UnityObjectToClipPos(float4(v.nextPos, 1.0));
#else
		float4 clipPos = UnityObjectToClipPos(v.vertex);
		float4 clipPos_prev = UnityObjectToClipPos(float4(v.prevPos, 1.0));
		float4 clipPos_next = UnityObjectToClipPos(float4(v.nextPos, 1.0));
#endif

		float aspectRatio = _ScreenParams.x / _ScreenParams.y;
		float invAspectRatio = _ScreenParams.y / _ScreenParams.x;

		float2 ssPos = float2(clipPos.x * aspectRatio, clipPos.y);
		float2 ssPos_prev = float2(clipPos_prev.x * aspectRatio, clipPos_prev.y);
		float2 ssPos_next = float2(clipPos_next.x * aspectRatio, clipPos_next.y);
		
		float scaledLineWidth = _LineWidth * _LineScale;

#ifndef FOV_SCALING_OFF
		float t = unity_CameraProjection._m11;
		float fov = atan(1.0f / t) * 114.59155902616464175359630962821; // = 2 * 180 / UNITY_PI = 2 * rad2deg
		scaledLineWidth = scaledLineWidth * 60.0 / fov;
#endif
		
		// screen-space offset vectors from previous/next to current:
		float2 scrPos = ssPos.xy/clipPos.w;
		
		float2 lineDirProj_prev = scaledLineWidth * normalize(
			scrPos - ssPos_prev.xy/clipPos_prev.w
		) * sign(clipPos.w) * sign(clipPos_prev.w);

		float2 lineDirProj_next = scaledLineWidth * normalize(
			scrPos - ssPos_next.xy/clipPos_next.w
		) * sign(clipPos.w) * sign(clipPos_next.w);
		
		if (distance(v.prevPos, v.nextPos) < 1.0)
		{
			float2 offset =
				v.texcoord1.x * lineDirProj_prev +
				v.texcoord1.y * float2(lineDirProj_prev.y, -lineDirProj_prev.x)
			;
			clipPos.x += offset.x / aspectRatio;
			clipPos.y += offset.y;
		}
		else
		{
			float2 deltaNextPrev = lineDirProj_prev - lineDirProj_next;
			float2 offset = 0.5 * (
				v.texcoord1.x * deltaNextPrev +
				v.texcoord1.y * float2(deltaNextPrev.y, -deltaNextPrev.x)
			);
			clipPos.x += offset.x / aspectRatio;
			clipPos.y += offset.y;
		}
		
		o.pos = clipPos;
		return o;
	}

#if !defined(VOL_LINE_SHDMODE_FAST)
	fixed _LightSaberFactor;
	fixed4 _Color;
#endif
	sampler2D _MainTex;
	
	fixed4 frag(v2f i) : SV_Target
	{
		fixed4 tx = tex2D(_MainTex, i.uv);
		
#ifdef VOL_LINE_SHDMODE_FAST
		return tx;
#else
		return
			tx.a > _LightSaberFactor
			?
			fixed4(1.0, 1.0, 1.0, tx.a)
			:
			tx * _Color
		;
#endif
	}
	
#endif
