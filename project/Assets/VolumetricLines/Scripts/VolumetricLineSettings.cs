using System.Collections;
using System.Collections.Generic;
using UnityEngine;

/// <summary>
/// Global settings for Volumetric Lines rendering
/// </summary>
public class VolumetricLineSettings : MonoBehaviour
{
	/// <summary>
	/// If set to true, volumetric lines rendering will not apply scaling based on the
	/// camera's field of view.
	/// By default (which means, this property is set to false), scaling is enabled,
	/// which means, that for varying field of view values, volumetric lines will have 
	/// a constant line width.
	/// </summary>
	[SerializeField]
	private bool m_disableFieldOfViewScaling;


	// Use this for initialization
	void Awake ()
	{
		if (m_disableFieldOfViewScaling)
		{
			Shader.EnableKeyword("FOV_SCALING_OFF");
		}	
		else
		{
			Shader.DisableKeyword("FOV_SCALING_OFF");
		}
	}
	
}
