using System;

namespace VolumetricLines.Utils
{
	// All credits go to Mift and Venryx
	// http://wiki.unity3d.com/index.php/ExposePropertiesInInspector_SetOnlyWhenChanged
	//
	[AttributeUsage(AttributeTargets.Property)] 
	public class ExposePropertyAttribute : Attribute {}
}                         