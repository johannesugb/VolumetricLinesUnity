using UnityEngine;
using System.Collections;

namespace VolumetricLines.Utils
{
	public static class TransformExtensionMethods 
	{
		public static float GetGlobalUniformScaleForLineWidth(this Transform trans)
		{
			// TODO: Not sure, if this is a good idea
			// Should be used with uniform scaling only anyways.
			return (trans.lossyScale.x + trans.lossyScale.y + trans.lossyScale.z) / 3f;
		}
	}
}
