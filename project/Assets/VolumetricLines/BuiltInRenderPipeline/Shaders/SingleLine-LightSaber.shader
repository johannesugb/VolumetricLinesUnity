/// Render a single volumetric line using an additive shader which does not support changing the color
/// 
/// Based on the Volumetric lines algorithm by Sebastien Hillaire
/// http://sebastien.hillaire.free.fr/index.php?option=com_content&view=article&id=57&Itemid=74
/// 
/// Thread in the Unity3D Forum:
/// http://forum.unity3d.com/threads/181618-Volumetric-lines
/// 
/// Unity3D port by Johannes Unterguggenberger
/// johannes.unterguggenberger@gmail.com
/// 
/// Thanks to Michael Probst for support during development.
/// 
/// Thanks for bugfixes and improvements to Unity Forum User "Mistale"
/// http://forum.unity3d.com/members/102350-Mistale
/// 
/// Shader code optimization and cleanup by Lex Darlog (aka DRL)
/// http://forum.unity3d.com/members/lex-drl.67487/
/// 
Shader "VolumetricLine/SingleLine-LightSaber" {
	Properties {
		[NoScaleOffset] _MainTex ("Base (RGB)", 2D) = "white" {}
		_LineWidth ("Line Width", Range(0.01, 100)) = 1.0
		_LineScale ("Line Scale", Float) = 1.0
		_LightSaberFactor ("LightSaberFactor", Range(0.0, 1.0)) = 0.9
		_Color ("Main Color", Color) = (1,1,1,1)
	}
	SubShader {
		// batching is forcefully disabled here because the shader simply won't work with it:
		Tags {
			"DisableBatching"="True"
			"RenderType"="Transparent"
			"Queue"="Transparent"
			"IgnoreProjector"="True"
			"ForceNoShadowCasting"="True"
			"PreviewType"="Plane"
		}
		LOD 200
		
		Pass {
			
			Cull Off
			ZWrite Off
			ZTest LEqual
			Blend One One
			Lighting Off
			
			CGPROGRAM
				#pragma glsl_no_auto_normalization
				#pragma vertex vert
				#pragma fragment frag
				
				// tell the cginc file that this is a simplified version of the shader:
				#define LIGHT_SABER_MODE_ON

				#include "_SingleLineShader.cginc"
			ENDCG
		}
	}
	FallBack "Diffuse"
}