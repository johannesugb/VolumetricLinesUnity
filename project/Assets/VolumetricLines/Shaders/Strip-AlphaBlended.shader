/// Render a volumetric line strip using an alpha blended shader
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
Shader "VolumetricLine/Strip-AlphaBlended" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_Color ("Main Color", Color) = (1,1,1,1)
		_LineWidth ("Line Width", Range(0.01, 100)) = 1.0
		_LineScale ("Line Scale", Float) = 1.0
		_LightSaberFactor ("LightSaberFactor", Range(0.0, 1.0)) = 0.9
	}
	SubShader {
		Tags { "RenderType"="Geometry" "Queue" = "Transparent" }
		LOD 200
		
		Pass {
			
			Cull Off
			ZWrite Off
			ZTest LEqual
			Blend SrcAlpha OneMinusSrcAlpha
			Lighting On
			
			CGPROGRAM
				#pragma glsl_no_auto_normalization
				#pragma vertex vert
				#pragma fragment frag
				#pragma multi_compile FOV_SCALING_OFF FOV_SCALING_ON
				
				#include "_StripShader.cginc"
			ENDCG
		}
	}
	FallBack "Diffuse"
}