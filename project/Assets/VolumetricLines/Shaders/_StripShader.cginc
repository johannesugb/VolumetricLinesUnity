#ifndef VOL_LINE_STRIP_SHADER_INC
#define VOL_LINE_STRIP_SHADER_INC
	
	#include "UnityCG.cginc"
	
	sampler2D _MainTex;
	float4 _MainTex_ST;
	float4 _Color;
	float _LineWidth;
	float _LineScale;
	float _LightSaberFactor;
	float _CAMERA_FOV = 60.0f;
	
	struct a2v
	{
		float4 vertex : POSITION;
		float3 normal : NORMAL;
		float3 tangent : TANGENT;
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
		
		float4 prev = float4(v.normal.xyz, 1.0);
		float4 prevMVP = mul(UNITY_MATRIX_MVP, prev);
		
		float4 next = float4(v.tangent.xyz, 1.0);
		float4 nextMVP = mul(UNITY_MATRIX_MVP, next);
		
		float scaledLineWidth = _LineWidth * _LineScale;
#if FOV_SCALING_ON
		scaledLineWidth *= (60.0 / _CAMERA_FOV); // 60 = 180 / scaling factor
#endif
		
		float2 lineDirProjPrev = scaledLineWidth * normalize((vMVP.xy/vMVP.w) - (prevMVP.xy/prevMVP.w));
		//		if (sign(prevMVP.w) != sign(vMVP.w))
		//			lineDirProjPrev = -lineDirProjPrev;
		
		float2 lineDirProjNext = scaledLineWidth * normalize((vMVP.xy/vMVP.w) - (nextMVP.xy/nextMVP.w));
		//		if (sign(nextMVP.w) != sign(vMVP.w))
		//			lineDirProjNext = -lineDirProjNext;
		
		if (distance(prev, next) < 1.0)
		{
			vMVP.x = vMVP.x + lineDirProjPrev.x * v.texcoord1.x;
			vMVP.y = vMVP.y + lineDirProjPrev.y * v.texcoord1.x;
			vMVP.x = vMVP.x + lineDirProjPrev.y * v.texcoord1.y;
			vMVP.y = vMVP.y - lineDirProjPrev.x * v.texcoord1.y;
		}
		else
		{
			vMVP.x = vMVP.x + ((lineDirProjPrev.x * v.texcoord1.x - lineDirProjNext.x * v.texcoord1.x) * .5);
			vMVP.y = vMVP.y + ((lineDirProjPrev.y * v.texcoord1.x - lineDirProjNext.y * v.texcoord1.x) * .5);
			vMVP.x = vMVP.x + ((lineDirProjPrev.y * v.texcoord1.y - lineDirProjNext.y * v.texcoord1.y) * .5);
			vMVP.y = vMVP.y - ((lineDirProjPrev.x * v.texcoord1.y - lineDirProjNext.x * v.texcoord1.y) * .5);
		}
		
		o.pos = vMVP;
		return o;
	}
	
	float4 frag(v2f i) : COLOR
	{
		float4 tx = tex2D (_MainTex, i.uv);
		
		if (tx.a > _LightSaberFactor)
		{
			return float4(1.0, 1.0, 1.0, tx.a);
		}
		else
		{
			return tx * _Color;
		}
	}
	
#endif
