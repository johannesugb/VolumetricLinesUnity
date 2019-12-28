// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

#ifndef VOL_LINE_SIMPLE_SHADER_INC
#define VOL_LINE_SIMPLE_SHADER_INC
	
	#include "UnityCG.cginc"
	
	float _LineWidth;
	float _LineScale;
	
	struct a2v
	{
		float4 vertex : POSITION;
		float3 otherPos : NORMAL; // object-space position of the other end
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
		float4 clipPos_other = UnityObjectToClipPos(float4(v.otherPos, 1.0));
#else
		float4 clipPos = UnityObjectToClipPos(v.vertex);
		float4 clipPos_other = UnityObjectToClipPos(float4(v.otherPos, 1.0));
#endif

		float aspectRatio = _ScreenParams.x / _ScreenParams.y;
		float invAspectRatio = _ScreenParams.y / _ScreenParams.x;

		float2 ssPos = float2(clipPos.x * aspectRatio, clipPos.y);
		float2 ssPos_other = float2(clipPos_other.x * aspectRatio, clipPos_other.y);

		float scaledLineWidth = _LineWidth * _LineScale;

#ifndef FOV_SCALING_OFF
		float t = unity_CameraProjection._m11;
		float fov = atan(1.0f / t) * 114.59155902616464175359630962821; // = 2 * 180 / UNITY_PI = 2 * rad2deg
		scaledLineWidth = scaledLineWidth * 60.0 / fov;
#endif
		
		// screen-space offset vector:
		float2 lineDirProj = scaledLineWidth * normalize(
			ssPos.xy/clipPos.w - // screen-space pos of current end
			ssPos_other.xy/clipPos_other.w // screen-space position of the other end
		) * sign(clipPos.w) * sign(clipPos_other.w);
		
		float2 offset =
			v.texcoord1.x * lineDirProj +
			v.texcoord1.y * float2(lineDirProj.y, -lineDirProj.x)
		;
		
		clipPos.x += offset.x / aspectRatio;
		clipPos.y += offset.y;
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
