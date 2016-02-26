using UnityEngine;
using System.Collections;

namespace VolumetricLines
{
    /// <summary>
	/// Sets the global shader variable _CAMERA_FOV to this Camera's FOV value
	/// 
	/// Based on the Volumetric lines algorithm by Sébastien Hillaire
	/// http://sebastien.hillaire.free.fr/index.php?option=com_content&view=article&id=57&Itemid=74
	/// 
	/// Thread in the Unity3D Forum:
	/// http://forum.unity3d.com/threads/181618-Volumetric-lines
	/// 
	/// Unity3D port by Johannes Unterguggenberger
	/// johannes.unterguggenberger@gmail.com
	/// </summary>
    [RequireComponent(typeof(Camera))]
    public class SetFovGlobalShaderVariable : MonoBehaviour
    {
        private Camera m_camera;

        void Awake()
        {
            m_camera = GetComponent<Camera>();
            Shader.EnableKeyword("FOV_SCALING_ON");
        }

        void OnPreCull()
        {
            Shader.SetGlobalFloat("_CAMERA_FOV", m_camera.fieldOfView);
        }
    }
}
