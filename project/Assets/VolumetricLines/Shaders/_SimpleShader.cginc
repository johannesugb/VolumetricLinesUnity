#ifndef VOL_LINE_SIMPLE_SHADER_INC
#define VOL_LINE_SIMPLE_SHADER_INC
	
	#include "UnityCG.cginc"
	
	sampler2D _MainTex;
	float4 _MainTex_ST;
	float _LineWidth;
	float _LineScale;
	float _CAMERA_FOV = 60.0f;
#if !defined(VOL_LINE_SHDMODE_FAST)
	float _LightSaberFactor;
	float4 _Color;
#endif
	
	struct a2v
	{
		float4 vertex : POSITION;
		float3 normal : NORMAL;
		float4 texcoord : TEXCOORD0;
		float2 texcoord1 : TEXCOORD1;
	};
	
	struct v2f
	{
		float4 pos : POSITION;
		float2 uv : TEXCOORD0;
	};
	
	v2f vert (a2v v)
	{
		v2f o;
		o.uv = TRANSFORM_TEX (v.texcoord, _MainTex);
		
		float4 vMVP = mul(UNITY_MATRIX_MVP, v.vertex);
		float4 otherPos = float4(v.normal.xyz, 1.0);
		float4 otherMVP = mul(UNITY_MATRIX_MVP, otherPos);
		float scaledLineWidth = _LineWidth * _LineScale;
#if FOV_SCALING_ON
		scaledLineWidth *= (60.0 / _CAMERA_FOV); // 60 = 180 / scaling factor
#endif
		float2 lineDirProj = scaledLineWidth * normalize((vMVP.xy/vMVP.w) - (otherMVP.xy/otherMVP.w));
		
		vMVP.x = vMVP.x + lineDirProj.x * v.texcoord1.x + lineDirProj.y * v.texcoord1.y;
		vMVP.y = vMVP.y + lineDirProj.y * v.texcoord1.x - lineDirProj.x * v.texcoord1.y;
		o.pos = vMVP;
		return o;
	}
	
	float4 frag(v2f i) : COLOR
	{
		float4 tx = tex2D (_MainTex, i.uv);
		
#ifdef VOL_LINE_SHDMODE_FAST
		return tx;
#else
		if (tx.a > _LightSaberFactor)
		{
			return float4(1.0, 1.0, 1.0, tx.a);
		}
		else
		{
			return tx * _Color;
		}
#endif
	}
	
#endif
